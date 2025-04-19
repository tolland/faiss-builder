from typing import List, Tuple

import numpy as np

"""Create a bar plot with error bars for multiple values per build type."""
def create_bar_plot(
        ax: object,
        x: np.ndarray,
        width: float,
        data: List[Tuple[List[float], List[float]]],
        labels: List[str],
        title: str,
        ylabel: str,
        use_log: bool = False,
) -> None:
    """

    Args:
        ax:
        x:
        width:
        data:
        labels:
        title:
        ylabel:
        use_log:
    """
    for i, (times, stddevs) in enumerate(data):
        bars = ax.bar(x + i * width, times, width, label=labels[i])
        # Use stddev for symmetrical error bars
        # ax.errorbar(
        #     x + i * width, times, yerr=stddevs, fmt="none", color="black", capsize=3
        # )

    ax.set_xlabel("Index Type")
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.set_xticks(x + width * 1.5)
    ax.set_xticklabels(["flat", "ivf", "hnsw"])
    ax.legend()
    ax.grid(True, axis="y", linestyle="--", alpha=0.7)

    if use_log:
        ax.set_yscale("log")
        # Set y-axis minimum to avoid negative values in log scale
        ax.set_ylim(bottom=1e-6)
