#!/bin/bash

set -eu
set -o pipefail

# Source common functions and variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
source "$SCRIPT_DIR/common.sh"

# Ensure we're in the project root directory
ensure_project_root

# Check for existing versions file
if [ -f "versions.txt" ] && [ "${1:-}" != "--force" ]; then
    echo "versions.txt already exists. Use --force to overwrite."
    exit 0
fi

# Initialize versions file
cat > "versions.txt" << EOF
# Repository versions
# Generated on $(date)

# NumPy version
NUMPY_REPO="https://github.com/numpy/numpy.git"
NUMPY_VERSION="v2.1.0"

# FAISS version
FAISS_REPO="https://github.com/facebookresearch/faiss.git"
FAISS_VERSION="v1.7.4"
EOF

echo "Created versions.txt file:"
cat "versions.txt"

# Source the newly created versions file
source_versions

# Print configuration
echo "============================================================"
echo "NumPy: $NUMPY_REPO @ $NUMPY_VERSION"
echo "FAISS: $FAISS_REPO @ $FAISS_VERSION"
echo "============================================================"