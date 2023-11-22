@echo off

REM Installs Chipset Driver, which works well with 
REM the Dell Command Update Driver Installer Snapin
REM Created by Aaron S. for CEDC IT Dept. 11-14-2023

echo "Installing Chipset Driver... May Restart the PC"
start /wait %FILEROOT%Chipset\SetupChipset.exe /s
