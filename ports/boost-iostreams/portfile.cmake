# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/iostreams
    REF boost-${VERSION}
    SHA512 4ceafacc4eb5797f3add43e45b7ea6232724abe553b1069d050bfdbcf82a236e9a4e662f88f8a11d6bc760b55fb43b898692bed006455f7753baf2c9a74baf6c
    HEAD_REF master
    PATCHES
        Removeseekpos.patch
        fix-zstd.diff
)

set(FEATURE_OPTIONS "")
include("${CMAKE_CURRENT_LIST_DIR}/features.cmake")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
