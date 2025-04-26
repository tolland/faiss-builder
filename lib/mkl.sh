#!/bin/bash

# Source common.sh if not already sourced
[ -z "${COMMON_SOURCED:-""}" ] && source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/common.sh"

# Activate MKL environment with shared libraries
set +u
source "$MKL_ROOT/env/vars.sh"
source "$MKL_COMPILER_ROOT/env/vars.sh"
set -u

# shellcheck disable=SC2034
MKL_SOURCED="true"
