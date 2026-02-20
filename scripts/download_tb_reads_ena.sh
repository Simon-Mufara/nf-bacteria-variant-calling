#!/usr/bin/env bash
set -euo pipefail

OUTDIR="${1:-data/reads}"
mkdir -p "$OUTDIR"
cd "$OUTDIR"

# Real paired-end TB dataset (ENA mirror)
wget -c ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR251/004/ERR2510654/ERR2510654_1.fastq.gz
wget -c ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR251/004/ERR2510654/ERR2510654_2.fastq.gz

echo "Done. Files:"
ls -lh ERR2510654_*.fastq.gz
EOF

chmod +x scripts/download_tb_reads_ena.sh