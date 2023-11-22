@echo off
set "OWNPATH=%~dp0"
echo Starting the Domain Trust Fix Tool...
echo:
timeout /t 1
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -Verb RunAs powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%OWNPATH%DomainTrustFixTool.ps1\" '"
echo:
echo "Complete!"
pause
: the %~dp0 : %0 contains the full path to the called .bat file & ~dp says to get the drive and path, including trailing \.