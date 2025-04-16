# Building a Python Package of FAISS

This repo is for building a Python wheel from FAISS (Facebook AI Similarity Search).

It uses the Intel MKL LAPACK and BLAS packages.

## Project Structure

```
faiss-proj/
├── lib/                  # Library scripts and utilities
│   ├── 00_versions.sh    # Generate versions.txt file
│   ├── 01_checkout.sh    # Clone/checkout repositories
│   ├── 10_*.sh           # NumPy build scripts
│   ├── 20_*.sh           # FAISS build scripts
│   ├── common.sh         # Common functions and variables
│   └── mkl.sh            # MKL environment setup
├── tests/                # Test and benchmark scripts
├── build.sh              # Main build entry point
└── benchmark.sh          # Benchmark entry point
```

## Building FAISS

The main entry point for building FAISS is the `build.sh` script:

```bash
./build.sh <numpy_build_type> <faiss_build_type> [options]
```

### NumPy Build Types

- `numpy` - Build NumPy without MKL
- `numpy_mkl` - Build NumPy with MKL

### FAISS Build Types

- `cpu` - Build FAISS for CPU only
- `cpu_mkl` - Build FAISS for CPU with MKL
- `gpu` - Build FAISS with GPU support
- `gpu_mkl` - Build FAISS with GPU support and MKL

### Build Options

- `--only-numpy` - Only build NumPy, skip FAISS build
- `--only-faiss` - Only build FAISS, skip NumPy build
- `--skip-numpy-build` - Skip NumPy build step
- `--skip-numpy-install` - Skip NumPy install step
- `--skip-faiss-configure` - Skip FAISS configure step
- `--skip-faiss-build` - Skip FAISS build step
- `--skip-faiss-python-build` - Skip FAISS Python package build step
- `--skip-faiss-python-install` - Skip FAISS Python package install step
- `--skip-faiss-test` - Skip FAISS test step
- `--only-faiss-configure` - Only run FAISS configure step
- `--only-faiss-build` - Only run FAISS build step
- `--only-faiss-python-build` - Only run FAISS Python package build step
- `--only-faiss-python-install` - Only run FAISS Python package install step
- `--only-faiss-test` - Only run FAISS test step

### Examples

Build FAISS with CPU and MKL:
```bash
./build.sh numpy_mkl cpu_mkl
```

Build only NumPy with MKL:
```bash
./build.sh numpy_mkl cpu_mkl --only-numpy
```

Build FAISS with GPU, skipping tests:
```bash
./build.sh numpy gpu --skip-faiss-test
```

Only run FAISS configuration step:
```bash
./build.sh numpy cpu --only-faiss-configure
```

## Running Benchmarks

To run benchmarks on a built FAISS version:

```bash
./benchmark.sh <build_type>
```

Where `<build_type>` is one of: `cpu`, `cpu_mkl`, `gpu`, or `gpu_mkl`.

## Performance Benchmarks

This project includes comprehensive performance benchmarks to compare different FAISS builds and index types. The benchmarks test search performance across various configurations:

### Build Types
- CPU (without MKL)
- CPU with MKL
- GPU
- GPU with MKL

### Index Types
- Flat (exact search)
- IVF (inverted file index)
- HNSW (hierarchical navigable small world graph)

### Benchmark Results

After running the tests for different build types, a performance comparison plot is generated in `tests/benchmark_results/performance_comparison.png`. This plot shows:

- Mean search time for each index type
- Comparison across all tested build types
- Error bars indicating performance variability

The raw benchmark data is also saved as JSON files in the `tests/benchmark_results/` directory for further analysis.

### Test Configuration

The benchmarks use the following parameters:
- Vector dimension: 128
- Database size: 10,000 vectors
- Query size: 1,000 vectors
- k-NN search: k=10
- Each test is run for multiple rounds

## Virtual Environments

The build scripts create separate virtual environments for each configuration:

- `numpy_venv`: NumPy without MKL
- `numpy_mkl_venv`: NumPy with MKL
- `faiss_cpu_venv`: FAISS CPU-only
- `faiss_cpu_mkl_venv`: FAISS CPU with MKL
- `faiss_gpu_venv`: FAISS with GPU
- `faiss_gpu_mkl_venv`: FAISS with GPU and MKL

For development purposes, you can append `_local` to the environment name by setting the `DEV_LOCAL` environment variable:

```bash
DEV_LOCAL="_local" ./build.sh numpy cpu
```