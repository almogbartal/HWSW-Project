#!/bin/bash
# script_NBody.sh

set -e

# --- VM Permissions Fix ---
echo 0 > /proc/sys/kernel/kptr_restrict
echo -1 > /proc/sys/kernel/perf_event_paranoid

# --- Environment setup & dependency installation ---
rm -rf FlameGraph
git clone https://github.com/brendangregg/FlameGraph FlameGraph

# --- Benchmark execution (using the working command) ---
perf record -F 999 -e cpu-clock -g -o "perf_baseline.data" python3 -m pyperformance run --bench nbody

# --- Flame graph and performance data generation ---
perf report -i "perf_baseline.data" --stdio > perf_report_NBody.txt

perf script -i "perf_baseline.data" \
    | FlameGraph/stackcollapse-perf.pl \
    | FlameGraph/flamegraph.pl --title "NBody - Baseline" \
    > Nbody_flamegraph.html

# --- Post-optimization benchmark execution ---
perf record -F 999 -e cpu-clock -g -o "perf_optimized.data" python3 nbody_optimized.py
perf report -i "perf_optimized.data" --stdio > perf_report_NBody_optimized.txt
perf script -i "perf_optimized.data" \
    | FlameGraph/stackcollapse-perf.pl \
    | FlameGraph/flamegraph.pl --title "NBody - Optimized" \
    > Nbody_optimized_flamegraph.html
