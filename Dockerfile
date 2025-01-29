# Base image with dependencies for Yocto build
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV YOCTO_DIR=/home/yocto
ENV BUILD_DIR=${YOCTO_DIR}/build
ENV YOCTO_PROJECT_NAME=Scarthgap

# Install necessary packages
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    cpio \
    gawk \
    python3 \
    python3-pip \
    python3-pexpect \
    xz-utils \
    debianutils \
    iputils-ping \
    chrpath \
    diffstat \
    socat \
    file \
    locales \
    sudo \
    nano \
    curl \
    unzip \
    zstd \
    lz4 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create Yocto build user
RUN useradd -m -s /bin/bash yocto && echo "yocto ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/yocto

# Switch to Yocto user
USER yocto
WORKDIR /home/yocto

# Clone Yocto and required layers
RUN git clone -b ${YOCTO_PROJECT_NAME} git://git.yoctoproject.org/poky.git && \
    cd poky && \
    git clone -b ${YOCTO_PROJECT_NAME} git://git.openembedded.org/meta-openembedded && \
    git clone -b ${YOCTO_PROJECT_NAME} git://git.yoctoproject.org/meta-ti && \
    git clone -b ${YOCTO_PROJECT_NAME} https://github.com/crops/meta-beagleboard && \
    git clone -b ${YOCTO_PROJECT_NAME} https://github.com/atomic-3dpenguin/meta-hrt

# Setup build environment
RUN cd poky && source oe-init-build-env ${BUILD_DIR} && \
    bitbake-layers add-layer ${YOCTO_DIR}/poky/meta-openembedded/meta-oe && \
    bitbake-layers add-layer ${YOCTO_DIR}/poky/meta-openembedded/meta-python && \
    bitbake-layers add-layer ${YOCTO_DIR}/poky/meta-openembedded/meta-networking && \
    bitbake-layers add-layer ${YOCTO_DIR}/poky/meta-ti && \
    bitbake-layers add-layer ${YOCTO_DIR}/poky/meta-beagleboard && \
    bitbake-layers add-layer ${YOCTO_DIR}/meta-hrt && \
    cp ${YOCTO_DIR}/meta-hrt/conf/bblayers.conf.sample ${BUILD_DIR}/conf/bblayers.conf && \
    cp ${YOCTO_DIR}/meta-hrt/conf/local.conf.sample ${BUILD_DIR}/conf/local.conf

# Source build environment script on startup
RUN echo "source ${YOCTO_DIR}/poky/oe-init-build-env ${BUILD_DIR}" >> /home/yocto/.bashrc && \
    echo "${YOCTO_DIR}/meta-hrt/scripts/auto-config.sh" >> /home/yocto/.bashrc

# Set work directory to build
WORKDIR ${BUILD_DIR}

# Command to keep container running
# CMD ["/bin/bash"]
