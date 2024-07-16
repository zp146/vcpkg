vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "ssh://git@172.24.146.81:8022/rl-autowheel/RlCommon.git"
    REF "7dac14f34c8fba4e2bc06b820b67c0b6db81f9c0"
)

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
