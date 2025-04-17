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
_FAISS_VENV_DIR=$(get_faiss_venv_dir "${_FAISS_BUILD_TYPE}")

# Check if a virtual environment is already active
check_venv_active

# Setup the virtual environment
setup_venv "${_FAISS_VENV_DIR}"

_NUMPY_DIST_DIR=$(get_numpy_dist_dir "${_NUMPY_BUILD_TYPE}")

# Install dependencies for building FAISS
pip install -q --upgrade pip
pip install -q pytest wheel packaging

# Install numpy from the appropriate dist directory
echo "Installing numpy for faiss build..."
"${_FAISS_VENV_DIR}/bin/pip" install --force-reinstall \
    "${_NUMPY_DIST_DIR}/"numpy-*.whl

echo "FAISS build virtual environment created successfully!"
pip freeze | grep -E '^numpy|^faiss' || echo "no numpy or faiss packages found"