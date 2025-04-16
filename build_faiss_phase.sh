#!/bin/bash
set -eu

# Check if argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <build_type>"
    echo "Build types: cpu, cpu_mkl, gpu, gpu_mkl"
    exit 1
fi

BUILD_TYPE=$1
BUILD_DIR="_build_${BUILD_TYPE}"



# Build FAISS
echo "Building FAISS..."
./20_create_faiss_venv.sh $BUILD_TYPE
./21_faiss_configure.sh $BUILD_TYPE
./22_faiss_build.sh $BUILD_TYPE
./23_faiss_python_package.sh $BUILD_TYPE
./24_faiss_install_package.sh $BUILD_TYPE
./25_faiss_test_package.sh $BUILD_TYPE

echo "FAISS build phase completed successfully!"
