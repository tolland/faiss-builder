#!/bin/bash

set -eu
set -o pipefail

# Source common functions
[ -z "${COMMON_SOURCED:-""}" ] && source common.sh
ensure_script_dir
source_versions
verify_repositories

# Activate numpy venv for packaging
activate_venv "$NUMPY_VENV_DIR"

cd "$SCRIPT_DIR/faiss"

# Package faiss
cd "$SCRIPT_DIR/faiss/_build/faiss/python"
run_command "python setup.py sdist bdist_wheel" "Creating faiss package"
