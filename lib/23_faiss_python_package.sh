#!/bin/bash

set -eu
set -o pipefail

# Source common functions and variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Get the build type from argument
BUILD_TYPE=$1

source "$SCRIPT_DIR/common.sh"

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
        BUILD_DIR="${CPU_BUILD_DIR}"
        ;;
    "cpu_mkl")
        BUILD_DIR="${CPU_MKL_BUILD_DIR}"
        ;;
    "gpu")
        BUILD_DIR="${GPU_BUILD_DIR}"
        ;;
    "gpu_mkl")
        BUILD_DIR="${GPU_MKL_BUILD_DIR}"
        ;;
esac

cd "${FAISS_SRC}"

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: Build directory $BUILD_DIR does not exist. Please run 21_faiss_configure.sh and 22_faiss_build.sh first."
    exit 1
fi

which python

# Build Python package
cd "$BUILD_DIR/faiss/python"
python setup.py bdist_wheel

echo "FAISS Python package built successfully!"