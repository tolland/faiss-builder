import faiss
import numpy as np

xb = np.random.rand(10000, 128).astype('float32')
xq = np.random.rand(100, 128).astype('float32')

indexes = [
    faiss.IndexFlatL2(128),
    faiss.IndexFlatIP(128),
    faiss.IndexIVFFlat(faiss.IndexFlatL2(128), 128, 100),
    faiss.IndexIVFPQ(faiss.IndexFlatL2(128), 128, 100, 16, 8),
    faiss.IndexPQ(128, 16, 8),
    faiss.IndexHNSWFlat(128, 32),
]

for index in indexes:
    index.train(xb)
    index.add(xb)
    D, I = index.search(xq, 5)