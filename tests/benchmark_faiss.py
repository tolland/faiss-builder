import pytest
import numpy as np
import faiss
import matplotlib.pyplot as plt
import json
from pathlib import Path
import time

def generate_test_data(dim=128, num_vectors=10000, num_queries=1000):
    """Generate random test data."""
    np.random.seed(1234)
    vectors = np.random.random((num_vectors, dim)).astype('float32')
    queries = np.random.random((num_queries, dim)).astype('float32')
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

def run_benchmark(benchmark, dim, num_vectors, num_queries, index_type, k=10):
    """Run a benchmark test."""
    vectors, queries = generate_test_data(dim, num_vectors, num_queries)
    
    def setup():
        index = create_index(dim, vectors, index_type)
        return index, queries, k
    
    def search(index, queries, k):
        D, I = index.search(queries, k)
        return D, I
    
    result = benchmark.pedantic(search, setup=setup, rounds=5, iterations=1)
    return result

@pytest.mark.parametrize("index_type", ['flat', 'ivf', 'hnsw'])
def test_search_performance(benchmark, index_type):
    """Test search performance for different index types."""
    dim = 128
    num_vectors = 10000
    num_queries = 1000
    k = 10
    
    result = run_benchmark(benchmark, dim, num_vectors, num_queries, index_type, k)
    
    # Store benchmark results
    results_dir = Path("benchmark_results")
    results_dir.mkdir(exist_ok=True)
    
    result_data = {
        "index_type": index_type,
        "dim": dim,
        "num_vectors": num_vectors,
        "num_queries": num_queries,
        "k": k,
        "mean_time": benchmark.stats.mean,
        "std_time": benchmark.stats.stdev,
        "min_time": benchmark.stats.min,
        "max_time": benchmark.stats.max,
        "timestamp": time.time()
    }
    
    result_file = results_dir / f"benchmark_{index_type}.json"
    with open(result_file, 'w') as f:
        json.dump(result_data, f, indent=2)

def generate_performance_plot():
    """Generate a performance comparison plot from benchmark results."""
    results_dir = Path("benchmark_results")
    if not results_dir.exists():
        return
    
    # Collect all benchmark results
    results = []
    for result_file in results_dir.glob("benchmark_*.json"):
        with open(result_file, 'r') as f:
            results.append(json.load(f))
    
    if not results:
        return
    
    # Create plot
    plt.figure(figsize=(10, 6))
    
    index_types = [r['index_type'] for r in results]
    mean_times = [r['mean_time'] for r in results]
    std_times = [r['std_time'] for r in results]
    
    plt.bar(index_types, mean_times, yerr=std_times, capsize=5)
    plt.title('FAISS Search Performance Comparison')
    plt.xlabel('Index Type')
    plt.ylabel('Mean Search Time (seconds)')
    plt.grid(True, axis='y', linestyle='--', alpha=0.7)
    
    # Save plot
    plot_path = results_dir / "performance_comparison.png"
    plt.savefig(plot_path, dpi=300, bbox_inches='tight')
    plt.close()

def pytest_sessionfinish(session, exitstatus):
    """Generate performance plot after all tests complete."""
    generate_performance_plot() 