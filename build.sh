#!/bin/bash

DEST=/srv/http/apks/netr
SOURCE=build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk 

mkdir -p "${DEST}"
flutter build apk --split-per-abi
VERSION=$(aapt dump badging "${SOURCE}" | \
  sed -e '/^package: /!d' \
    -e "s/.*versionCode='\([0-9]\+\)' .*/\1/")
cp -av "${SOURCE}" "${DEST}"
echo "{ \"version\":\"${VERSION}\" }" > "${DEST}/info.json"

