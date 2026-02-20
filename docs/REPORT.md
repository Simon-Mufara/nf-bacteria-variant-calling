# Run Report (Example)

This document summarizes a representative run of the pipeline on a real public dataset.

## Dataset
- Organism: *Mycobacterium tuberculosis*
- Reads: ERR2510654 (paired-end Illumina)
- Reference: H37Rv (NC_000962.3)

## Outputs produced
- QC:
  - FastQC reports per sample
  - MultiQC aggregated report
- Alignment:
  - Sorted + indexed BAM
- Variants:
  - Raw VCF (`.vcf.gz`)
  - Filtered VCF (`.filtered.vcf.gz`)
  - Variant statistics (`.vcfstats.txt`)

## How to reproduce
See the Quickstart section in the main README.

## Notes
- Filtering criteria used in this pipeline (default):
  - QUAL ≥ 20
  - DP ≥ 10

You can adjust these in `process BCFTOOLS_FILTER_STATS` in `main.nf`.
