#!/bin/bash
set -eu
set -o pipefail

# Check if argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <venv_type>"
    echo "Venv types: numpy, numpy_mkl"
    exit 1
fi

VENV_TYPE=$1

[ -z "${COMMON_SOURCED:-""}" ] && source common.sh

# Determine which venv directory to use
case "$VENV_TYPE" in
    "numpy")
        VENV_DIR="$NUMPY_VENV_DIR"
        ;;
    "numpy_mkl")
        VENV_DIR="$NUMPY_MKL_VENV_DIR"
        [ -z "${MKL_SOURCED:-""}" ] && source "$SCRIPT_DIR/mkl.sh"
        ;;
    *)
        echo "Error: Invalid venv type '$VENV_TYPE'"
        echo "Valid venv types: numpy, numpy_mkl"
        exit 1
        ;;
esac

# Create and activate numpy-specific venv
echo "Creating ${VENV_TYPE} virtual environment..."
python3 -m venv "${VENV_DIR}"
source "${VENV_DIR}/bin/activate"

# Install build dependencies
echo "Installing build dependencies..."
pip install --upgrade pip
pip install -r "$SCRIPT_DIR/numpy/requirements/build_requirements.txt"
pip install build
