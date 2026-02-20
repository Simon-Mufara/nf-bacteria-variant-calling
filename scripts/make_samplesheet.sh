#!/usr/bin/env bash
set -euo pipefail

OUT="${1:-data/samplesheet.csv}"

cat > "$OUT" <<'CSV'
sample_id,fastq_1,fastq_2
ERR2510654,data/reads/ERR2510654_1.fastq.gz,data/reads/ERR2510654_2.fastq.gz
CSV

echo "Wrote $OUT"
cat "$OUT"
EOF

chmod +x scripts/make_samplesheet.sh