#!/bin/bash

set -eu
set -o pipefail

# Source common functions
[ -z "${COMMON_SOURCED:-""}" ] && source common.sh
[ -z "${MKL_SOURCED:-""}" ] && source mkl.sh
ensure_script_dir
source_versions
verify_repositories

# Activate numpy build venv
activate_venv "$NUMPY_VENV_DIR"

# Build numpy with MKL
cd "$SCRIPT_DIR/numpy"
run_command "python -m build -Csetup-args=-Dblas=mkl -Csetup-args=-Dlapack=mkl" "Building numpy with MKL support"
run_command "pip install dist/*.whl" "Installing numpy"

