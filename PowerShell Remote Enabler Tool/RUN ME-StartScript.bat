@echo off
echo Starting the PS Remote Enabler Tool...
echo:
timeout /t 1
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -Verb RunAs powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0PSRE.ps1\" -_vLUF %_vLUF%'"
echo:
echo "Complete!"
pause
: the %~dp0 : %0 contains the full path to the called .bat file & ~dp says to get the drive and path, including trailing \.