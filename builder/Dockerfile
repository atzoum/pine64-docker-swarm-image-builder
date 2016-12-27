FROM aarch64/ubuntu:xenial

RUN \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install bc curl gcc git libncurses5-dev lzop make u-boot-tools cpio device-tree-compiler xz-utils gcc-arm-linux-gnueabihf dos2unix dosfstools mtools wget kpartx bsdtar debootstrap module-init-tools && \
    # qemu-user-static must be installed with --priviledged mode
    apt-get clean  && \
    rm -rf /var/lib/apt/lists/*
COPY src /src
VOLUME /workspace
WORKDIR /workspace
CMD ["sh", "/src/build_pine64_image.sh"]