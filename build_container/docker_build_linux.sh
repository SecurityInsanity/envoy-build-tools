#!/bin/bash
#The ppc64le is not supported by google-cloud-sdk. So ppc64le is temporary removed.

set -e

build_image()
{
    ARCH=$1

    case ${ARCH:-} in
    'amd64')
        QEMUARCH='x86_64'
        ;;
    'arm64')
        IMAGEARCH='arm64v8/'
        QEMUARCH='aarch64'
        ;;
    'ppc64le')
        IMAGEARCH='ppc64le/'
        QEMUARCH='ppc64le'
        ;;
    *)
        echo 'Cpu architecture is not supportted!'
        exit 1
        ;;
    esac

    BUILD_NAME="${IMAGE_NAME}"
    echo "build ${BUILD_NAME}:${CONTAINER_TAG}-${ARCH}"

    docker build --build-arg IMAGEARCH=${IMAGEARCH} \
                   --build-arg QEMUARCH=${QEMUARCH} \
                   -f "Dockerfile-${OS_DISTRO}" -t "${BUILD_NAME}:${CONTAINER_TAG}-${ARCH}" .
}

docker run --rm --privileged multiarch/qemu-user-static:register --reset

[[ -z "${OS_DISTRO}" ]] && OS_DISTRO="ubuntu"
[[ -z "${IMAGE_NAME}" ]] && IMAGE_NAME="envoyproxy/envoy-build-${OS_DISTRO}"

for arch in ${IMAGE_ARCH}
do
    echo "Build the $arch image"
    build_image $arch
done
