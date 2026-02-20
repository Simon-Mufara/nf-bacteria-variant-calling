## MultiQC report 

Dataset

Sample: ERR2510654 (paired-end)

FastQC total reads: ~1.26 million read pairs (R1 ≈ 1.260386M, R2 ≈ 1.260386M)

fastp passed reads: ~2.52 million reads total (≈ 2.520772M)

% surviving (PF): ~99.12%

Q30 after filtering: ~95.03%

GC% after filtering: ~65.13% (this is exactly what we expect for M. tuberculosis H37Rv—high GC)

Duplication (fastp): ~1.10% (nice and low)

Adapter content (fastp): ~1.28% (small; trimming worked)

FastQC “module flags” (the PASS/WARN/FAIL heatmap)

PASS: Basic stats, per-base quality, per-sequence quality, per-sequence GC, N-content, duplication, overrepresented, adapter content.

WARN: Sequence length distribution (often expected after trimming because read lengths are no longer uniform).

FAIL: Per-base sequence content (very common in real data; can be caused by library prep / priming bias, and in bacteria you often see consistent bias that triggers the FastQC rule even when the data is usable).

Variants (bcftools stats on your filtered VCF)

Filtered variant records: 1,942

SNPs: 1,773

Indels: 169

Ts/Tv: ~1.53 (reasonable for bacterial SNP calls; not a red flag)

What this says overall

QC is strong (high PF, high Q30, low duplication).

GC content looks biologically correct for MTB.

Variant count and Ts/Tv look sane for a single isolate vs H37Rv.

The two FastQC flags (per-base content FAIL + length WARN) are not deal-breakers—they’re common patterns with real sequencing.