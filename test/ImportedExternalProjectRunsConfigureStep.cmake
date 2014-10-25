# /tests/ImportedExternalProjectRunsConfigureStep.cmake
#
# Tests that upon importing an external project, we run the
# configure step for that project as part of its configuration.
#
# See LICENCE.md for Copyright information

include (CMakeUnit)
include (ImportedProjectUtils)
include (CreateExternalProjectHelper)

polysquare_import_external_project (${EXTERNAL_PROJECT_NAME}
                                    library-exports
                                    OPTIONS
                                    SOURCE_DIR
                                    ${EXTERNAL_PROJECT_DIRECTORY})

set (BIN_DIR ${CMAKE_CURRENT_BINARY_DIR})
set (EXTPROJ_DIR ${BIN_DIR}/${EXTERNAL_PROJECT_NAME})
set (EXTPROJ_META_DIR ${EXTPROJ_DIR}/${EXTERNAL_PROJECT_NAME}-Meta)
set (EXTPROJ_META_STAMP_DIR ${EXTPROJ_META_DIR}/configure-stamp)
set (EXTPROJ_CONFIGURE_STAMP
     ${EXTPROJ_META_STAMP_DIR}/${EXTERNAL_PROJECT_NAME}-download)

assert_file_exists (${EXTPROJ_CONFIGURE_STAMP})