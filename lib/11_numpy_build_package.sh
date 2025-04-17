#!/bin/bash

set -eu
set -o pipefail

# Source common functions and variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

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
source_mkl_if_needed "${_NUMPY_BUILD_TYPE}"

# Get the appropriate venv directory
NUMPY_VENV_DIR=$(get_numpy_venv_dir "${_NUMPY_BUILD_TYPE}")

# Get the dist directory
_NUMPY_DIST_DIR=$(get_numpy_dist_dir "${_NUMPY_BUILD_TYPE}")

# Activate the virtual environment
activate_venv "$NUMPY_VENV_DIR"

# Create output directory
mkdir -p "${_NUMPY_DIST_DIR}"

# Install build package if not already installed
pip install -q build

if [ -d "$_NUMPY_DIST_DIR" ] && [ ! -z "$(ls -A $_NUMPY_DIST_DIR/*.whl 2>/dev/null)" ]; then
  echo "numpy already exists in \"${_NUMPY_DIST_DIR}\" - please delete to recreate"
  exit 0
fi

cd "${NUMPY_SRC}"

# Build the package
if [ "${_NUMPY_BUILD_TYPE}" = "numpy_mkl" ]; then
    # Build with MKL
    python -m build -Csetup-args=-Dblas=mkl -Csetup-args=-Dlapack=mkl --outdir "${_NUMPY_DIST_DIR}"
else
    # Standard build with explicit BLAS and LAPACK settings
    python -m build -Csetup-args=-Dblas=blas -Csetup-args=-Dlapack=lapack --outdir "${_NUMPY_DIST_DIR}"
fi


echo "NumPy package built successfully in \"${_NUMPY_DIST_DIR}\"/"