FROM ubuntu:18.04
ENV CLANG_VER         9
ENV LLVM_VER          ${CLANG_VER}
ENV MSVC_BASE         /clang_windows_sdk/msvc
ENV MSVC_VER          msvc2019
ENV WINSDK_BASE       /clang_windows_sdk/winsdk
ENV WINSDK_VER        "10.0.18362.0"
ENV WindowsSdkDir     "${WINSDK_BASE}/"
ENV WindowsSDKVersion "${WINSDK_VER}"
RUN dpkg --add-architecture i386 &&\
    apt update &&\
    apt -y install ninja-build build-essential python git wget curl p7zip zip unzip nasm clang-${CLANG_VER} clang-tools-${CLANG_VER} llvm-${LLVM_VER} lld-${LLVM_VER} pkg-config &&\
    apt clean
RUN cd / &&\
    git clone --branch=with-resume https://github.com/circulosmeos/gdown.pl gdown && mv gdown/gdown.pl /usr/bin/ && rm -rf gdown &&\
    git clone https://github.com/Nemirtingas/clang-msvc-sdk clang_windows_sdk &&\
    cd /clang_windows_sdk/msvc && gdown.pl 'https://drive.google.com/file/d/1mJxny3IsxZlI_BSFC_1BMWcZ7jpVmQci/view?usp=sharing' "${MSVC_VER}.tgz"; tar xf "${MSVC_VER}.tgz" && rm "${MSVC_VER}.tgz" gdown* &&\
    cd /clang_windows_sdk/winsdk && gdown.pl 'https://drive.google.com/file/d/1O1GmbPIyKyzdfMb3HqGW6aP1pOAtrrc-/view?usp=sharing' "winsdk_${WINSDK_VER}.tgz"; tar xf "winsdk_${WINSDK_VER}.tgz" && rm "winsdk_${WINSDK_VER}.tgz" gdown* &&\
    ln -s /clang_windows_sdk/mt /usr/bin/ &&\
    ln -s /clang_windows_sdk/powershell /usr/bin/
RUN cd / &&\
    git clone --depth 1 -b my_crosscompile https://github.com/Nemirtingas/vcpkg.git vcpkg &&\
    cd /vcpkg &&\
    ./bootstrap-vcpkg.sh -disableMetrics &&\
    ln -s /vcpkg/vcpkg /usr/bin/ &&\
    ln -s /vcpkg/downloads/tools/cmake-*-linux/cmake-*-Linux-x86_64/bin/cmake /usr/bin/
