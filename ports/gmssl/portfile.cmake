vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO guanzhi/GmSSL
    REF v3.1.1
    SHA512 7bab347d916973e65928cbc9925c0332234b1ae0fb53473110f8b584b61f28dba971a1aba10e6bde14c35d707f9c6b5cf1745ea92135c5c6c97dd809c26da18d
    HEAD_REF master
)

# GmSSL 3.1.1 默认会在非 iOS 平台构建命令行工具/测试/示例，
# 此处将条件改为恒假，仅保留 gmssl 库，缩短构建并避免安装多余产物。
file(READ "${SOURCE_PATH}/CMakeLists.txt" _cmake_lists)
string(REPLACE
    "if (NOT \${CMAKE_SYSTEM_NAME} STREQUAL \"iOS\")"
    "if (FALSE) # vcpkg overlay: skip tools/tests/demos"
    _cmake_lists "${_cmake_lists}")
# MSVC 块在 if(NOT iOS) 之外仍引用 gmssl-bin，一并跳过
string(REPLACE
    "target_compile_options(gmssl-bin PRIVATE /utf-8)"
    "# vcpkg overlay: gmssl-bin skipped"
    _cmake_lists "${_cmake_lists}")
# MSVC 块硬编码了安装前缀 C:/Program Files/GmSSL，覆盖 vcpkg 前缀，需移除
string(REPLACE
    "set(CMAKE_INSTALL_PREFIX \"C:/Program Files/GmSSL\")"
    "# vcpkg overlay: use vcpkg install prefix"
    _cmake_lists "${_cmake_lists}")
file(WRITE "${SOURCE_PATH}/CMakeLists.txt" "${_cmake_lists}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
