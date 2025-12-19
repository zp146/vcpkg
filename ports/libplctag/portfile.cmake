vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libplctag/libplctag
    REF "v${VERSION}"
    SHA512 f540780642112483bd199995b327342bd2df2ec4a4d44c2356886ab94879aeb2da3e420760da2f00b5aee0d1278fc582f73cba8227b276787d21b18fa12a3add
    HEAD_REF master
	PATCHES
        fix_install.patch
)

#file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)

#if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    #vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libplctag.h" "elif defined(LIBBUILD)" "elif 1")
#endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-2.LGPL")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
