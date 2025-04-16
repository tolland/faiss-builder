#!/bin/bash

set -eu
set -o pipefail

# Check if argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <build_type>"
    echo "Build types: cpu, cpu_mkl, gpu, gpu_mkl"
    exit 1
fi

BUILD_TYPE=$1
BUILD_DIR="_build_${BUILD_TYPE}"

[ -z "${COMMON_SOURCED:-""}" ] && source common.sh

# Activate numpy build venv to get numpy headers
source "${NUMPY_VENV_DIR}/bin/activate"
cd "$SCRIPT_DIR/faiss"

# Common MKL libraries
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

# Base CMake command
CMAKE_CMD="cmake -B ${BUILD_DIR} \
  -DFAISS_ENABLE_PYTHON=ON \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_TESTING=OFF \
  -DFAISS_ENABLE_CUVS=OFF \
  -DCMAKE_BUILD_TYPE=Debug"

case "$BUILD_TYPE" in
    "cpu")
        $CMAKE_CMD \
          -DFAISS_ENABLE_GPU=OFF \
          -DFAISS_OPT_LEVEL=avx2 \
          .
        ;;
    "cpu_mkl")
        [ -z "${MKL_SOURCED:-""}" ] && source "$SCRIPT_DIR/mkl.sh"
        $CMAKE_CMD \
          -DFAISS_ENABLE_GPU=OFF \
          -DFAISS_OPT_LEVEL=avx2 \
          -DBLA_VENDOR=Intel10_64lp \
          -DMKL_LIBRARIES="$(IFS=';'; echo "${MKL_LIBRARIES[*]}")" \
          .
        ;;
    "gpu")
        $CMAKE_CMD \
          -DFAISS_ENABLE_GPU=ON \
          -DFAISS_OPT_LEVEL=avx2 \
          -DCMAKE_CUDA_ARCHITECTURES="80;86;89;90" \
          .
        ;;
    "gpu_mkl")
        [ -z "${MKL_SOURCED:-""}" ] && source "$SCRIPT_DIR/mkl.sh"
        $CMAKE_CMD \
          -DFAISS_ENABLE_GPU=ON \
          -DFAISS_OPT_LEVEL=avx2 \
          -DCMAKE_CUDA_ARCHITECTURES="80;86;89;90" \
          -DBLA_VENDOR=Intel10_64lp \
          -DMKL_LIBRARIES="$(IFS=';'; echo "${MKL_LIBRARIES[*]}")" \
          .
        ;;
    *)
        echo "Error: Invalid build type '$BUILD_TYPE'"
        echo "Valid build types: cpu, cpu_mkl, gpu, gpu_mkl"
        exit 1
        ;;
esac
