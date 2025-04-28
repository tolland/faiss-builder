#!/bin/bash

set -eu
set -o pipefail

# Rops
# shellcheck disable=SC2034
NUMPY_REPO="https://github.com/numpy/numpy.git"
# shellcheck disable=SC2034
FAISS_REPO="https://github.com/facebookresearch/faiss.git"

# MKL paths and settings
MKL_ROOT="/opt/intel/oneapi/mkl/2025.1"
MKL_COMPILER_ROOT="/opt/intel/oneapi/compiler/2025.1"
TBB_ROOT="/opt/intel/oneapi/tbb/2022.1"

# MKL Libraries
export MKL_LIBRARIES=(
  "$MKL_COMPILER_ROOT/lib/libiomp5.so"
  "$MKL_ROOT/lib/intel64/libmkl_intel_lp64.so"
  "$MKL_ROOT/lib/intel64/libmkl_intel_lp64.so.2"
  "$MKL_ROOT/lib/libmkl_core.so"
  "$MKL_ROOT/lib/libmkl_core.so.2"
  "$MKL_ROOT/lib/libmkl_gf_lp64.so"
  "$MKL_ROOT/lib/libmkl_gf_lp64.so.2"
  "$MKL_ROOT/lib/libmkl_gnu_thread.so"
  "$MKL_ROOT/lib/libmkl_gnu_thread.so.2"
  "$MKL_ROOT/lib/libmkl_intel_lp64.so"
  "$MKL_ROOT/lib/libmkl_intel_lp64.so.2"
  "$MKL_ROOT/lib/libmkl_intel_thread.so"
  "$MKL_ROOT/lib/libmkl_intel_thread.so.2"
  "$MKL_ROOT/lib/libmkl_tbb_thread.so"
  "$MKL_ROOT/lib/libmkl_tbb_thread.so.2"
  "$TBB_ROOT/lib/libtbb.so"
  "$TBB_ROOT/lib/libtbb.so.12"
  "$TBB_ROOT/lib/libtbb.so.12.15"
)

# Build settings
export CMAKE_BUILD_TYPE="Debug"
export FAISS_OPT_LEVEL="avx2"
export CUDA_ARCHITECTURES="80;86;89;90"
# NUM_PROCS="$(( $(nproc) / 2 ))"
NUM_PROCS="${NUM_PROCS:-$(( $(nproc) / 2 ))}"

# Get the directory where this script is located and the project root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
LIB_DIR="$PROJECT_ROOT/lib"

# Virtual environment paths
SUBDIR_SRCS="build/srcs"
SUBDIR_VENVS="build/venvs"
SUBDIR_NUMPY_DISTS="build/dists"
SUBDIR_FAISS_DISTS="build/dists"
NUMPY_SRC="$PROJECT_ROOT/${SUBDIR_SRCS}/numpy"
FAISS_SRC="$PROJECT_ROOT/${SUBDIR_SRCS}/faiss"
NUMPY_DISTS="$PROJECT_ROOT/${SUBDIR_NUMPY_DISTS}"
FAISS_DISTS="$PROJECT_ROOT/${SUBDIR_FAISS_DISTS}"
mkdir -p "${SUBDIR_SRCS}"
mkdir -p "${SUBDIR_VENVS}"
mkdir -p "${NUMPY_DISTS}"
mkdir -p "${FAISS_DISTS}"
# Build directories
NUMPY_DIST_DIR="$PROJECT_ROOT/${SUBDIR_NUMPY_DISTS}/numpy"
NUMPY_DIST_DIR_MKL="$PROJECT_ROOT/${SUBDIR_NUMPY_DISTS}/numpy_mkl"
NUMPY_VENV_DIR="$PROJECT_ROOT/$SUBDIR_VENVS/numpy_venv${DEV_LOCAL:-""}"
NUMPY_MKL_VENV_DIR="$PROJECT_ROOT/$SUBDIR_VENVS/numpy_mkl_venv${DEV_LOCAL:-""}"

