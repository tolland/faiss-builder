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

@pytest.mark.parametrize("index_type", ['flat', 'ivf', 'hnsw'])
def test_search_performance(benchmark, index_type):
    """Test search performance for different index types."""
    dim = 128
    num_vectors = 10000
    num_queries = 1000
    k = 10
    
    # Generate test data
    vectors, queries = generate_test_data(dim, num_vectors, num_queries)
    
    # Create index
    index = create_index(dim, vectors, index_type)
    
    # Run benchmark
    def search():
        D, I = index.search(queries, k)
        return D, I
    
    benchmark(search)
    
    # Store benchmark results
    results_dir = Path("benchmark_results")
    results_dir.mkdir(exist_ok=True)
    
    # Access benchmark properties safely
    try:
        mean_time = getattr(benchmark, "mean", None)
        if mean_time is None and hasattr(benchmark, "stats"):
            mean_time = benchmark.stats.mean
        
        std_time = getattr(benchmark, "stddev", None)
        if std_time is None and hasattr(benchmark, "stats"):
            std_time = benchmark.stats.stddev
            
        min_time = getattr(benchmark, "min", None)
        if min_time is None and hasattr(benchmark, "stats"):
            min_time = benchmark.stats.min
            
        max_time = getattr(benchmark, "max", None)
        if max_time is None and hasattr(benchmark, "stats"):
            max_time = benchmark.stats.max
    except Exception as e:
        print(f"Debug - Error accessing benchmark stats: {e}")
        print(f"Debug - Benchmark attributes: {dir(benchmark)}")
        if hasattr(benchmark, "stats"):
            print(f"Debug - Stats attributes: {dir(benchmark.stats)}")
        mean_time = 0
        std_time = 0
        min_time = 0
        max_time = 0
    
    result_data = {
        "index_type": index_type,
        "dim": dim,
        "num_vectors": num_vectors,
        "num_queries": num_queries,
        "k": k,
        "mean_time": mean_time,
        "std_time": std_time,
        "min_time": min_time,
        "max_time": max_time,
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