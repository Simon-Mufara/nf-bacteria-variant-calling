nextflow.enable.dsl=2

params.samplesheet = params.samplesheet ?: "data/samplesheet.csv"
params.ref         = params.ref         ?: "data/ref/H37Rv.fa"
params.outdir      = params.outdir      ?: "results"
params.skip_trim   = params.skip_trim   ?: false
params.skip_qc     = params.skip_qc     ?: false

// ----------------------
// Read samplesheet CSV: sample_id,fastq_1,fastq_2
// ----------------------
Channel
  .fromPath(params.samplesheet)
  .ifEmpty { error "Samplesheet not found: ${params.samplesheet}" }
  .splitCsv(header:true)
  .map { row ->
      def s  = row.sample_id
      def r1 = file(row.fastq_1)
      def r2 = file(row.fastq_2)
      if( !r1.exists() ) error "Missing FASTQ_1 for ${s}: ${row.fastq_1}"
      if( !r2.exists() ) error "Missing FASTQ_2 for ${s}: ${row.fastq_2}"
      tuple(s, r1, r2)
  }
  .set { CH_READS }

CH_REF = Channel.value(file(params.ref))
if( !file(params.ref).exists() ) error "Reference not found: ${params.ref}"

// ----------------------
// Processes
// ----------------------
process FASTP {
  tag "$sample"
  cpus 4
  memory '4 GB'
  time '1h'
  publishDir "${params.outdir}/trimmed", mode: 'copy'

  container 'quay.io/biocontainers/fastp:0.23.4--h125f33a_5'

  input:
  tuple val(sample), path(r1), path(r2)

  output:
  tuple val(sample), path("${sample}_R1.trim.fastq.gz"), path("${sample}_R2.trim.fastq.gz"), emit: reads
  path "${sample}.fastp.html", emit: html
  path "${sample}.fastp.json", emit: json
  
  script:
  """
  fastp \
    -i $r1 -I $r2 \
    -o ${sample}_R1.trim.fastq.gz \
    -O ${sample}_R2.trim.fastq.gz \
    --thread ${task.cpus} \
    --html ${sample}.fastp.html \
    --json ${sample}.fastp.json
  """
}

process FASTQC {
  tag "$sample"
  cpus 1
  memory '2 GB'
  time '30m'
  publishDir "${params.outdir}/fastqc", mode: 'copy'

  container 'quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0'

  input:
  tuple val(sample), path(r1), path(r2)

  output:
  path "*_fastqc.html"
  path "*_fastqc.zip"

  script:
  """
  fastqc -t ${task.cpus} $r1 $r2
  """
}

process MULTIQC {
  cpus 1
  memory '2 GB'
  time '30m'
  publishDir "${params.outdir}/multiqc", mode: 'copy'

  container 'quay.io/biocontainers/multiqc:1.21--pyhdfd78af_0'

  input:
  path results_dir

  output:
  path "multiqc_report.html"
  path "multiqc_data"

  script:
  """
  multiqc $results_dir -f -o .
  """
}

process BWA_INDEX {
  cpus 2
  memory '4 GB'
  time '1h'

  container 'quay.io/biocontainers/bwa:0.7.17--hed695b0_7'

  input:
  path ref

  output:
  tuple path(ref), path("${ref}.*"), emit: idx

  script:
  """
  bwa index $ref
  """
}

process BWA_MEM {
  tag "$sample"
  cpus 8
  memory '16 GB'
  time '6h'
  publishDir "${params.outdir}/bam", mode: 'copy'

  container 'quay.io/biocontainers/bwa:0.7.17--hed695b0_7'

    input:
  tuple val(sample), path(r1), path(r2)
  tuple path(ref), path(ref_idx)
  output:
  tuple val(sample), path("${sample}.sam")

  script:
  """
  bwa mem -t ${task.cpus} $ref $r1 $r2 > ${sample}.sam
  """
}

process SORT_INDEX {
  tag "$sample"
  cpus 4
  memory '16 GB'
  time '3h'
  publishDir "${params.outdir}/bam", mode: 'copy'

  container 'quay.io/biocontainers/samtools:1.20--h50ea8bc_0'

  input:
  tuple val(sample), path(sam)

  output:
  tuple val(sample), path("${sample}.sorted.bam"), path("${sample}.sorted.bam.bai")

  script:
  """
  samtools sort -@ ${task.cpus} -o ${sample}.sorted.bam $sam
  samtools index ${sample}.sorted.bam
  """
}

process BCFTOOLS_CALL {
  tag "$sample"
  cpus 4
  memory '16 GB'
  time '4h'
  publishDir "${params.outdir}/vcf", mode: 'copy'

  container 'quay.io/biocontainers/bcftools:1.20--h8b25389_0'

  input:
  tuple val(sample), path(bam), path(bai)
  path ref

  output:
  tuple val(sample), path("${sample}.vcf.gz"), path("${sample}.vcf.gz.tbi")

  script:
  """
  bcftools mpileup -f $ref $bam \
    | bcftools call -mv -Oz -o ${sample}.vcf.gz
  tabix -p vcf ${sample}.vcf.gz
  """
}

process BCFTOOLS_FILTER_STATS {
  tag "$sample"
  cpus 2
  memory '8 GB'
  time '1h'
  publishDir "${params.outdir}/vcf_filtered", mode: 'copy'

  container 'quay.io/biocontainers/bcftools:1.20--h8b25389_0'

  input:
  tuple val(sample), path(vcfgz), path(tbi)

  output:
  path "${sample}.filtered.vcf.gz"
  path "${sample}.filtered.vcf.gz.tbi"
  path "${sample}.vcfstats.txt"

  script:
  """
  bcftools filter -i 'QUAL>=20 && DP>=10' $vcfgz -Oz -o ${sample}.filtered.vcf.gz
  tabix -p vcf ${sample}.filtered.vcf.gz
  bcftools stats ${sample}.filtered.vcf.gz > ${sample}.vcfstats.txt
  """
}

// ----------------------
// Workflow
// ----------------------
workflow {

  // Optional trimming
  reads_for_downstream = params.skip_trim ? CH_READS : FASTP(CH_READS).reads

  // Optional QC
  if( !params.skip_qc ) {
    FASTQC(reads_for_downstream)
  }

  // Index reference once, then pass indexed reference into alignment
  ref_indexed = BWA_INDEX(CH_REF).idx

  // Align -> sort/index -> call -> filter/stats
  sam_ch = BWA_MEM(reads_for_downstream, ref_indexed)
  bam_ch = SORT_INDEX(sam_ch)
  vcf_ch = BCFTOOLS_CALL(bam_ch, CH_REF)          // bcftools only needs the FASTA (not BWA indexes)
  BCFTOOLS_FILTER_STATS(vcf_ch)

  // MultiQC at end (scan results directory)
  if( !params.skip_qc ) {
  MULTIQC(Channel.value(file(params.outdir)))
}
}