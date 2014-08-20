# /tests/CMakeLists.txt
# Main entry point for the cmake-imported-project-utils tests.
#
# See LICENCE.md for Copyright information

if (POLICY CMP0025)

    cmake_policy (SET CMP0025 NEW)

endif (POLICY CMP0025)

project (CMakeImportedProjectUtilsTests)
cmake_minimum_required (VERSION 2.8)

# We assume that it is one-above us
set (POLYSQUARE_IMPORT_UTILS_RELATIVE_CMAKE_DIRECTORY
     ${CMAKE_CURRENT_SOURCE_DIR}/..)
get_filename_component (POLYSQUARE_IMPORT_UTILS_CMAKE_DIRECTORY
                        ${POLYSQUARE_IMPORT_UTILS_RELATIVE_CMAKE_DIRECTORY}
                        ABSOLUTE)

set (CMAKE_UNIT_DIRECTORY
     ${POLYSQUARE_IMPORT_UTILS_CMAKE_DIRECTORY}/cmake-unit)

# Put our directories into the cache
set (POLYSQUARE_IMPORT_UTILS_CMAKE_INITIAL_CACHE_CONTENTS
     "set (POLYSQUARE_IMPORT_UTILS_CMAKE_DIRECTORY\n"
     "     ${POLYSQUARE_IMPORT_UTILS_CMAKE_DIRECTORY}\n"
     "     CACHE STRING \"\" FORCE)\n"
     "set (POLYSQUARE_IMPORT_UTILS_CMAKE_UNIT_DIRECTORY\n"
     "     ${CMAKE_UNIT_DIRECTORY}\n"
     "     CACHE STRING \"\" FORCE)\n"
     "set (POLYSQUARE_IMPORT_UTILS_CMAKE_GENERATOR\n"
     "     ${CMAKE_GENERATOR}\n"
     "     CACHE STRING \"\" FORCE)\n")

set (CMAKE_MODULE_PATH
     ${CMAKE_UNIT_DIRECTORY}
     ${CMAKE_MODULE_PATH})

include (CMakeUnitRunner)

bootstrap_cmake_unit (INITIAL_CACHE_CONTENTS
                      POLYSQUARE_IMPORT_UTILS_CMAKE_INITIAL_CACHE_CONTENTS)

add_cmake_test (ImportLibraryCreatesImportedTarget)
add_cmake_test (GetLibraryLocationForLibraryPath)
add_cmake_test (GetLibraryLocationForLibraryTarget)
add_cmake_test (AppendCacheDefinition)

add_cmake_build_test (ImportLibraryFromExtProjectGeneratesFromExtProject
                      ImportLibraryFromExtProjectGeneratesFromExtProjectVerify)