#!/bin/bash

set -eu
set -o pipefail

# Check if argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <build_type>"
    echo "Build types: numpy, numpy_mkl"
    exit 1
fi

BUILD_TYPE=$1

# Source common functions
[ -z "${COMMON_SOURCED:-""}" ] && source common.sh
ensure_script_dir
source_versions
verify_repositories

case "$BUILD_TYPE" in
    "numpy")
        # Activate regular numpy venv
        activate_venv "$NUMPY_VENV_DIR"
        
        # Build numpy without MKL
        cd "$SCRIPT_DIR/numpy"
        run_command "python -m build -Csetup-args=-Dblas=blas -Csetup-args=-Dlapack=lapack --outdir dist_numpy" "Building numpy without MKL support"
        ;;
    "numpy_mkl")
        # Source MKL and activate MKL numpy venv
        [ -z "${MKL_SOURCED:-""}" ] && source mkl.sh
        activate_venv "$NUMPY_MKL_VENV_DIR"
        
        # Build numpy with MKL
        cd "$SCRIPT_DIR/numpy"
        run_command "python -m build -Csetup-args=-Dblas=mkl -Csetup-args=-Dlapack=mkl  --outdir dist_numpy_mkl" "Building numpy with MKL support"
        ;;
    *)
        echo "Error: Invalid build type '$BUILD_TYPE'"
        echo "Valid build types: numpy, numpy_mkl"
        exit 1
        ;;
esac
