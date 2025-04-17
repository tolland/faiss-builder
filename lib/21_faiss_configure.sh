#!/bin/bash

set -eu
set -o pipefail

# Source common functions and variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Get the build type from argument
BUILD_TYPE=$1

source "$SCRIPT_DIR/common.sh"

# Ensure we're in the project root directory
ensure_project_root

# Source versions file
source_versions

# Verify repositories
verify_repositories

# Source MKL if needed
source_mkl_if_needed "$BUILD_TYPE"

# Determine which build directory to use based on build type
case "$BUILD_TYPE" in
    "cpu")
        BUILD_DIR="$CPU_BUILD_DIR"
        ;;
    "cpu_mkl")
        BUILD_DIR="$CPU_MKL_BUILD_DIR"
        ;;
    "gpu")
        BUILD_DIR="$GPU_BUILD_DIR"
        ;;
    "gpu_mkl")
        BUILD_DIR="$GPU_MKL_BUILD_DIR"
        ;;
esac

cd "${FAISS_SRC}"

# Base CMake command
CMAKE_CMD="cmake -B ${BUILD_DIR} \
  -DFAISS_ENABLE_PYTHON=ON \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_TESTING=OFF \
  -DFAISS_ENABLE_CUVS=OFF \
  -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE"

# Use NUMPY_TYPE environment variable if set, otherwise use defaults based on BUILD_TYPE
NUMPY_TYPE="${NUMPY_TYPE:-}"
if [ -z "$NUMPY_TYPE" ]; then
    if [[ "$BUILD_TYPE" == *"mkl"* ]]; then
        NUMPY_TYPE="numpy_mkl"
    else
        NUMPY_TYPE="numpy"
    fi
fi

# Get the NumPy venv directory based on the type
NUMPY_VENV=$(get_numpy_venv_dir "$NUMPY_TYPE")
echo "Using NumPy venv: $NUMPY_VENV for FAISS configuration"

# Activate the NumPy venv for building
source "${NUMPY_VENV}/bin/activate"

case "$BUILD_TYPE" in
    "cpu")
        $CMAKE_CMD \
          -DFAISS_ENABLE_GPU=OFF \
          -DFAISS_OPT_LEVEL=$FAISS_OPT_LEVEL \
          .
        ;;
    "cpu_mkl")
        $CMAKE_CMD \
          -DFAISS_ENABLE_GPU=OFF \
          -DFAISS_OPT_LEVEL=$FAISS_OPT_LEVEL \
          -DBLA_VENDOR=Intel10_64lp \
          -DMKL_LIBRARIES="$(IFS=';'; echo "${MKL_LIBRARIES[*]}")" \
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
          .
        ;;
esac

echo "FAISS configuration completed successfully!"