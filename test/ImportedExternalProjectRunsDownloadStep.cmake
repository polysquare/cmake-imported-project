# /tests/ImportedExternalProjectRunsDownloadStep.cmake
#
# Tests that upon importing an external project, we run the
# download step for that project as part of its configuration.
#
# See LICENCE.md for Copyright information

include (CMakeUnit)
include (ImportedProjectUtils)
include (CreateExternalProjectHelper)
include (ExportCfgIntDirHelper)

file (MAKE_DIRECTORY ${EXTERNAL_PROJECT_DIRECTORY})
file (WRITE
      ${EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE_FILE}
      ${EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE_CONTENT})
file (WRITE
      ${EXTERNAL_PROJECT_DIRECTORY}/CMakeLists.txt
      ${EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT})

polysquare_import_external_project (${EXTERNAL_PROJECT_NAME}
                                    library-exports
                                    OPTIONS
                                    SOURCE_DIR
                                    ${EXTERNAL_PROJECT_DIRECTORY})