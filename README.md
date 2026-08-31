# HWSW-Project
# Benchmarks Optimization: N-Body & Raytracer
This repository documents the process of optimizing two distinct Python benchmarks: **N-Body Simulation** (nbody) and a **3D Raytracer** (raytracer). The project demonstrates how to identify performance bottlenecks using Linux profiling tools, implement targeted software optimizations, and evaluate a SystemVerilog hardware accelerator to bypass Python constraints.

# Project structure:

```text
HWSW-Project/
├── Nbody/
│   ├── Nbody_benchmark.py
│   ├── Nbody_benchmark_optimized.py
│   ├── Nbody_Hardware_Acceleration.sv
│   ├── Nbody_flamegraph.html
│   ├── Nbody_optimized_flamegraph.html
│   ├── perf_report_Nbody.txt
│   ├── perf_report_Nbody_optimized.txt
│   ├── script_Nbody.sh
│   ├── report_Nbody.txt
│   └── report_Nbody.pdf
├── Raytrace/
│   ├── raytrace_benchmark.py
│   ├── raytrace_benchmark_optimized.py
│   ├── raytrace_hardware_acceleration.sv
│   ├── raytrace_flamegraph.html
│   ├── raytrace_optimized_flamegraph.html
│   ├── perf_report_raytrace.txt
│   ├── perf_report_raytrace_optimized.txt
│   ├── script_raytrace.sh
│   ├── report_raytrace.txt
│   └── report_raytrace.pdf
├── prompts.txt
└── README.md
```
