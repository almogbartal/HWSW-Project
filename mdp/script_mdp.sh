#!/bin/bash
# script_mdp.sh

set -e

# --- VM Permissions Fix ---
echo 0 > /proc/sys/kernel/kptr_restrict 2>/dev/null || true
echo -1 > /proc/sys/kernel/perf_event_paranoid 2>/dev/null || true

# --- Environment setup & dependency installation ---
if [ ! -d "FlameGraph" ]; then
    git clone https://github.com/brendangregg/FlameGraph FlameGraph
fi

# --- 1. Baseline Execution (Direct Python run for fast profiling) ---
# Running mdp directly with pyperf options or fast calibration
perf record -F 999 -e cpu-clock -g -o "perf_baseline.data" python3 mdp_benchmark.py --values 1 -w 0

# --- 2. Baseline Reports & FlameGraph ---
perf stat -o perf_report_mdp.txt python3 mdp_benchmark.py --values 3 -w 1
perf report -i "perf_baseline.data" --stdio >> perf_report_mdp.txt

perf script -i "perf_baseline.data" \
    | FlameGraph/stackcollapse-perf.pl \
    | FlameGraph/flamegraph.pl --title "MDP - Baseline" \
    > mdp_flamegraph.html

# --- 3. Optimized Execution ---
#if [ -f "mdp_benchmark_optimized.py" ]; then
 #   perf record -F 999 -e cpu-clock -g -o "perf_optimized.data" python3 mdp_benchmark_optimized.py --values 1 -w 0
  #  perf stat -o perf_report_mdp_optimized.txt python3 mdp_benchmark_optimized.py --values 3 -w 1
   # perf report -i "perf_optimized.data" --stdio >> perf_report_mdp_optimized.txt

    #perf script -i "perf_optimized.data" \
     #   | FlameGraph/stackcollapse-perf.pl \
      #  | FlameGraph/flamegraph.pl --title "MDP - Optimized" \
       # > mdp_optimized_flamegraph.html
fi
