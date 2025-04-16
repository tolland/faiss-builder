#!/bin/bash
set -eu
set -o pipefail

[ -z "${COMMON_SOURCED:-""}" ] && source common.sh

# Create and activate numpy-specific venv
echo "Creating numpy build virtual environment..."
python3 -m venv "${NUMPY_VENV_DIR}"
source "${NUMPY_VENV_DIR}/bin/activate"

# Install build dependencies
echo "Installing build dependencies..."
pip install --upgrade pip
pip install build
