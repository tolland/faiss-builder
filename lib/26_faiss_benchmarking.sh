#!/bin/bash

set -eu
set -o pipefail

# Source common functions and variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Get the build type from argument
_FAISS_BUILD_TYPE=$1

source "$SCRIPT_DIR/common.sh"

# Ensure we're in the project root directory
ensure_project_root

# Source versions file
source_versions

# Verify repositories
verify_repositories

# Source MKL if needed
source_mkl_if_needed "${_FAISS_BUILD_TYPE}"

_NUMPY_BUILD_TYPE="$(get_numpy_build_type "${_FAISS_BUILD_TYPE}")"

# Get the appropriate venv directory
_FAISS_VENV_DIR=$(get_faiss_venv_dir "${_NUMPY_BUILD_TYPE}" "${_FAISS_BUILD_TYPE}")

# Check if a virtual environment is already active
check_venv_active

# Activate faiss test venv
activate_venv "${_FAISS_VENV_DIR}"

pip install -q --upgrade pip
# Install benchmark dependencies (except numpy which we want from our build)
pip install -q -r "$PROJECT_ROOT/benchmarks/requirements-benchmark.txt"

# Run benchmark tests
echo "Running benchmark tests for ${_FAISS_BUILD_TYPE}..."

mkdir -p benchmarks/benchmark_results
mkdir -p benchmarks/charts

# Run pytest with benchmark
pytest -k "smoke or small" \
  --exitfirst \
  --capture=no \
  benchmarks/benchmark_faiss.py -v \
  --build-type="${_FAISS_BUILD_TYPE}" \
  --benchmark-only \
  --benchmark-json="benchmarks/benchmark_results/benchmark_${_FAISS_BUILD_TYPE}_results.json" \
  --benchmark-time-unit=ms \
  --benchmark-columns="min,max,mean,stddev,iqr,rounds,iterations" \
  --benchmark-min-rounds=1

# # --benchmark-columns="min,max,mean,stddev,iqr,rounds,iterations" \
#  --benchmark-histogram="benchmarks/benchmark_results/benchmark_${_FAISS_BUILD_TYPE}_histogram" \