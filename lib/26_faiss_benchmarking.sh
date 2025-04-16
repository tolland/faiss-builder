#!/bin/bash

set -eu
set -o pipefail

# Source common functions and variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
source "$SCRIPT_DIR/common.sh"

# Get the build type from argument
BUILD_TYPE=$1

# Ensure we're in the project root directory
ensure_project_root

# Source versions file
source_versions

# Verify repositories
verify_repositories

# Source MKL if needed
source_mkl_if_needed "$BUILD_TYPE"

# Get the appropriate venv directory
VENV_DIR=$(get_faiss_venv_dir "$BUILD_TYPE")

# Check if a virtual environment is already active
check_venv_active

# Activate faiss test venv
activate_venv "$VENV_DIR"

pip install -q --upgrade pip
# Install benchmark dependencies (except numpy which we want from our build)
pip install -q -r "$PROJECT_ROOT/tests/requirements-benchmark.txt"

# Run benchmark tests
echo "Running benchmark tests for $BUILD_TYPE..."
cd "$PROJECT_ROOT/tests"
mkdir -p benchmark_results

which pytest

# Run pytest with benchmark
pytest benchmark_faiss.py -v --benchmark-only --benchmark-json="benchmark_results/benchmark_${BUILD_TYPE}_results.json"

# Generate performance comparison plot
echo "Generating performance comparison plot..."
python generate_plot.py