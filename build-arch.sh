#!/bin/bash

set -e

flutter build linux --release --verbose

OS=Arch
ARCH=$(uname -m)
BUILD_DIR=build/netr-arch
DEST_DIR="/opt/netr"
DESKTOP_DIR="/usr/share/applications"
PIXMAP_DIR="/usr/share/pixmaps"
BIN_DIR="/usr/bin"
MY_DIR=$(dirname "$0")
APP_VER=$(/opt/flutter/bin/dart "$MY_DIR/version.dart")

case $ARCH in
    x86_64)
        SARCH='x64'
	      ;;
    *)
        SARCH=$ARCH
esac

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cat > "$BUILD_DIR/PKGBUILD" << EOF
# Maintainer: Neeraj J <neerajcd@gmail.com>

pkgname=netr
pkgver=${APP_VER}
pkgrel=1
pkgdesc="A CCTV camera monitor App"
arch=('i686' 'x86_64')
depends=('vlc')
license=(custom)
options=(!strip)

package() {
    mkdir -vp "\$pkgdir$BIN_DIR" "\$pkgdir$DEST_DIR" "\$pkgdir$DESKTOP_DIR" "\$pkgdir$PIXMAP_DIR"
    pwd
    cp -av ../../../linux/netr.desktop "\$pkgdir$DESKTOP_DIR/netr.desktop"
    cp -av ../../../icons/netr.png "\$pkgdir$PIXMAP_DIR"
    cp -av ../../linux/$SARCH/release/bundle/* "\$pkgdir$DEST_DIR"
    ln -s /opt/netr/netr "\$pkgdir$BIN_DIR"
}
EOF
cd "$BUILD_DIR"
makepkg -cf
cd -

