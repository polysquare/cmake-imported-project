# /tests/ReturnsListOfVars.cmake
#
# Checks that when using _polysquare_assign_variables_in_list
# that for an empty list, we just get an empty list back with
# no errors
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
include (ImportedProjectUtils)

list (APPEND PAIR_LIST
      VARIABLE_ONE value_one
      VARIABLE_TWO value_two)

_polysquare_assign_variables_in_list (PAIR_LIST LIST_RETURN)

assert_list_contains_value (LIST_RETURN STRING EQUAL VARIABLE_ONE)
assert_list_contains_value (LIST_RETURN STRING EQUAL VARIABLE_TWO)