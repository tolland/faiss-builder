#!/bin/bash

set -e
set -o pipefail

# Get the directory where this script is located
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LIB_DIR="$PROJECT_ROOT/lib"

# Source common functions and variables
source "$LIB_DIR/common.sh"

# Function to display usage information
display_usage() {
    echo "Usage: $0 <numpy_build_type> <faiss_build_type> [options]"
    echo ""
    echo "Numpy build types:"
    echo "  numpy      - Build NumPy without MKL"
    echo "  numpy_mkl  - Build NumPy with MKL"
    echo ""
    echo "FAISS build types:"
    echo "  cpu       - Build FAISS for CPU only"
    echo "  cpu_mkl   - Build FAISS for CPU with MKL"
    echo "  gpu       - Build FAISS with GPU support"
    echo "  gpu_mkl   - Build FAISS with GPU support and MKL"
    echo ""
    echo "Options:"
    echo "  --num-procs N              - Number of processors to use (default: nproc/2)"
    echo "  --only-numpy                - Only build NumPy, skip FAISS build"
    echo "  --only-faiss                - Only build FAISS, skip NumPy build"
    echo "  --skip-numpy-build          - Skip NumPy build step"
    echo "  --skip-numpy-install        - Skip NumPy install step"
    echo "  --skip-faiss-configure      - Skip FAISS configure step"
    echo "  --skip-faiss-build          - Skip FAISS build step"
    echo "  --skip-faiss-python-build   - Skip FAISS Python package build step"
    echo "  --skip-faiss-python-install - Skip FAISS Python package install step"
    echo "  --skip-faiss-test           - Skip FAISS test step"
    echo "  --only-faiss-configure      - Only run FAISS configure step"
    echo "  --only-faiss-build          - Only run FAISS build step"
    echo "  --only-faiss-python-build   - Only run FAISS Python package build step"
    echo "  --only-faiss-python-install - Only run FAISS Python package install step"
    echo "  --only-faiss-test           - Only run FAISS test step"
    echo "  --help                      - Display this help message"
    exit 1
}

# Check if we have the required number of arguments
if [ $# -lt 2 ]; then
    display_usage
fi

# Parse positional arguments
NUMPY_BUILD_TYPE="$1"
FAISS_BUILD_TYPE="$2"
shift 2

# Validate NumPy build type
if [[ ! "$NUMPY_BUILD_TYPE" =~ ^(numpy|numpy_mkl)$ ]]; then
    echo "Error: Invalid NumPy build type. Must be 'numpy' or 'numpy_mkl'."
    display_usage
fi

# Validate FAISS build type
if [[ ! "$FAISS_BUILD_TYPE" =~ ^(cpu|cpu_mkl|gpu|gpu_mkl)$ ]]; then
    echo "Error: Invalid FAISS build type. Must be 'cpu', 'cpu_mkl', 'gpu', or 'gpu_mkl'."
    display_usage
fi

# Initialize flags for build steps
BUILD_NUMPY=true
BUILD_FAISS=true
RUN_NUMPY_BUILD=true
RUN_NUMPY_INSTALL=true
RUN_FAISS_CONFIGURE=true
RUN_FAISS_BUILD=true
RUN_FAISS_PYTHON_BUILD=true
RUN_FAISS_PYTHON_INSTALL=true
RUN_FAISS_TEST=true

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --num-procs)
            if [[ -z "$2" ]]; then
                echo "Error: --num-procs requires a value"
                display_usage
            fi
            export NUM_PROCS="$2"
            shift
            ;;
        --only-numpy)
            BUILD_FAISS=false
            ;;
        --only-faiss)
            BUILD_NUMPY=false
            ;;
        --skip-numpy-build)
            RUN_NUMPY_BUILD=false
            ;;
        --skip-numpy-install)
            RUN_NUMPY_INSTALL=false
            ;;
        --skip-faiss-configure)
            RUN_FAISS_CONFIGURE=false
            ;;
        --skip-faiss-build)
            RUN_FAISS_BUILD=false
            ;;
        --skip-faiss-python-build)
            RUN_FAISS_PYTHON_BUILD=false
            ;;
        --skip-faiss-python-install)
            RUN_FAISS_PYTHON_INSTALL=false
            ;;
        --skip-faiss-test)
            RUN_FAISS_TEST=false
            ;;
        --only-faiss-configure)
            RUN_FAISS_BUILD=false
            RUN_FAISS_PYTHON_BUILD=false
            RUN_FAISS_PYTHON_INSTALL=false
            RUN_FAISS_TEST=false
            BUILD_NUMPY=false
            ;;
        --only-faiss-build)
            RUN_FAISS_CONFIGURE=false
            RUN_FAISS_PYTHON_BUILD=false
            RUN_FAISS_PYTHON_INSTALL=false
            RUN_FAISS_TEST=false
            BUILD_NUMPY=false
            ;;
        --only-faiss-python-build)
            RUN_FAISS_CONFIGURE=false
            RUN_FAISS_BUILD=false
            RUN_FAISS_PYTHON_INSTALL=false
            RUN_FAISS_TEST=false
            BUILD_NUMPY=false
            ;;
        --only-faiss-python-install)
            RUN_FAISS_CONFIGURE=false
            RUN_FAISS_BUILD=false
            RUN_FAISS_PYTHON_BUILD=false
            RUN_FAISS_TEST=false
            BUILD_NUMPY=false
            ;;
        --only-faiss-test)
            RUN_FAISS_CONFIGURE=false
            RUN_FAISS_BUILD=false
            RUN_FAISS_PYTHON_BUILD=false
            RUN_FAISS_PYTHON_INSTALL=false
            BUILD_NUMPY=false
            ;;
        --help)
            display_usage
            ;;
        *)
            echo "Error: Unknown option: $1"
            display_usage
            ;;
    esac
    shift
