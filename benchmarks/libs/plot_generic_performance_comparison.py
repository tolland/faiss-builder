import logging
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from rich import inspect

from benchmarks.libs.bar_plot import create_bar_plot
from benchmarks.libs.const import index_types, scales, build_types

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

def generate_comparison_plots(basic_search_data):

    # Create multiple plot variations for each scale
    x = np.arange(len(index_types))
    width = 0.2

    inspect(basic_search_data)

    charts_dir = Path(__file__).resolve().parent.parent / "charts"

    for scale in scales:
        # Skip if no data for this scale

        print(f"scale {scale}")
        inspect(basic_search_data[scale])

        if not any(any(times) for times, _ in basic_search_data[scale]):
            print(f"Skipping {scale} scale due to no data.")
            continue

        # 1. Linear scale plot
        fig, ax = plt.subplots(figsize=(12, 6))
        create_bar_plot(
            ax,
            x,
            width,
            basic_search_data[scale],
            build_types,
            f"FAISS Performance Comparison - {scale.capitalize()} Scale (Linear)",
            "Mean Search Time (seconds)",
        )
        plt.tight_layout()
        plt.savefig(
            charts_dir / f"performance_comparison_{scale}_linear.png",
            dpi=300,
            bbox_inches="tight",
        )
        plt.close()

        # 2. Log scale plot
        fig, ax = plt.subplots(figsize=(12, 8))
        create_bar_plot(
            ax,
            x,
            width,
            basic_search_data[scale],
            build_types,
            f"FAISS Performance Comparison - {scale.capitalize()} Scale (Log)",
            "Mean Search Time (seconds)",
            use_log=True,
        )
        plt.tight_layout()
        plt.savefig(
            charts_dir / f"performance_comparison_{scale}_log.png",
            dpi=300,
            bbox_inches="tight",
        )
        plt.close()
