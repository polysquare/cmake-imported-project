# /CMakeLists.txt
#
# Main entry point for ImportedProjectUtils tests.
#
# See /LICENCE.md for Copyright information
include ("${CMAKE_CURRENT_LIST_DIR}/conanbuildinfo.cmake")
set (CMAKE_MODULE_PATH
     ${CONAN_CMAKE_MODULE_PATH}  # NOLINT:correctness/quotes
     ${CMAKE_MODULE_PATH})  # NOLINT:correctness/quotes

cmake_minimum_required (VERSION 2.8)

set (CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR};${CMAKE_MODULE_PATH}")

include ("cmake/cmake-module-common/Common" OPTIONAL)
include (ImportedProjectUtils)

# Checks that when appending a definition, we get the format
# "set (${VARIABLE} \"${VALUE}\" CACHE STRING \"\" FORCE)"
function (psq_test_append_cache_definition)

    function (psq_configure)

        set (VARIABLE "VARIABLE")
        set (VALUE "VALUE")
        set (CACHE_LINES)
        psq_append_cache_definition_variable (${VARIABLE}
                                              ${VALUE}
                                              CACHE_LINES)
        set (EXPECTED_CACHE_LINES
             "\nset (${VARIABLE} \"${VALUE}\" CACHE STRING \"\" FORCE)")
        cmake_unit_assert_that (CACHE_LINES compare_as STRING EQUAL
                                "${EXPECTED_CACHE_LINES}")

    endfunction ()

    cmake_unit_configure_config_only_test (CONFIGURE COMMAND psq_configure)

endfunction ()

# Checks that when appending a BOOL definition, we get the format
# "set (${VARIABLE} \"${VALUE}\" CACHE BOOL \"\" FORCE)"
function (psq_test_append_typed_cache_definition)

    function (psq_configure)

        set (VARIABLE "VARIABLE")
        set (VALUE "VALUE")
        set (CACHE_LINES)
        psq_append_typed_cache_definition (${VARIABLE}
                                           ${VALUE}
                                           BOOL
                                           CACHE_LINES)
        set (EXPECTED_CACHE_LINES
             "\nset (${VARIABLE} \"${VALUE}\" CACHE BOOL \"\" FORCE)")
        cmake_unit_assert_that (CACHE_LINES compare_as STRING EQUAL
                                "${EXPECTED_CACHE_LINES}")

    endfunction ()

    cmake_unit_configure_config_only_test (CONFIGURE COMMAND psq_configure)

endfunction ()

# Checks that when using psq_assign_variables_in_list
# that for a list VARIABLE value that VARIABLE gets assigned with
# value
function (psq_test_assign_one_pair_in_pair_list)

    function (psq_configure)

        list (APPEND PAIR_LIST VAR value)
        psq_assign_variables_in_list (PAIR_LIST LIST_RETURN)
        cmake_unit_assert_that (VAR compare_as STRING EQUAL value)

    endfunction ()

    cmake_unit_configure_config_only_test (CONFIGURE COMMAND psq_configure)

endfunction ()

# Checks that when using psq_assign_variables_in_list
# that for a list VARIABLE_ONE value_one VARIABLE_TWO value_two
# that VARIABLE_ONE gets assigned with value_one and VARIABLE_TWO
# gets assigned with value_two
function (psq_test_assign_two_pairs_in_pair_list)

    function (psq_configure)

        list (APPEND PAIR_LIST VARIABLE_ONE value_one VARIABLE_TWO value_two)
        psq_assign_variables_in_list (PAIR_LIST LIST_RETURN)
        cmake_unit_assert_that (VARIABLE_ONE compare_as STRING EQUAL value_one)
        cmake_unit_assert_that (VARIABLE_TWO compare_as STRING EQUAL value_two)

    endfunction ()

    cmake_unit_configure_config_only_test (CONFIGURE COMMAND psq_configure)

endfunction ()

# Checks that when using psq_assign_variables_in_list
# that for an empty list, we just get an empty list back with
# no errors
function (psq_test_assign_zero_pairs_in_pair_list)

    function (psq_configure)

        set (PAIR_LIST)
        psq_assign_variables_in_list (PAIR_LIST VARIABLE_LIST)
        cmake_unit_assert_that (VARIABLE_LIST compare_as STRING EMPTY EMPTY)

    endfunction ()

    cmake_unit_configure_config_only_test (CONFIGURE COMMAND psq_configure)

endfunction ()

