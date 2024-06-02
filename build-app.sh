#!/bin/bash

set -e

if [ $# -eq 0 ]
then
  echo "Usage: $0 <destination-directory>"
  exit 1
fi

DEST="$1"
SOURCE=build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk

mkdir -p "${DEST}"
flutter build apk --split-per-abi --verbose
VERSION=$(aapt dump badging "${SOURCE}" | \
  sed -e '/^package: /!d' \
    -e "s/.*versionCode='\([0-9]\+\)' .*/\1/")
cp -av "${SOURCE}" "${DEST}"
echo "{ \"version\":\"${VERSION}\" }" > "${DEST}/info.json"
