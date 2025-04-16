#!/bin/bash

set -eu
set -o pipefail

# Function to execute a script and handle errors
run_script() {
    local script=$1
    echo "Executing $script..."
    if ! bash "$script"; then
        echo "Error: $script failed"
        exit 1
    fi
    echo "Completed $script"
    echo "----------------------------------------"
}

# List of scripts to execute in order
SCRIPTS=(
    "00_versions.sh"
    "01_checkout.sh"
    "02_venv.sh"
    "10_build_numpy.sh"
    "11_install_mkl_numpy.sh"
    "21_configure.sh"
    "22_build.sh"
    "23_package.sh"
    "24_install_package.sh"
    "25_test_package.sh"
)

# Execute each script in order
for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        run_script "$script"
    else
        echo "Warning: Script $script not found, skipping..."
    fi
done

echo "All build steps completed successfully!" 