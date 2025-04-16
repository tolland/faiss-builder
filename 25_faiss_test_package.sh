#!/bin/bash

set -eu
set -o pipefail

# Check if argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <build_type>"
    echo "Build types: cpu, cpu_mkl, gpu, gpu_mkl"
    exit 1
fi

BUILD_TYPE=$1

# Source common functions
source "$(dirname "$0")/common.sh"
ensure_script_dir
source_versions
verify_repositories

FAISS_TESTS=(
    "tests/simple.py"
    "faiss/tutorial/python/1-Flat.py"
    "faiss/tutorial/python/2-IVFFlat.py"
    "faiss/tutorial/python/3-IVFPQ.py"
    "faiss/tutorial/python/7-PQFastScan.py"
)

# Determine which venv directory to use
case "$BUILD_TYPE" in
    "cpu")
        VENV_DIR="$FAISS_CPU_VENV_DIR"
        
        ;;
    "cpu_mkl")
        VENV_DIR="$FAISS_CPU_MKL_VENV_DIR"
        [ -z "${MKL_SOURCED:-""}" ] && source mkl.sh
        ;;
    "gpu")
        VENV_DIR="$FAISS_GPU_VENV_DIR"
        FAISS_TESTS+=(
            "tests/gpu.py"
            "faiss/tutorial/python/4-GPU.py"
            "faiss/tutorial/python/5-Multiple-GPUs.py"
        )
        ;;
    "gpu_mkl")
        VENV_DIR="$FAISS_GPU_MKL_VENV_DIR"
        [ -z "${MKL_SOURCED:-""}" ] && source mkl.sh
        FAISS_TESTS+=(
            "tests/gpu.py"
            "faiss/tutorial/python/4-GPU.py"
            "faiss/tutorial/python/5-Multiple-GPUs.py"
        )
        ;;
    *)
        echo "Error: Invalid build type '$BUILD_TYPE'"
        echo "Valid build types: cpu, cpu_mkl, gpu, gpu_mkl"
        exit 1
        ;;
esac

echo "Sanity check: Testing FAISS build type: $BUILD_TYPE"
run_command "python -c 'import faiss; print(faiss.__version__)'" "Testing faiss import"

# Run tests from the tests directory
"$SCRIPT_DIR/tests/test_faiss.sh" "$BUILD_TYPE"

# Run tests
echo "Testing FAISS build type: $BUILD_TYPE"
run_command "python -c 'import faiss; print(faiss.__version__)'" "Testing faiss import"

echo "Running tests..."
for test in "${FAISS_TESTS[@]}"; do
    echo "Running test: $test"
    run_command "python $test" "Running test: $test"
done

