# /tests/ForwardCacheNamespaces.cmake
#
# Checks that when appending a definition, we get the format
# "-DVARIABLE:string=VALUE"
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
include (ImportedProjectUtils)

set (NAMESPACE_CACHE_VAR_ONE "ONE" CACHE STRING "Cache var one" FORCE)
set (NAMESPACE_CACHE_VAR_TWO "TWO" CACHE STRING "Cache var one" FORCE)

set (CACHE_LINES)

polysquare_forward_cache_namespaces (CACHE_LINES NAMESPACES NAMESPACE)

assert_list_contains_value (CACHE_LINES STRING EQUAL
	                        "-DNAMESPACE_CACHE_VAR_ONE:STRING=ONE")
assert_list_contains_value (CACHE_LINES STRING EQUAL
	                        "-DNAMESPACE_CACHE_VAR_TWO:STRING=TWO")
