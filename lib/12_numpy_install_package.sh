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

# Check if wheel files exist in dist_numpy directory first, then fallback to dist
if [ -d "dist_numpy" ] && [ "$(ls -A dist_numpy/*.whl 2>/dev/null | wc -l)" -gt 0 ]; then
    WHEEL_DIR="dist_numpy"
elif [ -d "dist" ] && [ "$(ls -A dist/*.whl 2>/dev/null | wc -l)" -gt 0 ]; then
    WHEEL_DIR="dist"
else
    echo "Error: No wheel files found in dist_numpy/ or dist/. Please run 11_numpy_build_package.sh first."
    exit 1
fi

echo "Installing NumPy wheel from $WHEEL_DIR directory"

# Install the wheel file
pip install --force-reinstall --no-dependencies $WHEEL_DIR/*.whl

# Verify installation
python -c "import numpy; print(f'NumPy version: {numpy.__version__}')"

echo "NumPy installed successfully in $VENV_DIR"