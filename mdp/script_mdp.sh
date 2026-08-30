#!/bin/bash
# script_mdp.sh

set -e

echo 0 > /proc/sys/kernel/kptr_restrict 2>/dev/null || true
echo -1 > /proc/sys/kernel/perf_event_paranoid 2>/dev/null || true

if [ ! -d "FlameGraph" ]; then
    git clone https://github.com/brendangregg/FlameGraph FlameGraph
fi

# --- 1. Baseline Run (F 99 to prevent VM slowdown) ---
echo "Recording baseline..."
perf record -F 99 -e cpu-clock -g -o "perf_baseline.data" python3 -c "import mdp_benchmark; mdp_benchmark.bench_mdp(1)"

echo "Collecting baseline stat..."
perf stat -o perf_report_mdp.txt python3 -c "import mdp_benchmark; mdp_benchmark.bench_mdp(1)"
perf report -i "perf_baseline.data" --stdio >> perf_report_mdp.txt

echo "Building baseline FlameGraph..."
perf script -i "perf_baseline.data" \
    | FlameGraph/stackcollapse-perf.pl \
    | FlameGraph/flamegraph.pl --title "MDP - Baseline" \
    > mdp_flamegraph.html

echo "Baseline finished successfully!"
