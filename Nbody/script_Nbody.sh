#!/bin/bash
# script_Nbody.sh

# --- VM Permissions Fix ---
echo 0 > /proc/sys/kernel/kptr_restrict
echo -1 > /proc/sys/kernel/perf_event_paranoid

# --- Environment setup & dependency installation ---
rm -rf FlameGraph
git clone https://github.com/brendangregg/FlameGraph FlameGraph > /dev/null 2>&1

# ==========================================
# 1. BASELINE EXECUTION & PROFILING
# ==========================================
echo "=== Running Baseline Benchmark ==="

# Record stack traces and show benchmark time
perf record -F 999 -e cpu-clock -g -o "perf_baseline.data" \
  python3 -m pyperformance run --quiet --bench nbody 2>&1 | grep "Mean" || true

# Generate TXT report and FlameGraph
perf report -i "perf_baseline.data" --stdio > perf_report_NBody.txt

perf script -i "perf_baseline.data" \
    | FlameGraph/stackcollapse-perf.pl \
    | FlameGraph/flamegraph.pl --title "NBody - Baseline" \
    > Nbody_flamegraph.html

cat perf_report_NBody.txt


# ==========================================
# 2. OPTIMIZED EXECUTION & PROFILING
# ==========================================
echo "=== Running Optimized Benchmark ==="

# Record stack traces and show benchmark time
perf record -F 999 -e cpu-clock -g -o "perf_optimized.data" \
  python3 Nbody_benchmark_optimized.py 2>&1 | grep "Mean" || true

# Generate TXT report and FlameGraph
perf report -i "perf_optimized.data" --stdio > perf_report_NBody_optimized.txt

perf script -i "perf_optimized.data" \
    | FlameGraph/stackcollapse-perf.pl \
    | FlameGraph/flamegraph.pl --title "NBody - Optimized" \
    > Nbody_optimized_flamegraph.html

cat perf_report_NBody_optimized.txt
