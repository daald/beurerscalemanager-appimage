#!/bin/sh

set -e -x

docker build -t beurer-buildenv-2023 buildenv-docker

mkdir -p tools/
#wget https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage -O tools/linuxdeployqt-x86_64.AppImage
#chmod +x tools/linuxdeployqt-x86_64.AppImage
wget https://github.com/linuxdeploy/linuxdeploy/releases/download/1-alpha-20220822-1/linuxdeploy-x86_64.AppImage -O tools/linuxdeploy-x86_64.AppImage
chmod +x tools/linuxdeploy-x86_64.AppImage

docker run --rm \
  -v "$(pwd)/BeurerScaleManager:/workspace" \
  -v "$(pwd)/tools:/tools:ro" \
  -v "$(pwd)/extra:/extra:ro" \
  -w '/workspace' \
  beurer-buildenv-2023 sh -xec "
    cmake .
    make clean all
    #/tools/linuxdeployqt-x86_64.AppImage --appimage-extract-and-run /tmp/deployqt -appimage -bundle-non-qt-libs -verbose=2
    #/tools/linuxdeploy-x86_64.AppImage --appimage-extract-and-run --list-plugins
    rm -rf AppDir/
    mkdir -p AppDir/usr/lib/qt4/plugins/sqldrivers/
    cp /usr/lib/x86_64-linux-gnu/qt4/plugins/sqldrivers/libqsqlite.so AppDir/usr/lib/qt4/plugins/sqldrivers/

    cc /extra/BeurerScaleManager-launcher.c -o BeurerScaleManager-launcher

    /tools/linuxdeploy-x86_64.AppImage --appimage-extract-and-run \
      --appdir AppDir \
      -e BeurerScaleManager-launcher \
      -e BeurerScaleManager \
      --library=/usr/lib/x86_64-linux-gnu/qt4/plugins/sqldrivers/libqsqlite.so \
      -i /extra/BeurerScaleManager.png \
      -d /extra/beurerscalemanager.desktop \
      --output appimage
  "
mv -v ./BeurerScaleManager/Beurer_Scale_Manager-x86_64.AppImage BeurerScaleManager-x86_64.AppImage

# testrun
./BeurerScaleManager-x86_64.AppImage
