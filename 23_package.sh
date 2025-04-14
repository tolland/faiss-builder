#!/bin/bash

set -eu
set -o pipefail

set +u
source /opt/intel/oneapi/mkl/2025.1/env/vars.sh
source /opt/intel/oneapi/compiler/2025.1/env/vars.sh
set -u


(

cd /build/faiss

NUMPY_VENV_DIR=/build/numpy_venv
source "${NUMPY_VENV_DIR}/bin/activate"

NUM_PROCS="$(( $(nproc) / 2 ))"

make -C /build/faiss/_build \
    -j${NUM_PROCS} swigfaiss swigfaiss_avx2

cd _build/faiss/python/

FAISS_VENV_DIR=/build/faiss_venv

"${FAISS_VENV_DIR}/bin/python" setup.py sdist bdist_wheel

)
