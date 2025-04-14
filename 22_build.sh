#!/bin/bash

set -eu
set -o pipefail

set +u
source /opt/intel/oneapi/mkl/2025.1/env/vars.sh
source /opt/intel/oneapi/compiler/2025.1/env/vars.sh
set -u

(

NUMPY_VENV_DIR=/build/numpy_venv
source "${NUMPY_VENV_DIR}/bin/activate"

cd /build/faiss

NUM_PROCS="$(( $(nproc) / 2 ))"

make -C _build \
        -j${NUM_PROCS} faiss faiss_avx2

)