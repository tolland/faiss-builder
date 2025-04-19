import logging

from benchmarks.libs.plot_generic_performance_comparison import generate_comparison_plots
from benchmarks.libs.plot_per_test_func import generate_plot_per_func
from benchmarks.libs.plot_specialized import generate_specialized_plots
from benchmarks.libs.results_loader import load_data_into_dicts

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

def generate_performance_plots():
    """Generate multiple performance comparison plots from benchmark results."""
    logger.debug("Generating performance plots...")

    # Collect all benchmark results

    # Prepare data for basic search performance tests

    basic_search_data, benchmarks_dict, build_type_dict, = load_data_into_dicts()

    generate_comparison_plots(basic_search_data)

    generate_specialized_plots(benchmarks_dict)

    generate_plot_per_func(benchmarks_dict)

    # for build_type in build_types:
    #     logger.debug(f"Processing build type: {build_type}")
    #     benchmark_dict = load_benchmark_data(results_dir, build_type)
    #     if not benchmark_dict:
    #         continue
    #
    #     # cross_test_benchmarks[build_type] = benchmark_dict
    #
    #     for scale in scales:
    #         times = []
    #         stddevs = []
    #         for idx in index_types:
    #             test_name = f"test_search_performance[{idx}-{scale}]"
    #             if test_name in benchmark_dict:
    #                 stats = benchmark_dict[test_name]["stats"]
    #                 times.append(stats["mean"])
    #                 # Use standard deviation for error bars
    #                 stddevs.append(stats["stddev"])
    #                 tmp_copy = benchmark_dict[test_name].copy()
    #                 tmp_copy["path"] = False
    #                 cross_test_benchmarks[
    #                     (
    #                         idx,
    #                         scale,
    #                     )
    #                 ]["title"] = benchmark_dict[
    #                     test_name
    #                 ]["extra_info"]["title"]
    #                 tmp_copy["title"] = benchmark_dict[test_name]["extra_info"]["title"]
    #                 tmp_copy["name"] = benchmark_dict[test_name]["name"].replace(
    #                     "test_search_performance[",
    #                     f"test_search_performance[{build_type}-",
    #                 )
    #                 cross_test_benchmarks[
    #                     (
    #                         idx,
    #                         scale,
    #                     )
    #                 ][
    #                     "benchmarks"
    #                 ].append({**tmp_copy, **tmp_copy["stats"]})
    #             else:
    #                 times.append(0)
    #                 stddevs.append(0)
    #         basic_search_data[scale].append((times, stddevs))

    # inspect(cross_test_benchmarks)

    # for key, benchmarks in cross_test_benchmarks.items():
    #     if not benchmarks["benchmarks"]:
    #         print(f"Skipping {key} due to no data.")
    #         continue
    #     print(f"Benchmark: {key}")
    #     for row in benchmarks["benchmarks"]:
    #         print(f"  {row['name']}: {row['stats']['mean']} ± {row['stats']['stddev']}")
    #     make_histogram(
    #         benchmarks["title"],
    #         Path(f"benchmarks/charts"),
    #         key,
    #         benchmarks["benchmarks"],
    #         1e6,
    #     )


if __name__ == "__main__":
    generate_performance_plots()
