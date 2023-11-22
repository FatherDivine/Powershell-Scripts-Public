@echo off
set "OWNPATH=%~dp0"
IF EXIST "%OWNPATH%Cred.xml" (
IF EXIST "%OWNPATH%Data.xml" (
IF EXIST "%OWNPATH%pneumotach.ps1" (
  echo All files detected^!
  echo:
  echo Starting The pneumotach Domain Joiner Script.
  echo:
  timeout /t 2
 powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -Verb RunAs powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%OWNPATH%pneumotach.ps1\" '"
                   ))) ELSE (
  echo Did not detect credential files ^(Cred.xml ^& Key.xml^). Make sure they are in the same location as pneumatch.ps1 and this bat file.
  timeout /t 3
  EXIT /B
 )
echo:
echo Complete^!
pause
EXIT /B
: the %~dp0 : %0 contains the full path to the called .bat file & ~dp says to get the drive and path, including trailing \.
