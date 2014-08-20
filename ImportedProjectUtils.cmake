# /ImportedProjectUtils.cmake
#
# Some utility functions to make dealing with imported projects
# easier.
#
# See LICENCE.md for Copyright information.

# polysquare_imported_project_utils_import_library
#
# Creates a new target with the imported library at
# a location with a specified type
#
# TARGET: Target to create
# LOCATION: Location of library to import
# TYPE: Type of library (STATIC, SHARED)
macro (polysquare_import_utils_import_library TARGET
                                              TYPE
                                              LOCATION)

    add_library (${TARGET} ${TYPE} IMPORTED GLOBAL)
    set_target_properties (${TARGET}
                           PROPERTIES IMPORTED_LOCATION ${LOCATION})

endmacro (polysquare_import_utils_import_library)

# polysquare_import_utils_library_from_extproject
#
# Imports a library from an external project, adding a dependency to
# "generate" it from running the external project (in order to satisfy
# pre-build stat generators like Ninja)
#
# TARGET: Target to create
# TYPE: Type of library (STATIC, SHARED)
# LOCATION: Location of library to import
# EXTERNAL_PROJECT: Name of external project that generates this library.
macro (polysquare_import_utils_library_from_extproject TARGET
                                                       TYPE
                                                       LOCATION
                                                       EXTERNAL_PROJECT)

    # Also create a rule to "generate" the library on disk by running
    # the external project build process. This satisfies pre-build
    # stat generators like Ninja.
    add_custom_command (OUTPUT ${LOCATION}
                        DEPENDS ${EXTERNAL_PROJECT})
    add_custom_target (ensure_build_of_${TARGET}
                       SOURCES ${LOCATION})

    polysquare_import_utils_import_library (${TARGET} ${TYPE} ${LOCATION})
    set_target_properties (${TARGET}
                           PROPERTIES EXTERNAL_PROJECT ${EXTERNAL_PROJECT})
    add_dependencies (${TARGET} ${EXTERNAL_PROJECT})
    add_dependencies (${TARGET} ensure_build_of_${TARGET})

endmacro (polysquare_import_utils_library_from_extproject)

# polysquare_import_utils_get_build_suffix_for_generator
#
# Some generators place executables withing CMAKE_BINARY_DIR/BuildType
# (where BuildType may be "Debug", "Release" etc). Get the suffix
# that these generators use.
#
# SUFFIX: Name of a variable to hold the result.
function (polysquare_import_utils_get_build_suffix_for_generator SUFFIX)

    if (${CMAKE_GENERATOR} STREQUAL "Xcode")

        if (CMAKE_BUILD_TYPE)

            set (${SUFFIX} ${CMAKE_BUILD_TYPE} PARENT_SCOPE)

        else (CMAKE_BUILD_TYPE)

            set (${SUFFIX} "Debug" PARENT_SCOPE)

        endif (CMAKE_BUILD_TYPE)

    endif (${CMAKE_GENERATOR} STREQUAL "Xcode")

endfunction (polysquare_import_utils_get_build_suffix_for_generator)

# polysquare_import_utils_get_library_location
#
# Some generators place executables withing CMAKE_BINARY_DIR/BuildType
# (where BuildType may be "Debug", "Release" etc). Get the suffix
# that these generators use.
#
# LIBRARY: Target name or library location
# RESULT: Name of a variable to hold the result location
function (polysquare_import_utils_get_library_location LIBRARY
                                                       RESULT)

    set (_location)
    if (TARGET ${LIBRARY})
        get_property (_location TARGET ${LIBRARY} PROPERTY LOCATION)
    endif (TARGET ${LIBRARY})

    # If a location is set, we should use that one, otherwise
    # just use the linker line
    if (_location)
        set (${RESULT} ${_location} PARENT_SCOPE)
    else (_location)
        set (${RESULT} ${_location} ${LIBRARY} PARENT_SCOPE)
    endif (_location)

endfunction (polysquare_import_utils_get_library_location)

# polysquare_import_utils_get_library_location_from_variable
#
# Some generators place executables withing CMAKE_BINARY_DIR/BuildType
# (where BuildType may be "Debug", "Release" etc). Get the suffix
# that these generators use.
#
# LIBRARY: Name of a variable that holds the library we want the location of
# RESULT: Name of a variable to hold the result location
function (polysquare_import_utils_get_library_location_from_variable LIBRARY
                                                                     RESULT)

    if (DEFINED ${LIBRARY})

        set (INTERNAL_RESULT)
        polysquare_import_utils_get_library_location (${${LIBRARY}}
                                                      INTERNAL_RESULT)
        set (${RESULT} ${INTERNAL_RESULT} PARENT_SCOPE)

    endif (DEFINED ${LIBRARY})

endfunction (polysquare_import_utils_get_library_location_from_variable)

# polysquare_import_utils_append_cache_definition
#
# Appends some values to a CMakeCache definition (eg, -DVALUE=OPTION)
#
# CACHE_OPTION: Name of the option
# VALUE: Value
# CACHE_LINES: Variable constituting the cache arguments, 
macro (polysquare_import_utils_append_cache_definition CACHE_OPTION
                                                       VALUE
                                                       CACHE_LINES)

    list (APPEND ${CACHE_LINES}
          "-D${CACHE_OPTION}:string=${VALUE}")

endmacro (polysquare_import_utils_append_cache_definition)

# polysquare_import_utils_append_cache_definition_variable
#
# Appends some values to a CMakeCache definition (eg, -DVALUE=OPTION)
#
# CACHE_OPTION: Name of the option
# VALUE: Variable containing the value to append
# CACHE_LINES: Variable constituting the cache arguments, 
macro (polysquare_import_utils_append_cache_definition_variable CACHE_OPTION
                                                                VALUE
                                                                CACHE_LINES)

    if (DEFINED ${VALUE})
        polysquare_import_utils_append_cache_definition (${CACHE_OPTION}
                                                         ${VALUE}
                                                         ${CACHE_LINES})
    endif (DEFINED ${VALUE})

endmacro (polysquare_import_utils_append_cache_definition_variable)