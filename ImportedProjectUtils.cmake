# /ImportedProjectUtils.cmake
#
# Some utility functions to make dealing with imported projects
# easier.
#
# See /LICENCE.md for Copyright information

if (NOT BIICODE)

    set (CMAKE_MODULE_PATH
         "${CMAKE_SOURCE_DIR}/bii/deps"
         "${CMAKE_MODULE_PATH}")

endif ()

include ("smspillaz/cmake-include-guard/IncludeGuard")
cmake_include_guard (SET_MODULE_PATH)
include ("smspillaz/cmake-header-language/DetermineHeaderLanguage")
include (CMakeParseArguments)

if (NOT CMAKE_SCRIPT_MODE_FILE)
    include (ExternalProject)
endif ()

# psq_import_utils_import_library
#
# Creates a new target with the imported library at
# a location with a specified type
#
# VARIABLE: Variable to store library name for linking in
# TARGET: Target to create
# LOCATION: Location of library to import
# TYPE: Type of library (STATIC, SHARED)
macro (psq_import_utils_import_library VARIABLE
                                       TARGET
                                       TYPE
                                       LOCATION)

    add_library (${TARGET} ${TYPE} IMPORTED GLOBAL)
    set_target_properties (${TARGET}
                           PROPERTIES IMPORTED_LOCATION ${LOCATION})
    set (${VARIABLE} ${TARGET} CACHE STRING "" FORCE)
    set (${VARIABLE}_LOCATION ${LOCATION} CACHE STRING "" FORCE)

endmacro ()

# psq_make_imported_target_depend_on_project
#
# Ensure that an imported target depends on an external project, and make
# explicit any file-level dependencies, such that pre-build stat generators
# like Ninjas can see the full dependency graph.
#
# TARGET : Target name
# PROJECT : Project that TARGET will depend on
function (psq_make_imported_target_depend_on_project TARGET PROJECT)

    get_property (TARGET_LOCATION
                  TARGET ${TARGET}
                  PROPERTY LOCATION)

    # Set each extracted library as a "source" of the external project.
    # This means that pre-build scanning generators like Ninja
    # will see that the library will be available as soon as the
    # external project is linked (as opposed to being available at
    # configure time).
    add_custom_command (OUTPUT ${TARGET_LOCATION}
                        DEPENDS ${PROJECT})
    add_custom_target (import_${TARGET}
                       SOURCES ${TARGET_LOCATION})
    add_dependencies (import_${TARGET} ${PROJECT})
    add_dependencies (${TARGET} import_${TARGET})

endfunction ()

# psq_import_utils_library_from_extproject
#
# Imports a library from an external project, adding a dependency to
# "generate" it from running the external project (in order to satisfy
# pre-build stat generators like Ninja)
#
# TARGET: Target to create
# TYPE: Type of library (STATIC, SHARED)
# LOCATION: Location of library to import
# EXTERNAL_PROJECT: Name of external project that generates this library.
macro (psq_import_utils_library_from_extproject TARGET
                                                TYPE
                                                LOCATION
                                                EXTERNAL_PROJECT)

    psq_import_utils_import_library (${TARGET} ${TYPE} ${LOCATION})
    psq_make_imported_target_depend_on_project (${TARGET}
                                                ${EXTERNAL_PROJECT})

endmacro ()

# psq_import_utils_append_typed_cache_definition
#
# Appends some typed values to a CMakeCache definition (eg, -DVALUE=OPTION)
#
# COPT: Name of the option
# VALUE: Value
# TYPE: (string, bool, path, file path)
# CLINES: Variable constituting the cache arguments
macro (psq_import_utils_append_typed_cache_definition COPT
                                                      VALUE
                                                      TYPE
                                                      CLINES)

    string (TOUPPER "${TYPE}" UTYPE)
    set (${CLINES}
         "${${CLINES}}\nset (${COPT} \"${VALUE}\" CACHE ${UTYPE} \"\" FORCE)")

endmacro ()

