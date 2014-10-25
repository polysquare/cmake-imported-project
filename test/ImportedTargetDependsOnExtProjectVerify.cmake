# /tests/ImportedTargetDependsOnExtProjectVerify.cmake
#
# Tests that generated.c got generated.
#
# See LICENCE.md for Copyright information

include (CMakeUnit)
set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_has_line_matching (${BUILD_OUTPUT}
	                           "^.*E touch.*generated.c.*$")