done

# Function to execute a script and handle errors
run_script() {
    local script="$1"
    shift
    local script_args="$@"

    echo "========================================="
    echo "Executing $(basename "$script") $script_args..."
    echo "========================================="

    if ! bash "$script" "$@"; then
        echo "Error: $script failed"
        exit 1
    fi
    
    echo "Completed $(basename "$script")"
    echo "-----------------------------------------"
}

# Ensure we have versions.txt
if [ ! -f "$PROJECT_ROOT/versions.txt" ]; then
    run_script "$LIB_DIR/00_versions.sh"
fi

# Check if repositories exist, if not, checkout them
if [ ! -d "$PROJECT_ROOT/numpy" ] || [ ! -d "$PROJECT_ROOT/faiss" ]; then
    run_script "$LIB_DIR/01_checkout.sh"
fi

# Build NumPy if required
if [ "$BUILD_NUMPY" = true ]; then
    echo "Building NumPy ($NUMPY_BUILD_TYPE)..."
    
    if [ "$RUN_NUMPY_BUILD" = true ]; then
        run_script "$LIB_DIR/10_numpy_create_venv.sh" "$NUMPY_BUILD_TYPE"
        run_script "$LIB_DIR/11_numpy_build_package.sh" "$NUMPY_BUILD_TYPE"
    fi
    
    if [ "$RUN_NUMPY_INSTALL" = true ]; then
        run_script "$LIB_DIR/12_numpy_install_package.sh" "$NUMPY_BUILD_TYPE"
    fi
    
    echo "NumPy build completed successfully!"
    echo "========================================="
fi

# Build FAISS if required
if [ "$BUILD_FAISS" = true ]; then
    echo "Building FAISS ($FAISS_BUILD_TYPE)..."
    
    # Always create the virtual environment if we're building FAISS
    run_script "$LIB_DIR/20_create_faiss_venv.sh" "$NUMPY_BUILD_TYPE" "$FAISS_BUILD_TYPE"
    
    # Determine which NumPy venv to use based on FAISS build type
    if [[ "$FAISS_BUILD_TYPE" == *"mkl"* ]]; then
        # For MKL FAISS builds, use the MKL NumPy if available, else regular NumPy
        if [ -d "$NUMPY_MKL_VENV_DIR" ]; then
            NUMPY_TYPE="numpy_mkl"
        else
            NUMPY_TYPE="numpy"
        fi
    else
        # For non-MKL FAISS builds, use regular NumPy
        NUMPY_TYPE="numpy"
    fi
    
    echo "Using NumPy build type: $NUMPY_TYPE for FAISS build"
    
    if [ "$RUN_FAISS_CONFIGURE" = true ]; then
        # Pass the NumPy type as an environment variable for configuration
        NUMPY_TYPE="$NUMPY_TYPE" run_script "$LIB_DIR/21_faiss_configure.sh" "$FAISS_BUILD_TYPE"
    fi
    
    if [ "$RUN_FAISS_BUILD" = true ]; then
        run_script "$LIB_DIR/22_faiss_build.sh" "$FAISS_BUILD_TYPE"
    fi
    
    if [ "$RUN_FAISS_PYTHON_BUILD" = true ]; then
        run_script "$LIB_DIR/23_faiss_python_package.sh" "$FAISS_BUILD_TYPE"
    fi
    
    if [ "$RUN_FAISS_PYTHON_INSTALL" = true ]; then
        run_script "$LIB_DIR/24_faiss_install_package.sh" "$FAISS_BUILD_TYPE"
    fi
    
    if [ "$RUN_FAISS_TEST" = true ]; then
        run_script "$LIB_DIR/25_faiss_test_package.sh" "$FAISS_BUILD_TYPE"
    fi
    
    echo "FAISS build completed successfully!"
    echo "========================================="
fi

echo "Build process completed successfully!"