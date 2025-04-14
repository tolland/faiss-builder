#!/bin/bash

set -eu
set -o pipefail

set +u
source /opt/intel/oneapi/mkl/2025.1/env/vars.sh
source /opt/intel/oneapi/compiler/2025.1/env/vars.sh
set -u

# Create a temporary directory
# TEMP_DIR=$(mktemp -d)

(

FAISS_VENV_DIR=/build/faiss_venv
source "${FAISS_VENV_DIR}/bin/activate"

# Run your tests
#python -m unittest discover -s tests

# # Clean up the temporary directory
# rm -rf $TEMP_DIR

    # echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
    # echo "MKLROOT=$MKLROOT"
    # set +u
    # source /opt/intel/oneapi/setvars.sh
    # set -u
    # LD_DEBUG=libs

# LD_LIBRARY_PATH=/opt/intel/oneapi/mkl/2025.1/lib/:/opt/intel/oneapi/compiler/2025.1/lib:${LD_LIBRARY_PATH:-""}

    python -c "import faiss" || true
    # python -c "import faiss._swigfaiss" || true


# Run tests
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


)