# psq_import_utils_append_cache_definition
#
# Appends some values to a CMakeCache definition (eg, -DVALUE=OPTION)
#
# CACHE_OPTION: Name of the option
# VALUE: Value
# CACHE_LINES: Variable constituting the cache arguments
macro (psq_import_utils_append_cache_definition CACHE_OPTION
                                                VALUE
                                                CACHE_LINES)

    psq_import_utils_append_typed_cache_definition (${CACHE_OPTION}
                                                    ${VALUE}
                                                    string
                                                    ${CACHE_LINES})

endmacro ()

# psq_import_utils_append_cache_definition_variable
#
# Appends some values to a CMakeCache definition (eg, -DVALUE=OPTION)
#
# CACHE_OPTION: Name of the option
# VALUE: Variable containing the value to append
# CACHE_LINES: Variable constituting the cache arguments,
macro (psq_import_utils_append_cache_definition_variable CACHE_OPTION
                                                         VALUE
                                                         CACHE_LINES)

    if (DEFINED ${VALUE})
        psq_import_utils_append_cache_definition (${CACHE_OPTION}
                                                  ${VALUE}
                                                  ${CACHE_LINES})
    endif ()

endmacro ()

# psq_forward_cache_namespaces_to_file
#
# Appends all variables in this project's cache matching any of
# of the namespaces provided in NAMESPACES to the file specified
# in CACHE_FILE
function (psq_forward_cache_namespaces_to_file CACHE_FILE)

    set (FORWARD_CACHE_MULTIVAR_ARGS NAMESPACES)

    cmake_parse_arguments (FORWARD_CACHE
                           ""
                           ""
                           "${FORWARD_CACHE_MULTIVAR_ARGS}"
                           ${ARGN})

    get_property (AVAILABLE_CACHE_VARIABLES
                  GLOBAL
                  PROPERTY CACHE_VARIABLES)

    # First pass - getting all the variables in the specified namespaces
    foreach (VAR ${AVAILABLE_CACHE_VARIABLES})

        # Search for the namespace at the beginning of the var name. If the
        # found position is 0, then this is a usable cache entry and we should
        # search for the next ":"
        foreach (NAMESPACE ${FORWARD_CACHE_NAMESPACES})

            string (FIND "${VAR}" "${NAMESPACE}" NS_POS)

            if (NS_POS EQUAL 0)

                list (APPEND NAMESPACED_VARIABLES ${VAR})

            endif ()

        endforeach ()

    endforeach ()

    # Second pass - adding those variables to the CACHE_DEFS
    foreach (VAR ${NAMESPACED_VARIABLES})

        get_property (CACHE_VARIABLE_TYPE
                      CACHE ${VAR}
                      PROPERTY TYPE)

        # Ignore STATIC, INTERNAL or UNINITIALIZED type cache entries
        # as they aren't user-modifiable or set.
        if (NOT CACHE_VARIABLE_TYPE STREQUAL "STATIC" AND
            NOT CACHE_VARIABLE_TYPE STREQUAL "INTERNAL" AND
            NOT CACHE_VARIABLE_TYPE STREQUAL "UNINITIALIZED")

            set (TYPE ${CACHE_VARIABLE_TYPE})
            psq_import_utils_append_typed_cache_definition (${VAR}
                                                            "${${VAR}}"
                                                            ${TYPE}
                                                            CACHE_DEFS)

        endif ()

    endforeach ()

    file (WRITE "${CACHE_FILE}" "${CACHE_DEFS}")

endfunction ()

function (psq_assign_variables_in_list PAIRS_LIST VARIABLES_LIST_RETURN)

    if (NOT ${PAIRS_LIST})

        set (${VARIABLES_LIST_RETURN}
             ${${VARIABLES_LIST_RETURN}}
             ""
             PARENT_SCOPE)
        return ()

    endif ()

    list (LENGTH ${PAIRS_LIST} PAIRS_LIST_LENGTH)
    math (EXPR PAIRS_LIST_MODULO "${PAIRS_LIST_LENGTH} % 2")

    if (NOT PAIRS_LIST_MODULO EQUAL 0)

        message (FATAL_ERROR "Length of ${PAIRS_LIST} must be even")

    endif ()

    math (EXPR PAIRS_LIST_MAXIMUM_COUNT "${PAIRS_LIST_LENGTH} - 1")
    foreach (PAIRS_LIST_INDEX RANGE 0 ${PAIRS_LIST_MAXIMUM_COUNT} 2)

        set (PAIRS_LIST_KEY_INDEX ${PAIRS_LIST_INDEX})
        math (EXPR PAIRS_LIST_VALUE_INDEX "${PAIRS_LIST_INDEX} + 1")

        list (GET ${PAIRS_LIST} ${PAIRS_LIST_KEY_INDEX} VARIABLE)
        list (GET ${PAIRS_LIST} ${PAIRS_LIST_VALUE_INDEX} VALUE)

        # But not in the cache, yet
        set (${VARIABLE} "${VALUE}" PARENT_SCOPE)
        list (APPEND VARIABLES_LIST ${VARIABLE})

    endforeach ()

    set (${VARIABLES_LIST_RETURN}
         ${${VARIABLES_LIST_RETURN}}
         "${VARIABLES_LIST}"
         PARENT_SCOPE)

