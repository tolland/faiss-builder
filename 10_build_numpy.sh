#!/bin/bash

set -eu
set -o pipefail

set +u
source /opt/intel/oneapi/mkl/2025.1/env/vars.sh
source /opt/intel/oneapi/compiler/2025.1/env/vars.sh
set -u

NUMPY_VENV_DIR=/build/numpy_venv

cd /build/numpy

echo "fixing version for faiss"
sed -i -E 's/version = "([0-9]+\.[0-9]+\.[0-9]+).*"/version = "\1"/' ./pyproject.toml

"${NUMPY_VENV_DIR}/bin/python" -m build -Csetup-args=-Dblas=mkl -Csetup-args=-Dlapack=mkl