# Import this file to create an external project, which has a directory
# structure like:
# external/
# - include/
#   - /header.h
# - /library.c
# - /CMakeLists.txt
macro (_psq_create_external_project_helper)

    set (EXTERNAL_PROJECT_NAME ExternalProject)  # NOLINT:unused/var_in_func
    set (EXTERNAL_PROJECT_DIRECTORY "${BINARY_DIR}/external")
    set (EXTERNAL_PROJECT_BINARY_DIRECTORY  # NOLINT:unused/var_in_func
         "${EXTERNAL_PROJECT_DIRECTORY}/build")
    set (EXTERNAL_PROJECT_LIB "library")
    set (EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE_CONTENTS
         "int function () { return 1\; }")
    set (EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE
         "${EXTERNAL_PROJECT_DIRECTORY}/library.c")
    set (EXTERNAL_PROJECT_IMPORTED_LIBRARY_INCLUDE_DIR
         "${EXTERNAL_PROJECT_DIRECTORY}/include")
    set (EXTERNAL_PROJECT_IMPORTED_LIBRARY_HEADER_FILE
         "${EXTERNAL_PROJECT_IMPORTED_LIBRARY_INCLUDE_DIR}/header.h")
    set (EXTERNAL_PROJECT_IMPORTED_LIBRARY_HEADER_FILE_CONTENTS
         "#ifndef HEADER_H\n"
         "#define HEADER_H\n"
         "int function ()\;\n"
         "#define MY_MACRO 1\n"
         "#endif")
    set (EXTERNAL_PROJECT_IMPORTED_LIBRARY_EXPORTS
         "library-exports.cmake")
    set (EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT
         "project (external)\n"
         "option (PROJECT_OPTION \"Documentation\" OFF)\n"
         "message (STATUS \"FORWARDED_VARIABLE is \${FORWARDED_VARIABLE}\")\n"
         "message (STATUS \"PROJECT_OPTION is \${PROJECT_OPTION}\")\n"
         "cmake_minimum_required (VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION})\n"
         "add_library (${EXTERNAL_PROJECT_LIB} STATIC\n"
         "             ${EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE})\n")
    if (NOT "${ARGN}" STREQUAL "NO_EXPORTS")
        set (EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT
             ${EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT}
             "export (TARGETS library\n"
             "        FILE ${EXTERNAL_PROJECT_IMPORTED_LIBRARY_EXPORTS})")
    endif ()
    file (MAKE_DIRECTORY "${EXTERNAL_PROJECT_DIRECTORY}")
    file (WRITE "${EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE}"
          ${EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE_CONTENTS})
    file (WRITE "${EXTERNAL_PROJECT_IMPORTED_LIBRARY_HEADER_FILE}"
          ${EXTERNAL_PROJECT_IMPORTED_LIBRARY_HEADER_FILE_CONTENTS})
    file (WRITE "${EXTERNAL_PROJECT_DIRECTORY}/CMakeLists.txt"
          ${EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT})

endmacro ()

# Checks that when we provide an uneven number of pairs to
# psq_assign_variables_in_list that we get an error
function (psq_test_error_on_uneven_pairs)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        list (APPEND PAIR_LIST VARIABLE)
        psq_assign_variables_in_list (PAIR_LIST LIST_RETURN)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_CONFIGURE ERROR CONFIGURE_ERROR)
        cmake_unit_assert_that (${CONFIGURE_ERROR}
                                file_contents any_line matches_regex
                                "^.*CMake Error.*$")

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS ALLOW_FAIL
                                           CONFIGURE COMMAND psq_configure
                                           VERIFY COMMAND psq_verify)
endfunction ()

# Writes out CMAKE_CFG_INTDIR to ${BINARY_DIR}/CfgIntDirValue.txt
# at build time
macro (_psq_test_export_cfg_int_dir_helper)

    set (OUTPUT_FILE
         "${BINARY_DIR}/CfgIntDirValue.txt")
    set (WRITE_TO_OUTPUT_FILE_SCRIPT
         "${BINARY_DIR}/WriteCfgIntDir.cmake")
    set (WRITE_TO_OUTPUT_FILE_SCRIPT_CONTENTS
         "file (WRITE ${OUTPUT_FILE} \"\${INTDIR}\")\n")
    file (WRITE ${WRITE_TO_OUTPUT_FILE_SCRIPT}
          "${WRITE_TO_OUTPUT_FILE_SCRIPT_CONTENTS}")
    add_custom_command (OUTPUT "${OUTPUT_FILE}"
                        COMMAND
                        "${CMAKE_COMMAND}"
                        -DINTDIR=${CMAKE_CFG_INTDIR}
                        -P
                        ${WRITE_TO_OUTPUT_FILE_SCRIPT})
    add_custom_target (write_cfg_int_dir ALL SOURCES "${OUTPUT_FILE}")

