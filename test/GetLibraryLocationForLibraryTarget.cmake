# /tests/GetLibraryLocationForLibraryTarget.cmake
#
# Checks that getting the library location for a target returns
# the actual target location.
#
# See LICENCE.md for Copyright information.

include (${POLYSQUARE_IMPORT_UTILS_CMAKE_UNIT_DIRECTORY}/CMakeUnit.cmake)
include (${POLYSQUARE_IMPORT_UTILS_CMAKE_DIRECTORY}/ImportedProjectUtils.cmake)

set (LIBRARY_SOURCE_FILE_CONTENTS
    "int function () {}\n")
set (LIBRARY_SOURCE_FILE
     ${CMAKE_CURRENT_BINARY_DIR}/library.c)
file (WRITE ${LIBRARY_SOURCE_FILE} ${LIBRARY_SOURCE_FILE_CONTENTS})

set (TARGET_NAME lib)
add_library (${TARGET_NAME} SHARED ${LIBRARY_SOURCE_FILE})

polysquare_import_utils_get_library_location (${TARGET_NAME} RESULT)

get_property (LIBRARY_LOCATION TARGET ${TARGET_NAME} PROPERTY LOCATION)
assert_variable_is (RESULT STRING EQUAL ${LIBRARY_LOCATION})