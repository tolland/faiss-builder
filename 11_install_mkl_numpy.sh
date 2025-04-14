#!/bin/bash

set -eu
set -o pipefail

# set +u
# source /opt/intel/oneapi/mkl/2025.1/env/vars.sh
# source /opt/intel/oneapi/compiler/2025.1/env/vars.sh
# set -u

NUMPY_VENV_DIR=/build/numpy_venv

echo "install mkl numpy"

"${NUMPY_VENV_DIR}/bin/pip" install --force-reinstall \
    /build/numpy/dist/numpy-2.2.4-cp313-cp313-linux_x86_64.whl



FAISS_VENV_DIR=/build/faiss_venv

"${FAISS_VENV_DIR}/bin/pip" install --force-reinstall \
    /build/numpy/dist/numpy-2.2.4-cp313-cp313-linux_x86_64.whl
