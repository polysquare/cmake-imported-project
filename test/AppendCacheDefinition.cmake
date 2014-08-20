# /tests/AppendCacheDefinition.cmake
#
# Checks that when appending a definition, we get the format
# "-DVARIABLE:string=VALUE"
#
# See LICENCE.md for Copyright information.

include (${POLYSQUARE_IMPORT_UTILS_CMAKE_UNIT_DIRECTORY}/CMakeUnit.cmake)
include (${POLYSQUARE_IMPORT_UTILS_CMAKE_DIRECTORY}/ImportedProjectUtils.cmake)

set (VARIABLE "VARIABLE")
set (VALUE "VALUE")
set (CACHE_LINES)

polysquare_import_utils_append_cache_definition_variable (${VARIABLE}
	                                                      ${VALUE}
	                                                      CACHE_LINES)

assert_variable_is (${CACHE_LINES} STRING EQUAL
	                "-D${VARIABLE}:string=${VALUE}")