endmacro ()

# Checks that when forwarding a namespace, we get all variables in that
# namespace in the format of:
# "set (${VARIABLE} \"${VALUE}\" CACHE STRING \"\" FORCE)"
function (psq_test_forward_cache_namespaces)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (NAMESPACE_CACHE_VAR_ONE "ONE" CACHE STRING "Cache var one" FORCE)
        set (NAMESPACE_CACHE_VAR_TWO "TWO" CACHE STRING "Cache var one" FORCE)
        set (CACHE_FILE "${BINARY_DIR}/CacheFile.cmake")
        psq_forward_cache_namespaces_to_file ("${CACHE_FILE}"
                                              NAMESPACES NAMESPACE)
        file (READ "${CACHE_FILE}" CACHE_LINES)
        set (EXPECTED_CACHE_LINES
             "\nset (NAMESPACE_CACHE_VAR_ONE \"ONE\" CACHE STRING \"\" FORCE)"
             "\nset (NAMESPACE_CACHE_VAR_TWO \"TWO\" CACHE STRING \"\" FORCE)")
        string (REPLACE ";" "" EXPECTED_CACHE_LINES "${EXPECTED_CACHE_LINES}")
        cmake_unit_assert_that (CACHE_LINES compare_as
                                STRING EQUAL "${EXPECTED_CACHE_LINES}")

    endfunction ()

    cmake_unit_configure_config_only_test (CONFIGURE COMMAND psq_configure)

endfunction ()

# Tests that we can forward cache namespaces to external projects.
function (psq_test_forward_namespaces_to_imported_external_project)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        _psq_create_external_project_helper ()
        set (FORWARDED_VARIABLE "forwarded_value" CACHE STRING "" FORCE)
        psq_import_external_project (${EXTERNAL_PROJECT_NAME}
                                     library-exports
                                     OPTIONS
                                     SOURCE_DIR
                                     "${EXTERNAL_PROJECT_DIRECTORY}"
                                     NAMESPACES FORWARDED)
        add_custom_target (on_all ALL)
        add_dependencies (on_all ${EXTERNAL_PROJECT_NAME})

    endfunction ()

    function (psq_verify)

        set (EXTERNAL_PROJECT_NAME ExternalProject)
        set (EXTERNAL_PROJECT_ROOT "${BINARY_DIR}/${EXTERNAL_PROJECT_NAME}")
        set (EXTERNAL_PROJECT_META
             "${EXTERNAL_PROJECT_ROOT}/${EXTERNAL_PROJECT_NAME}-Meta")
        set (EXTERNAL_PROJECT_META_CONFIGURE_OUTPUT
             "${EXTERNAL_PROJECT_META}/build/BuildMetaProjectOutput.txt")
        cmake_unit_get_log_for (INVOKE_CONFIGURE OUTPUT CONFIGURE_OUTPUT)
        cmake_unit_assert_that (${EXTERNAL_PROJECT_META_CONFIGURE_OUTPUT}
                                file_contents any_line matches_regex
                                "^.*FORWARDED_VARIABLE.*forwarded_value.*$")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)
endfunction ()

# Tests that we can pass options to external projects
function (psq_test_pass_options_to_to_imported_external_project)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        _psq_create_external_project_helper ()
        psq_import_external_project (${EXTERNAL_PROJECT_NAME}
                                     library-exports
                                     OPTIONS
                                     CMAKE_ARGS
                                     -DPROJECT_OPTION=ON
                                     SOURCE_DIR
                                     "${EXTERNAL_PROJECT_DIRECTORY}")
        add_custom_target (on_all ALL)
        add_dependencies (on_all ${EXTERNAL_PROJECT_NAME})

    endfunction ()

    function (psq_verify)

        set (EXTERNAL_PROJECT_NAME ExternalProject)
        set (EXTERNAL_PROJECT_ROOT "${BINARY_DIR}/${EXTERNAL_PROJECT_NAME}")
        set (EXTERNAL_PROJECT_META
             "${EXTERNAL_PROJECT_ROOT}/${EXTERNAL_PROJECT_NAME}-Meta")
        set (EXTERNAL_PROJECT_META_CONFIGURE_OUTPUT
             "${EXTERNAL_PROJECT_META}/build/BuildMetaProjectOutput.txt")
        cmake_unit_get_log_for (INVOKE_CONFIGURE OUTPUT CONFIGURE_OUTPUT)
        cmake_unit_assert_that (${EXTERNAL_PROJECT_META_CONFIGURE_OUTPUT}
                                file_contents any_line matches_regex
                                "^.*PROJECT_OPTION.*ON.*$")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)
