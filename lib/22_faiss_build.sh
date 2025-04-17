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

_FAISS_BUILD_DIR=$(get_faiss_build_dir "${_NUMPY_BUILD_TYPE}" "${_FAISS_BUILD_TYPE}")

cd "${FAISS_SRC}"

# Check if build directory exists
if [ ! -d "${_FAISS_BUILD_DIR}" ]; then
    echo "Error: Build directory ${_FAISS_BUILD_DIR} does not exist. Please run 21_faiss_configure.sh first."
    exit 1
fi

# Create build log directory if it doesn't exist
BUILD_LOGS_DIR="${PROJECT_ROOT}/build/logs"
mkdir -p "${BUILD_LOGS_DIR}"

#make -C "${_FAISS_BUILD_DIR}" \
#    -j${NUM_PROCS} swigfaiss swigfaiss_avx2

# Log file for this build
BUILD_LOG="${BUILD_LOGS_DIR}/faiss_build_${_NUMPY_BUILD_TYPE}_${_FAISS_BUILD_TYPE}_$(date +%Y%m%d_%H%M%S).log"

# Log CMake configuration
echo "=== CMake Configuration ===" | tee -a "${BUILD_LOG}"
cat "${_FAISS_BUILD_DIR}/CMakeCache.txt" | grep -E '^CMAKE_|^FAISS_|^BUILD_|^CUDA_' | tee -a "${BUILD_LOG}"
echo "=== End CMake Configuration ===" | tee -a "${BUILD_LOG}"

# Build FAISS with timing
echo "Starting FAISS build..." | tee -a "${BUILD_LOG}"
START_TIME=$(date +%s)

# Build with ninja and capture output
if ! ninja -C "${_FAISS_BUILD_DIR}" -j "$NUM_PROCS" swigfaiss swigfaiss_avx2 2>&1 | tee -a "${BUILD_LOG}"; then
    echo "FAISS build failed!" | tee -a "${BUILD_LOG}"
    exit 1
fi

END_TIME=$(date +%s)
BUILD_DURATION=$((END_TIME - START_TIME))

echo "FAISS build completed successfully in ${BUILD_DURATION} seconds!" | tee -a "${BUILD_LOG}"
echo "Build log saved to: ${BUILD_LOG}"