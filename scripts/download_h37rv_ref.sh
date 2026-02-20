#!/usr/bin/env bash
set -euo pipefail

OUTDIR="${1:-data/ref}"
mkdir -p "$OUTDIR"
cd "$OUTDIR"

# Stable NCBI nucleotide record for H37Rv complete genome
wget -O H37Rv.fa "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NC_000962.3&rettype=fasta&retmode=text"

echo "Downloaded: $OUTDIR/H37Rv.fa"
head -n 2 H37Rv.fa
EOF

chmod +x scripts/download_h37rv_ref.sh