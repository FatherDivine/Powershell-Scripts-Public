@echo off
set "OWNPATH=%~dp0"
IF EXIST "%OWNPATH%Cred.xml" (
IF EXIST "%OWNPATH%Key.xml" (
  echo Credential Files ^(Cred.xml ^& Key.xml^) detected^!
  echo Starting The Domain Join Tool.
  echo:
  timeout /t 2
 powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -Verb RunAs powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%OWNPATH%DJT.ps1\" '"
                   )) ELSE (
  echo Did not detect credential files ^(Cred.xml ^& Key.xml^)^, so starting XML Credentials Generator Script first.
  timeout /t 2
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -Verb RunAs powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%OWNPATH%XML Credentials Generator Script.ps1\" '" -wait
  echo:
  echo Starting The Domain Join Tool.
  echo:
  timeout /t 1
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -Verb RunAs powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%OWNPATH%DJT.ps1\" '"
                           )
echo:
echo Complete^!
pause
: the %~dp0 : %0 contains the full path to the called .bat file & ~dp says to get the drive and path, including trailing \.
: removed -_vLUF %_vLUF%. old :  \"%~dp0DJT.ps1\" -_vLUF %_vLUF%'" 