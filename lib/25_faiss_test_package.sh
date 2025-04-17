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

# Determine if we should test GPU functionality
if [[ "${_FAISS_BUILD_TYPE}" == *"gpu"* ]]; then
    TEST_GPU=true
else
    TEST_GPU=false
fi

# Check if a virtual environment is already active
check_venv_active

# Activate the virtual environment
activate_venv "${_FAISS_VENV_DIR}"

# Install test dependencies
pip install -q pytest

# Run basic FAISS tests
cd "$PROJECT_ROOT/tests"

# Run the CPU test
echo "Running basic FAISS CPU test..."
python test_basic.py

#echo "Running various index tests..."
#python test_index_types.py

# Run the GPU test if applicable
if [ "$TEST_GPU" = true ]; then
    echo "Running FAISS GPU test..."
    python test_gpu.py
fi

cd "${FAISS_SRC}"

# echo "Running pytest tests..."
# pytest -v --ignore=tests/external_module_test.py tests/

echo "FAISS package tests completed successfully!"