#!/bin/bash

set -ouex pipefail

rpm-ostree install \
    kvantum \
    plasma-wayland-protocols \
    gmp-ecm \
    kf5-plasma

cp -rf /tmp/vistathemeplasma/usr/* /usr/
cp -r /tmp/vistathemeplasma/plasma/sddm/sddm-theme-mod/ /usr/share/sddm/themes/
tar -xvzf /tmp/vistathemeplasma/misc/cursors/aero-drop.tar.gz -C /usr/share/icons/

rm -rf /tmp/vistathemeplasma
