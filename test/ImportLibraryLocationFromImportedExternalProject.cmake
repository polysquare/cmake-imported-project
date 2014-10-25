# /tests/ImportLibraryLocationFromImportedExternalProject.cmake
#
# Tests that upon importing an external project, PROJECT_LIBRARY_LOCATION
# is set and available for us to use.
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

assert_variable_is_defined (PROJECT_LIBRARY_LOCATION)