import faiss
import numpy as np

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