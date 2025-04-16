#!/bin/bash

set -eu
set -o pipefail

# Source common functions
[ -z "${COMMON_SOURCED:-""}" ] && source common.sh
[ -z "${MKL_SOURCED:-""}" ] && source mkl.sh
ensure_script_dir
source_versions
verify_repositories

# Install MKL numpy
cd "$SCRIPT_DIR/numpy"
run_command "pip install --no-cache-dir numpy" "Installing numpy with MKL support"

echo "install mkl numpy"

echo "SCRIPT DIR: $SCRIPT_DIR"
echo "NUMPY_VENV_DIR: $NUMPY_VENV_DIR"

"${NUMPY_VENV_DIR}/bin/pip" install --force-reinstall \
    "$SCRIPT_DIR/numpy/dist/numpy-2.2.4-cp313-cp313-linux_x86_64.whl"



# FAISS_VENV_DIR=/build/faiss_venv

# "${FAISS_VENV_DIR}/bin/pip" install --force-reinstall \
#     /build/numpy/dist/numpy-2.2.4-cp313-cp313-linux_x86_64.whl
