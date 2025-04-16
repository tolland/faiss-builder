#!/bin/bash

set -eu
set -o pipefail

# Source common functions and variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
source "$SCRIPT_DIR/common.sh"

# Get the build type from argument
VENV_TYPE=$1

# Ensure we're in the project root directory
ensure_project_root

# Source versions file
source_versions

# Verify repositories
verify_repositories

# Source MKL if needed
source_mkl_if_needed "$VENV_TYPE"

# Get the appropriate venv directory
VENV_DIR=$(get_numpy_venv_dir "$VENV_TYPE")

# Activate the virtual environment
activate_venv "$VENV_DIR"

# Navigate to NumPy directory
cd "$PROJECT_ROOT/numpy"

# Clean any previous builds
rm -rf build dist dist_numpy

# Create output directory
mkdir -p dist_numpy

# Install build package if not already installed
pip install -q build

# Build the package
if [ "$VENV_TYPE" = "numpy_mkl" ]; then
    # Build with MKL
    python -m build -Csetup-args=-Dblas=mkl -Csetup-args=-Dlapack=mkl --outdir dist_numpy
else
    # Standard build with explicit BLAS and LAPACK settings
    python -m build -Csetup-args=-Dblas=blas -Csetup-args=-Dlapack=lapack --outdir dist_numpy
fi

# Copy wheel files to dist directory for consistency with other scripts
mkdir -p dist
cp dist_numpy/*.whl dist/

echo "NumPy package built successfully in dist_numpy/"