from benchmarks.libs.const import scales, build_types
from benchmarks.libs.results_loader import load_benchmark_data
from benchmarks.libs.specialized_plot import create_specialized_plot
import json
from pathlib import Path
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np

def generate_specialized_plots(benchmarks_dict):

    charts_dir = Path(__file__).resolve().parent.parent / "charts"

    #     # 3. Specialized test cases
    specialized_tests = [
        "test_favor_cpu_with_mkl_flatl2",
        "test_favor_gpu_with_scale_ivf",
        "test_slight_cpu_advantage_hnsw",
        "test_favor_gpu_cpu_should_struggle",
    ]
    #
    #     for test_name in specialized_tests:
    #         # Group by scale
    test_data = {scale: [] for scale in scales}

    # for test_name in benchmarks_dict:
        # Group by scale

    for test_name_base in specialized_tests:
        test_data = {scale: [] for scale in scales}

        for build_type in build_types:
            benchmark_dat = load_benchmark_data(build_type)

            benchmark_dict = {benchmark["name"]: benchmark for benchmark in benchmark_dat["benchmarks"]}
            for scale in scales:
                full_test_name = f"{test_name_base}[{scale}]"
                if full_test_name in benchmark_dict:
                    stats = benchmark_dict[full_test_name]["stats"]
                    # Use standard deviation for error bars
                    test_data[scale].append((stats["mean"], stats["stddev"]))
                else:
                    test_data[scale].append((0, 0))

        # Create plots for each scale
        for scale in scales:
            if not any(time for time, _ in test_data[scale]):
                continue

            fig, ax = plt.subplots(figsize=(12, 8))
            create_specialized_plot(
                ax,
                test_data[scale],
                build_types,
                f"FAISS Performance - {test_name_base} ({scale.capitalize()} Scale)",
                "Mean Execution Time (seconds)",
            )
            plt.tight_layout()
            plt.savefig(
                charts_dir / f"performance_{test_name_base}_{scale}.png",
                dpi=300,
                bbox_inches="tight",
            )
            plt.close()
