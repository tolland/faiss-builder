#!/bin/bash

set -eu
set -o pipefail

# Check if argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <build_type>"
    echo "Build types: cpu, cpu_mkl, gpu, gpu_mkl"
    exit 1
fi

BUILD_TYPE=$1

# Source common functions
source "$(dirname "$0")/common.sh"
ensure_script_dir
source_versions
verify_repositories

# Check if a virtual environment is already active
check_venv_active

# Determine which venv directory to use
case "$BUILD_TYPE" in
    "cpu")
        VENV_DIR="$FAISS_CPU_VENV_DIR"
        ;;
    "cpu_mkl")
        VENV_DIR="$FAISS_CPU_MKL_VENV_DIR"
        [ -z "${MKL_SOURCED:-""}" ] && source mkl.sh
        ;;
    "gpu")
        VENV_DIR="$FAISS_GPU_VENV_DIR"
        ;;
    "gpu_mkl")
        VENV_DIR="$FAISS_GPU_MKL_VENV_DIR"
        [ -z "${MKL_SOURCED:-""}" ] && source mkl.sh
        ;;
    *)
        echo "Error: Invalid build type '$BUILD_TYPE'"
        echo "Valid build types: cpu, cpu_mkl, gpu, gpu_mkl"
        exit 1
        ;;
esac

# Activate faiss test venv
activate_venv "$VENV_DIR"

pip install -q --upgrade pip
# Install benchmark dependencies (except numpy which we want from our build)
pip install -q -r "$SCRIPT_DIR/tests/requirements-benchmark.txt"

# Run benchmark tests
echo "Running benchmark tests for $BUILD_TYPE..."
cd "$SCRIPT_DIR/tests"
mkdir -p benchmark_results

which pytest

# Run pytest with benchmark
pytest benchmark_faiss.py -v --benchmark-only --benchmark-json="benchmark_results/benchmark_${BUILD_TYPE}_results.json"

# Generate performance comparison plot
echo "Generating performance comparison plot..."
python3 generate_plot.py
