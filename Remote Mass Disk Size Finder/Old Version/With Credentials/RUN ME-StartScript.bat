@echo off
echo Starting the credentials generator script first so you can create your own credentials.
echo After closing the Powershell script, the Remote Mass Disk Size Finder script will open.
timeout /t 7
echo:
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -Verb RunAs powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0XML Credentials Generator Script.ps1\" -_vLUF %_vLUF%'" -wait
echo:
echo Starting the Remote Mass Disk Size Finder script
echo:
timeout /t 3
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -Verb RunAs powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0RMDSF.ps1\" -_vLUF %_vLUF%'"
echo:
echo Complete!
pause
: the %~dp0 : %0 contains the full path to the called .bat file & ~dp says to get the drive and path, including trailing \.