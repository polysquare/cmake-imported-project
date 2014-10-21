# /tests/AppendTypedCacheDefinition.cmake
#
# Checks that when appending a BOOL definition, we get the format
# "-DVARIABLE:BOOL=VALUE"
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
include (ImportedProjectUtils)

set (VARIABLE "VARIABLE")
set (VALUE "VALUE")
set (CACHE_LINES)

polysquare_import_utils_append_typed_cache_definition (${VARIABLE}
	                                                   ${VALUE}
                                                       BOOL
	                                                   CACHE_LINES)

assert_variable_is (${CACHE_LINES} STRING EQUAL
	                "-D${VARIABLE}:BOOL=${VALUE}")