endfunction ()

function (psq_exec_and_check_success NAME)

    set (EXEC_AND_CHECK_SUCCESS_MULTIVAR_ARGS COMMAND)
    set (EXEC_AND_CHECK_SUCCESS_SINGLEVAR_ARGS WORKING_DIRECTORY)

    cmake_parse_arguments (EXEC_AND_CHECK_SUCCESS
                           ""
                           "${EXEC_AND_CHECK_SUCCESS_SINGLEVAR_ARGS}"
                           "${EXEC_AND_CHECK_SUCCESS_MULTIVAR_ARGS}"
                           ${ARGN})

    if (NOT EXEC_AND_CHECK_SUCCESS_COMMAND)

        message (FATAL_ERROR "COMMAND must be set")

    endif ()

    if (NOT EXEC_AND_CHECK_SUCCESS_WORKING_DIRECTORY)

        message (FATAL_ERROR "WORKING_DIRECTORY must be set")

    endif ()


    set (LOG_PREFIX
         "${EXEC_AND_CHECK_SUCCESS_WORKING_DIRECTORY}/${NAME}")

    execute_process (COMMAND
                     ${EXEC_AND_CHECK_SUCCESS_COMMAND}
                     WORKING_DIRECTORY
                     "${EXEC_AND_CHECK_SUCCESS_WORKING_DIRECTORY}"
                     OUTPUT_FILE ${LOG_PREFIX}Output.txt
                     ERROR_FILE ${LOG_PREFIX}Error.txt
                     RESULT_VARIABLE RESULT)

    if (NOT RESULT EQUAL 0)

        file (READ ${LOG_PREFIX}Output.txt OUTPUT)
        file (READ ${LOG_PREFIX}Error.txt ERROR)
        message ("${OUTPUT}")
        message ("${ERROR}")
        message (FATAL_ERROR "${NAME} (${EXEC_AND_CHECK_SUCCESS_COMMAND})"
                             " failed with ${RESULT}")

    endif ()

endfunction ()

