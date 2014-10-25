# /test/CreateExternalProjectHelper.cmake
#
# Import this file to create an external project, which has a directory
# structure like:
# external/
# - include/
#   - header.h
# - library.c
# - CMakeLists.txt
#
# And a binary directory structure like:
# - [optional] library-exports.cmake
# - library
#
# The project also optionally generates an exports file called
# library-exports.cmake, but won't generate one if EXTERNAL_PROJECT_NO_EXPORTS
# is set before including this file
#
# See LICENCE.md for Copyright information.

set (EXTERNAL_PROJECT_NAME ExternalProject)
set (EXTERNAL_PROJECT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/external)
set (EXTERNAL_PROJECT_BINARY_DIRECTORY ${EXTERNAL_PROJECT_DIRECTORY}/build)
set (EXTERNAL_PROJECT_LIB "library")
set (EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE_FILE_CONTENTS
     "int function () { return 1\; }")
set (EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE_FILE
     ${EXTERNAL_PROJECT_DIRECTORY}/library.c)
set (EXTERNAL_PROJECT_IMPORTED_LIBRARY_INCLUDE_DIR
   ${EXTERNAL_PROJECT_DIRECTORY}/include)
set (EXTERNAL_PROJECT_IMPORTED_LIBRARY_HEADER_FILE
   ${EXTERNAL_PROJECT_IMPORTED_LIBRARY_INCLUDE_DIR}/header.h)
set (EXTERNAL_PROJECT_IMPORTED_LIBRARY_HEADER_FILE_CONTENTS
   "#ifndef HEADER_H\n"
   "#define HEADER_H\n"
   "int function ()\;\n"
   "#define MY_MACRO 1\n"
   "#endif")
set (EXTERNAL_PROJECT_IMPORTED_LIBRARY_EXPORTS
     library-exports.cmake)
set (EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT
     "project (external)\n"
     "message (STATUS \"FORWARDED_VARIABLE is \${FORWARDED_VARIABLE}\")\n"
     "cmake_minimum_required (VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION})\n"
     "add_library (${EXTERNAL_PROJECT_LIB} STATIC\n"
     "             ${EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE_FILE})\n")

if (NOT EXTERNAL_PROJECT_NO_EXPORTS)
    set (EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT
         ${EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT}
         "export (TARGETS library\n"
         "        FILE ${EXTERNAL_PROJECT_IMPORTED_LIBRARY_EXPORTS})")
endif (NOT EXTERNAL_PROJECT_NO_EXPORTS)

file (MAKE_DIRECTORY ${EXTERNAL_PROJECT_DIRECTORY})
file (WRITE
      ${EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE_FILE}
      ${EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE_FILE_CONTENTS})
file (WRITE
      ${EXTERNAL_PROJECT_IMPORTED_LIBRARY_HEADER_FILE}
      ${EXTERNAL_PROJECT_IMPORTED_LIBRARY_HEADER_FILE_CONTENTS})
file (WRITE
      ${EXTERNAL_PROJECT_DIRECTORY}/CMakeLists.txt
      ${EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT})
