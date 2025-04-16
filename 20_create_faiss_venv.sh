#!/bin/bash
set -eu
set -o pipefail

[ -z "${COMMON_SOURCED:-""}" ] && source common.sh

# Create faiss-specific venv
echo "Creating faiss build virtual environment..."
python3 -m venv "${FAISS_VENV_DIR}"
source "${FAISS_VENV_DIR}/bin/activate"

# Install build dependencies
echo "Installing build dependencies..."
# pip install --upgrade pip
# Install setuptools and wheel
#

# Install numpy (with MKL) from numpy dist for faiss build
"${FAISS_VENV_DIR}/bin/pip" install --force-reinstall \
    "$SCRIPT_DIR/numpy/dist/numpy-2.2.4-cp313-cp313-linux_x86_64.whl"
