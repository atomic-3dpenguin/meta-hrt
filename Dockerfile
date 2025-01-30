# Base image with dependencies for Yocto build
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV YOCTO_DIR=/home/yocto
ENV SOURCE_DIR=${YOCTO_DIR}/source
ENV BUILD_DIR=${YOCTO_DIR}/build
ENV YOCTO_PROJECT_NAME=scarthgap

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

# Create Yocto build user and set permissions
RUN useradd -m -s /bin/bash yocto && \
    echo "yocto ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/yocto && \
    mkdir -p ${SOURCE_DIR} ${BUILD_DIR} && \
    chown -R yocto:yocto ${YOCTO_DIR}

RUN mkdir -p ${SOURCE_DIR}

# Install locales package
RUN apt-get update && apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Set the default locale environment variables
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Switch to Yocto user
USER yocto
WORKDIR /home/yocto

# Clone Yocto and required layers
RUN cd ${SOURCE_DIR} && \
    git clone -b ${YOCTO_PROJECT_NAME} git://git.yoctoproject.org/poky.git && \
    git clone -b ${YOCTO_PROJECT_NAME} git://git.openembedded.org/meta-openembedded && \
    git clone -b ${YOCTO_PROJECT_NAME} git://git.yoctoproject.org/meta-ti && \
    git clone -b master https://github.com/beagleboard/meta-beagleboard.git && \
    git clone -b main https://github.com/atomic-3dpenguin/meta-hrt

# # Setup build environment using TEMPLATECONF
# RUN cd ${SOURCE_DIR}\poky && \
#     export TEMPLATECONF=${SOURCE_DIR}/meta-Honu Research and Technologies/conf/templates/default && \
#     source oe-init-build-env ${BUILD_DIR}

# Setup build environment
# RUN cd ${SOURCE_DIR}/poky && source oe-init-build-env ${BUILD_DIR} && \
#     bitbake-layers add-layer ${SOURCE_DIR}/poky/meta-openembedded/meta-oe && \
#     bitbake-layers add-layer ${SOURCE_DIR}/poky/meta-openembedded/meta-python && \
#     bitbake-layers add-layer ${SOURCE_DIR}/poky/meta-openembedded/meta-networking && \
#     bitbake-layers add-layer ${SOURCE_DIR}/meta-ti && \
#     bitbake-layers add-layer ${SOURCE_DIR}/meta-beagleboard && \
#     bitbake-layers add-layer ${SOURCE_DIR}/meta-hrt
    # cp ${SOURCE_DIR}/meta-hrt/conf/bblayers.conf.sample ${BUILD_DIR}/conf/bblayers.conf && \
    # cp ${SOURCE_DIR}/meta-hrt/conf/local.conf.sample ${BUILD_DIR}/conf/local.conf

# Source build environment script on startup
RUN echo "TEMPLATECONF=${SOURCE_DIR}/meta-hrt/conf/templates/default source ${SOURCE_DIR}/poky/oe-init-build-env ${BUILD_DIR}">>/home/yocto/.bashrc

# Set work directory to build
WORKDIR ${BUILD_DIR}

# RUN bitbake recipe-config

# Command to keep container running
# CMD ["/bin/bash"]
