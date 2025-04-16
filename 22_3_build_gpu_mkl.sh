#!/bin/bash

set -eu
set -o pipefail

# Source common functions
[ -z "${COMMON_SOURCED:-""}" ] && source common.sh
ensure_script_dir
source_versions
verify_repositories

# Activate numpy venv for building (needed for numpy headers)
activate_venv "$NUMPY_VENV_DIR"

cd "$SCRIPT_DIR/faiss"

# Build faiss
# run_command "make -C _build -j${NUM_PROCS}" "Building faiss"

# Build swig shared libraries for faiss
make -C _build \
    -j${NUM_PROCS} swigfaiss swigfaiss_avx2
    