@echo off
set "OWNPATH=%~dp0"
echo Starting the PS Remote Enabler Tool...
echo:
timeout /t 2
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -Verb RunAs powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%OWNPATH%PSRE.ps1\" '"
echo:
echo "Complete!"
pause
: the %~dp0 : %0 contains the full path to the called .bat file & ~dp says to get the drive and path, including trailing \.