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
python3 -c "
import faiss
import numpy as np

# Create some random vectors
d = 64
nb = 1000
nq = 10
np.random.seed(1234)
xb = np.random.random((nb, d)).astype('float32')
xq = np.random.random((nq, d)).astype('float32')

# Build index
index = faiss.IndexFlatL2(d)
index.add(xb)

# Search
k = 4
D, I = index.search(xq, k)
print('First 5 results of first query:')
print(I[0][:5])
print('Distances:')
print(D[0][:5])
"


