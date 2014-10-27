# /tests/CMakeLists.txt
# Main entry point for the cmake-imported-project-utils tests.
#
# See LICENCE.md for Copyright information

if (POLICY CMP0025)

    cmake_policy (SET CMP0025 NEW)

endif (POLICY CMP0025)

project (CMakeImportedProjectUtilsTests)
cmake_minimum_required (VERSION 2.8)

# We assume that it is one-above us
set (POLYSQUARE_IMPORT_UTILS_RELATIVE_CMAKE_DIRECTORY
     ${CMAKE_CURRENT_SOURCE_DIR}/..)
get_filename_component (POLYSQUARE_IMPORT_UTILS_CMAKE_DIRECTORY
                        ${POLYSQUARE_IMPORT_UTILS_RELATIVE_CMAKE_DIRECTORY}
                        ABSOLUTE)

set (CMAKE_UNIT_DIRECTORY
     ${POLYSQUARE_IMPORT_UTILS_CMAKE_DIRECTORY}/cmake-unit)

set (CMAKE_MODULE_PATH
     ${CMAKE_UNIT_DIRECTORY}
     ${POLYSQUARE_IMPORT_UTILS_CMAKE_DIRECTORY}
     ${CMAKE_CURRENT_SOURCE_DIR}
     ${CMAKE_MODULE_PATH})

include (CMakeUnitRunner)

# Put our directories into the cache
bootstrap_cmake_unit (VARIABLES CMAKE_GENERATOR
                                CMAKE_MODULE_PATH
                                CMAKE_MAKE_PROGRAM)

add_cmake_test (ImportLibraryCreatesImportedTarget)
add_cmake_test (ImportLibrarySetsVariableLocationSuffix)
add_cmake_test (GetLibraryLocationForLibraryPath)
add_cmake_test (GetLibraryLocationForLibraryTarget)
add_cmake_test (AppendCacheDefinition)
add_cmake_test (AppendTypedCacheDefinition)
add_cmake_test (ForwardCacheNamespaces)
add_cmake_test (AssignOnePairInPairList)
add_cmake_test (AssignTwoPairsInPairList)
add_cmake_test (AssignZeroPairsInPairList)
add_cmake_test (ReturnsListOfVars)

add_cmake_test (ImportLibraryLocationFromImportedExternalProject)
add_cmake_build_test (ImportedExternalProjectRunsDownloadStep
                      ImportedExternalProjectRunsDownloadStepVerify)
add_cmake_build_test (ImportedExternalProjectRunsConfigureStep
                      ImportedExternalProjectRunsConfigureStepVerify)
add_cmake_build_test (ErrorOnUnevenPairs
                      ErrorOnUnevenPairsVerify
                      ALLOW_CONFIGURE_FAIL)
add_cmake_build_test (ImportedTargetDependsOnExtProject
                      ImportedTargetDependsOnExtProjectVerify
                      TARGET imported_target)
add_cmake_build_test (ImportLibraryFromImportedExternalProject
                      ImportLibraryFromImportedExternalProjectVerify)
add_cmake_build_test (ImportLibraryFromImportedExternalProjectGenerateExports
                      ImportLibraryFromImportedExternalProjectGenerateExportsVerify)
add_cmake_build_test (ImportIncludeDirFromExternalProject
                      ImportIncludeDirFromExternalProjectVerify)
add_cmake_build_test (ForwardNamespacesToImportedExternalProject
                      ForwardNamespacesToImportedExternalProjectVerify)
