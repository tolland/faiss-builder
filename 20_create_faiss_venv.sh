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

[ -z "${COMMON_SOURCED:-""}" ] && source common.sh

# Determine which venv directory to use
case "$BUILD_TYPE" in
    "cpu")
        VENV_DIR="$FAISS_CPU_VENV_DIR"
        NUMPY_WHEEL_DIR="dist_numpy"
        ;;
    "cpu_mkl")
        VENV_DIR="$FAISS_CPU_MKL_VENV_DIR"
        NUMPY_WHEEL_DIR="dist_numpy_mkl"
        [ -z "${MKL_SOURCED:-""}" ] && source mkl.sh
        ;;
    "gpu")
        VENV_DIR="$FAISS_GPU_VENV_DIR"
        NUMPY_WHEEL_DIR="dist_numpy"
        ;;
    "gpu_mkl")
        VENV_DIR="$FAISS_GPU_MKL_VENV_DIR"
        NUMPY_WHEEL_DIR="dist_numpy_mkl"
        [ -z "${MKL_SOURCED:-""}" ] && source mkl.sh
        ;;
    *)
        echo "Error: Invalid build type '$BUILD_TYPE'"
        echo "Valid build types: cpu, cpu_mkl, gpu, gpu_mkl"
        exit 1
        ;;
esac

# Create faiss-specific venv
echo "Creating faiss ${BUILD_TYPE} virtual environment..."
python3 -m venv "${VENV_DIR}"
source "${VENV_DIR}/bin/activate"

# Install numpy from the appropriate dist directory
echo "Installing numpy for faiss build..."
"${VENV_DIR}/bin/pip" install --force-reinstall \
    "$SCRIPT_DIR/numpy/${NUMPY_WHEEL_DIR}/numpy-*.whl"
