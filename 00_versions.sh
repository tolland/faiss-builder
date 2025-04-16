#!/bin/bash

set -eu
set -o pipefail

# Source common functions
[ -z "${COMMON_SOURCED:-""}" ] && source common.sh
ensure_script_dir

# Function to get latest stable version from GitHub API
get_latest_stable_version() {
    local repo=$1
    local api_url="https://api.github.com/repos/${repo}/releases/latest"

    # Try to get the latest release
    local version=$(curl -s "$api_url" | grep -oP '"tag_name": "\K[^"]*')

    # If no releases found, try to get the latest tag
    if [ -z "$version" ]; then
        local tags_url="https://api.github.com/repos/${repo}/tags"
        version=$(curl -s "$tags_url" | grep -oP '"name": "\K[^"]*' | grep -v "rc" | grep -v "beta" | grep -v "alpha" | head -n 1)
    fi

    echo "$version"
}

# Get latest stable versions
echo "Fetching latest stable versions..."

NUMPY_VERSION=$(get_latest_stable_version "numpy/numpy")
FAISS_VERSION=$(get_latest_stable_version "facebookresearch/faiss")

# Validate versions
if [ -z "$NUMPY_VERSION" ] || [ -z "$FAISS_VERSION" ]; then
    echo "Error: Could not determine stable versions"
    exit 1
fi

echo "Latest stable versions:"
echo "Numpy: $NUMPY_VERSION"
echo "Faiss: $FAISS_VERSION"

# Export versions for use in other scripts
export NUMPY_VERSION
export FAISS_VERSION

# Create versions file for reference
cat > "$SCRIPT_DIR/versions.txt" << EOF
NUMPY_VERSION=$NUMPY_VERSION
FAISS_VERSION=$FAISS_VERSION
EOF
