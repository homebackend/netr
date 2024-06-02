@echo off

echo #################################################
echo # Building Apk                                  #
echo #################################################
call flutter build apk --split-per-abi
dir build\app\outputs\apk\release
