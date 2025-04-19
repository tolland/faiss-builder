import faiss
import numpy as np

# Test GPU resources
res = faiss.StandardGpuResources()
print('GPU resources initialized successfully')

# Test GPU index
d = 64
nb = 1000
nq = 10
np.random.seed(1234)
xb = np.random.random((nb, d)).astype('float32')
xq = np.random.random((nq, d)).astype('float32')

# Build GPU index
index = faiss.IndexFlatL2(d)
gpu_index = faiss.index_cpu_to_gpu(res, 0, index)
gpu_index.add(xb)

# Search on GPU
k = 4
D, I = gpu_index.search(xq, k)
print('GPU search results (first 5):')
print(I[0][:5])
print('GPU search distances:')
print(D[0][:5])
