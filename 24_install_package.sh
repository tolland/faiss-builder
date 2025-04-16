#!/bin/bash

set -eu
set -o pipefail

# Source common functions
[ -z "${COMMON_SOURCED:-""}" ] && source common.sh
ensure_script_dir
source_versions
verify_repositories

source "${FAISS_VENV_DIR}/bin/activate"

cd "$SCRIPT_DIR/faiss/_build/faiss/python"

# Uninstall only FAISS if it exists
pip uninstall -y faiss || true

# Install the new FAISS wheel
pip install dist/faiss-*.whl
