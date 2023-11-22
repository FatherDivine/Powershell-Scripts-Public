:: The below line is used for testing purposes when the script closes too fast to see the error. It will launch the script in a second CMD prompt that won't close.
::if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )

::::::::::::::::::::::::::::::::::::::::::::
:: Automatically check & get admin rights V2
::::::::::::::::::::::::::::::::::::::::::::
@echo off
CLS
ECHO.
ECHO =============================
ECHO Running Admin shell
ECHO =============================
echo.
:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
ECHO.
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation
ECHO **************************************

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " " >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul & shift /1)

::::::::::::::::::::::::::::
::START
::::::::::::::::::::::::::::

if exist "C:\Users\cladmin\Desktop\LCHWC" (
	echo LCHWC folder already exists on cladmin desktop. Moving on...
	echo.
) else (
	echo LCHWC folder does NOT exist on cladmin desktop. Creating...
	echo.
	mkdir "C:\Users\cladmin\Desktop\LCHWC"
	type NUL > C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
	
)
@Echo OFF
(Call :Empty C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt && (
echo PreHardware.txt is not empty, so creating PostHardware.txt for comparison...
echo.
 wmic /OUTPUT:C:\Users\cladmin\Desktop\LCHWC\time.tmp os get LocalDateTime
   TYPE C:\Users\cladmin\Desktop\LCHWC\time.tmp  > C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
::   echo %date% >> C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
echo Service Tag >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
wmic csproduct get identifyingnumber >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
echo Hard Drive >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
wmic diskdrive get serialnumber >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
echo Motherboard >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
wmic baseboard get serialnumber >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
echo Memory >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
wmic memorychip get manufacturer, partnumber >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
echo Successfully created Post Hardware file at C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
echo.
echo Next step is comparison which is NOT coded yet...
echo.
)) || (
echo PreHardware.txt is empty, therefore creating new...
echo.
 wmic /OUTPUT:C:\Users\cladmin\Desktop\LCHWC\time.tmp os get LocalDateTime
   TYPE C:\Users\cladmin\Desktop\LCHWC\time.tmp > C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
::   echo %date% >> C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo Service Tag >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
wmic csproduct get identifyingnumber >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo Hard Drive >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
wmic diskdrive get serialnumber >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo Motherboard >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
wmic baseboard get serialnumber >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo Memory >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
wmic memorychip get manufacturer, partnumber >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo Successfully created Pre Hardware file at C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo.
echo Now to lock down PreHardware.txt to read-only...
attrib +R C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo.
echo Script complete.
echo.
)
::exit script, you can `goto :eof` if you prefer that. Exit /B keeps cmd prompt open
pause
Exit


::subroutine
:Empty
If %~z1 EQU 0 (Exit /B 1) Else (Exit /B 0)