#!/bin/bash

set -eu
set -o pipefail

(

[ -z "${COMMON_SOURCED:-""}" ] && source common.sh

# Activate numpy build venv to get numpy headers
source "${NUMPY_VENV_DIR}/bin/activate"

cd "$SCRIPT_DIR/faiss"

cmake -B _build_cpu \
  -DFAISS_ENABLE_GPU=OFF \
  -DFAISS_ENABLE_PYTHON=ON \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_TESTING=OFF \
  -DFAISS_ENABLE_CUVS=OFF \
  -DCMAKE_BUILD_TYPE=Debug \
  -DFAISS_OPT_LEVEL=avx2 \
  .
)
