#!/bin/bash

set -eu
set -o pipefail

# Source common functions
source "$(dirname "$0")/common.sh"
ensure_script_dir
source_versions
verify_repositories

# Create and activate virtual environment
run_command "python3 -m venv venv" "Creating virtual environment"
run_command "source venv/bin/activate" "Activating virtual environment"

# Install required packages
run_command "venv/bin/pip install --upgrade pip" "Upgrading pip"
run_command "venv/bin/pip install wheel setuptools" "Installing build dependencies"

echo $NUMPY_VENV_DIR
echo $SCRIPT_DIR/numpy/requirements/build_requirements.txt

# Create and setup numpy build venv
setup_venv "$NUMPY_VENV_DIR" "$SCRIPT_DIR/numpy/requirements/build_requirements.txt"

# Export venv directory for other scripts
export NUMPY_VENV_DIR




if [ ! -d "$FAISS_VENV_DIR" ]; then
    python3 -m venv "$FAISS_VENV_DIR"
fi

(

"${FAISS_VENV_DIR}/bin/pip" install setuptools wheel

)
