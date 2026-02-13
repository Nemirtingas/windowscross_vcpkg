#! /bin/bash

cd "$(dirname "$0")"

container_name=

function cleanup()
{
  [ ! -z "${container_name}" ] && docker rm "${container_name}"
  exit -1
}

function build_image()
{
    NAME="$1"
    UBUNTU_VER="$2"
    MSVC_VER="$3"
    WIN_VER="$4"
    CLANG_VER="$5"
    VERSION="${MSVC_VER}_win${WIN_VER}_clang${CLANG_VER}"
    docker image rm nemirtingas/${NAME}:${VERSION} --force
    docker image rm ${NAME}:${VERSION} --force
    container_name="$(mktemp -u XXXXXXXXXXXX)"
    echo "Container: ${container_name}"
    docker build --build-arg "UBUNTU_VER=${UBUNTU_VER}" --build-arg CLANG_VER=${CLANG_VER} --build-arg MSVC_VER=${MSVC_VER} --build-arg WINSDK_VER=${WIN_VER} --no-cache --rm -t ${NAME}:${VERSION} . &&
    docker run "--name=${container_name}" ${NAME}:${VERSION} /bin/bash -c exit &&
    docker commit -m "${NAME} image built on ubuntu${UBUNTU_VER} with ${VERSION} and clang ${CLANG_VER}" -a "Nemirtingas" "${container_name}" nemirtingas/${NAME}:${VERSION} &&
    docker push nemirtingas/${NAME}:${VERSION} &&
    docker rm "${container_name}"
}

trap cleanup INT
# Start building your docker image: build_image "repository" "msvc version" "window sdk version" "clang/llvm version"
#build_image "windowscross_vcpkg" "22.04" "msvc2019" "10.0.18362.0" "17"
#build_image "windowscross_vcpkg" "22.04" "msvc2022_14.40.33807" "10.0.18362.0" "18"
#build_image "windowscross_vcpkg" "22.04" "msvc2022_14.40.33807" "10.0.22621.0" "20"
#build_image "windowscross_vcpkg" "22.04" "msvc2022_14.44.35207" "10.0.26100.0" "22"
build_image "windowscross_vcpkg" "24.04" "msvc2022_14.44.35207" "10.0.26100.0" "22"
