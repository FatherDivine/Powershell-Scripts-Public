@echo off
set "OWNPATH=%~dp0"


  echo Attempting to restart SSSD...
  echo:
  timeout /t 2
 pwsh -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -Verb RunAs pwsh -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%OWNPATH%CSCI-NC-DATA-R1-SSSD-Restart.ps1\" '"

echo:
echo Complete^!
pause
: the %~dp0 : %0 contains the full path to the called .bat file & ~dp says to get the drive and path, including trailing \.
: removed -_vLUF %_vLUF%. old :  \"%~dp0DJT.ps1\" -_vLUF %_vLUF%'" 