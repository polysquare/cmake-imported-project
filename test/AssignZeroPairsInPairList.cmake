# /tests/AssignZeroPairsInPairList.cmake
#
# Checks that when using _polysquare_assign_variables_in_list
# that for an empty list, we just get an empty list back with
# no errors
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
include (ImportedProjectUtils)

set (PAIR_LIST)

_polysquare_assign_variables_in_list (PAIR_LIST VARIABLE_LIST)

# Basically, we should just have no errors here and LIST_RETURN
# should be empty
assert_variable_is (VARIABLE_LIST STRING EQUAL "")