endfunction ()

# Imports the written out CMAKE_CFG_INTDIR and stores it in CMAKE_CFG_INTDIR
macro (_psq_import_cfg_int_dir_helper)

    file (READ "${BINARY_DIR}/CfgIntDirValue.txt"
          CMAKE_CFG_INTDIR)  # NOLINT:unused/var_in_func

endmacro ()

# Tests that upon importing an external project, we run the
# configure step for that project as part of its configuration.
function (psq_test_imported_external_project_runs_configure_step)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        _psq_create_external_project_helper ()
        _psq_test_export_cfg_int_dir_helper ()
        psq_import_external_project (${EXTERNAL_PROJECT_NAME}
                                     library-exports
                                     OPTIONS
                                     SOURCE_DIR
                                     "${EXTERNAL_PROJECT_DIRECTORY}")

    endfunction ()

    function (psq_verify)

        _psq_import_cfg_int_dir_helper ()
        set (EXTERNAL_PROJECT_NAME ExternalProject)
        set (BIN_DIR "${BINARY_DIR}")
        set (EXTPROJ_DIR "${BIN_DIR}/${EXTERNAL_PROJECT_NAME}")
        set (EXTPROJ_META_DIR "${EXTPROJ_DIR}/${EXTERNAL_PROJECT_NAME}-Meta")
        set (EXTPROJ_META_STAMP_DIR
             "${EXTPROJ_META_DIR}/configure-stamp/${CMAKE_CFG_INTDIR}")
        set (EXTPROJ_DOWNLOADED_STAMP
             "${EXTPROJ_META_STAMP_DIR}/${EXTERNAL_PROJECT_NAME}-configure")
        cmake_unit_assert_that (${EXTPROJ_DOWNLOADED_STAMP} exists_as_file)

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)

endfunction ()

# Tests that upon importing an external project, we run the
# download step for that project as part of its configuration.
function (psq_test_imported_external_project_runs_download_step)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        _psq_create_external_project_helper ()
        _psq_test_export_cfg_int_dir_helper ()
        file (MAKE_DIRECTORY "${EXTERNAL_PROJECT_DIRECTORY}")
        file (WRITE "${EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE}"
              ${EXTERNAL_PROJECT_IMPORTED_LIBRARY_SOURCE_CONTENT})
        file (WRITE "${EXTERNAL_PROJECT_DIRECTORY}/CMakeLists.txt"
              ${EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT})
        psq_import_external_project (${EXTERNAL_PROJECT_NAME}
                                     library-exports
                                     OPTIONS
                                     SOURCE_DIR
                                     "${EXTERNAL_PROJECT_DIRECTORY}")

    endfunction ()

    function (psq_verify)

        _psq_import_cfg_int_dir_helper ()
        set (EXTERNAL_PROJECT_NAME ExternalProject)
        set (BIN_DIR "${BINARY_DIR}")
        set (EXTPROJ_DIR "${BIN_DIR}/${EXTERNAL_PROJECT_NAME}")
        set (EXTPROJ_META_DIR "${EXTPROJ_DIR}/${EXTERNAL_PROJECT_NAME}-Meta")
        set (EXTPROJ_META_STAMP_DIR
             "${EXTPROJ_META_DIR}/configure-stamp/${CMAKE_CFG_INTDIR}")
        set (EXTPROJ_DOWNLOADED_STAMP
             "${EXTPROJ_META_STAMP_DIR}/${EXTERNAL_PROJECT_NAME}-download")
        cmake_unit_assert_that (${EXTPROJ_DOWNLOADED_STAMP} exists_as_file)

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)

endfunction ()

