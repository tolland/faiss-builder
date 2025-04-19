import logging
from pathlib import Path
from typing import Any

import faiss
import numpy as np
import pytest
from numpy import ndarray, dtype

# Use a fixed seed for reproducible benchmark results
RNG = np.random.default_rng(seed=1234)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def generate_test_data(dim=128, num_vectors=10000, num_queries=1000):
    """Generate random test data using a fixed seed."""
    vectors: ndarray[tuple[int, ...], dtype[Any]] = RNG.random((num_vectors, dim)).astype('float32')
    queries = RNG.random((num_queries, dim)).astype('float32')
    return vectors, queries


def create_index(dim, vectors, index_type='flat'):
    """Create and populate an index."""

    if index_type == 'flat':
        index = faiss.IndexFlatL2(dim)

    elif index_type == 'ivf':
        nlist = 100
        quantizer = faiss.IndexFlatL2(dim)
        index = faiss.IndexIVFFlat(quantizer, dim, nlist)
        index.train(vectors)

    elif index_type == 'hnsw':
        index = faiss.IndexHNSWFlat(dim, 32)

    else:
        raise ValueError(f"Unknown index type: {index_type}")

    index.add(vectors)
    return index

@pytest.mark.benchmark(
    group="generic-performance-comparison",
)
@pytest.mark.parametrize("scale", [
    {'num_vectors': 4000, 'num_queries': 100, 'dim': 16, 'k': 5, 'name': 'smoke'},
    {'num_vectors': 10000, 'num_queries': 1000, 'dim': 128, 'k': 10, 'name': 'small'},
    {'num_vectors': 20000, 'num_queries': 4000, 'dim': 128, 'k': 10, 'name': 'medium'},
    # {'num_vectors': 1000000, 'num_queries': 100000, 'dim': 128, 'k': 10, 'name': 'large'}, # Optional: Comment out large
], ids=lambda x: f"{x['name']}")  # Existing ids logic
@pytest.mark.parametrize("index_type", ['flat', 'ivf', 'hnsw'])
def test_search_performance(benchmark, index_type, scale, build_type):
    """Test search performance for different index types."""
    # Update ids to include build_type
    test_name = f"{build_type}-{index_type}-{scale['name']}"
    pytest.current_test_name = test_name  # Store the name for debugging/logging if needed

    benchmark.extra_info["test_name"] = test_name
    benchmark.extra_info["title"] = f"FAISS Performance Comparison: {index_type} - (size: {scale['name']})"
    benchmark.extra_info["build_type"] = build_type
    benchmark.extra_info["index_type"] = index_type
    benchmark.extra_info["scale"] = scale

    logger.debug(f"Starting test: {build_type}-{index_type}-{scale['name']}")
    logger.debug(f"Scale parameters: {scale}")

    # Generate test data
    vectors, queries = generate_test_data(
        dim=scale['dim'],
        num_vectors=scale['num_vectors'],
        num_queries=scale['num_queries']
    )
    logger.info(f"Generated {vectors.shape[0]} vectors and {queries.shape[0]} queries.")

    # ADDED Check: Skip if vectors generation resulted in 0 vectors
    if vectors.shape[0] == 0:
        pytest.skip(f"Skipping {index_type}/{scale['name']} due to zero vectors")
        return

    try: # ADDED Try/Except for potential index creation errors with small data
        index = create_index(scale['dim'], vectors, index_type)
        logger.info(f"Created {index_type} index with {index.ntotal} vectors.")
    except ValueError as e:
        logger.warning(f"Index creation failed for {index_type}/{scale['name']}: {e}")
        pytest.skip(f"Skipping {index_type}/{scale['name']} due to index creation error: {e}")
        return

    # Run benchmark
    def search():
        # ADDED Check: Ensure k is valid and index has vectors
        actual_k = min(scale['k'], index.ntotal)
        if queries.shape[0] > 0 and actual_k > 0 and index.ntotal > 0:
            D, I = index.search(queries, actual_k)
            # logger.debug(f"Search completed. Top distances: {D[:5]}")
            return D, I
        else:
            logger.warning(f"Search skipped due to invalid parameters (ntotal={index.ntotal}, k={scale['k']}, nq={queries.shape[0]})")
            # Return something or handle the non-search case
            return None, None

    # ADDED Check: Only benchmark if a search is possible
    if index.ntotal > 0 and scale['k'] > 0 and queries.shape[0] > 0:
        benchmark.extra_info.update({"params": scale, "index_type": index_type})
        benchmark(search)
    else:
        logger.warning(f"Skipping benchmark for {index_type}/{scale['name']} (ntotal={index.ntotal}, k={scale['k']}, nq={queries.shape[0]})")
        # You might want to benchmark a dummy function here if pytest-benchmark requires it
        benchmark(lambda: None)

    # Ensure benchmark_results directory exists
    # Plotting and detailed JSON handling is done in gener  ate_plot.py
    results_dir = Path("benchmark_results")
    results_dir.mkdir(exist_ok=True)

# These tests are designed to specifically favor CPU or GPU implementations
# or to test MKL performance

