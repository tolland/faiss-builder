import subprocess

from rich import inspect
import pytest
from typing import Dict, List

# This file is used by pytest to discover hooks and fixtures.
# https://docs.pytest.org/en/stable/reference/fixtures.html#conftest-py-sharing-fixtures-across-multiple-files

def pytest_addoption(parser):
    """
    Adds custom command-line options for the pytest session.
    """
    parser.addoption(
        "--build-type",
        action="store",
        default="cpu",
        help="Specify the FAISS build type: cpu, cpu_mkl, gpu, gpu_mkl",
    )


@pytest.fixture(scope="session")
def build_type(request) -> str:
    """
    Fixture that provides access to the build type throughout the session.
    """
    return request.config.getoption("--build-type")

def pytest_sessionfinish(session, exitstatus):
    """
    Hook called after the entire test session finishes.
    Generates the performance plot using data from benchmark runs.
    """
    # Check if any tests failed or were interrupted.
    # You might want to skip plot generation in these cases.
    # For example:
    # if exitstatus == pytest.ExitCode.OK:
    #     print("Test session finished successfully. Generating performance plot...")
    #     generate_performance_plot()
    # else:
    #     print(f"Test session finished with status {exitstatus}. Skipping plot generation.")

    # print("pytest_sessionfinish hook called from conftest.py")
    # generate_performance_plot()

def pytest_benchmark_generate_commit_info(config):
    return {}

def pytest_benchmark_generate_machine_info(config):
    return {}
