#!/bin/bash

set -eu
set -o pipefail

# Check if argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <build_type>"
    echo "Build types: numpy, numpy_mkl"
    exit 1
fi

BUILD_TYPE=$1

# Source common functions
[ -z "${COMMON_SOURCED:-""}" ] && source common.sh
ensure_script_dir
source_versions
verify_repositories

case "$BUILD_TYPE" in
    "numpy")
        # Install regular numpy
        echo "Installing numpy package"
        echo "SCRIPT DIR: $SCRIPT_DIR"
        echo "NUMPY_VENV_DIR: $NUMPY_VENV_DIR"

        "${NUMPY_VENV_DIR}/bin/pip" install --force-reinstall \
            "$SCRIPT_DIR/numpy/dist_numpy/"numpy-*.whl
        ;;
    "numpy_mkl")
        # Source MKL and install MKL numpy
        [ -z "${MKL_SOURCED:-""}" ] && source mkl.sh
        echo "Installing MKL numpy package"
        echo "SCRIPT DIR: $SCRIPT_DIR"
        echo "NUMPY_MKL_VENV_DIR: $NUMPY_MKL_VENV_DIR"

        "${NUMPY_MKL_VENV_DIR}/bin/pip" install --force-reinstall \
            "$SCRIPT_DIR/numpy/dist_numpy_mkl/"numpy-*.whl
        ;;
    *)
        echo "Error: Invalid build type '$BUILD_TYPE'"
        echo "Valid build types: numpy, numpy_mkl"
        exit 1
        ;;
esac

# FAISS_VENV_DIR=/build/faiss_venv

# "${FAISS_VENV_DIR}/bin/pip" install --force-reinstall \
#     /build/numpy/dist/numpy-2.2.4-cp313-cp313-linux_x86_64.whl
