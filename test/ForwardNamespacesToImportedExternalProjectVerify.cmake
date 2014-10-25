# /tests/ForwardNamespacesToExternalProjectVerify.cmake
#
# Check to to make sure that our forwarded cache variable is
# printed with its forwarded value (forwarded_value) on
# configure.
#
# See LICENCE.md for Copyright information

include (CMakeUnit)

set (EXTERNAL_PROJECT_NAME ExternalProject)

set (EXTERNAL_PROJECT_ROOT
     ${CMAKE_CURRENT_BINARY_DIR}/${EXTERNAL_PROJECT_NAME})
set (EXTERNAL_PROJECT_META
     ${EXTERNAL_PROJECT_ROOT}/${EXTERNAL_PROJECT_NAME}-Meta)
set (EXTERNAL_PROJECT_META_CONFIGURE_OUTPUT
     ${EXTERNAL_PROJECT_META}/build/BuildMetaProjectOutput.txt)

set (CONFIGURE_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/CONFIGURE.output)

assert_file_has_line_matching (${EXTERNAL_PROJECT_META_CONFIGURE_OUTPUT}
	                           "^.*FORWARDED_VARIABLE.*forwarded_value.*$")
