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
    
    # Also save individual benchmark JSON files for each index type
    for i, build_type in enumerate(build_types):
        try:
            bench_file = results_dir / f'benchmark_{build_type}_results.json'
            if not bench_file.exists():
                continue
                
            with open(bench_file, 'r') as f:
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
                            # Use mean time from benchmark data
                            mean_time = benchmark_dict[test_name]['stats']['mean']
                            times.append(mean_time)
                            
                            # Also save individual benchmark file for this index type
                            idx_data = {
                                "index_type": idx,
                                "dim": 128,  # These are constants in the benchmark_faiss.py
                                "num_vectors": 10000,
                                "num_queries": 1000,
                                "k": 10,
                                "mean_time": mean_time,
                                "std_time": benchmark_dict[test_name]['stats']['stddev'],
                                "min_time": benchmark_dict[test_name]['stats']['min'],
                                "max_time": benchmark_dict[test_name]['stats']['max'],
                                "timestamp": data.get('datetime', '')
                            }
                            
                            # Write individual benchmark file
                            with open(results_dir / f"benchmark_{idx}.json", 'w') as f:
                                json.dump(idx_data, f, indent=2)
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