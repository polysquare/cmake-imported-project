# /tests/ImportLibraryFromExtProjectGeneratesFromExtProject.cmake
#
# Tests that upon importing a library built by an external project,
# we create an ensure_build_of_${LIBRARY} target
#
# See LICENCE.md for Copyright information

include (CMakeUnit)
include (ImportedProjectUtils)

set (EXTERNAL_PROJECT_NAME ExternalProject)
set (EXTERNAL_PROJECT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/external)
set (EXTERNAL_PROJECT_BINARY_DIRECTORY ${EXTERNAL_PROJECT_DIRECTORY}/build)
set (EXTERNAL_PROJECT_LIB "library")
set (EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE_CONTENT
	 "int function () { return 1\; }")
set (EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE_FILE
	 ${EXTERNAL_PROJECT_DIRECTORY}/library.c)
set (EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT
	 "project (external)\n"
	 "cmake_minimum_required (VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION})\n"
	 "add_library (${EXTERNAL_PROJECT_LIB} STATIC\n"
	 "             ${EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE_FILE})\n")

file (MAKE_DIRECTORY ${EXTERNAL_PROJECT_DIRECTORY})
file (WRITE
	  ${EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE_FILE}
	  ${EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE_CONTENT})
file (WRITE
	  ${EXTERNAL_PROJECT_DIRECTORY}/CMakeLists.txt
	  ${EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT})

include (ExternalProject)

ExternalProject_Add (${EXTERNAL_PROJECT_NAME}
	                 SOURCE_DIR ${EXTERNAL_PROJECT_DIRECTORY}
	                 BINARY_DIR ${EXTERNAL_PROJECT_BINARY_DIRECTORY}
	                 INSTALL_COMMAND "")

polysquare_import_utils_get_build_suffix_for_generator (SUFFIX)
set (IMPORT_LIBRARY_LOCATION
	 ${EXTERNAL_PROJECT_BINARY_DIRECTORY}/${SUFFIX}/${EXTERNAL_PROJECT_LIB}.a)
set (IMPORT_LIBRARY_TARGET
	 imported_${EXTERNAL_PROJECT_LIB})
polysquare_import_utils_library_from_extproject (${IMPORT_LIBRARY_TARGET}
	                                             STATIC
	                                             ${IMPORT_LIBRARY_LOCATION}
	                                             ${EXTERNAL_PROJECT_NAME})

# Check if an ensure_build_of_imported_library target exists
assert_target_exists (ensure_build_of_${IMPORT_LIBRARY_TARGET})