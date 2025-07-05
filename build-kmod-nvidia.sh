#!/bin/bash

set -ouex pipefail

KERNEL="$(cat /kernel-version.txt)"

dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-42.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-42.noarch.rpm \
    fedora-repos-archive

dnf install -y \
    mock \
    xorg-x11-drv-nvidia-470xx{,-cuda} \
    binutils \
    kernel-$KERNEL \
    kernel-devel-$KERNEL

if [[ ! -s "/tmp/certs/private_key.priv" ]]; then
    echo "WARNING: Using test signing key."
    install -Dm644 /tmp/certs/public_key.der.test   /etc/pki/akmods/certs/public_key.der
    install -Dm644 /tmp/certs/private_key.priv.test /etc/pki/akmods/private/private_key.priv
else
    install -Dm644 /tmp/certs/public_key.der   /etc/pki/akmods/certs/public_key.der
    install -Dm644 /tmp/certs/private_key.priv /etc/pki/akmods/private/private_key.priv
fi

akmods --force --kernels "${KERNEL}"
