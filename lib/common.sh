#!/bin/bash

# Get the directory where this script is located and the project root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
LIB_DIR="$PROJECT_ROOT/lib"

# Rops
# shellcheck disable=SC2034
NUMPY_REPO="https://github.com/numpy/numpy.git"
# shellcheck disable=SC2034
FAISS_REPO="https://github.com/facebookresearch/faiss.git"

# Virtual environment paths
SUBDIR_SRCS="build/srcs"
SUBDIR_VENVS="build/venvs"
SUBDIR_NUMPY_DISTS="build/dists"
SUBDIR_FAISS_DISTS="build/dists"
NUMPY_SRC="$PROJECT_ROOT/${SUBDIR_SRCS}/numpy"
FAISS_SRC="$PROJECT_ROOT/${SUBDIR_SRCS}/faiss"
NUMPY_DISTS="$PROJECT_ROOT/${SUBDIR_NUMPY_DISTS}"
mkdir -p "${SUBDIR_SRCS}"
mkdir -p "${SUBDIR_VENVS}"
mkdir -p "${NUMPY_DISTS}"
FAISS_DISTS="$PROJECT_ROOT/${SUBDIR_FAISS_DISTS}"
mkdir -p "${FAISS_DISTS}"
# Build directories
NUMPY_DIST_DIR="$PROJECT_ROOT/${SUBDIR_NUMPY_DISTS}/dist_numpy"
NUMPY_DIST_DIR_MKL="$PROJECT_ROOT/${SUBDIR_NUMPY_DISTS}/dist_numpy_mkl"
NUMPY_VENV_DIR="$PROJECT_ROOT/$SUBDIR_VENVS/numpy_venv${DEV_LOCAL:-""}"
NUMPY_MKL_VENV_DIR="$PROJECT_ROOT/$SUBDIR_VENVS/numpy_mkl_venv${DEV_LOCAL:-""}"
FAISS_CPU_VENV_DIR="$PROJECT_ROOT/$SUBDIR_VENVS/faiss_cpu_venv${DEV_LOCAL:-""}"
FAISS_CPU_MKL_VENV_DIR="$PROJECT_ROOT/$SUBDIR_VENVS/faiss_cpu_mkl_venv${DEV_LOCAL:-""}"
FAISS_GPU_VENV_DIR="$PROJECT_ROOT/$SUBDIR_VENVS/faiss_gpu_venv${DEV_LOCAL:-""}"
FAISS_GPU_MKL_VENV_DIR="$PROJECT_ROOT/$SUBDIR_VENVS/faiss_gpu_mkl_venv${DEV_LOCAL:-""}"

FAISS_CPU_DIST_DIR="${FAISS_DISTS}/faiss_cpu"
FAISS_CPU_MKL_DIST_DIR="${FAISS_DISTS}/faiss_cpu_mkl"
FAISS_GPU_DIST_DIR="${FAISS_DISTS}/faiss_gpu"
FAISS_GPU_MKL_DIST_DIR="${FAISS_DISTS}/faiss_gpu_mkl"

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

# Function to get the FAISS venv directory based on build type
get_faiss_venv_dir() {
    local build_type="$1"
    case "$build_type" in
        "cpu")
            echo "$FAISS_CPU_VENV_DIR"
            ;;
        "cpu_mkl")
            echo "$FAISS_CPU_MKL_VENV_DIR"
            ;;
        "gpu")
            echo "$FAISS_GPU_VENV_DIR"
            ;;
        "gpu_mkl")
            echo "$FAISS_GPU_MKL_VENV_DIR"
            ;;
        *)
            echo "Error: Invalid FAISS build type '$build_type'" >&2
            exit 1
            ;;
    esac
}

# Function to get the FAISS dist dir
get_faiss_dist_dir() {
    local build_type="$1"
    case "$build_type" in
        "cpu")
            echo "${FAISS_CPU_DIST_DIR}"
            ;;
        "cpu_mkl")
            echo "${FAISS_CPU_MKL_DIST_DIR}"
            ;;
        "gpu")
            echo "${FAISS_GPU_DIST_DIR}"
            ;;
        "gpu_mkl")
            echo "${FAISS_GPU_MKL_DIST_DIR}"
            ;;
        *)
            echo "Error: Invalid FAISS build type '$build_type'" >&2
            exit 1
            ;;
    esac
}

# Function to determine if MKL should be sourced based on build type
needs_mkl() {
    local build_type="$1"
    echo "checking build type $build_type"
    if [[ "$build_type" == *"_mkl"* || "$build_type" == *"mkl"* ]]; then
        return 0  # true in bash
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

# Build directories
CPU_BUILD_DIR="_build_cpu"
CPU_MKL_BUILD_DIR="_build_cpu_mkl"
GPU_BUILD_DIR="_build_gpu"
GPU_MKL_BUILD_DIR="_build_gpu_mkl"

# MKL paths and settings
MKL_ROOT="/opt/intel/oneapi/mkl/2025.1"
MKL_COMPILER_ROOT="/opt/intel/oneapi/compiler/2025.1"
TBB_ROOT="/opt/intel/oneapi/tbb/2022.1"

# MKL Libraries
MKL_LIBRARIES=(
  "$MKL_ROOT/lib/libmkl_intel_lp64.so"
  "$MKL_ROOT/lib/libmkl_tbb_thread.so"
  "$MKL_ROOT/lib/libmkl_gnu_thread.so"
  "$MKL_ROOT/lib/libmkl_core.so"
  "$MKL_ROOT/lib/libmkl_intel_thread.so"
  "$MKL_ROOT/lib/intel64/libmkl_intel_lp64.so"
  "$MKL_COMPILER_ROOT/lib/libiomp5.so"
  "$MKL_ROOT/lib/libmkl_gf_lp64.so"
  "$TBB_ROOT/lib/libtbb.so"
)

# Build settings
CMAKE_BUILD_TYPE="Debug"
FAISS_OPT_LEVEL="avx2"
CUDA_ARCHITECTURES="80;86;89;90"
# NUM_PROCS="$(( $(nproc) / 2 ))"
NUM_PROCS="${NUM_PROCS:-$(( $(nproc) / 2 ))}"

# Flag to indicate common.sh has been sourced
COMMON_SOURCED="true"

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
        type -a deactivate
        deactivate
    fi
}