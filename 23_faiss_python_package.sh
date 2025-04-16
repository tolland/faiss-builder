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
BUILD_DIR="_build_${BUILD_TYPE}"

# Source common functions
[ -z "${COMMON_SOURCED:-""}" ] && source common.sh
ensure_script_dir
source_versions
verify_repositories

# Activate numpy venv for packaging
activate_venv "$NUMPY_VENV_DIR"

cd "$SCRIPT_DIR/faiss"

# Package faiss
cd "$SCRIPT_DIR/faiss/${BUILD_DIR}/faiss/python"
run_command "python setup.py sdist bdist_wheel" "Creating faiss package"
