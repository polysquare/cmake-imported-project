# /tests/ForwardCacheNamespaces.cmake
#
# Checks that when forwarding a namespace, we get all variables in that
# namespace in the format of:
# "set (${VARIABLE} \"${VALUE}\" CACHE STRING \"\" FORCE)"
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
include (ImportedProjectUtils)

set (NAMESPACE_CACHE_VAR_ONE "ONE" CACHE STRING "Cache var one" FORCE)
set (NAMESPACE_CACHE_VAR_TWO "TWO" CACHE STRING "Cache var one" FORCE)

set (CACHE_FILE ${CMAKE_CURRENT_BINARY_DIR}/CacheFile.cmake)
polysquare_forward_cache_namespaces_to_file (${CACHE_FILE} NAMESPACES NAMESPACE)

file (READ ${CACHE_FILE} CACHE_LINES)

set (EXPECTED_CACHE_LINES
     "\nset (NAMESPACE_CACHE_VAR_ONE \"ONE\" CACHE STRING \"\" FORCE)"
     "\nset (NAMESPACE_CACHE_VAR_TWO \"TWO\" CACHE STRING \"\" FORCE)")
string (REPLACE ";" "" EXPECTED_CACHE_LINES "${EXPECTED_CACHE_LINES}")

assert_variable_is (CACHE_LINES STRING EQUAL "${EXPECTED_CACHE_LINES}")
