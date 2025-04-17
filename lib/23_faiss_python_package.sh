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

# Get the appropriate venv directory
FAISS_VENV_DIR=$(get_faiss_venv_dir "${_NUMPY_BUILD_TYPE}" "${_FAISS_BUILD_TYPE}")

_FAISS_BUILD_DIR=$(get_faiss_build_dir "${_NUMPY_BUILD_TYPE}" "${_FAISS_BUILD_TYPE}")

_FAISS_DIST_DIR=$(get_faiss_dist_dir "${_NUMPY_BUILD_TYPE}" "${_FAISS_BUILD_TYPE}")

cd "${FAISS_SRC}"

# Check if build directory exists
if [ ! -d "${_FAISS_BUILD_DIR}" ]; then
    echo "Error: Build directory ${_FAISS_BUILD_DIR} does not exist. Please run 21_faiss_configure.sh and 22_faiss_build.sh first."
    exit 1
fi

which python

# Build Python package
cd "${_FAISS_BUILD_DIR}/faiss/python"
# @TODO this seems to be using the system python
python setup.py bdist_wheel --dist-dir "${_FAISS_DIST_DIR}"

echo "FAISS Python package built successfully!"
ls -lah "${_FAISS_DIST_DIR}"