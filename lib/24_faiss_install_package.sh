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
_NUMPY_DIST_DIR=$(get_numpy_dist_dir "${_NUMPY_BUILD_TYPE}" "${_FAISS_BUILD_TYPE}")

# Install the correct numpy for this build type
if [ ! -d "$_NUMPY_DIST_DIR" ] || [ -z "$(ls -A "${_NUMPY_DIST_DIR}/"*.whl 2>/dev/null)" ]; then
      echo "_NUMPY_DIST_DIR is ${_NUMPY_DIST_DIR}"
      ls -lah "${_NUMPY_DIST_DIR}"
    echo "Error: Python wheel not found. Please build the numpy package first."
    exit 1
fi


# Check for the faiss wheel file
if [ ! -d "${_FAISS_DIST_DIR}" ] || [ -z "$(ls -A "${_FAISS_DIST_DIR}"/*.whl 2>/dev/null)" ]; then
    echo "Error: Python wheel not found. Please build the faiss package first."
    echo "_FAISS_DIST_DIR is ${_FAISS_DIST_DIR}"
    ls -lah "${_FAISS_DIST_DIR}"
    exit 1
fi

# Activate the virtual environment
activate_venv "$FAISS_VENV_DIR"

# Install the wheel
pip install --force-reinstall --no-dependencies "${_FAISS_DIST_DIR}"/*.whl

# Verify installation
python -c "import faiss; print(f'FAISS version: {faiss.__version__}')"

echo "FAISS package installed successfully in $FAISS_VENV_DIR"
pip freeze | grep -E '^numpy|^faiss' || echo "no numpy or faiss packages found"