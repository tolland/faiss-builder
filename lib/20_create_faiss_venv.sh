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

# Setup the virtual environment
setup_venv "$VENV_DIR"

# Install dependencies for building FAISS
pip install -q --upgrade pip
pip install -q numpy
pip install -q pytest
pip install -q wheel
pip install -q swig

# Install CUDA dependencies for GPU builds
if [[ "$BUILD_TYPE" == *"gpu"* ]]; then
    pip install -q cupy-cuda12x
fi

echo "FAISS build virtual environment created successfully!"