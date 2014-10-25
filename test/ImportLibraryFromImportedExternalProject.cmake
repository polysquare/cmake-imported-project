# /tests/ImportLibraryFromImportedExternalProject.cmake
#
# Tests that upon importing an external project, we can import
# the "library" target and use it as a library in this project.
#
# See LICENCE.md for Copyright information

include (CMakeUnit)
include (ImportedProjectUtils)
include (CreateExternalProjectHelper)

polysquare_import_external_project (${EXTERNAL_PROJECT_NAME}
                                    library-exports
                                    OPTIONS
                                    SOURCE_DIR
                                    ${EXTERNAL_PROJECT_DIRECTORY}
                                    TARGETS
                                    PROJECT_LIBRARY library)

set (EXECUTABLE_SOURCE_FILE_CONTENTS
     "extern int function ()\;\n"
     "int main ()\n"
     "{\n"
     "    return function ()\;\n"
     "}\n")
set (EXECUTABLE_SOURCE_FILE
     ${CMAKE_CURRENT_BINARY_DIR}/source.c)
file (WRITE ${EXECUTABLE_SOURCE_FILE}
      ${EXECUTABLE_SOURCE_FILE_CONTENTS})

add_executable (executable ${EXECUTABLE_SOURCE_FILE})
target_link_libraries (executable ${PROJECT_LIBRARY})