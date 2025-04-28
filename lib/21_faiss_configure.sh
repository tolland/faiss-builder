#!/bin/bash

set -eu
set -o pipefail

# Source common functions and variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the build type from argument
_NUMPY_BUILD_TYPE=$1
_FAISS_BUILD_TYPE=$2

source "$SCRIPT_DIR/common.sh"

# Ensure we're in the project root directory
ensure_project_root

# Source versions file
source_versions

# Verify repositories
verify_repositories

# Source MKL if needed
source_mkl_if_needed "${_FAISS_BUILD_TYPE}"

# Determine which build directory to use based on build type
_FAISS_BUILD_DIR=$(get_faiss_build_dir "${_NUMPY_BUILD_TYPE}" "${_FAISS_BUILD_TYPE}")

cd "${FAISS_SRC}"

# Get the NumPy venv directory based on the type
NUMPY_VENV=$(get_numpy_venv_dir "${_NUMPY_BUILD_TYPE}")
echo "Using NumPy venv: $NUMPY_VENV for FAISS configuration"

# Activate the NumPy venv for building
source "${NUMPY_VENV}/bin/activate"

# Base CMake command
CMAKE_CMD="cmake -B ${_FAISS_BUILD_DIR} \
  -DCMAKE_C_COMPILER_LAUNCHER=ccache \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
  -G Ninja \
  -DFAISS_ENABLE_PYTHON=ON \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_TESTING=OFF \
  -DFAISS_ENABLE_CUVS=OFF \
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"

export CC="ccache gcc"
export CXX="ccache g++"

case "${_FAISS_BUILD_TYPE}" in
    "cpu")
        $CMAKE_CMD \
          -DFAISS_ENABLE_GPU=OFF \
          -DFAISS_OPT_LEVEL=${FAISS_OPT_LEVEL} \
          .
        ;;
    "cpu_mkl")
        $CMAKE_CMD \
          -DFAISS_ENABLE_GPU=OFF \
          -DFAISS_OPT_LEVEL=${FAISS_OPT_LEVEL} \
          -DBLA_VENDOR=Intel10_64lp \
          -DMKL_LIBRARIES="$(IFS=';'; echo "${MKL_LIBRARIES[*]}")" \
          -DCMAKE_INSTALL_RPATH="\$ORIGIN/contrib" \
          -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
          .
        ;;
    "gpu")
    set -x
        $CMAKE_CMD \
          -DFAISS_ENABLE_GPU=ON \
          -DFAISS_OPT_LEVEL=$FAISS_OPT_LEVEL \
          -DCMAKE_CUDA_ARCHITECTURES="$CUDA_ARCHITECTURES" \
          .
          set +x
        ;;
    "gpu_mkl")
        $CMAKE_CMD \
          -DFAISS_ENABLE_GPU=ON \
          -DFAISS_OPT_LEVEL=$FAISS_OPT_LEVEL \
          -DCMAKE_CUDA_ARCHITECTURES="$CUDA_ARCHITECTURES" \
          -DBLA_VENDOR=Intel10_64lp \
          -DMKL_LIBRARIES="$(IFS=';'; echo "${MKL_LIBRARIES[*]}")" \
          -DCMAKE_INSTALL_RPATH="\$ORIGIN/contrib" \
          -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
          .
        ;;
esac

echo "FAISS configuration completed successfully!"
