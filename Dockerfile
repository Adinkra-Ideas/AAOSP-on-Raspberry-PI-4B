FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

#Install build essentials
RUN apt-get update && apt-get -y install gawk wget git-core \
    diffstat unzip texinfo gcc-multilib build-essential \
    chrpath socat cpio python3 python3-pip \
    python3-pexpect xz-utils debianutils iputils-ping \
    libsdl1.2-dev xterm tar locales curl nano

RUN apt-get -y install software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update
RUN rm /bin/sh && ln -s bash /bin/sh    

# HOST tools
RUN apt-get -y install zstd liblz4-tool file

#Build essentials for AAOSP
RUN apt-get install -y gnupg flex bison build-essential \
	zip zlib1g-dev libc6-dev-i386 x11proto-core-dev \
	libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils \
	xsltproc fontconfig

RUN apt-get install -y bc coreutils dosfstools e2fsprogs \
	fdisk kpartx mtools ninja-build pkg-config 

RUN apt-get update && apt-get install -y  rpm2cpio libegl1-mesa \
    libsdl1.2-dev lzop libelf-dev vim libterm-readkey-perl intltool \
    xalan  openssl groff-base cmake device-tree-compiler \
    gnupg2 apt-utils sudo rsync gnupg-agent gprbuild iproute2 net-tools u-boot-tools \
    zstd jq

#Install python packages
RUN pip3 install meson mako jinja2 ply pyyaml dataclasses

# Set locales
RUN locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# User settings. Should be passed using --build-arg when building the image. Otherwise, you can expect accesss errors.
ARG USER_NAME=username
ARG HOST_UID=1000
ARG HOST_GID=1000
ARG GIT_USER_NAME="username"
ARG GIT_EMAIL="username@email.com"

# Add the user to the image's linux:
#ADD sudo to the user and set $USER_NAME as password for sudo
RUN groupadd -g $HOST_GID $USER_NAME && \
    useradd -g $HOST_GID -m -s /bin/bash -u $HOST_UID $USER_NAME && \
    echo "$USER_NAME:$USER_NAME" | chpasswd && adduser $USER_NAME sudo

USER $USER_NAME
ENV USER_FOLDER /home/$USER_NAME

# Setup folders:
RUN mkdir -p $USER_FOLDER/bin

#Install curl and set right properties
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > $USER_FOLDER/bin/repo
RUN chmod a+x $USER_FOLDER/bin/repo
ENV PATH="$USER_FOLDER/bin:${PATH}"

#Configures image's linux git config to avoid warning messages
RUN git config --global user.email "$GIT_USER_NAME"
RUN git config --global user.name "$GIT_EMAIL"
