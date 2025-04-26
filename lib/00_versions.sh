#!/bin/bash

set -eu
set -o pipefail

# Source common functions and variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

_FORCE_STEPS=$1

source "$SCRIPT_DIR/common.sh"

# Ensure we're in the project root directory
ensure_project_root

# Check for existing versions file
if [ -f "versions.txt" ] && [ "${_FORCE_STEPS}" != true ]; then
    echo "versions.txt already exists. Use --force to overwrite."
    exit 0
fi

# Function to get latest stable version from GitHub API
get_latest_stable_version() {
    local repo=$1
    local api_url="https://api.github.com/repos/${repo}/releases/latest"
    local version

    # Try to get the latest release
    version=$(curl -s "$api_url" | grep -oP '"tag_name": "\K[^"]*')

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
cat > "${PROJECT_ROOT}/versions.txt" << EOF
NUMPY_VERSION=$NUMPY_VERSION
FAISS_VERSION=$FAISS_VERSION
EOF
