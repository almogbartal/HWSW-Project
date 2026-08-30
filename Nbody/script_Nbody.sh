#!/bin/bash
# script_NBody.sh

set -e

# --- VM Permissions Fix ---
echo 0 > /proc/sys/kernel/kptr_restrict
echo -1 > /proc/sys/kernel/perf_event_paranoid

# --- Environment setup & dependency installation ---
rm -rf FlameGraph
git clone https://github.com/brendangregg/FlameGraph FlameGraph

# ==========================================
# 1. BASELINE EXECUTION & PROFILING
# ==========================================
echo "=== Running Baseline Benchmark ===" > perf_report_NBody.txt

# Run pyperformance directly and capture kernel execution metrics (239 ms)
python3 -m pyperformance run --bench nbody >> perf_report_NBody.txt 2>&1
echo -e "\n--- Hardware Counters (perf stat) ---" >> perf_report_NBody.txt

# Run perf stat
perf stat -o perf_report_NBody_stat_temp.txt python3 -m pyperformance run --bench nbody
cat perf_report_NBody_stat_temp.txt >> perf_report_NBody.txt
rm perf_report_NBody_stat_temp.txt

# Record stack traces for FlameGraph & Profiler
perf record -F 999 -e cpu-clock -g -o "perf_baseline.data" python3 -m pyperformance run --bench nbody

echo -e "\n--- Call Graph Profiler (perf report) ---" >> perf_report_NBody.txt
perf report -i "perf_baseline.data" --stdio >> perf_report_NBody.txt

# Generate Baseline FlameGraph
perf script -i "perf_baseline.data" \
    | FlameGraph/stackcollapse-perf.pl \
    | FlameGraph/flamegraph.pl --title "NBody - Baseline" \
    > Nbody_flamegraph.html


# ==========================================
# 2. OPTIMIZED EXECUTION & PROFILING
# ==========================================
echo "=== Running Optimized Benchmark ===" > perf_report_NBody_optimized.txt

# Capture pure pyperformance JIT kernel metrics (3.14 ms) into the TXT report
python3 -m pyperformance run --bench nbody -s Nbody_benchmark_optimized.py >> perf_report_NBody_optimized.txt 2>&1 || \
python3 Nbody_benchmark_optimized.py >> perf_report_NBody_optimized.txt 2>&1

echo -e "\n--- Hardware Counters (perf stat) ---" >> perf_report_NBody_optimized.txt

# Run perf stat
perf stat -o perf_report_NBody_opt_stat_temp.txt python3 Nbody_benchmark_optimized.py
cat perf_report_NBody_opt_stat_temp.txt >> perf_report_NBody_optimized.txt
rm perf_report_NBody_opt_stat_temp.txt

# Record stack traces for FlameGraph & Profiler
perf record -F 999 -e cpu-clock -g -o "perf_optimized.data" python3 Nbody_benchmark_optimized.py

echo -e "\n--- Call Graph Profiler (perf report) ---" >> perf_report_NBody_optimized.txt
perf report -i "perf_optimized.data" --stdio >> perf_report_NBody_optimized.txt

# Generate Optimized FlameGraph
perf script -i "perf_optimized.data" \
    | FlameGraph/stackcollapse-perf.pl \
    | FlameGraph/flamegraph.pl --title "NBody - Optimized" \
    > Nbody_optimized_flamegraph.html

echo "Done! All metrics and execution timings saved to perf_report_NBody_optimized.txt"
