# /tests/ForwardNamespacesToImportedExternalProject.cmake
#
# Tests that we can forward cache namespaces to external projects.
#
# See LICENCE.md for Copyright information

include (CMakeUnit)
include (ImportedProjectUtils)
include (CreateExternalProjectHelper)

set (FORWARDED_VARIABLE "forwarded_value" CACHE STRING "" FORCE)
polysquare_import_external_project (${EXTERNAL_PROJECT_NAME}
                                    library-exports
                                    OPTIONS
                                    SOURCE_DIR
                                    ${EXTERNAL_PROJECT_DIRECTORY}
                                    NAMESPACES
                                    FORWARDED)

add_custom_target (on_all ALL)
add_dependencies (on_all ${EXTERNAL_PROJECT_NAME})

