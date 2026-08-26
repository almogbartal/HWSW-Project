#!/bin/bash
# script_Nbody.sh
# Executes the Nbody benchmark, generates perf reports, and creates Flame Graphs.

set -e

echo "[setup] --- Installing dependencies if needed ---"
# sudo apt-get update && sudo apt-get install -y linux-tools-common linux-tools-generic git python3-dbg

# ================================
# ENVIRONMENT SETUP & FLAMEGRAPH
# ================================
echo "[setup] Cloning brendangregg/FlameGraph..."
rm -rf FlameGraph
git clone https://github.com/brendangregg/FlameGraph FlameGraph

# ================================
# BASELINE BENCHMARK EXECUTION
# ================================
echo "[Nbody] --- Running Baseline Benchmark ---"
BASE_CMD="python3-dbg -m pyperformance run --bench nbody"

echo "[Nbody] --- perf record: Baseline ---"
perf record -F 999 -g -o "perf_baseline.data" $BASE_CMD

echo "[Nbody] --- Generating Baseline Report ---"
perf report -i "perf_baseline.data" --stdio > report_Nbody.txt
echo "[Nbody]   -> report_Nbody.txt created"

echo "[Nbody] --- Generating Baseline Flame Graph ---"
perf script -i "perf_baseline.data" \
    | FlameGraph/stackcollapse-perf.pl \
    | FlameGraph/flamegraph.pl --title "Nbody - Baseline" \
    > Nbody_baseline.html
echo "[Nbody]   -> Nbody_baseline.html created"

# ================================
# POST-OPTIMIZATION BENCHMARK
# ================================
# echo "[Nbody] --- Running Optimized Benchmark ---"
# OPT_CMD="python3-dbg nbody_optimized.py"

# echo "[Nbody] --- perf record: Optimized ---"
# perf record -F 999 -g -o "perf_optimized.data" $OPT_CMD

# echo "[Nbody] --- Generating Optimized Report ---"
# perf report -i "perf_optimized.data" --stdio > report_Nbody_optimized.txt
# echo "[Nbody]   -> report_Nbody_optimized.txt created"

# echo "[Nbody] --- Generating Optimized Flame Graph ---"
# perf script -i "perf_optimized.data" \
#     | FlameGraph/stackcollapse-perf.pl \
#     | FlameGraph/flamegraph.pl --title "Nbody - Optimized" \
#     > Nbody_optimized.html
# echo "[Nbody]   -> Nbody_optimized.html created"

echo "[script] done."