@pytest.mark.benchmark(
    group="specific-performance-comparison",
)
@pytest.mark.parametrize("scale", [
    {'num_vectors': 1000, 'num_queries': 100, 'dim': 128, 'k': 5, 'name': 'smoke', 'log': False},
    {'num_vectors': 10000, 'num_queries': 100, 'dim': 128, 'k': 5, 'name': 'small', 'log': False},
    {'num_vectors': 100000, 'num_queries': 1000, 'dim': 128, 'k': 5, 'name': 'medium', 'log': False},
    {'num_vectors': 1000000, 'num_queries': 10000, 'dim': 128, 'k': 5, 'name': 'large', 'log': True},
], ids=lambda x: f"{x['name']}")
def test_favor_cpu_with_mkl_flatl2(benchmark, scale,build_type):
    """Test that should favor CPU with MKL over GPU.
    Uses a simple flat index with L2 distance, which is well-optimized for CPU.
    Flat Index (IndexFlatL2): Best for small datasets or exact search. CPU (especially with MKL
    or AVX2) outperforms GPU unless query count is very high.
    """

    benchmark.extra_info["title"] = f"Test that should favor CPU with MKL over GPU - (size: {scale['name']})"

    benchmark.extra_info["build_type"] = build_type

    def favor_cpu_with_mkl():
        if scale['log']:
            logger.info(f"Running search with k={scale['k']} on IndexFlatL2 index.")
        index = faiss.IndexFlatL2(scale['dim'])
        xb = RNG.random((scale['num_vectors'], scale['dim'])).astype('float32')
        xq = RNG.random((scale['num_queries'], scale['dim'])).astype('float32')
        index.add(xb)
        index.search(xq, scale['k'])

    benchmark(favor_cpu_with_mkl)

@pytest.mark.benchmark(
    group="specific-performance-comparison",
)
@pytest.mark.parametrize("scale", [
    {'num_vectors': 10000, 'num_queries': 1000, 'dim': 128, 'k': 5, 'name': 'smoke', 'log': False},
    {'num_vectors': 100000, 'num_queries': 10000, 'dim': 128, 'k': 5, 'name': 'small', 'log': False},
    {'num_vectors': 1000000, 'num_queries': 1000, 'dim': 128, 'k': 5, 'name': 'medium', 'log': False},
    {'num_vectors': 1000000, 'num_queries': 1000, 'dim': 128, 'k': 5, 'name': 'large', 'log': True},
], ids=lambda x: x['name'])
def test_favor_gpu_with_scale_ivf(benchmark, scale, build_type):
    """Test that should favor GPU over CPU.
    Uses IVF index with large dataset to leverage GPU's parallel processing capabilities."""

    benchmark.extra_info["title"] = f"Test that should favor GPU over CPU."
    benchmark.extra_info["build_type"] = build_type

    def favor_gpu_with_scale_ivf():
        if scale['log']:
            logger.info(f"Running search with k={scale['k']} on IndexIVFFlat index.")
        quantizer = faiss.IndexFlatL2(scale['dim'])
        index = faiss.IndexIVFFlat(quantizer, scale['dim'], 100)
        xb = RNG.random((scale['num_vectors'], scale['dim'])).astype('float32')
        xq = RNG.random((scale['num_queries'], scale['dim'])).astype('float32')
        index.train(xb)
        index.add(xb)
        index.search(xq, scale['k'])

    benchmark(favor_gpu_with_scale_ivf)

@pytest.mark.parametrize("scale", [
    {'num_vectors': 10000, 'num_queries': 1000, 'dim': 128, 'k': 5, 'name': 'small', 'log': False},
    {'num_vectors': 100000, 'num_queries': 10000, 'dim': 128, 'k': 5, 'name': 'medium', 'log': False},
    {'num_vectors': 1000000, 'num_queries': 100000, 'dim': 128, 'k': 5, 'name': 'large', 'log': True},
], ids=lambda x: x['name'])
def test_slight_cpu_advantage_hnsw(benchmark, scale,build_type):
    """Test that should show slight CPU advantage.
    Uses HNSW index which can benefit from CPU's better memory access patterns."""

    benchmark.extra_info["title"] = f"Test that should show slight CPU advantage."
    benchmark.extra_info["build_type"] = build_type

    def slight_cpu_advantage_hnsw():
        if scale['log']:
            logger.info(f"Running search with k={scale['k']} on IndexHNSWFlat index.")
        index = faiss.IndexHNSWFlat(scale['dim'], 32)
        xb = RNG.random((scale['num_vectors'], scale['dim'])).astype('float32')
        xq = RNG.random((scale['num_queries'], scale['dim'])).astype('float32')
        index.add(xb)
        index.search(xq, scale['k'])

    benchmark(slight_cpu_advantage_hnsw)

@pytest.mark.parametrize("scale", [
    {'num_vectors': 50000, 'num_queries': 200, 'dim': 128, 'k': 5, 'name': 'small', 'log': False},
    {'num_vectors': 500000, 'num_queries': 2000, 'dim': 128, 'k': 5, 'name': 'medium', 'log': False},
    {'num_vectors': 5000000, 'num_queries': 20000, 'dim': 128, 'k': 5, 'name': 'large', 'log': True},
], ids=lambda x: x['name'])
def test_favor_gpu_cpu_should_struggle(benchmark, scale, build_type):
    """Test that should strongly favor GPU.
    Uses IVFPQ index which is computationally intensive and benefits from GPU's parallel processing."""

    benchmark.extra_info["title"] = f"Test that should strongly favor GPU."
    benchmark.extra_info["build_type"] = build_type

    def favor_gpu_cpu_should_struggle():
        if scale['log']:
            logger.info(f"Running search with k={scale['k']} on IndexIVFPQ index.")
        quantizer = faiss.IndexFlatL2(scale['dim'])
        index = faiss.IndexIVFPQ(quantizer, scale['dim'], 16, 8, 8)
        xb = RNG.random((scale['num_vectors'], scale['dim'])).astype('float32')
        xq = RNG.random((scale['num_queries'], scale['dim'])).astype('float32')
        index.train(xb)
        index.add(xb)
        index.search(xq, scale['k'])

    benchmark(favor_gpu_cpu_should_struggle)
