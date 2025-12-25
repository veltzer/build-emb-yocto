#!/bin/bash
set -e

cd /home/yocto

git clone git://git.yoctoproject.org/poky
cd poky
git checkout scarthgap

source oe-init-build-env build

cat >> conf/local.conf << EOF
MACHINE = "qemuarm64"
INIT_MANAGER = "sysvinit"
PACKAGE_CLASSES = "package_ipk"
EOF

bitbake core-image-minimal
