import json
from pathlib import Path
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np

from benchmarks.libs.bar_plot import create_bar_plot
from benchmarks.libs.histogram import make_histogram
from benchmarks.libs.results_loader import load_benchmark_data


def create_specialized_plot(
    ax, data: List[Tuple[float, float]], labels: List[str], title: str, ylabel: str
):
    """Create a bar plot for specialized tests with single values."""
    x = np.arange(len(labels))
    width = 0.6

    for i, (time, stddev) in enumerate(data):
        ax.bar(x[i], time, width, label=labels[i])
        # Use stddev for symmetrical error bars
        ax.errorbar(x[i], time, yerr=stddev, fmt="none", color="black", capsize=3)

    ax.set_xlabel("Build Type")
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.grid(True, axis="y", linestyle="--", alpha=0.7)

