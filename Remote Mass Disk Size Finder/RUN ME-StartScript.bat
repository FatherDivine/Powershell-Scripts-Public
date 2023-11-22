@echo off
set "OWNPATH=%~dp0"
echo Starting the Remote Mass Disk Size Finder script
echo:
timeout /t 3
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -Verb RunAs powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%OWNPATH%RMDSF.ps1\" '"
echo:
echo "Complete!"
pause
: the %~dp0 : %0 contains the full path to the called .bat file & ~dp says to get the drive and path, including trailing \.