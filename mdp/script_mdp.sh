#!/bin/bash
# script_mdp.sh

set -e

# --- VM Permissions Fix ---
echo 0 > /proc/sys/kernel/kptr_restrict 2>/dev/null || true
echo -1 > /proc/sys/kernel/perf_event_paranoid 2>/dev/null || true

# --- Environment setup ---
if [ ! -d "FlameGraph" ]; then
    git clone https://github.com/brendangregg/FlameGraph FlameGraph
fi

# --- 1. Baseline Execution (Explicitly 1 loop, 1 run, 0 warmups) ---
echo "Running Baseline Perf Record..."
perf record -F 999 -e cpu-clock -g -o "perf_baseline.data" python3 mdp_benchmark.py --loops 1 -w 0 -n 1

echo "Running Baseline Perf Stat..."
perf stat -o perf_report_mdp.txt python3 mdp_benchmark.py --loops 1 -w 0 -n 1
perf report -i "perf_baseline.data" --stdio >> perf_report_mdp.txt

echo "Generating Baseline FlameGraph..."
perf script -i "perf_baseline.data" \
    | FlameGraph/stackcollapse-perf.pl \
    | FlameGraph/flamegraph.pl --title "MDP - Baseline" \
    > mdp_flamegraph.html

echo "Baseline Done!"

# --- 2. Optimized Execution ---
#if [ -f "mdp_benchmark_optimized.py" ]; then
 #   echo "Running Optimized Perf..."
  #  perf record -F 999 -e cpu-clock -g -o "perf_optimized.data" python3 mdp_benchmark_optimized.py --loops 1 -w 0 -n 1
   # perf stat -o perf_report_mdp_optimized.txt python3 mdp_benchmark_optimized.py --loops 1 -w 0 -n 1
    #perf report -i "perf_optimized.data" --stdio >> perf_report_mdp_optimized.txt

    #perf script -i "perf_optimized.data" \
     #   | FlameGraph/stackcollapse-perf.pl \
      #  | FlameGraph/flamegraph.pl --title "MDP - Optimized" \
       # > mdp_optimized_flamegraph.html
    #echo "Optimized Done!"
fi
