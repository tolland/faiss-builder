#!/bin/bash

set -eu
set -o pipefail

set +u
source /opt/intel/oneapi/mkl/latest/env/vars.sh
source /opt/intel/oneapi/compiler/latest/env/vars.sh
set -u

# Create a temporary directory
# TEMP_DIR=$(mktemp -d)

TEMP_DIR=/tmp/faiss_test

echo $TEMP_DIR


if [ ! -d "$TEMP_DIR" ]; then
    mkdir "${TEMP_DIR}"
    python3 -m venv "$TEMP_DIR/venv"
fi

(

source "${TEMP_DIR}/venv/bin/activate"

pip uninstall -y faiss || true

pip install /tmp/faiss-proj/faiss/_build/faiss/python/dist/faiss-*.whl

# Run your tests
#python -m unittest discover -s tests

# # Clean up the temporary directory
# rm -rf $TEMP_DIR

python -c "import faiss"

)