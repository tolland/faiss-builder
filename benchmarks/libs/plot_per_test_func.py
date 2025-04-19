from pathlib import Path

from benchmarks.libs.histogram import make_histogram


def generate_plot_per_func(benchmarks_dict):

    for key, benchmarks in benchmarks_dict.items():
        if not benchmarks["benchmarks"]:
            print(f"Skipping {key} due to no data.")
            continue
        print(f"Benchmark: {key}")
        for row in benchmarks["benchmarks"]:
            print(f"  {row['name']}: {row['stats']['mean']} ± {row['stats']['stddev']}")
        make_histogram(
            benchmarks["title"],
            Path(f"benchmarks/charts"),
            key,
            benchmarks["benchmarks"],
            1e6,
        )
