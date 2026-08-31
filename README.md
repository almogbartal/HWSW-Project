# HWSW-Project
# Benchmarks Optimization: N-Body & Raytracer
This repository documents the process of optimizing two distinct Python benchmarks: **N-Body Simulation** (nbody) and a **3D Raytracer** (raytracer). The project demonstrates how to identify performance bottlenecks using Linux profiling tools, implement targeted software optimizations, and evaluate a SystemVerilog hardware accelerator to bypass Python constraints.

# Benchmarks:
## 1. N-Body Simulation (`nbody`):
This benchmark evaluates the performance of gravitational multi-body simulations. It performs iterative numerical integration to calculate vector forces, velocities, and positional shifts across planetary bodies. It focuses on floating-point math, loop iterations, and array operations.
## 2. 3D Raytracer (`raytracer`):
This benchmark assesses the performance of a 3D raytracing engine. It involves generating camera rays, calculating vector dot products, evaluating ray-sphere intersections, and shading scene objects, representing a heavily compute-bound graphics workload.

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
# Tools Used:
- **`perf`:** Linux performance counter and call-graph profiling tool.
- **`FlameGraph`:** Visualization suite for analyzing call-stack sample distributions.
- **`SystemVerilog`:** Hardware Description Language (HDL) used to model the accelerator.
- **`Python 3.8+`:** Target runtime environment.

# Results:
## N-Body Benchmark:
**Key Improvements:**
- Interpreter Overhead: Substantially decreased by applying Numba JIT compilation, shifting execution away from CPython bytecode evaluation directly into native assembly.
- Floating-Point Overhead: Completely eliminated Python's internal wrappers for floating-point arithmetic (`float_mul`, `float_sub`, `float_add`) via JIT compilation, passing math operations directly to hardware FPU registers.
- Object Allocation: Fully eliminated heap memory management overhead by avoiding temporary Python float object creation during intermediate math steps.
## Raytracer Benchmark:
**Key Improvements:**
- Optimized ray-sphere intersection logic and discriminant evaluation.
- Designed a SystemVerilog hardware accelerator yielding an estimated **50x–100x speedup** for the intersection kernel.
- Flattened nested loop structures to improve instruction execution density.

** *Flame graphs, hardware metrics analysis, and complete SystemVerilog RTL specifications are included in the repository for detailed inspection.*

# How to Run

## 1. Clone the Repository
```bash
git clone https://github.com/almogbartal/HWSW-Project.git
cd HWSW-Project
```

## 2. Prerequisites
Make sure you have Python 3, `perf`, and the required packages installed:
```bash
pip install pyperformance numba
```

---

## 3. Running Nbody Benchmark
To run the automated profiling and benchmark script:
```bash
cd Nbody
chmod +x script_Nbody.sh
./script_Nbody.sh
cd ..
```

---

## 4. Running Raytrace Benchmark
To run the automated profiling and benchmark script:
```bash
cd Raytrace
chmod +x script_raytrace.sh
./script_raytrace.sh
cd ..
```

---

### Viewing Profiling Results
All generated outputs, reports, and visual graphs can be inspected directly inside each benchmark's directory:
* **Perf Reports:** `perf_report_<benchmark>.txt` and `perf_report_<benchmark>_optimized.txt` for detailed hardware counters and symbol overheads.
* **Flame Graphs:** Open `*_flamegraph.html` files directly in any web browser to explore interactive CPU execution call stacks.
* **Full Documentation:** Refer to `report_<benchmark>.pdf` (or `.txt`) for the full analysis, optimization breakdown, and hardware unit architecture.
