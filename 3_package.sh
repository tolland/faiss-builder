#!/bin/bash

set -eu
set -o pipefail

set +u
source /opt/intel/oneapi/mkl/latest/env/vars.sh
source /opt/intel/oneapi/compiler/latest/env/vars.sh
set -u

cd faiss

make -C _build \
    -j$(( $(nproc) / 2 )) swigfaiss swigfaiss_avx2

cd _build/faiss/python/

python3 setup.py sdist bdist_wheel
