#!/bin/bash
# script_raytrace.sh

set -e

# --- VM Permissions Fix ---
echo 0 > /proc/sys/kernel/kptr_restrict
echo -1 > /proc/sys/kernel/perf_event_paranoid

# --- Environment setup & dependency installation ---
rm -rf FlameGraph
git clone https://github.com/brendangregg/FlameGraph FlameGraph

# --- Benchmark execution (using the working command) ---
perf record -F 999 -e cpu-clock -g -o "perf_baseline.data" python3 -m pyperformance run --bench raytrace

# --- Flame graph and performance data generation ---
perf stat -o perf_report_raytrace.txt python3 -m pyperformance run --bench raytrace
perf report -i "perf_baseline.data" --stdio >> perf_report_raytrace.txt

perf script -i "perf_baseline.data" \
    | FlameGraph/stackcollapse-perf.pl \
    | FlameGraph/flamegraph.pl --title "Raytrace - Baseline" \
    > raytrace_flamegraph.html

# --- Post-optimization benchmark execution ---
perf record -F 999 -e cpu-clock -g -o "perf_optimized.data" python3 raytrace_benchmark_optimized.py
perf stat -o perf_report_raytrace_optimized.txt python3 raytrace_benchmark_optimized.py
perf report -i "perf_optimized.data" --stdio >> perf_report_raytrace_optimized.txt
perf script -i "perf_optimized.data" \
    | FlameGraph/stackcollapse-perf.pl \
    | FlameGraph/flamegraph.pl --title "Raytrace - Optimized" \
    > raytrace_optimized_flamegraph.html
