#!/bin/bash

set -e

flutter build linux --release --verbose

OS=$(lsb_release -is)
RELEASE=$(lsb_release -cs)
ARCH=$(dpkg --print-architecture)
BUILD_DIR=build/netr-$OS-$RELEASE-$ARCH
DEB_DIR="$BUILD_DIR/DEBIAN"
DEST_DIR="$BUILD_DIR/opt/netr"
DESKTOP_DIR="$BUILD_DIR/usr/share/applications"
PIXMAP_DIR="$BUILD_DIR/usr/share/pixmaps"
BIN_DIR="$BUILD_DIR/usr/bin"
MY_DIR=$(dirname "$0")
APP_VER=$(dart "$MY_DIR/version.dart")

case $ARCH in
    amd64)
        SARCH='x64'
	;;
    *)
        SARCH=$ARCH
esac

rm -rf "$BUILD_DIR"
mkdir -vp "$DEB_DIR" "$BIN_DIR" "$DEST_DIR" "$DESKTOP_DIR" "$PIXMAP_DIR"
cat > "$DEB_DIR/control" << EOF
Package: netr
Maintainer: Neeraj J <neerajcd@gmail.com>
Version: ${APP_VER}
Section: misc
Priority: optional
Standards-Version: ${APP_VER}
Architecture: $ARCH
Depends: vlc
Description: A CCTV camera monitor App
EOF
cp -av linux/netr.desktop "$DESKTOP_DIR/netr.desktop"
cp -av icons/netr.png "$PIXMAP_DIR"
cp -av build/linux/$SARCH/release/bundle/* "$DEST_DIR"
ln -s /opt/netr/netr "$BIN_DIR"
dpkg-deb --build "$BUILD_DIR"
rm -rf "$BIN_DIR" "$DEST_DIR" "$DESKTOP_DIR" "$PIXMAP_DIR"
