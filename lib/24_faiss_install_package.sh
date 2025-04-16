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

# Determine which build directory to use based on build type
case "$BUILD_TYPE" in
    "cpu")
        BUILD_DIR="$CPU_BUILD_DIR"
        ;;
    "cpu_mkl")
        BUILD_DIR="$CPU_MKL_BUILD_DIR"
        ;;
    "gpu")
        BUILD_DIR="$GPU_BUILD_DIR"
        ;;
    "gpu_mkl")
        BUILD_DIR="$GPU_MKL_BUILD_DIR"
        ;;
esac

# Check for the wheel file
PYTHON_WHEEL_DIR="$PROJECT_ROOT/faiss/$BUILD_DIR/faiss/python/dist"
if [ ! -d "$PYTHON_WHEEL_DIR" ] || [ -z "$(ls -A "$PYTHON_WHEEL_DIR"/*.whl 2>/dev/null)" ]; then
    echo "Error: Python wheel not found. Please run 23_faiss_python_package.sh first."
    exit 1
fi

# Activate the virtual environment
activate_venv "$VENV_DIR"

# Install the wheel
pip install --force-reinstall --no-dependencies "$PYTHON_WHEEL_DIR"/*.whl

# Verify installation
python -c "import faiss; print(f'FAISS version: {faiss.__version__}')"

echo "FAISS package installed successfully in $VENV_DIR"