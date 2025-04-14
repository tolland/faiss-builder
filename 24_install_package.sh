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

pip install --force-reinstall /build/faiss/_build/faiss/python/dist/faiss-*.whl

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


)