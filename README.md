# nf-bacteria-variant-calling

<p align="center">
<img src="https://img.shields.io/badge/Simon%20Mufara-Bioinformatics%20Engineer-blue?style=for-the-badge">
<img src="https://img.shields.io/badge/Nextflow-DSL2-brightgreen?style=for-the-badge">
<img src="https://img.shields.io/badge/HPC-SLURM-blue?style=for-the-badge">
<img src="https://img.shields.io/badge/Containers-Singularity-orange?style=for-the-badge">
<img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge">
</p>

A reproducible **Nextflow DSL2 pipeline** for bacterial whole-genome variant calling using **SLURM + Singularity**.

## Quick Start

```bash
# Load modules
module load nextflow singularity
mkdir -p $HOME/.singularity/cache $HOME/nextflow_work

# Download data
./scripts/download_reads.sh data/reads
./scripts/download_reference.sh data/ref
./scripts/make_samplesheet.sh data/samplesheet.csv

# Run pipeline
nextflow run main.nf \
  -profile standard \
  --samplesheet data/samplesheet.csv \
  --ref data/ref/wildtype.fna \
  -with-report -with-timeline -with-trace

# Resume if interrupted
nextflow run main.nf -resume
```

## Pipeline Steps

1. **Read Trimming** — `fastp`
2. **Quality Control** — `FastQC`
3. **QC Aggregation** — `MultiQC`
4. **Alignment** — `bwa mem` + `samtools sort`
5. **Variant Calling** — `bcftools mpileup + call`
6. **Filtering** — `bcftools filter`

## Results

- **QC Reports:** `results/fastqc/`, `results/multiqc/`
- **Alignments:** `results/bam/*.sorted.bam`
- **Variants:** `results/vcf/*.vcf.gz`, `results/vcf_filtered/`
- **Reports:** `report.html`, `timeline.html`, `trace.txt`

## Variant Visualization

Example variant at position 103048 (T → A substitution):

<p align="center">
  <img src="Final_Assignment/docs/igv_variant_visualization.png" width="1000" alt="IGV Variant Visualization">
</p>

**Variant:** SNP at position 103048 | Genotype: 1/1 (homozygous) | Depth: 21 reads | Quality: 225.417

## Input Format

**Samplesheet (CSV):**
```csv
sample_id,fastq_1,fastq_2
sample1,data/reads/sample1_R1.fq.gz,data/reads/sample1_R2.fq.gz
```

**Reference:** `data/ref/wildtype.fna` (FASTA format)

## Configuration

- **Default CPU:** 4 cores
- **Default Memory:** 8 GB
- **Default Time:** 24 hours
- **Variant Filters:** QUAL ≥ 20, Depth ≥ 10

Adjust in `conf/base.config`

## Author

**Simon Mufara**
MSc Computational Health Informatics — University of Cape Town

## License

MIT License

## Citation

```bibtex
@software{Mufara2026,
  author = {Mufara, Simon},
  title = {nf-bacteria-variant-calling: Nextflow DSL2 pipeline for bacterial variant calling},
  year = {2026},
  url = {https://github.com/Simon-Mufara/nf-bacteria-variant-calling}
}
```
