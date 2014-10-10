# /tests/ImportLibraryFromExtProjectGeneratesFromExtProjectVerify
#
# Check to make sure that the external project was run
#
# See LICENCE.md for Copyright information

include (CMakeUnit)
set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_has_line_matching (${BUILD_OUTPUT}
	                           "^.*library.c.*$")