# Function to get the NumPy venv directory based on build type
get_numpy_venv_dir() {
    local build_type="$1"
    case "$build_type" in
        "numpy")
            echo "$NUMPY_VENV_DIR"
            ;;
        "numpy_mkl")
            echo "$NUMPY_MKL_VENV_DIR"
            ;;
        *)
            echo "Error: Invalid NumPy build type '$build_type'" >&2
            exit 1
            ;;
    esac
}

# Function to get the dist directory
get_numpy_dist_dir() {
    local build_type="$1"
    case "$build_type" in
        "numpy")
            echo "$NUMPY_DIST_DIR"
            ;;
        "numpy_mkl")
            echo "$NUMPY_DIST_DIR_MKL"
            ;;
        *)
            echo "Error: Invalid NumPy build type '$build_type'" >&2
            exit 1
            ;;
    esac
}

get_numpy_wheel_prefix() {
    local build_type="$1"
    case "${build_type}" in
        "numpy")
            echo "numpy"
            ;;
        "numpy_mkl")
            echo "numpy_mkl"
            ;;
        *)
            echo "Error: Invalid NumPy build type '$build_type'" >&2
            exit 1
            ;;
    esac
}

# Function to get the FAISS venv directory based on build type
get_faiss_venv_dir() {
    local numpy_build_type="$1"
    local faiss_build_type="$2"
    echo "$PROJECT_ROOT/$SUBDIR_VENVS/venv_${numpy_build_type}_${faiss_build_type}${DEV_LOCAL:-""}"
}

# Function to get the FAISS dist dir
get_faiss_dist_dir() {
    local numpy_build_type="$1"
    local faiss_build_type="$2"
    # echo "${FAISS_DISTS}/faiss_${numpy_build_type}_${faiss_build_type}"
    echo "${FAISS_DISTS}"
}



# Build directories (this is relative, should be fully qualified?)
get_faiss_build_dir() {
    local numpy_build_type="$1"
    local faiss_build_type="$2"
    echo "_build_${numpy_build_type}_${faiss_build_type}"
}

# Function to determine if MKL should be sourced based on build type
needs_mkl() {
    local build_type="$1"
    echo "checking build type $build_type" >&2
    if [[ "$build_type" == *"_mkl"* || "$build_type" == *"mkl"* ]]; then
      echo "returning 0" >&2
        return 0
    else
        return 1
    fi
}

# Function to source MKL if needed
source_mkl_if_needed() {
    local build_type="$1"
    if needs_mkl "$build_type" && [ -z "${MKL_SOURCED:-""}" ]; then
        echo "sourcing mkl"
        source "$LIB_DIR/mkl.sh"
    else
      echo "not sourcing mkl"
    fi
}

# get preferred numpy from faiss build type
get_numpy_build_type() {
    local build_type="$1"
    case "${build_type}" in
        "cpu")
            echo "numpy"
            ;;
        "cpu_mkl")
            echo "numpy_mkl"
            ;;
        "gpu")
            echo "numpy"
            ;;
        "gpu_mkl")
            echo "numpy_mkl"
            ;;
        *)
            echo "Error: Invalid build type 'build_type'"
            echo "Valid build types: cpu, cpu_mkl, gpu, gpu_mkl"
            exit 1
            ;;
    esac
}

get_faiss_package_name() {
    local build_type="$1"
    case "${build_type}" in
        "cpu")
            echo "faiss-cpu"
            ;;
        "cpu_mkl")
            echo "faiss-cpu-mkl"
            ;;
        "gpu")
            echo "faiss-gpu"
            ;;
        "gpu_mkl")
            echo "faiss-gpu-mkl"
            ;;
        *)
            echo "Error: Invalid build type 'build_type'"
            echo "Valid build types: cpu, cpu_mkl, gpu, gpu_mkl"
            exit 1
            ;;
    esac
}

