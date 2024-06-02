@echo off

echo #################################################
echo # Building Windows Executable                   #
echo #################################################
call flutter build windows --release
dir build\windows\runner\Release\netr.exe

if exist "C:\Program Files (x86)\Resource Hacker\ResourceHacker.exe" (
"C:\Program Files (x86)\Resource Hacker\ResourceHacker.exe" ^
    -open %cd%\build\windows\runner\Release\netr.exe ^
    -save %cd%\build\windows\runner\Release\netr.exe ^
    -action addskip ^
    -res %cd%\windows\runner\resources\app_icon.ico ^
    -mask ICONGROUP,MAINICON,
) else (
echo "Please install resource hacker to change app icon from: http://www.angusj.com/resourcehacker/"
)

echo #################################################
echo # Building Windows Installer                    #
echo #################################################
rem call flutter pub run msix:create
rem dir build\windows\runner\Release\netr.msix

rmdir /q /s build\nsis
mkdir build\nsis
mkdir build\nsis\netr
copy windows\netr.nsi build\nsis
xcopy /a /s build\windows\runner\Release build\nsis\netr
cd build\nsis
"C:\Program Files (x86)\NSIS\makensis.exe" /V4 netr.nsi
cd ..\..
rmdir /q /s build\nsis\netr
