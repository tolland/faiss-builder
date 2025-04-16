#!/bin/bash

set -eu
set -o pipefail

(

[ -z "${COMMON_SOURCED:-""}" ] && source common.sh

# Activate numpy build venv to get numpy headers
source "${NUMPY_VENV_DIR}/bin/activate"

cd "$SCRIPT_DIR/faiss"

MKL_LIBRARIES=(
  "/opt/intel/oneapi/mkl/2025.1/lib/libmkl_intel_lp64.so"
  "/opt/intel/oneapi/mkl/2025.1/lib/libmkl_tbb_thread.so"
  "/opt/intel/oneapi/mkl/2025.1/lib/libmkl_gnu_thread.so"
  "/opt/intel/oneapi/mkl/2025.1/lib/libmkl_core.so"
  "/opt/intel/oneapi/mkl/2025.1/lib/libmkl_intel_thread.so"
  "/opt/intel/oneapi/mkl/2025.1/lib/intel64/libmkl_intel_lp64.so"
  "/opt/intel/oneapi/compiler/2025.1/lib/libiomp5.so"
  "/opt/intel/oneapi/mkl/2025.1/lib/libmkl_gf_lp64.so"
  "/opt/intel/oneapi/tbb/2022.1/lib/libtbb.so"
)

cmake -B _build \
  -DFAISS_ENABLE_GPU=ON \
  -DFAISS_ENABLE_PYTHON=ON \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_TESTING=OFF \
  -DFAISS_ENABLE_CUVS=OFF \
  -DCMAKE_BUILD_TYPE=Debug \
  -DFAISS_OPT_LEVEL=avx2 \
  -DBLA_VENDOR=Intel10_64lp \
  -DMKL_LIBRARIES="$(IFS=';'; echo "${MKL_LIBRARIES[*]}")" \
  -DCMAKE_CUDA_ARCHITECTURES="89" \
  .
)
