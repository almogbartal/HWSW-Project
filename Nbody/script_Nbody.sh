script_content = """#!/bin/bash
# script_NBody.sh

set -e

# --- Environment setup & dependency installation ---
# sudo apt-get update && sudo apt-get install -y python3-dbg
rm -rf FlameGraph
git clone https://github.com/brendangregg/FlameGraph FlameGraph

# --- Benchmark execution ---
perf record -F 999 -g python3-dbg -m pyperformance run --bench nbody

# --- Flame graph and performance data generation ---
perf report --stdio > perf_report_NBody.txt
perf script \
    | FlameGraph/stackcollapse-perf.pl \
    | FlameGraph/flamegraph.pl --title "NBody - Baseline" \
    > NBody_flamegraph.html

# --- Post-optimization benchmark execution ---
# perf record -F 999 -g python3-dbg nbody_optimized.py
# perf report --stdio > perf_report_NBody_optimized.txt
# perf script \
#     | FlameGraph/stackcollapse-perf.pl \
#     | FlameGraph/flamegraph.pl --title "NBody - Optimized" \
#     > NBody_optimized_flamegraph.html
"""

with open("script_NBody.sh", "w") as f:
    f.write(script_content)

print("script_NBody.sh")
