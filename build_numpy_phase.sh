#!/bin/bash
set -eu

# Check if argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <venv_type>"
    echo "Venv types: numpy, numpy_mkl"
    exit 1
fi

VENV_TYPE=$1


# Build numpy with MKL
echo "Building numpy with MKL..."
./10_numpy_create_venv.sh $VENV_TYPE
./11_numpy_build_package.sh $VENV_TYPE
./12_numpy_install_package.sh $VENV_TYPE

echo "Numpy build phase completed successfully!"
