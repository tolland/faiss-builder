#!/bin/bash

set -eu
set -o pipefail

# Source common functions
source "$(dirname "$0")/common.sh"
ensure_script_dir
source_versions

checkout_repo() {
    local REPOSRC=$1
    local LOCALREPO=$2
    local REF=$3

    if [ ! -d "$LOCALREPO" ]; then
        run_command "git clone --depth 1 --single-branch \"$REPOSRC\" \"$LOCALREPO\"" "Cloning $REPOSRC"
    else
        echo "Repository exists, resetting to tag ${REF}"
        cd "$LOCALREPO"
        run_command "git fetch origin refs/tags/${REF}:refs/tags/${REF}" "Fetching tag ${REF}"
        run_command "git reset --hard ${REF}" "Resetting to ${REF}"
        # run_command "git clean -fdx" "Cleaning repository"
        cd "$SCRIPT_DIR"
    fi
}

echo "getting numpy"
checkout_repo "https://github.com/numpy/numpy.git" "$SCRIPT_DIR/numpy" "$NUMPY_VERSION"

(
    cd "$SCRIPT_DIR/numpy"
    run_command "git submodule update --init --recursive" "Updating numpy submodules"
)

echo "getting faiss"
checkout_repo "https://github.com/facebookresearch/faiss.git" "$SCRIPT_DIR/faiss" "$FAISS_VERSION"

# Verify that both repositories exist and are siblings
verify_repositories

echo "Checkout completed successfully" 