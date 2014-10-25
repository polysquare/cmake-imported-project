# /tests/AssignOnePairInPairList.cmake
#
# Checks that when using _polysquare_assign_variables_in_list
# that for a list VARIABLE value that VARIABLE gets assigned with
# value
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
include (ImportedProjectUtils)

list (APPEND PAIR_LIST
      VAR value)

_polysquare_assign_variables_in_list (PAIR_LIST LIST_RETURN)

assert_variable_is (VAR STRING EQUAL value)