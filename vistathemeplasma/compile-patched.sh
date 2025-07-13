#!/bin/bash

CUR_DIR=$(pwd)
USE_SCRIPT="install.sh"

if [[ -z "$(command -v cmake)" ]]; then
    echo "CMake not found. Stopping."
    exit
fi
if [[ -z "$(command -v ninja)" ]]; then
    if [[ -z "$(command -v make)" ]]; then
        echo "Neither Ninja or GNU Make were found. Stopping"
        exit
    fi
fi

cd "$PWD/misc/defaulttooltip"
sh $USE_SCRIPT --wayland $@
cd "$CUR_DIR"
echo "Compiling plasmoids..."

for filename in "$PWD/plasma/plasmoids/src/"*; do
    cd "$filename"
    echo "Compiling $(pwd)"
    sh $USE_SCRIPT
    echo "Done."
    cd "$CUR_DIR"
done

echo "Compiling SMOD decorations..."
cd "$PWD/kwin/decoration"
sh $USE_SCRIPT --wayland $@
cd "$CUR_DIR"
echo "Done."

echo "Compiling KWin effects..."
for filename in "$PWD/kwin/effects_cpp/"*; do
    cd "$filename"
    echo "Compiling $(pwd)"
    sh $USE_SCRIPT $@
    sh $USE_SCRIPT --wayland $@
    echo "Done."
    cd "$CUR_DIR"
done
