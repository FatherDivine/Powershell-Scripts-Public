GOTO EndFirstComment

LCHWC Version 1.6
Created by: Aaron Staten for CEDC IT.
Lines that start with `rem :: ` are comment lines that narrate what the script does.

The below line is used for testing purposes when the script closes too fast to see the error. 
It will launch the script in a second CMD prompt that won't close when the script errors or comes to an end. 
Only use when testing is needed. Use by placing the line below the preceeding EndFirstComment statement:

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
echo Laptop Cart Hardware Checker Version 1.5.5
echo ---------------------------------------------------------------------------------
rem :: Checks if LCHWC folder already exists, and if not creates.

if exist "C:\Users\cladmin\Desktop\LCHWC" (
	echo The LCHWC folder already exists on cladmin Desktop. Moving on...
	echo.
) else (
	echo The LCHWC folder does NOT exist on cladmin desktop. Creating...
	echo.
	mkdir "C:\Users\cladmin\Desktop\LCHWC"
	type NUL > C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt	
)
rem :: Checks of the PreHardware text file is empty or not. If empty it will create. 
rem :: If it already has data, it skips to creating the PostHardware text file. 

(Call :Empty "C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt"  && (
    echo PreHardware.txt already exists/is not empty, 
    echo so creating PostHardware.txt ^& recording information for comparison...
echo.
rem :: The below lines gathers all the info required and puts into PostHardware text file on cladmin desktop. 
rem :: This includes local date & time, service tag, & the serial numbers for hard drive, memory, monitor, & motherboard.

wmic /OUTPUT:C:\Users\cladmin\Desktop\LCHWC\time.tmp os get LocalDateTime
TYPE C:\Users\cladmin\Desktop\LCHWC\time.tmp  > C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt
echo Successfully created the PostHardware.txt file at C:\Users\cladmin\Desktop\LCHWC\
echo Gathering hardware information...
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
echo.
echo Tech notes section. Write any notes on the condition of the hardware, 
echo including the physical condition *after* being brought back. 
set /p postnotes="Technician Notes:"
echo.
>>"C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt" echo "Technician Notes (Post): !postnotes!"
echo.

rem :: The below line compares PreHardware.txt and PostHardware.txt, outputting the results to Results.txt and printing them on-screen. 

:::::::::::::::::::::::::::::::::::::::::::: Add better language to easily tell if OK or fraud. Maybe compare both pre and post notes, and if they are the same, create a pop-up
echo Below are the hardware changes detected on %host%. If all you see is the LocalDateTime ^& the Technician Notes, that means no hardware changed:
set datestr=%date:~10,4%-%date:~7,2%-%date:~4,2%
for /f "tokens=2 delims==" %%a in ('wmic bios get serialnumber /value') do for %%b in (%%a) do set "serial=%%b"
fc /L "C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt" "C:\Users\cladmin\Desktop\LCHWC\PostHardware.txt" > "C:\Users\cladmin\Desktop\LCHWC\!datestr!-!serial!.txt"
echo.
type C:\Users\cladmin\Desktop\LCHWC\!datestr!-!serial!.txt
echo.
:::::::::::::::::::::::::::::::::::::::::::: successful line: echo [92mALL CLEAR! NO CHANGES DETECTED !! [0m
:::::::::::::::::::::::::::::::::::::::::::: fail line: echo [91mALERT!! CHANGES DETECTED!! CHECK C:\Users\cladmin\Desktop\LCHWC\results.txt !! [0m
:::::::::::::::::::::::::::::::::::::::::::: Last thing: need FC (or other) to only check first few lines to compare, 
goto :EOF
echo.
::::::::::::::::::::::::::::::::::::::::::::
echo Script complete.
echo.
)) || (
rem :: The below lines gathers all the info required and puts into PreHardware text file on cladmin desktop. 
rem :: This includes local date and time, service tag, & the serial numbers for hard drive, memory, monitor, & motherboard.

echo PreHardware.txt does not exist/is empty, a sign this script hasn't run before. 
echo Creating PreHardware.txt ^& recording hardware information...
echo.
wmic /OUTPUT:C:\Users\cladmin\Desktop\LCHWC\time.tmp os get LocalDateTime
TYPE C:\Users\cladmin\Desktop\LCHWC\time.tmp > C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo Successfully created the PreHardware.txt file at C:\Users\cladmin\Desktop\LCHWC\
echo Gathering hardware information...
del /f C:\Users\cladmin\Desktop\LCHWC\time.tmp 
echo Service Tag >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
wmic bios get serialnumber >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo Hard Drive >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
wmic diskdrive get serialnumber >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo Memory >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
wmic memorychip get manufacturer, partnumber, serialnumber >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo PNP Display/Monitor Device ID >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
wmic desktopmonitor get pnpdeviceid >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo Motherboard >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
wmic baseboard get serialnumber >>C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt
echo.
echo Successfully recorded hardware information to PreHardware.txt.
echo.
echo Tech notes section. Write any notes on the condition of the hardware,  
echo including the physical condition *before* being rented out. 
set /p prenotes="Technician Notes:"
>>"C:\Users\cladmin\Desktop\LCHWC\PreHardware.txt" echo "Technician Notes (Pre): !prenotes!" 
echo.
echo Making PreHardware.txt tamper resistant by locking it down to read-only...
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
:GetSerialNumber
for /f "tokens=2 delims==" %%a in ('
    wmic csproduct get identifyingnumber /value
') do for /f "delims=" %%b in ("%%a") do (
    Set "SerialNumber=%%b" 
)
exit /b
:EOF