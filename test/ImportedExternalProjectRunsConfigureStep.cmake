# /tests/ImportedExternalProjectRunsConfigureStep.cmake
#
# Tests that upon importing an external project, we run the
# configure step for that project as part of its configuration.
#
# See LICENCE.md for Copyright information

include (CMakeUnit)
include (ImportedProjectUtils)
include (CreateExternalProjectHelper)
include (ExportCfgIntDirHelper)

polysquare_import_external_project (${EXTERNAL_PROJECT_NAME}
                                    library-exports
                                    OPTIONS
                                    SOURCE_DIR
                                    ${EXTERNAL_PROJECT_DIRECTORY})