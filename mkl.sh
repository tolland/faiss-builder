#!/bin/bash


# Activate MKL environment with shared libraries
set +u
source /opt/intel/oneapi/mkl/2025.1/env/vars.sh
source /opt/intel/oneapi/compiler/2025.1/env/vars.sh
set -u

MKL_SOURCED="true"
