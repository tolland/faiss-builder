#!/bin/bash

set -eu
set -o pipefail

cd /build

checkout_repo() {
    local REPOSRC=$1
    local LOCALREPO=$2
    local REF=$3

    if [ ! -d "$LOCALREPO" ]; then
        echo "Creating repository at ${REF}"
        git clone --depth 1 \
                    --single-branch \
                    "$REPOSRC" \
                    "$LOCALREPO"
    else
        echo "Repository exists, resetting to tag ${REF}"
    fi

    cd "$LOCALREPO"
    git fetch origin refs/tags/${REF}:refs/tags/${REF}
    git reset --hard ${REF}
    git clean -fdx
    cd /build
}

echo "getting numpy"
checkout_repo "https://github.com/numpy/numpy.git" "/build/numpy" "v2.2.4"

(
    cd numpy
    git submodule update --init --recursive
)

echo "getting faiss"
checkout_repo "https://github.com/facebookresearch/faiss.git" "/build/faiss" "v1.10.0"
