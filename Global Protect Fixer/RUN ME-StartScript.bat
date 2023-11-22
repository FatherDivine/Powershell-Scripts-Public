set "OWNPATH=%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -Verb RunAs powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%OWNPATH%GlobalProtect-Fixer.ps1\" '"
:pause
: the %~dp0 : %0 contains the full path to the called .bat file & ~dp says to get the drive and path, including trailing \.