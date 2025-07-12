#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"


### Install packages

# Packages can be installed from any enabled yum repo on the image.

KERNEL_VERSION=$(cat /kernel-version.txt)

# Install RPMFusion
dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-42.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-42.noarch.rpm

# Disable Negativo 17 repo before installing RPMFusion packages
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo

rpm-ostree install \
    krdp \
    xorg-x11-drv-nvidia-470xx \
    xorg-x11-drv-nvidia-470xx-cuda \
    /tmp/nvidia/*${KERNEL_VERSION}*.rpm \
    plasma-workspace-x11

# Enable multimedia repo
sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/negativo17-fedora-multimedia.repo

rm -rf /var/* && rm -rf /tmp/nvidia && rm -f /kernel-version.txt

/tmp/install-vistathemeplasma.sh
