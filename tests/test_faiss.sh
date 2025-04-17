#!/bin/bash

set -eu
set -o pipefail

# Check if argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <build_type>"
    echo "Build types: cpu, cpu_mkl, gpu, gpu_mkl"
    exit 1
fi

_NUMPY_BUILD_TYPE=$1
_FAISS_BUILD_TYPE=$2

# Source common functions from parent directory
source "$(dirname "$0")/../common.sh"
ensure_script_dir
cd "$SCRIPT_DIR"
source_versions
verify_repositories

# Source MKL if needed
source_mkl_if_needed "${_FAISS_BUILD_TYPE}"

_FAISS_VENV_DIR=$(get_faiss_venv_dir "${_NUMPY_BUILD_TYPE}" "${_FAISS_BUILD_TYPE}")

# Activate faiss test venv
activate_venv "${_FAISS_VENV_DIR}"

# Install benchmark dependencies (except numpy which we want from our build)
pip install -r "$SCRIPT_DIR/tests/requirements-benchmark.txt"

# Run basic functionality tests
echo "Sanity check: Testing FAISS build type: ${_FAISS_BUILD_TYPE}"
run_command "python -c 'import faiss; print(faiss.__version__)'" "Testing faiss import"


# Run benchmark tests
echo "Running benchmark tests..."
cd "$SCRIPT_DIR/tests"
mkdir -p benchmark_results
pytest benchmark_faiss.py -v --benchmark-only --benchmark-json="benchmark_results/benchmark_${_NUMPY_BUILD_TYPE}_${_FAISS_BUILD_TYPE}_results.json"

# Generate performance comparison plot
echo "Generating performance comparison plot..."
python3 "$SCRIPT_DIR/tests/generate_plot.py" 
