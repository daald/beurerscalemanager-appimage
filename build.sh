#!/bin/sh

set -e -x

docker build -t beurer-buildenv-2023 buildenv-docker

mkdir -p tools/
wget https://github.com/linuxdeploy/linuxdeploy/releases/download/1-alpha-20220822-1/linuxdeploy-x86_64.AppImage -O tools/linuxdeploy-x86_64.AppImage
chmod +x tools/linuxdeploy-x86_64.AppImage

rm -rf build/
mkdir -p build/

docker run --rm \
  -v "$(pwd):/workspace/src:ro" \
  -v "$(pwd)/build:/workspace/build" \
  -w '/workspace' \
  -u "$(id -u)" \
  beurer-buildenv-2023 sh -xec "
    cd build/
    tar cC /workspace/src/src/ . | tar x
    cmake .
    make clean all

    mkdir -p AppDir/usr/lib/qt4/plugins/sqldrivers/
    cp /usr/lib/x86_64-linux-gnu/qt4/plugins/sqldrivers/libqsqlite.so AppDir/usr/lib/qt4/plugins/sqldrivers/

    cc /workspace/src/extra/BeurerScaleManager-launcher.c -o BeurerScaleManager-launcher

    /workspace/src/tools/linuxdeploy-x86_64.AppImage --appimage-extract-and-run \
      --appdir AppDir \
      -e BeurerScaleManager-launcher \
      -e BeurerScaleManager \
      --library=/usr/lib/x86_64-linux-gnu/qt4/plugins/sqldrivers/libqsqlite.so \
      -i /workspace/src/extra/BeurerScaleManager.png \
      -d /workspace/src/extra/beurerscalemanager.desktop \
      --output appimage
  "
cp -v ./build/*.AppImage BeurerScaleManager-x86_64.AppImage

# testrun
./BeurerScaleManager-x86_64.AppImage
