#!/bin/bash

set -eu
set -o pipefail

cd /build

NUMPY_VENV_DIR=/build/numpy_venv


if [ ! -d "$NUMPY_VENV_DIR" ]; then
    python3 -m venv "$NUMPY_VENV_DIR"
fi

(

"${NUMPY_VENV_DIR}/bin/pip" install -r /build/numpy/requirements/build_requirements.txt

)



FAISS_VENV_DIR=/build/faiss_venv


if [ ! -d "$FAISS_VENV_DIR" ]; then
    python3 -m venv "$FAISS_VENV_DIR"
fi

(

"${FAISS_VENV_DIR}/bin/pip" install setuptools wheel

)
