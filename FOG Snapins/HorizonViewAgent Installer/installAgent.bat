ECHO ON
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{0C94FB1A-6358-47FC-A3AE-3CA4F6C72C5E}

if %ERRORLEVEL% EQU 1 goto Install

if %ERRORLEVEL% EQU 0 goto Exit

:Install

VMware-Horizon-Agent-x86_64-2203-8.5.0-19564166.exe /s /v"/qn VDM_VC_MANAGED_AGENT=0 VDM_SERVER_NAME=oit-vdi-brk03.ucdenver.edu VDM_SERVER_USERNAME=university\svc-oit-vagent VDM_SERVER_PASSWORD=xAb7DQuEM10gkNl1JXru REBOOT=ReallySuppress"

shutdown /r /t 00
goto:eof

:Exit
goto:eof