function (psq_create_metaproject_from_extproject PROJECT_NAME
                                                 EXTERNAL_PROJECT_ROOT
                                                 SOURCE_DIR
                                                 BINARY_DIR
                                                 EXPORTS
                                                 GENERATE_EXPORTS
                                                 INITIAL_CACHE
                                                 METAPROJECT_BUILD_RET)

    set (CREATE_METAPROJECT_MULTIVAR_ARGS OPTIONS TARGETS)

    cmake_parse_arguments (CREATE_METAPROJECT
                           ""
                           ""
                           "${CREATE_METAPROJECT_MULTIVAR_ARGS}"
                           ${ARGN})

    # The "download" metaproject is an "external project" which we build
    # at configure time, which causes the external project files to be
    # downloaded and configured to the actual external project source dir
    set (METAPROJECT
         "${EXTERNAL_PROJECT_ROOT}/${PROJECT_NAME}-Meta")
    set (METAPROJECT_BUILD "${METAPROJECT}/build")
    set (METAPROJECT_STAMP_DIR "${METAPROJECT}/configure-stamp")

    # If the user passed any CMAKE_ARGS, insert our cache
    # argument, otherwise insert CMAKE_ARGS into
    # the end of CREATE_METAPROJECT_OPTIONS
    list (FIND CREATE_METAPROJECT_OPTIONS "CMAKE_ARGS"
          CREATE_METAPROJECT_CMAKE_ARGS_INDEX)

    if ("${CREATE_METAPROJECT_CMAKE_ARGS_INDEX}" EQUAL "-1")

        list (APPEND CREATE_METAPROJECT_OPTIONS
              CMAKE_ARGS
              "\"-C${INITIAL_CACHE}\"")
    else ()

        math (EXPR CREATE_METAPROJECT_CMAKE_ARGS_INSERT_INDEX
              "${CREATE_METAPROJECT_CMAKE_ARGS_INDEX} + 2")
        list (INSERT CREATE_METAPROJECT_OPTIONS
              "${CREATE_METAPROJECT_CMAKE_ARGS_INDEX}"
              "\"-C${INITIAL_CACHE}\"")

    endif ()

    # Need to pass this as space separated later
    string (REPLACE ";" " " CREATE_METAPROJECT_OPTIONS
            "${CREATE_METAPROJECT_OPTIONS}")

    # Escape spaces in the generator so that they aren't turned into list
    # separators when passing them to add_custom_command
    string (REPLACE " " "\\ " GENERATOR ${CMAKE_GENERATOR})

    set (METAPROJECT_CMAKELISTS
         "include (ExternalProject)\n"
         "externalproject_add (\"${PROJECT_NAME}\"\n"
         "                     ${CREATE_METAPROJECT_OPTIONS}\n"
         "                     PREFIX \"${EXTERNAL_PROJECT_ROOT}\"\n"
         "                     BINARY_DIR\n"
         "                     \"${BINARY_DIR}\"\n"
         "                     STAMP_DIR\n"
         "                     \"${METAPROJECT_STAMP_DIR}\"\n"
         "                     BUILD_COMMAND \"\"\n"
         "                     INSTALL_COMMAND \"\"\n"
         "                     CMAKE_GENERATOR\n"
         "                     \"${GENERATOR}\")\n")

    if (GENERATE_EXPORTS)

        # File that we will be appending to
        set (APPEND_TO "${SOURCE_DIR}/CMakeLists.txt")

        # Make a list of targets to be exported
        foreach (VARIABLE ${CREATE_METAPROJECT_TARGETS})

            list (APPEND EXPORTED ${${VARIABLE}})

        endforeach ()

        # Make the list of targets to export into a single string
        string (REPLACE ";" " " EXPORTED "${EXPORTED}")

        # A script which will append an export () command to a file
        set (METAPROJECT_APPEND_EXPORT_SCRIPT_CONTENTS
             "file (APPEND \"${APPEND_TO}\"\n"
             "      \"\\nexport (TARGETS ${EXPORTED}\\n\"\n"
             "      \"           FILE \"${EXPORTS}.cmake\")\\n\")\n")
        string (REPLACE ";" ""
                METAPROJECT_APPEND_EXPORT_SCRIPT_CONTENTS
                "${METAPROJECT_APPEND_EXPORT_SCRIPT_CONTENTS}")
        set (METAPROJECT_APPEND_EXPORTS
             "${METAPROJECT}/AppendExportTargets.cmake")
        file (WRITE ${METAPROJECT_APPEND_EXPORTS}
              "${METAPROJECT_APPEND_EXPORT_SCRIPT_CONTENTS}")

        # Add a new step to the meta-project to append an exports
        # command to the end of the downloaded /CMakeLists.txt, which should
        # run before the configure steps
        set (METAPROJECT_CMAKELISTS
             "${METAPROJECT_CMAKELISTS}\n"
             "externalproject_add_step (\"${PROJECT_NAME}\"\n"
             "                          append_exports\n"
             "                          COMMENT\n"
             "                          \"Adding exports to ${PROJECT_NAME}\"\n"
             "                          DEPENDEES download patch\n"
             "                          DEPENDERS configure\n"
             "                          COMMAND\n"
             "                          \"${CMAKE_COMMAND}\"\n"
             "                          \"-DAPPEND_TO_FILE=${APPEND_TO}\"\n"
             "                          -P\n"
             "                          \"${METAPROJECT_APPEND_EXPORTS}\"\n"
             "                          LOG)\n")

    endif ()

    string (REPLACE ";" ""
            METAPROJECT_CMAKELISTS
            "${METAPROJECT_CMAKELISTS}")

    file (MAKE_DIRECTORY ${METAPROJECT})
    file (MAKE_DIRECTORY ${METAPROJECT_BUILD})
    file (WRITE "${METAPROJECT}/CMakeLists.txt"
          "${METAPROJECT_CMAKELISTS}")

    set (${METAPROJECT_BUILD_RET} ${METAPROJECT_BUILD} PARENT_SCOPE)

