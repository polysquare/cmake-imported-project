# CMake imported project utilities #

Utilities to build and import projects at configure-time.

## Status ##

| Travis CI (Ubuntu) | AppVeyor (Windows) | Coverage | Biicode | Licence |
|--------------------|--------------------|----------|---------|---------|
|[![Travis](https://img.shields.io/travis/polysquare/cmake-imported-project-utils.svg)](http://travis-ci.org/polysquare/cmake-imported-project-utils)|[![AppVeyor](https://img.shields.io/appveyor/ci/smspillaz/cmake-imported-project-utils.svg)](https://ci.appveyor.com/project/smspillaz/cmake-imported-project-utils)|[![Coveralls](https://img.shields.io/coveralls/polysquare/cmake-imported-project-utils.svg)](http://coveralls.io/polysquare/cmake-imported-project-utils)|[![Biicode](https://webapi.biicode.com/v1/badges/smspillaz/smspillaz/cmake-imported-project/master)](https://www.biicode.com/smspillaz/cmake-imported-project)|[![License](https://img.shields.io/github/license/polysquare/cmake-imported-project.svg)](http://github.com/polysquare/cmake-imported-project)|

## Description ##

`cmake-imported-project-utils` is used as a support library by modules
such as `gmock-cmake` to import and configure an external project at
configure-time as opposed to build-time.
