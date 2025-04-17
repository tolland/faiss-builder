#!/bin/bash

set -eu
set -o pipefail

# Source common functions and variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Get the build type from argument
_NUMPY_BUILD_TYPE=$1
_FAISS_BUILD_TYPE=$2

source "$SCRIPT_DIR/common.sh"

# Ensure we're in the project root directory
ensure_project_root

# Source versions file
source_versions

# Verify repositories
verify_repositories

# Source MKL if needed
source_mkl_if_needed "${_FAISS_BUILD_TYPE}"

# Get the appropriate venv directory
_FAISS_VENV_DIR=$(get_faiss_venv_dir "${_NUMPY_BUILD_TYPE}" "${_FAISS_BUILD_TYPE}")

# Check if a virtual environment is already active
check_venv_active

# Activate faiss test venv
activate_venv "$VENV_DIR"

pip install -q --upgrade pip
# Install benchmark dependencies (except numpy which we want from our build)
pip install -q -r "$PROJECT_ROOT/tests/requirements-benchmark.txt"

# Run benchmark tests
echo "Running benchmark tests for ${_FAISS_BUILD_TYPE}..."
cd "$PROJECT_ROOT/tests"
mkdir -p benchmark_results

which pytest

# Run pytest with benchmark
pytest benchmark_faiss.py -v --benchmark-only --benchmark-json="benchmark_results/benchmark_${_NUMPY_BUILD_TYPE}_${_FAISS_BUILD_TYPE}_results.json"

# Generate performance comparison plot
echo "Generating performance comparison plot..."
python generate_plot.py