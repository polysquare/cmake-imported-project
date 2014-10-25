# /tests/ImportedTargetDependsOnExtProject.cmake
#
# Tests that upon adding an external project and then calling
# polysquare_make_imported_target_depend_on_project that when
# running the build rule for the imported target the project
# is also built.
#
# See LICENCE.md for Copyright information

include (CMakeUnit)
include (ImportedProjectUtils)

set (EXTERNAL_PROJECT_NAME ExternalProject)
set (EXTERNAL_PROJECT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/external)
set (EXTERNAL_PROJECT_BINARY_DIRECTORY ${EXTERNAL_PROJECT_DIRECTORY}/build)
set (EXTERNAL_PROJECT_GENERATED_SOURCE_FILE
     ${EXTERNAL_PROJECT_DIRECTORY}/generated.c)
set (EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT
     "project (external)\n"
     "set (CMAKE_VERBOSE_MAKEFILE ON)\n"
     "cmake_minimum_required (VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION})\n"
     "add_custom_command (OUTPUT ${EXTERNAL_PROJECT_GENERATED_SOURCE_FILE}\n"
     "                    COMMAND ${CMAKE_COMMAND} -E touch\n"
     "                    ${EXTERNAL_PROJECT_GENERATED_SOURCE_FILE})\n"
     "add_custom_target (target ALL SOURCES\n"
     "                   ${EXTERNAL_PROJECT_GENERATED_SOURCE_FILE})\n")

file (MAKE_DIRECTORY ${EXTERNAL_PROJECT_DIRECTORY})
file (WRITE
      ${EXTERNAL_PROJECT_DIRECTORY}/CMakeLists.txt
      ${EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT})

include (ExternalProject)

ExternalProject_Add (${EXTERNAL_PROJECT_NAME}
                     SOURCE_DIR ${EXTERNAL_PROJECT_DIRECTORY}
                     BINARY_DIR ${EXTERNAL_PROJECT_BINARY_DIRECTORY}
                     INSTALL_COMMAND "")

# Insert a dummy "imported" target, which is actually just a file
# in our external project generated at build time, which we'll add as a
# dependency to ensure that the external project gets built to "generate" it.
add_custom_target (imported_target)

set_property (TARGET imported_target
              PROPERTY LOCATION
              ${EXTERNAL_PROJECT_GENERATED_SOURCE_FILE})
polysquare_make_imported_target_depend_on_project (imported_target
                                                   ${EXTERNAL_PROJECT_NAME})
