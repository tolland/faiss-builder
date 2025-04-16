import json
import matplotlib.pyplot as plt
from pathlib import Path
import numpy as np

def generate_performance_plot():
    """Generate a performance comparison plot from benchmark results."""
    # Collect all benchmark results
    results_dir = Path('benchmark_results')
    if not results_dir.exists():
        return
    
    build_types = ['cpu', 'cpu_mkl', 'gpu', 'gpu_mkl']
    index_types = ['flat', 'ivf', 'hnsw']
    
    # Create a figure with subplots
    fig, ax = plt.subplots(figsize=(12, 8))
    
    # Plot data for each build type
    x = np.arange(len(index_types))
    width = 0.2
    
    for i, build_type in enumerate(build_types):
        try:
            with open(results_dir / f'benchmark_{build_type}_results.json', 'r') as f:
                data = json.load(f)
                # Look for benchmark data in the 'benchmarks' list
                if 'benchmarks' in data:
                    # Create a dictionary mapping test names to their data
                    benchmark_dict = {}
                    for benchmark in data['benchmarks']:
                        benchmark_dict[benchmark['name']] = benchmark
                    
                    # Extract times for each index type
                    times = []
                    for idx in index_types:
                        test_name = f'test_search_performance[{idx}]'
                        if test_name in benchmark_dict:
                            times.append(benchmark_dict[test_name]['stats']['mean'])
                        else:
                            times.append(0)  # Use 0 for missing data
                    
                    ax.bar(x + i*width, times, width, label=build_type)
        except (FileNotFoundError, KeyError) as e:
            print(f"Error processing {build_type} results: {e}")
            continue
    
    ax.set_xlabel('Index Type')
    ax.set_ylabel('Mean Search Time (seconds)')
    ax.set_title('FAISS Performance Comparison Across Build Types')
    ax.set_xticks(x + width*1.5)
    ax.set_xticklabels(index_types)
    ax.legend()
    ax.grid(True, axis='y', linestyle='--', alpha=0.7)
    
    plt.tight_layout()
    plt.savefig(results_dir / 'performance_comparison.png', dpi=300, bbox_inches='tight')
    plt.close()

if __name__ == '__main__':
    generate_performance_plot() 