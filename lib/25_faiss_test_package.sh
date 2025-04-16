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

# Determine if we should test GPU functionality
if [[ "$BUILD_TYPE" == *"gpu"* ]]; then
    TEST_GPU=true
else
    TEST_GPU=false
fi

# Check if a virtual environment is already active
check_venv_active

# Activate the virtual environment
activate_venv "$VENV_DIR"

# Install test dependencies
pip install -q pytest

# Run basic FAISS tests
cd "$PROJECT_ROOT/tests"

# Run the CPU test
echo "Running basic FAISS CPU test..."
python test_basic.py

# Run the GPU test if applicable
if [ "$TEST_GPU" = true ]; then
    echo "Running FAISS GPU test..."
    python test_gpu.py
fi

echo "FAISS package tests completed successfully!"