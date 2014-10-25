# /tests/ErrorOnUnevenPairs.cmake
#
# Checks that when we provide an uneven number of pairs to
# _polysquare_assign_variables_in_list that we get an error
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
include (ImportedProjectUtils)

list (APPEND PAIR_LIST
      VARIABLE)

_polysquare_assign_variables_in_list (PAIR_LIST LIST_RETURN)