GOTO EndFirstComment

LCHWC Version 1.5
Created by: Aaron Staten for CEDC IT.
Lines that start with `rem :: ` are comment lines that narrate what the script does.

The below line is used for testing purposes when the script closes too fast to see the error. 
It will launch the script in a second CMD prompt that won't close. Only use when testing is needed:

if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )

:EndFirstComment

::::::::::::::::::::::::::::::::::::::::::::
:: Set our environment & variables
::::::::::::::::::::::::::::::::::::::::::::
setlocal enableDelayedExpansion
@echo off
hostname.exe > __t.tmp
set /p host=<__t.tmp
del __t.tmp


CLS
::::::::::::::::::::::::::::::::::::::::::::
:: Automatically check & get admin rights V2
::::::::::::::::::::::::::::::::::::::::::::
if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
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



::::::::::::::::::::::::::::::::::::::::::::
:: START OF LAPTOP CART HARDWARE CHECKER 1.0
::::::::::::::::::::::::::::::::::::::::::::
rem :: Checks if LCHWC folder already exists, and if not creates.

if exist "C:\Users\cladmin\Desktop\LCHWC" (
	echo LCHWC folder already exists on cladmin desktop. Moving on...
	echo.
) else (
	echo LCHWC folder does NOT exist on cladmin desktop. Creating...
	echo.
	mkdir "C:\Users\cladmin\Desktop\LCHWC"
	type NUL > C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt	
)
rem :: Checks of the PreHardware text file is empty or not. If empty it will create. 
rem :: If it already has data, it skips to creating the PostHardware text file. 

(Call :Empty "C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt"  && (
    Echo PreHardware.txt is not empty, so creating PostHardware.txt for comparison...
echo.
rem :: The below lines gathers all the info required and puts into PostHardware text file on cladmin desktop. 
rem :: This includes local date & time, service tag, & the serial numbers for hard drive, memory, monitor, & motherboard.

wmic /OUTPUT:C:\Users\cladmin\Desktop\LCHWC\time.tmp os get LocalDateTime
TYPE C:\Users\cladmin\Desktop\LCHWC\time.tmp  > C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
del /f C:\Users\cladmin\Desktop\LCHWC\time.tmp 
echo Service Tag >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
wmic bios get serialnumber >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
echo Hard Drive >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
wmic diskdrive get serialnumber >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
echo Memory >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
wmic memorychip get manufacturer, partnumber, serialnumber >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
echo PNP Display/Monitor Device ID >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
wmic desktopmonitor get pnpdeviceid >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
echo Motherboard >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
wmic baseboard get serialnumber >>C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
echo Successfully created Post Hardware file at C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
echo.
echo Now is the time to write any notes about the condition of the hardware *after* being brought back.
set /p postnotes="Technician Notes:"
cls
>>"C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt" echo "Technician Notes (Post): !postnotes!"

echo Next step is comparison. Below are the changes from the pre-hardware check to post-hardware check.
echo If all you see is a timestamp and technician notes, that means no hardware changed:
echo.
echo.
rem :: The below line compares PreHardware.txt and PostHardware.txt, outputting the results to Results.txt and printing them on-screen. 
rem :: The /vg of findstr means V: print only lines that don't contain a match & G: get search strings from the specified file.

echo These are the results of %host%:
fc /L "C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt" "C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt" >"C:\Users\cladmin\Desktop\LCHWC\Results.txt"
echo.
powershell -File LCHWCMailer.ps1
echo.
echo File successfully e-mailed to cedchelp@ucdenver.edu.
echo.
echo Script complete.
echo.
)) || (
rem :: The below lines gathers all the info required and puts into PreHardware text file on cladmin desktop. 
rem :: This includes local date and time, service tag, & the serial numbers for hard drive, memory, monitor, & motherboard.

echo PreHardware.txt is empty, therefore creating new...
echo.
wmic /OUTPUT:C:\Users\cladmin\Desktop\LCHWC\time.tmp os get LocalDateTime
TYPE C:\Users\cladmin\Desktop\LCHWC\time.tmp > C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
del /f C:\Users\cladmin\Desktop\LCHWC\time.tmp 
echo Original Service Tag #>>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
wmic bios get serialnumber >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo Hard Drive >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
wmic diskdrive get serialnumber >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo Memory >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
wmic memorychip get manufacturer, partnumber, serialnumber >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo PNP Display/Monitor Device ID >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
wmic desktopmonitor get pnpdeviceid >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo Motherboard >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
wmic baseboard get serialnumber >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo Successfully created Pre Hardware file at C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo.
echo Now is the time to write any notes about the condition of the hardware *before* being rented out.
set /p prenotes="Technician Notes:"
cls
>>"C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt" echo "Technician Notes (Pre): !prenotes!" 

echo And finally to lock down PreHardware.txt to read-only...
attrib +R C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo.
echo Script complete.
echo.
)
rem :: exit script, you can `goto :eof` if you prefer that. Also, if you want to keep the cmd prompt open use `Exit /B`
pause
Exit
rem :: subroutine (defining the label called Empty as called in line 85)
:Empty
If %~z1 EQU 0 (Exit /B 1) Else (Exit /B 0)