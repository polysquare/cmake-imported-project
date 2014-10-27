# /test/ImportedExternalProjectRunsDownloadStepVerify.cmake
#
# Ensure that our meta-project's download step was run. We can only
# do this at the verify stage as we depend on the value of
# CMAKE_CFG_INTDIR to find the project stamps
#
# See LICENCE.md for Copyright information

include (CMakeUnit)
include (ImportCfgIntDirHelper)

set (EXTERNAL_PROJECT_NAME ExternalProject)
set (BIN_DIR ${CMAKE_CURRENT_BINARY_DIR})
set (EXTPROJ_DIR ${BIN_DIR}/${EXTERNAL_PROJECT_NAME})
set (EXTPROJ_META_DIR ${EXTPROJ_DIR}/${EXTERNAL_PROJECT_NAME}-Meta)
set (EXTPROJ_META_STAMP_DIR
     ${EXTPROJ_META_DIR}/configure-stamp/${CMAKE_CFG_INTDIR})
set (EXTPROJ_DOWNLOADED_STAMP
     ${EXTPROJ_META_STAMP_DIR}/${EXTERNAL_PROJECT_NAME}-download)

assert_file_exists (${EXTPROJ_DOWNLOADED_STAMP})