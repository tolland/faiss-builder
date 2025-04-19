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

    # Prepare data for basic search performance tests

    basic_search_data, benchmarks_dict, build_type_dict, = load_data_into_dicts()

    generate_comparison_plots(basic_search_data)

    generate_specialized_plots(benchmarks_dict)

    generate_plot_per_func(benchmarks_dict)

if __name__ == "__main__":
    generate_performance_plots()
