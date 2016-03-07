from conans import ConanFile
from conans.tools import download, unzip
import os

VERSION = "0.0.1"


class CMakeImportedProjectConan(ConanFile):
    name = "cmake-imported-project"
    version = os.environ.get("CONAN_VERSION_OVERRIDE", VERSION)
    generators = "cmake"
    requires = ("cmake-include-guard/master@smspillaz/cmake-include-guard",
                "cmake-forward-cache/master@smspillaz/cmake-forward-cache",
                "cmake-header-language/master@smspillaz/cmake-header-language",
                "cmake-unit/master@smspillaz/cmake-unit")
    url = "http://github.com/polysquare/cmake-imported-project"
    license = "MIT"

    def source(self):
        zip_name = "cmake-imported-project.zip"
        download("https://github.com/polysquare/"
                 "cmake-imported-project/archive/{version}.zip"
                 "".format(version="v" + VERSION),
                 zip_name)
        unzip(zip_name)
        os.unlink(zip_name)

    def package(self):
        self.copy(pattern="*.cmake",
                  dst="cmake/cmake-imported-project",
                  src="cmake-imported-project-" + VERSION,
                  keep_path=True)
