ARG CLANG_VER
ARG UBUNTU_VER
FROM nemirtingas/nemirtingas_compilation_base:ubuntu${UBUNTU_VER}_clang${CLANG_VER}
ARG MSVC_VER
ARG WINSDK_VER
ENV MSVC_BASE=/clang_windows_sdk/msvc
ENV MSVC_VER=${MSVC_VER}
ENV WINSDK_BASE=/clang_windows_sdk/winsdk
ENV WINSDK_VER=${WINSDK_VER}
ENV WindowsSdkDir="${WINSDK_BASE}/"
ENV WindowsSDKVersion="${WINSDK_VER}"
RUN cd / &&\
    git clone https://github.com/Nemirtingas/clang-msvc-sdk clang_windows_sdk --depth=1 &&\
    git clone https://github.com/Nemirtingas/windowscross_vcpkg "--branch=${MSVC_VER}" --depth=1 "${MSVC_BASE}_tmp" &&\
    cd "${MSVC_BASE}" &&\
    cat "${MSVC_BASE}_tmp/"*.tgz* | tar xz &&\
    rm -rf "${MSVC_BASE}_tmp" &&\
    git clone https://github.com/Nemirtingas/windowscross_vcpkg "--branch=winsdk_${WINSDK_VER}" --depth=1 "${WINSDK_BASE}_tmp" &&\
    cd "${WINSDK_BASE}" &&\
    cat "${WINSDK_BASE}_tmp/"*.tgz* | tar xz &&\
    rm -rf "${WINSDK_BASE}_tmp" &&\
    ln -s /clang_windows_sdk/powershell /usr/bin/
