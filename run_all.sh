#!/bin/bash

set -eu
set -o pipefail

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Store all arguments except the first two (which would be numpy/faiss types in build.sh)
OPTIONS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            "$SCRIPT_DIR/build.sh" --help
            exit 0
            ;;
        *)
            OPTIONS+=("$1")
            shift
            ;;
    esac
done

# Define build type combinations
NUMPY_TYPES=("numpy" "numpy_mkl")
FAISS_TYPES=("cpu" "cpu_mkl" "gpu" "gpu_mkl")

# Run all combinations
for numpy_type in $(printf "%s\n" "${NUMPY_TYPES[@]}" | shuf); do
    for faiss_type in $(printf "%s\n" "${FAISS_TYPES[@]}" | shuf); do
        echo "========================================="
        echo "Running build with: $numpy_type $faiss_type ${OPTIONS[*]}"
        echo "========================================="
        if ! "$SCRIPT_DIR/build.sh" "$numpy_type" "$faiss_type" "${OPTIONS[@]}"; then
            echo "Error: Build failed for $numpy_type $faiss_type"
            exit 1
        fi
        echo "-----------------------------------------"
    done
done

echo "All builds completed successfully!" 