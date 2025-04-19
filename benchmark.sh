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
    echo "Usage: $0 <build_type> [options]"
    echo ""
    echo "Build types:"
    echo "  cpu       - Run benchmarks with CPU build"
    echo "  cpu_mkl   - Run benchmarks with CPU+MKL build"
    echo "  gpu       - Run benchmarks with GPU build"
    echo "  gpu_mkl   - Run benchmarks with GPU+MKL build"
    echo ""
    echo "Options:"
    echo "  --help    - Display this help message"
    exit 1
}

# Check if we have the required number of arguments
if [ $# -lt 1 ]; then
    display_usage
fi

# Parse positional arguments
BUILD_TYPE="$1"
shift

# Validate build type
if [[ ! "$BUILD_TYPE" =~ ^(cpu|cpu_mkl|gpu|gpu_mkl)$ ]]; then
    echo "Error: Invalid build type. Must be 'cpu', 'cpu_mkl', 'gpu', or 'gpu_mkl'."
    display_usage
fi

# Initialize flags for build steps
RUN_BENCHMARKS=true
RUN_PLOTTING=false

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            display_usage
            ;;
        --only-plot)
            RUN_BENCHMARKS=false
            RUN_PLOTTING=true
            ;;
        *)
            echo "Error: Unknown option: $1"
            display_usage
            ;;
    esac
    shift
done

if [ "${RUN_BENCHMARKS}" = true ]; then
    # Run the benchmarking script
    echo "Running benchmarks for $BUILD_TYPE..."
    bash "$LIB_DIR/26_faiss_benchmarking.sh" "$BUILD_TYPE"

    echo "Benchmarking completed!"
fi

if [ "${RUN_PLOTTING}" = true ]; then
    # Run the benchmarking script
    echo "Running plot generator for $BUILD_TYPE..."
    bash "$LIB_DIR/27_faiss_benchmarking_plots.sh" "$BUILD_TYPE"

    echo "Plotting completed!"
fi