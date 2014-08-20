# /tests/ImportLibraryCreatesImportedTarget.cmake
#
# Checks that a new imported target is created when we import
# a known library
#
# See LICENCE.md for Copyright information.

include (${POLYSQUARE_IMPORT_UTILS_CMAKE_UNIT_DIRECTORY}/CMakeUnit.cmake)
include (${POLYSQUARE_IMPORT_UTILS_CMAKE_DIRECTORY}/ImportedProjectUtils.cmake)

# We're not building this project, so we can import a bogus library
set (LIBRARY_TARGET library_target)
set (LIBRARY_LOCATION "lib.a")
polysquare_import_utils_import_library (${LIBRARY_TARGET}
                                        STATIC
                                        ${LIBRARY_LOCATION})

assert_target_exists (${LIBRARY_TARGET})