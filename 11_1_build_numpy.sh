#!/bin/bash

set -eu
set -o pipefail

# Source common functions
[ -z "${COMMON_SOURCED:-""}" ] && source common.sh
ensure_script_dir
source_versions
verify_repositories

# Activate numpy build venv
activate_venv "$NUMPY_VENV_DIR"

# Build numpy with MKL
cd "$SCRIPT_DIR/numpy"
run_command "python -m build -Csetup-args=-Dblas=blas -Csetup-args=-Dlapack=lapack --outdir dist_numpy_no_mkl" "Building numpy without MKL support"
run_command "pip install dist_numpy_no_mkl/*.whl" "Installing numpy"