get_faiss_wheel_prefix() {
    local build_type="$1"
    case "${build_type}" in
        "cpu")
            echo "faiss_cpu"
            ;;
        "cpu_mkl")
            echo "faiss_cpu_mkl"
            ;;
        "gpu")
            echo "faiss_gpu"
            ;;
        "gpu_mkl")
            echo "faiss_gpu_mkl"
            ;;
        *)
            echo "Error: Invalid build type 'build_type'"
            echo "Valid build types: cpu, cpu_mkl, gpu, gpu_mkl"
            exit 1
            ;;
    esac
}


# Flag to indicate common.sh has been sourced
export COMMON_SOURCED="true"

echo "PROJECT ROOT: $PROJECT_ROOT"

# Function to ensure we're in the project root directory
ensure_project_root() {
    cd "$PROJECT_ROOT"
}

# Function to source the versions file
source_versions() {
    if [ -f "$PROJECT_ROOT/versions.txt" ]; then
        source "$PROJECT_ROOT/versions.txt"
    else
        echo "Error: versions.txt not found. Please run lib/00_versions.sh first."
        exit 1
    fi
}

# Function to verify numpy and faiss exist as siblings
verify_repositories() {
    if [ ! -d "${NUMPY_SRC}" ] || [ ! -d "${FAISS_SRC}" ]; then
        echo "Error: Required repositories not found. Please run lib/01_checkout.sh first."
        exit 1
    fi
}

# Function to run a command and handle errors
run_command() {
    local cmd="$1"
    local description="${2:-$cmd}"

    echo "Running: $description"
    if ! eval "$cmd"; then
        echo "Error: Failed to execute: $description"
        exit 1
    fi
}

# Function to create and setup a virtual environment
setup_venv() {
    local venv_dir="$1"
    local requirements_file="${2:-}"

    if [ ! -d "$venv_dir" ]; then
        run_command "python3 -m venv \"$venv_dir\"" "Creating virtual environment in $venv_dir"
    fi

    # Activate the virtual environment
    source "$venv_dir/bin/activate"

    # Install requirements if specified
    if [ -n "$requirements_file" ] && [ -f "$requirements_file" ]; then
        run_command "pip install -r \"$requirements_file\"" "Installing requirements from $requirements_file"
    fi
}

# Function to activate a virtual environment
activate_venv() {
    local venv_dir="$1"
    if [ ! -d "$venv_dir" ]; then
        echo "Error: Virtual environment $venv_dir does not exist"
        exit 1
    else
        echo "Activating virtual environment: $venv_dir"
    fi
    source "$venv_dir/bin/activate"
}

# Function to deactivate a virtual environment
# shellcheck disable=SC2120
deactivate() {
    if [ -n "${_OLD_VIRTUAL_PATH:-}" ]; then
        PATH="${_OLD_VIRTUAL_PATH:-}";
        export PATH;
        unset _OLD_VIRTUAL_PATH;
    fi;
    if [ -n "${_OLD_VIRTUAL_PYTHONHOME:-}" ]; then
        PYTHONHOME="${_OLD_VIRTUAL_PYTHONHOME:-}";
        export PYTHONHOME;
        unset _OLD_VIRTUAL_PYTHONHOME;
    fi;
    hash -r 2> /dev/null;
    if [ -n "${_OLD_VIRTUAL_PS1:-}" ]; then
        PS1="${_OLD_VIRTUAL_PS1:-}";
        export PS1;
        unset _OLD_VIRTUAL_PS1;
    fi;
    unset VIRTUAL_ENV;
    unset VIRTUAL_ENV_PROMPT;
    if [ ! "${1:-}" = "nondestructive" ]; then
        unset -f deactivate;
    fi
}

# Function to check if a virtual environment is active and deactivate it
check_venv_active() {
    if [ -n "${VIRTUAL_ENV:-}" ]; then
        echo "Deactivating current virtual environment: $VIRTUAL_ENV"
        deactivate
    fi
}
