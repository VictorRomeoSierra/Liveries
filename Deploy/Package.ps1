# clean up existing files
Remove-Item .\Output\* -Force -Recurse
# zip all the files in Mods\
Compress-Archive -Path .\Liveries "CustomDCS-Liveries.zip"
# exe latest deploy script
Invoke-PS2EXE .\Deploy\CustomDCS-Deploy.ps1 -outputFile "CustomDCS-Liveries.exe"

if (!(Test-Path .\Output\)) {
  mkdir Output
}
# copy to output folder
Move-Item "CustomDCS-Liveries.*" .\Output\.