# Tests that upon adding an external project and then calling
# psq_make_imported_target_depend_on_project that when
# running the build rule for the imported target the project
# is also built.
function (psq_test_imported_target_depends_on_ext_project)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (EXTERNAL_PROJECT_NAME ExternalProject)
        set (EXTERNAL_PROJECT_DIRECTORY "${BINARY_DIR}/external")
        set (EXTERNAL_PROJECT_BINARY_DIRECTORY
             "${EXTERNAL_PROJECT_DIRECTORY}/build")
        set (EXTERNAL_PROJECT_GENERATED_SOURCE
             "${EXTERNAL_PROJECT_DIRECTORY}/generated.c")
        set (EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT
             "project (external)\n"
             "set (CMAKE_VERBOSE_MAKEFILE ON)\n"
             "cmake_minimum_required (VERSION\n"
             "                        ${CMAKE_MINIMUM_REQUIRED_VERSION})\n"
             "add_custom_command (OUTPUT ${EXTERNAL_PROJECT_GENERATED_SOURCE}\n"
             "                    COMMAND ${CMAKE_COMMAND} -E touch\n"
             "                    ${EXTERNAL_PROJECT_GENERATED_SOURCE})\n"
             "add_custom_target (target ALL SOURCES\n"
             "                   ${EXTERNAL_PROJECT_GENERATED_SOURCE})\n")
        file (MAKE_DIRECTORY "${EXTERNAL_PROJECT_DIRECTORY}")
        file (WRITE "${EXTERNAL_PROJECT_DIRECTORY}/CMakeLists.txt"
              ${EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT})
        include (ExternalProject)
        externalproject_add (${EXTERNAL_PROJECT_NAME}
                             SOURCE_DIR "${EXTERNAL_PROJECT_DIRECTORY}"
                             BINARY_DIR "${EXTERNAL_PROJECT_BINARY_DIRECTORY}"
                             INSTALL_COMMAND "")
        add_custom_target (imported_target)
        set_property (TARGET imported_target
                      PROPERTY LOCATION "${EXTERNAL_PROJECT_GENERATED_SOURCE}")
        psq_make_imported_target_depend_on_project (imported_target
                                                    ${EXTERNAL_PROJECT_NAME})

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT}
                                file_contents any_line matches_regex
                                "^.*generated.c.*$")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)

endfunction ()

# Tests that upon importing an external project, we can import
# the include/ directory and use it in this project.
function (psq_test_import_include_dir_from_external_project)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        _psq_create_external_project_helper ()
        psq_import_external_project (${EXTERNAL_PROJECT_NAME}
                                     library-exports
                                     OPTIONS
                                     SOURCE_DIR
                                     "${EXTERNAL_PROJECT_DIRECTORY}"
                                     INCLUDE_DIRS
                                     PROJECT_INCLUDE
                                     include)
        set (EXECUTABLE_SOURCE_CONTENTS
             "#include <header.h>\n"
             "int main ()\n"
             "{"
             "    return 0\;\n"
             "}\n")
        set (EXECUTABLE_SOURCE "${BINARY_DIR}/source.c")
        file (WRITE "${EXECUTABLE_SOURCE}" ${EXECUTABLE_SOURCE_CONTENTS})
        include_directories (${PROJECT_INCLUDE})
        add_executable (executable "${EXECUTABLE_SOURCE}")

    endfunction ()

    function (psq_verify)

        if (CMAKE_C_COMPILER_ID STREQUAL "MSVC")

            set (INCLUDE_LINE_REGEX "^.*\\/I.*external.include.*$")

        else ()

            set (INCLUDE_LINE_REGEX "^.*-I.*external/include.*$")

        endif ()

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT}
                                file_contents any_line matches_regex
                                "${INCLUDE_LINE_REGEX}")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)
endfunction ()

# Checks that a new imported target is created when we import
# a known library
function (psq_test_import_library_creates_imported_target)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (LIBRARY_TARGET library_target)
        set (LIBRARY_LOCATION "lib.a")
        psq_import_utils_import_library (IMPORTED_LIBRARY
                                         ${LIBRARY_TARGET}
                                         STATIC
                                         ${LIBRARY_LOCATION})
        cmake_unit_assert_that (${LIBRARY_TARGET} target_exists)

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure)

endfunction ()

# Tests that upon importing an external project, we can import
# the "library" target and use it as a library in this project.
function (psq_test_import_library_from_imported_external_project)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        _psq_create_external_project_helper ()
        psq_import_external_project (${EXTERNAL_PROJECT_NAME}
                                     library-exports
                                     OPTIONS
                                     SOURCE_DIR
                                     "${EXTERNAL_PROJECT_DIRECTORY}"
                                     TARGETS
                                     PROJECT_LIBRARY
                                     library)
        set (EXECUTABLE_SOURCE_CONTENTS
             "extern int function ()\;\n"
             "int main ()\n"
             "{\n"
             "    return function ()\;\n"
             "}\n")
        set (EXECUTABLE_SOURCE "${BINARY_DIR}/source.c")
        file (WRITE "${EXECUTABLE_SOURCE}" ${EXECUTABLE_SOURCE_CONTENTS})
        add_executable (executable "${EXECUTABLE_SOURCE}")
        target_link_libraries (executable ${PROJECT_LIBRARY})

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT}
                                file_contents any_line matches_regex
                                "^.*executable.*library.*$")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)
