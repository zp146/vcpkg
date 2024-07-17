vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "ssh://git@10.50.135.26:8022/Mpp/FyRadar.git"
    REF "94b3c95dcec14134a1f296e5d001ded440578485"
)

#file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeHelpers.cmake" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS ${FEATURE_OPTIONS}
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
    OPTIONS_DEBUG 
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
