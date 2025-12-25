FROM ubuntu:22.04

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gawk wget git diffstat unzip texinfo gcc build-essential \
    chrpath socat cpio python3 python3-pip python3-pexpect xz-utils \
    debianutils iputils-ping python3-git python3-jinja2 python3-subunit \
    zstd liblz4-tool file locales libacl1 python3-websockets
RUN rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash yocto
USER yocto
WORKDIR /home/yocto

COPY --chown=yocto:yocto build-yocto.sh .

# RUN build-yocto.sh
