vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sqlcipher/sqlcipher
    REF "v${VERSION}"
    SHA512 023b2fc7248fe38b758ef93dd8436677ff0f5d08b1061e7eab0adb9e38ad92d523e0ab69016ee69bd35c1fd53c10f61e99b01f7a2987a1f1d492e1f7216a0a9c
    HEAD_REF master
)

# Find tclsh Executable needed for Amalgamation of SQLite
file(GLOB TCLSH_CMD
		${CURRENT_INSTALLED_DIR}/tools/tcl/bin/tclsh*${VCPKG_HOST_EXECUTABLE_SUFFIX}
)

# Check if TCLSH_CMD is empty and provide fallback
if(NOT TCLSH_CMD)
    message(WARNING "No tclsh found in ${CURRENT_INSTALLED_DIR}/tools/tcl/bin/, trying system tclsh")
    find_program(TCLSH_CMD tclsh)
    if(NOT TCLSH_CMD)
        message(FATAL_ERROR "tclsh not found. Please install tcl package first.")
    endif()
endif()

# Take the first match if multiple found
list(GET TCLSH_CMD 0 TCLSH_CMD)
file(TO_NATIVE_PATH "${TCLSH_CMD}" TCLSH_CMD)
file(TO_NATIVE_PATH "${SOURCE_PATH}" SOURCE_PATH_NAT)

# Determine TCL version (e.g. [path]tclsh90sx.exe -> 90 or tclsh8.6 -> 8.6)
if(TCLSH_CMD)
    message(STATUS "Found TCLSH_CMD: ${TCLSH_CMD}")
    string(REGEX REPLACE "^.*tclsh" "" TCLVERSION "${TCLSH_CMD}")
    message(STATUS "TCLVERSION after first regex: ${TCLVERSION}")
    
    # Check if VCPKG_HOST_EXECUTABLE_SUFFIX is defined and not empty
    if(DEFINED VCPKG_HOST_EXECUTABLE_SUFFIX AND VCPKG_HOST_EXECUTABLE_SUFFIX)
        message(STATUS "VCPKG_HOST_EXECUTABLE_SUFFIX: '${VCPKG_HOST_EXECUTABLE_SUFFIX}'")
        if(VCPKG_TARGET_IS_WINDOWS)
            if(TCLVERSION MATCHES ".*${VCPKG_HOST_EXECUTABLE_SUFFIX}$")
                string(REGEX REPLACE "[A-Za-z]*${VCPKG_HOST_EXECUTABLE_SUFFIX}$" "" TCLVERSION "${TCLVERSION}")
            endif()
        else()
            if(TCLVERSION MATCHES ".*${VCPKG_HOST_EXECUTABLE_SUFFIX}$")
                string(REGEX REPLACE "${VCPKG_HOST_EXECUTABLE_SUFFIX}$" "" TCLVERSION "${TCLVERSION}")
            endif()
        endif()
    else()
        message(STATUS "VCPKG_HOST_EXECUTABLE_SUFFIX is empty or undefined, skipping suffix removal")
    endif()
    message(STATUS "Final TCLVERSION: ${TCLVERSION}")
else()
    set(TCLVERSION "8.6")
    message(WARNING "Could not determine TCL version, using default: ${TCLVERSION}")
endif()

if(CMAKE_HOST_WIN32)
    # Windows-specific build using nmake
    find_program(NMAKE nmake REQUIRED)
    
    list(APPEND NMAKE_OPTIONS
        TCLSH_CMD="${TCLSH_CMD}"
        TCLVERSION=${TCLVERSION}
        ORIGINAL_SRC="${SOURCE_PATH_NAT}"
        EXT_FEATURE_FLAGS=-DSQLITE_TEMP_STORE=2\ -DSQLITE_HAS_CODEC
        LTLIBS=libcrypto.lib
        LTLIBPATHS=/LIBPATH:"${CURRENT_INSTALLED_DIR}/lib/"
    )

    set(ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include;$ENV{INCLUDE}")

    # Creating amalgamation files
    message(STATUS "Pre-building ${TARGET_TRIPLET}")
    vcpkg_execute_required_process(
        COMMAND ${NMAKE} -f Makefile.msc /A /NOLOGO clean tcl
        ${NMAKE_OPTIONS}
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME pre-build-${TARGET_TRIPLET}
    )
    message(STATUS "Pre-building ${TARGET_TRIPLET} done")
else()
    # Unix-like systems (Linux/macOS) using make
    find_program(MAKE make REQUIRED)

    # 先运行 ./configure
    vcpkg_execute_required_process(
        COMMAND ./configure
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME configure-${TARGET_TRIPLET}
    )

    # Set environment variables for Unix systems
    set(ENV{CFLAGS} "-I${CURRENT_INSTALLED_DIR}/include")
    set(ENV{LDFLAGS} "-L${CURRENT_INSTALLED_DIR}/lib")
    set(ENV{TCLSH_CMD} "${TCLSH_CMD}")
    set(ENV{TCLVERSION} "${TCLVERSION}")
    set(ENV{ORIGINAL_SRC} "${SOURCE_PATH_NAT}")

    # Creating amalgamation files
    message(STATUS "Pre-building ${TARGET_TRIPLET}")
    vcpkg_execute_required_process(
        COMMAND ${MAKE} clean libtclsqlite3.la
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME pre-build-${TARGET_TRIPLET}
    )
    message(STATUS "Pre-building ${TARGET_TRIPLET} done")
endif()

# The rest of the build process with the CMakeLists.txt is merely a copy of sqlite3

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        geopoly WITH_GEOPOLY
        json1 WITH_JSON1
        fts5 WITH_FTS5
    INVERTED_FEATURES
        tool SQLITE3_SKIP_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} -DSQLCIPHER_VERSION=${VERSION}
    OPTIONS_DEBUG
        -DSQLITE3_SKIP_TOOLS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH share/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(NOT SQLITE3_SKIP_TOOLS AND EXISTS "${CURRENT_PACKAGES_DIR}/tools/${PORT}/sqlcipher-bin${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/${PORT}/sqlcipher-bin${VCPKG_HOST_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/sqlcipher${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/sqlcipher-config.in.cmake"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/sqlcipher-config.cmake"
    @ONLY
)

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
vcpkg_fixup_pkgconfig()
