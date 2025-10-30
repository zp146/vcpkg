vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "git@github.com:zp146/CCCoreLib.git"
    REF "126e2605c75a5855b40624cefff9336ebabdce91"
)

# 手动下载 nanoflann
vcpkg_from_github(
    OUT_SOURCE_PATH NANOFLANN_SOURCE_PATH
    REPO jlblancoc/nanoflann
    REF v1.5.0
    SHA512 2248EED37872737C1F3C031E65D2F892024E35AA81CCF14CF8222289CFE12B5CA3FE461749E060FF822CA9E40DD9CB918216468C1343A42305F7ADF780888C50
)

# 复制 nanoflann 到正确位置
file(COPY "${NANOFLANN_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/extern/nanoflann")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
# 安装使用说明
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")