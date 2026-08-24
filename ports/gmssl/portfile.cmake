vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gmssl/gmssl
    REF "v${VERSION}"
    SHA512 7bab347d916973e65928cbc9925c0332234b1ae0fb53473110f8b584b61f28dba971a1aba10e6bde14c35d707f9c6b5cf1745ea92135c5c6c97dd809c26da18d
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGMSSL_NO_OPENSSL_COMPAT=ON   # 关键：关闭兼容层，避开与 OpenSSL 符号冲突
        -DGMSSL_BUILD_TOOLS=OFF
        -DGMSSL_BUILD_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")