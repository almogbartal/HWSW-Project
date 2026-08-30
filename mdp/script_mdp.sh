#!/bin/bash
# script_mdp.sh

set -e

# --- VM Permissions Fix ---
echo 0 > /proc/sys/kernel/kptr_restrict
echo -1 > /proc/sys/kernel/perf_event_paranoid

# --- Environment setup & dependency installation ---
rm -rf FlameGraph
git clone https://github.com/brendangregg/FlameGraph FlameGraph

# --- Benchmark execution (using the working command) ---
perf record -F 999 -e cpu-clock -g -o "perf_baseline.data" python3 -m pyperformance run --bench mdp

# --- Flame graph and performance data generation ---
perf stat -o perf_report_mdp.txt python3 -m pyperformance run --bench mdp
perf report -i "perf_baseline.data" --stdio >> perf_report_mdp.txt

perf script -i "perf_baseline.data" \
    | FlameGraph/stackcollapse-perf.pl \
    | FlameGraph/flamegraph.pl --title "MDP - Baseline" \
    > mdp_flamegraph.html

# --- Post-optimization benchmark execution ---
#perf record -F 999 -e cpu-clock -g -o "perf_optimized.data" python3 mdp_benchmark_optimized.py
#perf stat -o perf_report_mdp_optimized.txt python3 mdp_benchmark_optimized.py
#perf report -i "perf_optimized.data" --stdio >> perf_report_mdp_optimized.txt
#perf script -i "perf_optimized.data" \
 #   | FlameGraph/stackcollapse-perf.pl \
  #  | FlameGraph/flamegraph.pl --title "MDP - Optimized" \
   # > mdp_optimized_flamegraph.html
