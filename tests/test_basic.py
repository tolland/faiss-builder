from numpy.__config__ import DisplayModes

import faiss
import numpy as np
import sys
import platform

def check_numpy_backend():
    """Check which BLAS/LAPACK implementation NumPy is using."""
    print("\nNumPy Configuration:")
    print(f"Python version: {sys.version}")
    print(f"Platform: {platform.platform()}")
    print(f"NumPy version: {np.__version__}")

    # Check BLAS/LAPACK info
    blas_info = np.show_config(DisplayModes.dicts.value)["Build Dependencies"]["blas"]
    lapack_info = np.show_config(DisplayModes.dicts.value)["Build Dependencies"]["lapack"]

    print("\nBLAS Info:")
    for key, value in blas_info.items():
        print(f"{key}: {value}")

    print("\nLAPACK Info:")
    for key, value in lapack_info.items():
        print(f"{key}: {value}")

    # Check for MKL specifically
    if 'mkl' in str(blas_info).lower() or 'mkl' in str(lapack_info).lower():
        print("\nNumPy is using Intel MKL")
    elif 'openblas' in str(blas_info).lower() or 'openblas' in str(lapack_info).lower():
        print("\nNumPy is using OpenBLAS")
    else:
        print("\nNumPy is using a different BLAS/LAPACK implementation")

# Run the check
check_numpy_backend()

# Create some random vectors
d = 64
nb = 1000
nq = 10
np.random.seed(1234)
xb = np.random.random((nb, d)).astype('float32')
xq = np.random.random((nq, d)).astype('float32')

# Build index
index = faiss.IndexFlatL2(d)
index.add(xb)

# Search
k = 4
D, I = index.search(xq, k)
print('First 5 results of first query:')
print(I[0][:5])
print('Distances:')
print(D[0][:5])