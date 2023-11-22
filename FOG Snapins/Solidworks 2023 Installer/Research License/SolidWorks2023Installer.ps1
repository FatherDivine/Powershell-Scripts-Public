# Created by Aaron S. for CU Denver CEDC
Start-Transcript -Path "C:\Temp\TranscriptSolidWorks2023.txt" -Force
# unzip first
 Expand-Archive "${PSScriptRoot}\SOLIDWORKS_2023_SP3.0.zip" -DestinationPath "${PSScriptRoot}"

# install
Start-Process msiexec.exe -wait -ArgumentList '/qb /package "C:\Program Files (x86)\FOG\tmp\SolidWorks2023Installer\SOLIDWORKS_2023_SP3.0\swwi\data\solidworks.msi" INSTALLDIR="C:\Program Files\SOLIDWORKS Corp" SOLIDWORKSSERIALNUMBER="9010022931972310GR39GZ95" ENABLEPERFORMANCE="1" OFFICEOPTIONS="3" ADDLOCAL="SolidWorks"'


# Housekeeping. Should be done by FOG automatically
# Remove-Item "C:\Temp\SOLIDWORKS*" -Force
Stop-Transcript
