# /tests/AssignTwoPairsInPairList.cmake
#
# Checks that when using _polysquare_assign_variables_in_list
# that for a list VARIABLE_ONE value_one VARIABLE_TWO value_two
# that VARIABLE_ONE gets assigned with value_one and VARIABLE_TWO
# gets assigned with value_two
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
include (ImportedProjectUtils)

list (APPEND PAIR_LIST
      VARIABLE_ONE value_one
      VARIABLE_TWO value_two)

_polysquare_assign_variables_in_list (PAIR_LIST LIST_RETURN)

assert_variable_is (VARIABLE_ONE STRING EQUAL value_one)
assert_variable_is (VARIABLE_TWO STRING EQUAL value_two)