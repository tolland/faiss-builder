#!/bin/bash
set -eu

# Source common functions
source common.sh



# Build numpy with MKL
echo "Building numpy with MKL..."
./10_create_numpy_venv.sh
./11_build_numpy.sh
./12_install_mkl_numpy.sh

echo "Numpy build phase completed successfully!"
echo "Virtual environment is in: $(pwd)/numpy_venv" 