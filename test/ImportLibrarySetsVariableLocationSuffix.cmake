# /tests/ImportLibrarySetsVariableLocationSuffix.cmake
#
# Checks that a variable called IMPORTED_LIBRARY_LOCATION
# is created and it has the value of our LIBRARY_LOCATION
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
include (ImportedProjectUtils)

# We're not building this project, so we can import a bogus library
set (LIBRARY_TARGET library_target)
set (LIBRARY_LOCATION "lib.a")
polysquare_import_utils_import_library (IMPORTED_LIBRARY
                                        ${LIBRARY_TARGET}
                                        STATIC
                                        ${LIBRARY_LOCATION})

assert_variable_is (IMPORTED_LIBRARY_LOCATION STRING EQUAL ${LIBRARY_LOCATION})