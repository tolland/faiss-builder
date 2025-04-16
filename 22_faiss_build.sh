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

# Activate numpy venv for building (needed for numpy headers)
activate_venv "$NUMPY_VENV_DIR"

cd "$SCRIPT_DIR/faiss"

# Build swig shared libraries for faiss
make -C "${BUILD_DIR}" \
    -j${NUM_PROCS} swigfaiss swigfaiss_avx2