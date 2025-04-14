#!/bin/bash

set -eu
set -o pipefail


git clone \
    --depth 1 \
    --single-branch https://github.com/facebookresearch/faiss.git \
    /faiss
