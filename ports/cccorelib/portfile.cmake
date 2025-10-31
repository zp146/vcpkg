vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "git@github.com:zp146/CCCoreLib.git"
    REF "0f7d944b02203926ed47669058435ac055147a09"
)

# 映射 features -> CMake 选项（默认 OFF，避免强制安装）
vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cgal         CCCORELIB_USE_CGAL
        tbb          CCCORELIB_USE_TBB
        qtconcurrent CCCORELIB_USE_QT_CONCURRENT
)

# 共享/静态库根据 vcpkg 链接方式设置
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(_CCCORELIB_SHARED OFF)
else()
    set(_CCCORELIB_SHARED ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCCCORELIB_SHARED=${_CCCORELIB_SHARED}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# 如果项目安装到 lib/cmake/CCCoreLib（当前代码默认），请用这行：
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/CCCoreLib PACKAGE_NAME CCCoreLib)

# 如果你按我之前建议改为 share/CCCoreLib，则改为：
# vcpkg_cmake_config_fixup(CONFIG_PATH share/CCCoreLib PACKAGE_NAME CCCoreLib)

# 版权
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

# 清理
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# 使用说明
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")