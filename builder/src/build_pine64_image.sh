#!/bin/sh

DOCKER_CONFIG=/src/pine64_docker_defconfig && \
WORKSPACE=/workspace && \
apt-get update && apt-get install -y qemu-user-static && \

## cleanup any previous data
cd ${WORKSPACE} && \
rm -rf * && \
mkdir ${WORKSPACE}/target && \
cd ${WORKSPACE} && \
## clone git repos
git clone --depth 1 --single-branch https://github.com/atzoum/build-pine64-image && \
cd build-pine64-image && \
# https://github.com/longsleep/build-pine64-image/blob/master/kernel/README.md#kernel-310-from-bsp
git clone --depth 1 --branch pine64-hacks-1.2 --single-branch https://github.com/atzoum/linux-pine64.git linux && \
# https://github.com/longsleep/build-pine64-image/blob/master/kernel/README.md#get-busybox-tree
git clone --depth 1 --branch 1_24_stable --single-branch git://git.busybox.net/busybox busybox && \
# https://github.com/longsleep/build-pine64-image/blob/master/kernel/README.md#configure-bsp-kernel
cd linux && \
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- sun50iw1p1smp_linux_defconfig && \
### copy config file (this is the custom part...)
#cp ${DOCKER_CONFIG} ${WORKSPACE}/build-pine64-image/linux/.config && \ 
## compile kernel
# https://github.com/longsleep/build-pine64-image/blob/master/kernel/README.md#compile-bsp-kernel
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- sun50iw1p1smp_linux_defconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LOCALVERSION= clean && \
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j5 LOCALVERSION= Image && \
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j5 LOCALVERSION= modules && \
# https://github.com/longsleep/build-pine64-image/blob/master/kernel/README.md#configure-and-build-busybox
cp ${WORKSPACE}/build-pine64-image/kernel/pine64_config_busybox ${WORKSPACE}/build-pine64-image/busybox/.config && \
cd ${WORKSPACE}/build-pine64-image//busybox && \
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j5 oldconfig && \
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j5 && \
# https://github.com/longsleep/build-pine64-image/blob/master/kernel/README.md#make-initrdgz
cd ${WORKSPACE}/build-pine64-image/kernel && \
./make_initrd.sh && \
./make_kernel_tarball.sh ${WORKSPACE}/target && \
# https://github.com/longsleep/build-pine64-image/tree/master/u-boot-postprocess#u-boot-boot0-compatibility
cd ${WORKSPACE}/build-pine64-image/ && \
# https://github.com/longsleep/build-pine64-image/tree/master/u-boot-postprocess#get-u-boot-tree
git clone --depth 1 --branch pine64-hacks --single-branch https://github.com/longsleep/u-boot-pine64.git u-boot-pine64 && \
# https://github.com/longsleep/build-pine64-image/tree/master/u-boot-postprocess#get-arm-trust-firmware-atf
git clone --branch allwinner-a64-bsp --single-branch https://github.com/longsleep/arm-trusted-firmware.git arm-trusted-firmware-pine64 && \
# https://github.com/longsleep/build-pine64-image/tree/master/u-boot-postprocess#sunxi-pack-tools
git clone https://github.com/longsleep/sunxi-pack-tools.git sunxi-pack-tools && \
# https://github.com/longsleep/build-pine64-image/tree/master/u-boot-postprocess#compile-u-boot
cd ${WORKSPACE}/build-pine64-image/u-boot-pine64 && \
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- sun50iw1p1_config && \
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- && \
# https://github.com/longsleep/build-pine64-image/tree/master/u-boot-postprocess#compile-arm-trust-firmware-atf
cd ${WORKSPACE}/build-pine64-image/arm-trusted-firmware-pine64 && \
make clean && \
make ARCH=arm CROSS_COMPILE=aarch64-linux-gnu- PLAT=sun50iw1p1 bl31 && \
# https://github.com/longsleep/build-pine64-image/tree/master/u-boot-postprocess#sunxi-pack-tools
cd ${WORKSPACE}/build-pine64-image/sunxi-pack-tools && \
## comment out GLIBC line
sed -e '/GLIBC/s/^/\/\//g' -i script/script.c && \
make && \
# https://github.com/longsleep/build-pine64-image/tree/master/u-boot-postprocess#merge-u-boot-with-other-parts
cd ../u-boot-postprocess && \
./u-boot-postprocess.sh && \
# https://github.com/longsleep/build-pine64-image/tree/master/u-boot-postprocess#next-steps
cp ${WORKSPACE}/build-pine64-image/build/u-boot-with-dtb.bin ${WORKSPACE}/build-pine64-image/simpleimage/ && \
cd ../simpleimage && \
./make_simpleimage.sh ${WORKSPACE}/target/simpleimage.img 100 ${WORKSPACE}/target/linux-pine64-3.10.104-1.tar.xz && \
cd ${WORKSPACE}/target && \
xz -z simpleimage.img
cd ${WORKSPACE}/build-pine64-image && \
./build-pine64-image.sh ${WORKSPACE}/target/simpleimage.img.xz ${WORKSPACE}/target/linux-pine64-3.10.104-1.tar.xz