endfunction ()

function (psq_run_metaproject METAPROJECT_BUILD_DIR
                              EXTERNAL_PROJECT_BINARY_DIR
                              INITIAL_CACHE
                              EXTERNAL_PROJECT_EXPORTS_RETURN)

    # Configure the "download" meta-project
    psq_exec_and_check_success (ConfigMetaProject
                                COMMAND
                                "${CMAKE_COMMAND}"
                                ..
                                -C${INITIAL_CACHE}
                                -G${CMAKE_GENERATOR}
                                WORKING_DIRECTORY
                                "${METAPROJECT_BUILD_DIR}")

    if (CMAKE_GENERATOR MATCHES ".*Ninja.*")

        set (BUILD_TOOL_VERBOSE_OPTION "-v")

    endif ()

    # Build the "download" meta-project. This will cause the actual external
    # project to be downloaded, configured and built, but not installed.
    psq_exec_and_check_success (BuildMetaProject
                                COMMAND "${CMAKE_COMMAND}"
                                        --build
                                        .
                                        --
                                        ${BUILD_TOOL_VERBOSE_OPTION}
                                WORKING_DIRECTORY
                                "${METAPROJECT_BUILD_DIR}")

    set (EXTERNAL_PROJECT_EXPORTS
         "${EXTERNAL_PROJECT_BINARY_DIR}/${EXPORTS}.cmake")

    # Complain if we can't find the EXPORTS file, as we need it
    if (NOT EXISTS ${EXTERNAL_PROJECT_EXPORTS})

        message (FATAL_ERROR "Couldn't find ${EXPORTS}.cmake in "
                             "the build directory of ${PROJECT_NAME}.\n"
                             "Imported external projects must export targets "
                             "using the export() command. If they do not, then "
                             "consider adding the GENERATE_EXPORTS to a call "
                             "of psq_import_external_project instead, "
                             "which will automatically append the correct "
                             "command to the external project's CMakeLists.txt")

    endif ()

    set (${EXTERNAL_PROJECT_EXPORTS_RETURN}
         ${EXTERNAL_PROJECT_EXPORTS}
         PARENT_SCOPE)

endfunction ()

