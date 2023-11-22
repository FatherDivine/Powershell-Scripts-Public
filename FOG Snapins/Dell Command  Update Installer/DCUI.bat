@echo off

REM Installs Dell Command | Update and installs (driver) updates, both silently
REM Created to bypass the issue of Dell SupportAssist not allowing you to Install
REM Driver updates if you are logged in remotely. 
REM Created by Aaron S. for CEDC IT Dept. 11-13-2023

IF EXIST "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" (

echo "Dell Command | Update is already installed."

) else (

echo "Installing Dell Command | Update."
start /wait %FILEROOT%Dell-Command-Update-WUA_JCVW3.EXE /s

)

REM Apply updates
start /wait C:\Program" "Files\Dell\CommandUpdate\dcu-cli.exe /version

start /wait C:\Program" "Files\Dell\CommandUpdate\dcu-cli.exe /scan

start /wait C:\Program" "Files\Dell\CommandUpdate\dcu-cli.exe /applyUpdates 

exit