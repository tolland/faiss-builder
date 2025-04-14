#!/bin/bash

set -eu
set -o pipefail

set +u
source /opt/intel/oneapi/mkl/latest/env/vars.sh
source /opt/intel/oneapi/compiler/latest/env/vars.sh
set -u

cd faiss

cmake -B _build \
  -DFAISS_ENABLE_GPU=ON \
  -DFAISS_ENABLE_PYTHON=ON \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_TESTING=OFF \
  -DFAISS_ENABLE_CUVS=OFF \
  -DCMAKE_BUILD_TYPE=Debug \
  -DFAISS_OPT_LEVEL=avx2 \
  -DBLA_VENDOR=Intel10_64lp \
  -DMKL_LIBRARIES="/opt/intel/oneapi/mkl/2025.1/lib/libmkl_intel_lp64.a;/opt/intel/oneapi/mkl/2025.1/lib/libmkl_tbb_thread.a;/opt/intel/oneapi/mkl/2025.1/lib/libmkl_gnu_thread.a;/opt/intel/oneapi/mkl/2025.1/lib/libmkl_core.a;/opt/intel/oneapi/mkl/2025.1/lib/libmkl_intel_thread.a;/opt/intel/oneapi/mkl/latest/lib/intel64/libmkl_intel_lp64.a;/opt/intel/oneapi/compiler/2025.1/lib/libiomp5.a" \
  -DCMAKE_CUDA_ARCHITECTURES="89" \
  .

# ;-lgomp;-lpthread;-lm;-ldl
