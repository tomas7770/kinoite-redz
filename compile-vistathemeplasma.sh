#!/bin/bash

set -ouex pipefail

rpm-ostree install \
    git \
    plasma-workspace-devel \
    kvantum \
    qt6-qtmultimedia-devel \
    qt6-qt5compat-devel \
    libplasma-devel \
    qt6-qtbase-devel \
    qt6-qtwayland-devel \
    plasma-activities-devel \
    kf6-kpackage-devel \
    kf6-kglobalaccel-devel \
    qt6-qtsvg-devel \
    wayland-devel \
    plasma-wayland-protocols \
    kf6-ksvg-devel \
    kf6-kcrash-devel \
    kf6-kguiaddons-devel \
    kf6-kcmutils-devel \
    kf6-kio-devel \
    kdecoration-devel \
    kf6-ki18n-devel \
    kf6-knotifications-devel \
    kf6-kirigami-devel \
    kf6-kiconthemes-devel \
    cmake \
    gmp-ecm-devel \
    kf5-plasma-devel \
    libepoxy-devel \
    kwin-devel \
    kf6-karchive \
    kf6-karchive-devel \
    plasma-wayland-protocols-devel \
    qt6-qtbase-private-devel \
    qt6-qtbase-devel \
    kf6-knewstuff-devel \
    kf6-knotifyconfig-devel \
    kf6-attica-devel \
    kf6-krunner-devel \
    kf6-kdbusaddons-devel \
    kf6-sonnet-devel \
    plasma5support-devel \
    plasma-activities-stats-devel \
    polkit-qt6-1-devel \
    qt-devel \
    libdrm-devel \
    kf6-qqc2-desktop-style \
    kwin-x11-devel \
    ninja-build

git clone https://gitgud.io/catpswin56/vistathemeplasma.git /tmp/vistathemeplasma
cd /tmp/vistathemeplasma

###
CUR_DIR=$(pwd)
USE_SCRIPT="install.sh"

cd "$PWD/misc/defaulttooltip"
sed -i 's@VERSION="${array\[1\]}"@VERSION="$(rpm -qa plasma-workspace-devel --queryformat \x27%{VERSION}\x27)"@g' $USE_SCRIPT
cd "$CUR_DIR"
###

chmod +x /tmp/compile-patched.sh
/tmp/compile-patched.sh --ninja

for filename in $(find . -name "install_manifest.txt"); do
    while IFS="" read -r p || [ -n "$p" ]
    do
        if [ -f $p ]; then
            cp --parents $p /tmp
        fi
    done <$filename
done
cp --parents /usr/lib64/qt6/qml/org/kde/plasma/core/libcorebindingsplugin.so /tmp
PLASMA_VERSION="$(rpm -qa plasma-workspace-devel --queryformat \x27%{VERSION}\x27)"
for filename in "./misc/defaulttooltip/build/libplasma-v${PLASMA_VERSION}/build/bin/libPlasma"*; do
    echo "Copying $filename"
    cp "$filename" /tmp/usr/lib64/
done
