# /tests/AppendCacheDefinition.cmake
#
# Checks that when appending a definition, we get the format
# "set (${VARIABLE} \"${VALUE}\" CACHE STRING \"\" FORCE)"
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
include (ImportedProjectUtils)

set (VARIABLE "VARIABLE")
set (VALUE "VALUE")
set (CACHE_LINES)

polysquare_import_utils_append_cache_definition_variable (${VARIABLE}
	                                                      ${VALUE}
	                                                      CACHE_LINES)

assert_variable_is (CACHE_LINES STRING EQUAL
                    "\nset (${VARIABLE} \"${VALUE}\" CACHE STRING \"\" FORCE)")
