#!/bin/bash

set -eu
set -o pipefail

# Source common functions and variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
source "$SCRIPT_DIR/common.sh"

# Ensure we're in the project root directory
ensure_project_root

# Source versions file
source_versions

# Function to clone or update a repository
checkout_repo() {
    local repo_url="$1"
    local repo_name="$2"
    local version="$3"
    
    if [ ! -d "$repo_name" ]; then
        echo "Cloning $repo_name..."
        git clone --depth 1 --branch "$version" "$repo_url" "$repo_name"
    else
        echo "$repo_name already exists. Checking out $version..."
        (cd "$repo_name" && git fetch --depth 1 origin "$version" && git checkout "$version")
    fi
}

# Checkout NumPy
checkout_repo "$NUMPY_REPO" "numpy" "$NUMPY_VERSION"

# Checkout FAISS
checkout_repo "$FAISS_REPO" "faiss" "$FAISS_VERSION"

echo "Repositories cloned/updated successfully!"