endfunction ()

# Tests that upon importing an external project, we can import
# the "library" target and use it as a library in this project, even
# if the external project doesn't export any targets.
function (psq_test_import_library_generate_exports)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        _psq_create_external_project_helper (NO_EXPORTS)
        psq_import_external_project (${EXTERNAL_PROJECT_NAME}
                                     library-exports
                                     OPTIONS
                                     SOURCE_DIR
                                     "${EXTERNAL_PROJECT_DIRECTORY}"
                                     TARGETS
                                     PROJECT_LIBRARY
                                     library
                                     GENERATE_EXPORTS)
        set (EXECUTABLE_SOURCE_CONTENTS
             "extern int function ()\;\n"
             "int main ()\n"
             "{\n"
             "    return function ()\;\n"
             "}\n")
        set (EXECUTABLE_SOURCE "${BINARY_DIR}/source.c")
        file (WRITE "${EXECUTABLE_SOURCE}" ${EXECUTABLE_SOURCE_CONTENTS})
        add_executable (executable "${EXECUTABLE_SOURCE}")
        target_link_libraries (executable ${PROJECT_LIBRARY})

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT}
                                file_contents any_line matches_regex
                                "^.*executable.*library.*$")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)
endfunction ()

# Tests that upon importing an external project, PROJECT_LIBRARY_LOCATION
# is set and available for us to use.
function (psq_test_import_library_location)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        _psq_create_external_project_helper ()
        _psq_test_export_cfg_int_dir_helper ()
        psq_import_external_project (${EXTERNAL_PROJECT_NAME}
                                     library-exports
                                     OPTIONS
                                     SOURCE_DIR
                                     "${EXTERNAL_PROJECT_DIRECTORY}"
                                     TARGETS
                                     PROJECT_LIBRARY
                                     library)
        cmake_unit_assert_that (PROJECT_LIBRARY_LOCATION is_defined)

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure)

endfunction ()

# Checks that a variable called IMPORTED_LIBRARY_LOCATION
# is created and it has the value of our LIBRARY_LOCATION
function (psq_test_import_library_sets_variable_location_suffix)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (LIBRARY_TARGET library_target)
        set (LIBRARY_LOCATION "lib.a")
        psq_import_utils_import_library (IMPORTED_LIBRARY
                                         ${LIBRARY_TARGET}
                                         STATIC
                                         ${LIBRARY_LOCATION})
        cmake_unit_assert_that (IMPORTED_LIBRARY_LOCATION
                                compare_as STRING EQUAL ${LIBRARY_LOCATION})

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure)

endfunction ()

# Checks that when using psq_assign_variables_in_list
# that for an empty list, we just get an empty list back with
# no errors
function (psq_test_returns_list_of_vars)

    function (psq_configure)

        list (APPEND PAIR_LIST VARIABLE_ONE value_one VARIABLE_TWO value_two)
        psq_assign_variables_in_list (PAIR_LIST LIST_RETURN)
        cmake_unit_assert_that (LIST_RETURN list_contains_value
                                STRING EQUAL VARIABLE_ONE)
        cmake_unit_assert_that (LIST_RETURN list_contains_value
                                STRING EQUAL VARIABLE_TWO)

    endfunction ()

    cmake_unit_configure_config_only_test (CONFIGURE COMMAND psq_configure)

endfunction ()

set (CMAKE_FILES
     "${CMAKE_CURRENT_LIST_DIR}/ImportedProjectUtils.cmake"
     "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt")
set (MARKDOWN_FILES
     "${CMAKE_CURRENT_LIST_DIR}/LICENCE.md"
     "${CMAKE_CURRENT_LIST_DIR}/README.md")

if (COMMAND cmake_module_add_common_targets)

    cmake_module_add_common_targets (NAMESPACE "cmake"
                                     CMAKE_FILES ${CMAKE_FILES}
                                     DOCUMENTATION_FILES ${MARKDOWN_FILES})

endif ()
