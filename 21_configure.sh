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

cmake -B _build \
  -DFAISS_ENABLE_GPU=ON \
  -DFAISS_ENABLE_PYTHON=ON \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_TESTING=OFF \
  -DFAISS_ENABLE_CUVS=OFF \
  -DCMAKE_BUILD_TYPE=Debug \
  -DFAISS_OPT_LEVEL=avx2 \
  -DBLA_VENDOR=Intel10_64lp \
  -DMKL_LIBRARIES="/opt/intel/oneapi/mkl/2025.1/lib/libmkl_intel_lp64.so;/opt/intel/oneapi/mkl/2025.1/lib/libmkl_tbb_thread.so;/opt/intel/oneapi/mkl/2025.1/lib/libmkl_gnu_thread.so;/opt/intel/oneapi/mkl/2025.1/lib/libmkl_core.so;/opt/intel/oneapi/mkl/2025.1/lib/libmkl_intel_thread.so;/opt/intel/oneapi/mkl/2025.1/lib/intel64/libmkl_intel_lp64.so;/opt/intel/oneapi/compiler/2025.1/lib/libiomp5.so;/opt/intel/oneapi/mkl/2025.1/lib/libmkl_gf_lp64.so;/opt/intel/oneapi/tbb/2022.1/lib/libtbb.so" \
  -DCMAKE_CUDA_ARCHITECTURES="89" \
  .
)

#/opt/intel/oneapi/mkl/2025.1/lib/libmkl_gf_ilp64.so;