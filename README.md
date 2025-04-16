# building a python package of faiss

This repo is for building a python whl from faiss

It uses the Intel MKL lapack and blas packages

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

### Running Benchmarks

The benchmarks are automatically run as part of the test suite. Each build type is tested with all index types:

```bash
./25_test_package.sh cpu      # Run benchmarks for CPU build
./25_test_package.sh cpu_mkl  # Run benchmarks for CPU+MKL build
./25_test_package.sh gpu      # Run benchmarks for GPU build
./25_test_package.sh gpu_mkl  # Run benchmarks for GPU+MKL build
```

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
- Each test is run for 5 rounds

