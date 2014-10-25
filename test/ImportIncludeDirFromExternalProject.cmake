# /tests/ImportIncludeDirFromImportedExternalProject.cmake
#
# Tests that upon importing an external project, we can import
# the include/ directory and use it in this project.
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
                                    INCLUDE_DIRS
                                    PROJECT_INCLUDE include)

set (EXECUTABLE_SOURCE_FILE_CONTENTS
     "#include <header.h>\n"
     "int main ()\n"
     "{\n"
     "    return MY_MACRO\;\n"
     "}\n")
set (EXECUTABLE_SOURCE_FILE
     ${CMAKE_CURRENT_BINARY_DIR}/source.c)
file (WRITE ${EXECUTABLE_SOURCE_FILE}
      ${EXECUTABLE_SOURCE_FILE_CONTENTS})

include_directories (${PROJECT_INCLUDE})
add_executable (executable ${EXECUTABLE_SOURCE_FILE})