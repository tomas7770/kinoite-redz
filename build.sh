#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"


### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
# rpm-ostree install screen

# this would install a package from rpmfusion
# rpm-ostree install vlc

#### Example for enabling a System Unit File

# systemctl enable podman.socket

KERNEL_VERSION=$(cat /kernel-version.txt)

# Install RPMFusion
rpm-ostree install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-40.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-40.noarch.rpm

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
