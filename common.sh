#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NUMPY_VENV_DIR="$SCRIPT_DIR/numpy_venv"
FAISS_VENV_DIR=$SCRIPT_DIR/faiss_venv
COMMON_SOURCED="true"
NUM_PROCS="$(( $(nproc) / 2 ))"

# Activate MKL environment with shared libraries
set +u
source /opt/intel/oneapi/mkl/2025.1/env/vars.sh
source /opt/intel/oneapi/compiler/2025.1/env/vars.sh
set -u

echo "SCRIPT DIR: $SCRIPT_DIR"

# Function to ensure we're in the script directory
ensure_script_dir() {
    cd "$SCRIPT_DIR"
}

# Function to source the versions file
source_versions() {
    if [ -f "$SCRIPT_DIR/versions.txt" ]; then
        source "$SCRIPT_DIR/versions.txt"
    else
        echo "Error: versions.txt not found. Please run 00_versions.sh first."
        exit 1
    fi
}

# Function to verify numpy and faiss exist as siblings
verify_repositories() {
    if [ ! -d "$SCRIPT_DIR/numpy" ] || [ ! -d "$SCRIPT_DIR/faiss" ]; then
        echo "Error: Required repositories not found. Please run 01_checkout.sh first."
        exit 1
    fi
}

# Function to run a command and handle errors
run_command() {
    local cmd="$1"
    local description="${2:-$cmd}"
    
    echo "Running: $description"
    if ! eval "$cmd"; then
        echo "Error: Failed to execute: $description"
        exit 1
    fi
}

# Function to create and setup a virtual environment
setup_venv() {
    local venv_dir="$1"
    local requirements_file="${2:-}"
    
    if [ ! -d "$venv_dir" ]; then
        run_command "python3 -m venv \"$venv_dir\"" "Creating virtual environment in $venv_dir"
    fi
    
    # Activate the virtual environment
    source "$venv_dir/bin/activate"
    
    # Install requirements if specified
    if [ -n "$requirements_file" ] && [ -f "$requirements_file" ]; then
        run_command "pip install -r \"$requirements_file\"" "Installing requirements from $requirements_file"
    fi
}

# Function to activate a virtual environment
activate_venv() {
    local venv_dir="$1"
    if [ ! -d "$venv_dir" ]; then
        echo "Error: Virtual environment $venv_dir does not exist"
        exit 1
    fi
    source "$venv_dir/bin/activate"
} 