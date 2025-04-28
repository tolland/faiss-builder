import os
import platform
import shutil
from pathlib import Path
from typing import Any

from hatchling.builders.hooks.plugin.interface import BuildHookInterface


def prepare_faiss_package(build_dir: Path) -> None:
    """Prepare the faiss package directory structure."""
    faiss_dir = build_dir / "faiss"

    # Clean and recreate faiss directory
    if faiss_dir.exists():
        shutil.rmtree(faiss_dir)
    faiss_dir.mkdir()

    # Copy contrib directory
    shutil.copytree("contrib", faiss_dir / "contrib")

    # Copy Python files
    for py_file in [
        "__init__.py",
        "loader.py",
        "class_wrappers.py",
        "gpu_wrappers.py",
        "extra_wrappers.py",
        "array_conversions.py",
    ]:
        shutil.copyfile(py_file, faiss_dir / py_file)

    # Handle platform-specific library extensions
    ext = ".pyd" if platform.system() == "Windows" else ".so"
    prefix = "Release/" * (platform.system() == "Windows")

    # Define library names
    libs = {
        "generic": f"{prefix}_swigfaiss{ext}",
        "avx2": f"{prefix}_swigfaiss_avx2{ext}",
        "avx512": f"{prefix}_swigfaiss_avx512{ext}",
        "avx512_spr": f"{prefix}_swigfaiss_avx512_spr{ext}",
        "sve": f"{prefix}_swigfaiss_sve{ext}",
        "callbacks": f"{prefix}libfaiss_python_callbacks{ext}",
        "example": f"_faiss_example_external_module{ext}",
    }

    # Copy libraries and their corresponding Python files
    for lib_type, lib_name in libs.items():
        if os.path.exists(lib_name):
            print(f"Copying {lib_name}")

            # Copy the library
            shutil.copyfile(lib_name, faiss_dir / f"_{lib_name.lstrip(prefix)}")

            # Copy corresponding Python file if it exists
            py_file = (
                f"swigfaiss_{lib_type}.py"
                if lib_type != "example"
                else "faiss_example_external_module.py"
            )
            if os.path.exists(py_file):
                shutil.copyfile(py_file, faiss_dir / py_file)


def build_wheel(wheel_directory, config_settings=None, metadata_directory=None):
    """Custom build function for wheel building."""
    build_dir = Path(wheel_directory)

    # Prepare the faiss package
    prepare_faiss_package(build_dir)

    # Build the wheel using hatchling's default build
    from hatchling.build import build_wheel as hatchling_build_wheel

    return hatchling_build_wheel(wheel_directory, config_settings, metadata_directory)


class CustomBuildHook(BuildHookInterface):

    def initialize(self, version: str, build_data: dict[str, Any]) -> None:
        print("CustomBuildHook initialized")
        print(f"build_data: {build_data}")
        print(f"directory: {self.__directory}")
        print(f"target_name: {self.__target_name}")
        print(f"config: {self.__config}")
        super().initialize(version, build_data)
