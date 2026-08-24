vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gmssl/gmssl
    REF "v${VERSION}"
    SHA512 0          # 先留 0，install 报错回填真实值
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