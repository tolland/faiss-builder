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
source_mkl_if_needed "${_FAISS_BUILD_TYPE}"

# Get the appropriate venv directory
FAISS_VENV_DIR=$(get_faiss_venv_dir "${_NUMPY_BUILD_TYPE}" "${_FAISS_BUILD_TYPE}")
_FAISS_BUILD_DIR=$(get_faiss_build_dir "${_NUMPY_BUILD_TYPE}" "${_FAISS_BUILD_TYPE}")
_FAISS_DIST_DIR=$(get_faiss_dist_dir "${_NUMPY_BUILD_TYPE}" "${_FAISS_BUILD_TYPE}")

export _FAISS_PACKAGE_NAME=$(get_faiss_package_name "${_FAISS_BUILD_TYPE}")

cd "${FAISS_SRC}"

# Check if build directory exists
if [ ! -d "${_FAISS_BUILD_DIR}" ]; then
    echo "Error: Build directory ${_FAISS_BUILD_DIR} does not exist. Please run 21_faiss_configure.sh and 22_faiss_build.sh first."
    exit 1
fi

which python

# Build Python package
cd "${FAISS_SRC}/${_FAISS_BUILD_DIR}/faiss/python"

conf_file="${PROJECT_ROOT}/lib/pyproject.toml"

echo "_FAISS_BUILD_DIR = ${_FAISS_BUILD_DIR}"

if needs_mkl "${_FAISS_BUILD_TYPE}" ; then
  echo "Copying MKL libraries to contrib directory"
  mkdir -p "${FAISS_SRC}/${_FAISS_BUILD_DIR}/faiss/python/faiss"
  for lib in "${MKL_LIBRARIES[@]}"; do
    echo "Copying $lib to ${FAISS_SRC}/${_FAISS_BUILD_DIR}/faiss/python/contrib/"
    cp -a "$lib" "${FAISS_SRC}/${_FAISS_BUILD_DIR}/faiss/python/contrib/"
  done
fi

envsubst '$_FAISS_PACKAGE_NAME' < "$conf_file" > "${FAISS_SRC}/${_FAISS_BUILD_DIR}/faiss/python/pyproject.toml.tmp" && mv "${FAISS_SRC}/${_FAISS_BUILD_DIR}/faiss/python/pyproject.toml.tmp" "${FAISS_SRC}/${_FAISS_BUILD_DIR}/faiss/python/pyproject.toml"

cp "$PROJECT_ROOT/lib/hook_build.py" "${FAISS_SRC}/${_FAISS_BUILD_DIR}/faiss/python/"

# Build without isolation
# python setup.py sdist --dist-dir "${_FAISS_DIST_DIR}"

# Build wheel with RPATH set via LDFLAGS
# Use the absolute path to the contrib directory where MKL libraries are copied
# MKL_LIB_PATH="${FAISS_SRC}/${_FAISS_BUILD_DIR}/faiss/python/contrib"

echo "_FAISS_DIST_DIR = ${_FAISS_DIST_DIR}"

python -m build \
  --wheel \
  --outdir "${_FAISS_DIST_DIR}" \
  --verbose --verbose

# @TODO this seems to be using the system python
# python setup.py bdist_wheel --dist-dir "${_FAISS_DIST_DIR}"

echo "FAISS Python package built successfully!"
ls -lah "${_FAISS_DIST_DIR}"
