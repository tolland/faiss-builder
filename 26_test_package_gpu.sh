#!/bin/bash

set -eu
set -o pipefail

# Source common functions
source "$(dirname "$0")/common.sh"
ensure_script_dir
source_versions
verify_repositories

# Activate faiss test venv
activate_venv "$FAISS_VENV_DIR"

# Run tests

run_command "python -c 'import faiss; print(faiss.__version__)'" "Testing faiss import"


echo "Running tests..."

FAISS_TESTS=(
    "1-Flat.py"
    "2-IVFFlat.py"
    "3-IVFPQ.py"
    "4-GPU.py"
    "5-Multiple-GPUs.py"
    "7-PQFastScan.py"
    "8-PQFastScanRefine.py"
    "9-RefineComparison.py"
)

for file in "${FAISS_TESTS[@]}"; do
    echo "Running ${file}"
    python3 "faiss/tutorial/python/${file}"
done


