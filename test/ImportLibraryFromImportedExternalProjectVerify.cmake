# /tests/ImportLibraryFromImportedExternalProjectVerify.cmake
#
# Tests that upon importing an external project, we can import
# the "library" target and use it as a library in this project.
#
# See LICENCE.md for Copyright information

include (CMakeUnit)
set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_has_line_matching (${BUILD_OUTPUT}
                               "^.*executable.*library.*$")