#!/bin/bash
# script_NBody.sh

set -e

# --- VM Permissions Fix ---
echo 0 > /proc/sys/kernel/kptr_restrict
echo -1 > /proc/sys/kernel/perf_event_paranoid

# --- Environment setup & dependency installation ---
rm -rf FlameGraph
git clone https://github.com/brendangregg/FlameGraph FlameGraph > /dev/null 2>&1

# --- Benchmark execution (Baseline) ---
perf record -F 999 -e cpu-clock -g -o "perf_baseline.data" python3 -m pyperformance run --bench nbody > perf_report_NBody.txt 2>/dev/null

perf report -i "perf_baseline.data" --stdio >> perf_report_NBody.txt 2>/dev/null

perf script -i "perf_baseline.data" \
    | FlameGraph/stackcollapse-perf.pl \
    | FlameGraph/flamegraph.pl --title "NBody - Baseline" \
    > Nbody_flamegraph.html 2>/dev/null

# --- Post-optimization benchmark execution ---
perf record -F 999 -e cpu-clock -g -o "perf_optimized.data" python3 Nbody_benchmark_optimized.py > perf_report_NBody_optimized.txt 2>/dev/null

perf report -i "perf_optimized.data" --stdio >> perf_report_NBody_optimized.txt 2>/dev/null

perf script -i "perf_optimized.data" \
    | FlameGraph/stackcollapse-perf.pl \
    | FlameGraph/flamegraph.pl --title "NBody - Optimized" \
    > Nbody_optimized_flamegraph.html 2>/dev/null
