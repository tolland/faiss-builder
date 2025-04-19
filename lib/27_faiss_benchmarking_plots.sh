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

# Generate performance comparison plot
echo "Generating performance comparison plot..."
python -m benchmarks.generate_plot
