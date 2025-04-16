#!/bin/bash
set -e

# Source common functions
source common.sh

# Create and activate FAISS-specific venv
echo "Creating FAISS build virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install build dependencies
echo "Installing build dependencies..."
pip install --upgrade pip
pip install wheel setuptools

# Build FAISS
echo "Building FAISS..."
./21_configure.sh
./22_build.sh
./23_package.sh
./24_install_package.sh
./25_test_package.sh

echo "FAISS build phase completed successfully!"
echo "Virtual environment is in: $(pwd)/venv"