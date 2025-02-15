# windowscross_vcpkg

## How to use
### Building the vcpkg triplet

Build your own vcpkg triplet (if you want to use vcpkg) and put it in the vcpkg (community) triplet folder: /vcpkg/triplets/community

Triplet example for Windows 64bits (x64-windows-mytriplet.cmake)
```
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE static)
set(VCPKG_LIBRARY_LINKAGE static)
# You can override linkage type by package if needed
if(PORT STREQUAL "portaudio")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

set(VCPKG_BUILD_TYPE release)

set(ENV{HOST_ARCH} ${VCPKG_TARGET_ARCHITECTURE})

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE /clang_windows_sdk/clang-cl-msvc.cmake)

set(ENV{VCPKG_TOOLCHAIN} "/vcpkg/scripts/toolchains/windows.cmake")

set(VCPKG_POLICY_SKIP_ARCHITECTURE_CHECK enabled)
```

Triplet example for Windows 32bits (x86-windows-mytriplet.cmake)
```
set(VCPKG_TARGET_ARCHITECTURE x86)
set(VCPKG_CRT_LINKAGE static)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_BUILD_TYPE release)

set(ENV{HOST_ARCH} ${VCPKG_TARGET_ARCHITECTURE})

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE /clang_windows_sdk/clang-cl-msvc.cmake)

set(ENV{VCPKG_TOOLCHAIN} "/vcpkg/scripts/toolchains/windows.cmake")

set(VCPKG_POLICY_SKIP_ARCHITECTURE_CHECK enabled)
```

### Cross-compiling vcpkg libraries
vcpkg is in the PATH of this docker image, so you don't need to call it explicitly.

Cross-compiling libraries:
Define one triplet for multiple libraries:
```
vcpkg install --triplet=x86-windows-mytriplet zlib fmt
```
or define triplet for each library
```
vcpkg install zlib:x86-windows-mytriplet fmt:x64-windows-mytriplet
```

### Using cross-compiled vcpkg libraries with CMake
Build you own CMakeLists.txt and call it with the CMAKE_TOOLCHAIN_FILE and vcpkg variables:
```
export HOST_ARCH=x86
cmake -G Ninja -Wno-dev -DCMAKE_BUILD_TYPE=Release "-DVCPKG_TARGET_TRIPLET=x86-windows-mytriplet" "-DCMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake" "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=/clang_windows_sdk/clang-cl-msvc.cmake" -S . -B out
cmake --build out
cmake --install out
```
