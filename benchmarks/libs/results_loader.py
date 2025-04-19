import json
import logging
from collections import defaultdict
from pathlib import Path
from typing import Dict

from benchmarks.libs.const import scales, index_types, build_types

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

def load_benchmark_data(build_type: str) -> Dict:
    """Load benchmark data for a specific build type."""

    root_dir = Path(__file__).resolve().parent
    while not (root_dir / "pyproject.toml").exists() and not (root_dir / ".git").exists():
        if root_dir.parent == root_dir:  # Stop if we reach the filesystem root
            raise FileNotFoundError("Could not find project root marker (e.g., 'pyproject.toml' or '.git').")
        root_dir = root_dir.parent
    results_dir = root_dir / "benchmarks" / "benchmark_results"
    if not results_dir.exists():
        print(f"Error: Benchmark results directory not found at {results_dir}")
        raise FileNotFoundError(f"Benchmark results directory not found: {results_dir}")

    bench_file = results_dir / f"benchmark_{build_type}_results.json"
    if not bench_file.exists():
        raise FileNotFoundError(f"Benchmark file not found: {bench_file}")

    with open(bench_file, "r") as f:
        data = json.load(f)
        if "benchmarks" not in data:
            raise ValueError("Invalid benchmark data format: 'benchmarks' key not found.")

        if not data["benchmarks"]:
            raise ValueError("No benchmarks found in the benchmark data.")

        # # Create a dictionary mapping test names to their data
        # result =  {benchmark["name"]: benchmark for benchmark in data["benchmarks"]}

        # for benchmark in result.values():
        #     # Extract the test name and parameters
        #     test_name = benchmark["name"]
        #     print(f"Processing benchmark: {test_name} fiole: {bench_file}  {benchmark['name']}")
        #     print(f"benchmark results size: {len(benchmark['stats']['data'])}")
        return data

def load_data_into_dicts():
    """Load data into dictionaries for plotting."""

    # Group by scale first, then by build type
    scale_dict = {scale: [] for scale in scales}

    # Load benchmark data for each build type
    cross_test_benchmarks = {
        (
            index_type,
            scale,
        ): {
            "title": f"",
            "benchmarks": [],
        }
        for index_type in index_types
        for scale in scales
    }

    # not sure about why this is like this
    basic_search_data = {scale: [] for scale in scales}

    # dict keyed on the test_method[index_name-scale.name] = benchmark
    benchmark_dict = {}
    benchmarks_dict = defaultdict(lambda: {"benchmarks": []})
    # dict keyed on <build_type, benchmarks>
    build_type_dict = {}

    scale_timing_dict = {scale: [] for scale in scales}

    for build_type in build_types:
        logger.debug(f"Processing build type: {build_type}")
        build_type_dict[build_type] = load_benchmark_data(build_type)
        benchmark_dict = {benchmark["name"]:  benchmark for benchmark in build_type_dict[build_type]["benchmarks"]}

        for benchmark in build_type_dict[build_type]["benchmarks"]:
            tmp_benchmark = benchmark.copy()
            tmp_benchmark.update(benchmark["stats"])
            benchmarks_dict[benchmark["name"]]["benchmarks"].append(benchmark)
            benchmarks_dict[benchmark["name"]]["title"] = benchmark["extra_info"]["title"]

        # reproduce the logic being used for the generic plots
        for scale in scales:
            times = []
            stddevs = []
            for idx in index_types:
                test_name = f"test_search_performance[{idx}-{scale}]"
                if test_name in benchmark_dict:
                    stats = benchmark_dict[test_name]["stats"]
                    times.append(stats["mean"])
                    # Use standard deviation for error bars
                    stddevs.append(stats["stddev"])
                else:
                    times.append(0)
                    stddevs.append(0)
            basic_search_data[scale].append((times, stddevs))

    return basic_search_data,  benchmarks_dict, build_type_dict,
    # end of repro logic
