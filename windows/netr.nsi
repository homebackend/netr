# define installer name
OutFile "netr_installer.exe"
 
# set desktop as install directory
InstallDir "C:\Program Files\netr"
 
# default section start
Section
 
# define output path
SetOutPath $INSTDIR
 
# specify file to go in output path
File /r netr\*

CreateShortCut "$SMPROGRAMS\Netr App\Netr.lnk" "$INSTDIR\netr.exe" "" "$INSTDIR\netr.exe" 0
CreateShortCut "$SMPROGRAMS\Netr App\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
 
# define uninstaller name
WriteUninstaller $INSTDIR\uninstaller.exe
 
 
#-------
# default section end
SectionEnd
 
# create a section to define what the uninstaller does.
# the section will always be named "Uninstall"
Section "Uninstall"

Delete "$SMPROGRAMS\Netr App\*.*"
Delete "$SMPROGRAMS\Netr App"
  
# Delete the uninstaller
Delete $INSTDIR\uninstaller.exe
 
# Delete the directory
RMDir /r $INSTDIR
SectionEnd

Function .onInstSuccess
	MessageBox MB_OK "Netr App was installed successfully."
FunctionEnd

Function un.onUnistSuccess
	MessageBox MB_OK "Netr App was uninstalled successfully."
FunctionEnd
