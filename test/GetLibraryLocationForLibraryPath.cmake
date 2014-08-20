# /tests/GetLibraryLocationForLibraryPath.cmake
#
# Checks that getting a library location for a path returns the path.
#
# See LICENCE.md for Copyright information.

include (${POLYSQUARE_IMPORT_UTILS_CMAKE_UNIT_DIRECTORY}/CMakeUnit.cmake)
include (${POLYSQUARE_IMPORT_UTILS_CMAKE_DIRECTORY}/ImportedProjectUtils.cmake)

# We're not building this project, so we can get the path from a bogus library
set (LIBRARY_LOCATION "${CMAKE_CURRENT_BINARY_DIR}/lib.a")
polysquare_import_utils_get_library_location (${LIBRARY_LOCATION} RESULT)

assert_variable_is (RESULT STRING EQUAL ${LIBRARY_LOCATION})