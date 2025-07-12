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
    ninja-build

git clone https://gitgud.io/catpswin56/vistathemeplasma.git /tmp/vistathemeplasma
cd /tmp/vistathemeplasma

###
CUR_DIR=$(pwd)
USE_SCRIPT="install.sh"

mkdir /tmp/usr
mkdir -p /tmp/usr/lib64/qt6/qml/org/kde/plasma/core/

cd "$PWD/misc/defaulttooltip"
sed -i 's@/usr@/tmp/usr@g' $USE_SCRIPT
sed -i 's@VERSION="${array\[1\]}"@VERSION="$(rpm -qa plasma-workspace-devel --queryformat \x27%{VERSION}\x27)"@g' $USE_SCRIPT
cd "$CUR_DIR"

for filename in "$PWD/plasma/plasmoids/src/"*; do
    cd "$filename"
    sed -i 's@/usr@/tmp/usr@g' $USE_SCRIPT
    cd "$CUR_DIR"
done

cd "$PWD/kwin/decoration"
sed -i 's@/usr@/tmp/usr@g' $USE_SCRIPT
cd "$CUR_DIR"

for filename in "$PWD/kwin/effects_cpp/"*; do
    cd "$filename"
    sed -i 's@/usr@/tmp/usr@g' $USE_SCRIPT
    cd "$CUR_DIR"
done
###

chmod +x /tmp/compile-patched.sh
CMAKE_PREFIX_PATH=/usr:/tmp/usr /tmp/compile-patched.sh --wayland --ninja