# psq_import_external_project
#
# For a project name PROJECT_NAME and the basename of that project's
# exported targets file while configured, EXPORTS, imports an external project.
#
# This functions as a wrapper around externalproject_add, however the key
# difference is that the external project will be downloaded and configured
# (only) at configure-time instead of at build-time. This means that we are
# able to import targets, like any built libraries from it directly. This will
# work across generators.
#
# This command assumes that the imported external project will have an exports
# file by the name of EXPORTS. If the imported external project does not
# generate one, then GENERATE_EXPORTS indicates that it should be
# patched into the external project's /CMakeLists.txt
#
# The caller should specify how the external project is to be found in the
# same way that a call to ExternalProject might be made, for instance by
# specifying SOURCE_DIR, URL, CVS_REPOSITORY, SVN_REPOSITORY, GIT_REPOSITORY,
# HG_REPOSITORY, etc.
# For instance:
#
# psq_import_external_project (Project project-exports
#                                     URL http://my.domain/project)
#
# The desired target imports should be specified in TARGETS in the form of
# pairs of a variable name to store the imported target name as in part of the
# CMake cache and the target name itself. Any include directories should be
# specified as in INCLUDE_DIRS in the same format, with the include directory
# being a path relative to the imported project's source directory.
# For instance:
#
# psq_import_external_project (Project project-exports
#                                     TARGETS MY_TARGET my_target
#                                     INCLUDE_DIRS MY_INCLUDE_DIR include/)
#
# Sometimes it is desirable to propagate or set certain variables in the
# external project itself when it is being configured. This command
# allows "namespaces" of variables to be propagated when specified in
# NAMESPACES, for instance, POLYSQUARE will propagate any variable in the
# CMake Cache that begins with POLYSQUARE.
# For instance:
#
# psq_import_external_project (Project project-exports
#                              NAMESPACES POLYSQUARE)
#
# PROJECT_NAME : The name of the external project.
# EXPORTS : The basename of the project's exports file.
#
function (psq_import_external_project PROJECT_NAME EXPORTS)

    set (IMPORT_PROJECT_OPTION_ARGS GENERATE_EXPORTS)
    set (IMPORT_PROJECT_MULTIVAR_ARGS OPTIONS
                                      TARGETS
                                      INCLUDE_DIRS
                                      DEPENDS
                                      NAMESPACES)
    cmake_parse_arguments (IMPORT_PROJECT
                           "${IMPORT_PROJECT_OPTION_ARGS}"
                           ""
                           "${IMPORT_PROJECT_MULTIVAR_ARGS}"
                           ${ARGN})

    message (STATUS "Downloading and pre-configuring ${PROJECT_NAME}")

    # Set up main External Project variables.
    set (EXTERNAL_PROJECT_ROOT "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}")

    # The actual external project, which will be built at build time
    set (INITIAL_CACHE "${EXTERNAL_PROJECT_ROOT}/initial_cache.cmake")

    # By default, we use these. But see below. Don't rename these variables
    # as the override code depends on them having these names.
    set (EXTERNAL_PROJECT_DIST "${EXTERNAL_PROJECT_ROOT}/src")
    set (EXTERNAL_PROJECT_SOURCE_DIR "${EXTERNAL_PROJECT_DIST}/${PROJECT_NAME}")
    set (EXTERNAL_PROJECT_BINARY_DIR "${EXTERNAL_PROJECT_DIST}/build")
    set (EXTERNAL_PROJECT_STAMP_DIR "${EXTERNAL_PROJECT_DIST}/stamp")

    file (MAKE_DIRECTORY "${EXTERNAL_PROJECT_SOURCE_DIR}")
    file (MAKE_DIRECTORY "${EXTERNAL_PROJECT_BINARY_DIR}")
    file (MAKE_DIRECTORY "${EXTERNAL_PROJECT_STAMP_DIR}")

    # We need to be a little bit clever about setting
    # EXTERNAL_PROJECT_SOURCE_DIR and EXTERNAL_PROJECT_BINARY_DIR. If the caller
    # specifies SOURCE_DIR or BINARY_DIR then externalproject_add will just use
    # those, so we need to make sure that we use them too.
    set (CAPTURE_EP_ARGS SOURCE_DIR BINARY_DIR STAMP_DIR)

    foreach (ARG ${IMPORT_PROJECT_OPTIONS})

        # Find the current argument as part of OPTIONS in CAPTURE_EP_ARGS -
        # if found, then set EXTERNAL_PROJECT_${ARG} to index + 1
        list (FIND CAPTURE_EP_ARGS "${ARG}" FOUND_IN_CAPTURE_EP_ARGS)

        if (NOT FOUND_IN_CAPTURE_EP_ARGS EQUAL -1)

            list (FIND IMPORT_PROJECT_OPTIONS ${ARG} INDEX)
            math (EXPR VALUE_INDEX "${INDEX} + 1")
            list (GET IMPORT_PROJECT_OPTIONS ${VALUE_INDEX} ARG_VALUE)
            set (EXTERNAL_PROJECT_${ARG} ${ARG_VALUE})

            if (NOT "${ARG}" STREQUAL "SOURCE_DIR")

                # With the exception of SOURCE_DIR, remove the option from
                # IMPORT_PROJECT_OPTIONS, since we'll be passing it
                # explicitly now.
                list (REMOVE_ITEM IMPORT_PROJECT_OPTIONS "${ARG}")
                list (REMOVE_ITEM IMPORT_PROJECT_OPTIONS
                      "${EXTERNAL_PROJECT_${ARG}}")

            endif ()

        endif ()

    endforeach ()

    # Set up the variables for the targets and include directories we will
    # be importing later
    psq_assign_variables_in_list (IMPORT_PROJECT_TARGETS
                                  TARGET_VARIABLES)
    psq_assign_variables_in_list (IMPORT_PROJECT_INCLUDE_DIRS
                                  INCLUDE_DIR_VARIABLES)

    # Forward cache namespaces. The CMAKE namespace will be forwarded by
    # default. This ensures that all subprojects are built with the
    # same builder, compiler flags, etc.
    psq_forward_cache_namespaces_to_file (${INITIAL_CACHE}
                                          NAMESPACES
                                          CMAKE
                                          ${IMPORT_PROJECT_NAMESPACES})

    if (IMPORT_PROJECT_GENERATE_EXPORTS)

        set (GENERATE_EXPORTS ON)

    else ()

        set (GENERATE_EXPORTS OFF)

    endif ()

    # Create meta-project to download and configure external project at
    # configure-time. The METAPROJECT_BUILD_DIR will be set on success.
    psq_create_metaproject_from_extproject (${PROJECT_NAME}
                                            ${EXTERNAL_PROJECT_ROOT}
                                            "${EXTERNAL_PROJECT_SOURCE_DIR}"
                                            "${EXTERNAL_PROJECT_BINARY_DIR}"
                                            ${EXPORTS}
                                            ${GENERATE_EXPORTS}
                                            ${INITIAL_CACHE}
                                            METAPROJECT_BUILD_DIR
                                            OPTIONS
                                            ${IMPORT_PROJECT_OPTIONS}
                                            TARGETS
                                            ${TARGET_VARIABLES})

    psq_run_metaproject ("${METAPROJECT_BUILD_DIR}"
                         "${EXTERNAL_PROJECT_BINARY_DIR}"
                         ${INITIAL_CACHE}
                         EXTERNAL_PROJECT_EXPORTS)

    # Now extract the target's EXPORTS file
    include (${EXTERNAL_PROJECT_EXPORTS})

    # Now add an external project which just builds whats in the downloaded
    # external project. The project will re-configure again, though
    # no cache variables will be passed so it will re-use the same cache
    externalproject_add (${PROJECT_NAME}
                         DEPENDS ${IMPORT_PROJECT_DEPENDS}
                         STAMP_DIR "${EXTERNAL_PROJECT_STAMP_DIR}"
                         SOURCE_DIR "${EXTERNAL_PROJECT_SOURCE_DIR}"
                         BINARY_DIR "${EXTERNAL_PROJECT_BINARY_DIR}"
                         INSTALL_COMMAND ""
                         PREFIX ${EXTERNAL_PROJECT_ROOT}
                         LOG_DOWNLOAD 1
                         LOG_UPDATE 1
                         LOG_CONFIGURE 1
                         LOG_BUILD 1)

    # Add the BINARY_DIR to ADDITIONAL_MAKE_CLEAN_FILES as externalproject_add
    # doesn't do that by default.
    set_property (GLOBAL APPEND
                  PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
                  "${EXTERNAL_PROJECT_BINARY_DIR}")

    foreach (TARGET ${TARGET_VARIABLES})
        set (TARGET_VARIABLE ${TARGET})
        set (TARGET_NAME ${${TARGET_VARIABLE}})

        psq_make_imported_target_depend_on_project (${TARGET_NAME}
                                                    ${PROJECT_NAME})

        # Get the location of the target and put that in the cache too
        get_property (TARGET_LOCATION
                      TARGET ${TARGET_NAME}
                      PROPERTY LOCATION)
        set (${TARGET_VARIABLE}_LOCATION ${TARGET_LOCATION}
             CACHE STRING "" FORCE)
        set (${TARGET_VARIABLE} ${TARGET_NAME} CACHE STRING "" FORCE)

        mark_as_advanced (${TARGET_VARIABLE}_LOCATION)
        mark_as_advanced (${TARGET_VARIABLE})
    endforeach ()

    foreach (INCLUDE_DIR ${INCLUDE_DIR_VARIABLES})
        set (INCLUDE_DIR_VARIABLE "${INCLUDE_DIR}")
        set (INCLUDE_DIR_PATH ${${INCLUDE_DIR_VARIABLE}})

        set (${INCLUDE_DIR_VARIABLE}
             "${EXTERNAL_PROJECT_SOURCE_DIR}/${INCLUDE_DIR_PATH}"
             CACHE STRING "" FORCE)
    endforeach ()

endfunction ()
