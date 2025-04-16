#!/bin/bash

set -eu
set -o pipefail

# Check if argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <build_type>"
    echo "Build types: cpu, cpu_mkl, gpu, gpu_mkl"
    exit 1
fi

BUILD_TYPE=$1

# Source common functions
[ -z "${COMMON_SOURCED:-""}" ] && source common.sh
ensure_script_dir
source_versions
verify_repositories

# Determine which venv directory to use
case "$BUILD_TYPE" in
    "cpu")
        VENV_DIR="$FAISS_CPU_VENV_DIR"
        BUILD_DIR="_build_cpu"
        ;;
    "cpu_mkl")
        VENV_DIR="$FAISS_CPU_MKL_VENV_DIR"
        BUILD_DIR="_build_cpu_mkl"
        [ -z "${MKL_SOURCED:-""}" ] && source mkl.sh
        ;;
    "gpu")
        VENV_DIR="$FAISS_GPU_VENV_DIR"
        BUILD_DIR="_build_gpu"
        ;;
    "gpu_mkl")
        VENV_DIR="$FAISS_GPU_MKL_VENV_DIR"
        BUILD_DIR="_build_gpu_mkl"
        [ -z "${MKL_SOURCED:-""}" ] && source mkl.sh
        ;;
    *)
        echo "Error: Invalid build type '$BUILD_TYPE'"
        echo "Valid build types: cpu, cpu_mkl, gpu, gpu_mkl"
        exit 1
        ;;
esac

source "${VENV_DIR}/bin/activate"

cd "$SCRIPT_DIR/faiss/${BUILD_DIR}/faiss/python"

# Uninstall only FAISS if it exists
pip uninstall -y faiss || true

# Install the new FAISS wheel
pip install dist/faiss-*.whl
