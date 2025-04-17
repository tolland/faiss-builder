#!/bin/bash

set -eu
set -o pipefail

# Source common functions and variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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
source_mkl_if_needed "${_NUMPY_BUILD_TYPE}"

# Get the appropriate venv directory
VENV_DIR=$(get_numpy_venv_dir "${_NUMPY_BUILD_TYPE}")

# Get the dist directory
NUMPY_DIST_DIR=$(get_numpy_dist_dir "${_NUMPY_BUILD_TYPE}")

# Activate the virtual environment
activate_venv "$VENV_DIR"

# Check if wheel files exist in dist_numpy directory first, then fallback to dist
if [ -d "${NUMPY_DIST_DIR}" ] && [ "$(ls -A ${NUMPY_DIST_DIR}/*.whl 2>/dev/null | wc -l)" -gt 0 ]; then
    WHEEL_DIR="${NUMPY_DIST_DIR}"
else
    echo "Error: No wheel files found in \"${NUMPY_DIST_DIR}\". Please run 11_numpy_build_package.sh first."
    exit 1
fi

echo "Installing NumPy wheel from $WHEEL_DIR directory"

# Install the wheel file
pip install --force-reinstall --no-dependencies $WHEEL_DIR/*.whl

# Verify installation
python -c "import numpy; print(f'NumPy version: {numpy.__version__}')"

echo "NumPy installed successfully in $VENV_DIR"
pip freeze | grep -E '^numpy|^faiss' || echo "no numpy or faiss packages found"
