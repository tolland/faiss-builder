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
FAISS_VENV_DIR=$(get_faiss_venv_dir "$BUILD_TYPE")

# Determine which build directory to use based on build type
case "$BUILD_TYPE" in
    "cpu")
        BUILD_DIR="$CPU_BUILD_DIR"
        _NUMPY_DIST_DIR=$(get_numpy_dist_dir "numpy")
        ;;
    "cpu_mkl")
        BUILD_DIR="$CPU_MKL_BUILD_DIR"
        _NUMPY_DIST_DIR=$(get_numpy_dist_dir "numpy_mkl")
        ;;
    "gpu")
        BUILD_DIR="$GPU_BUILD_DIR"
        _NUMPY_DIST_DIR=$(get_numpy_dist_dir "numpy")
        ;;
    "gpu_mkl")
        BUILD_DIR="$GPU_MKL_BUILD_DIR"
        _NUMPY_DIST_DIR=$(get_numpy_dist_dir "numpy_mkl")
        ;;
esac

# Install the correct numpy for this build type
if [ ! -d "$_NUMPY_DIST_DIR" ] || [ -z "$(ls -A "${_NUMPY_DIST_DIR}/"*.whl 2>/dev/null)" ]; then
    echo "Error: Python wheel not found. Please build the numpy package first."
    exit 1
fi

_FAISS_DIST_DIR=$(get_faiss_dist_dir "$BUILD_TYPE")
# Check for the faiss wheel file
if [ ! -d "${_FAISS_DIST_DIR}" ] || [ -z "$(ls -A "${_FAISS_DIST_DIR}"/*.whl 2>/dev/null)" ]; then
    echo "Error: Python wheel not found. Please build the faiss package first."
    exit 1
fi

# Activate the virtual environment
activate_venv "$FAISS_VENV_DIR"

# Install the wheel
pip install --force-reinstall --no-dependencies "${_FAISS_DIST_DIR}"/*.whl

# Verify installation
python -c "import faiss; print(f'FAISS version: {faiss.__version__}')"

echo "FAISS package installed successfully in $FAISS_VENV_DIR"
pip freeze | grep -E '^numpy|^faiss' || echo "no numpy or faiss packages found"