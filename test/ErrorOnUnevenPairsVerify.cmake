# /tests/ErrorOnUnevenPairs.cmake
#
# Checks to make sure we got an error
#
# See LICENCE.md for Copyright information

include (CMakeUnit)
set (CONFIGURE_ERROR ${CMAKE_CURRENT_BINARY_DIR}/CONFIGURE.error)

assert_file_has_line_matching (${CONFIGURE_ERROR}
	                           "^.*CMake Error.*$")
