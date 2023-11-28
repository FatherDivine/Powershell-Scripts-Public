#requires -version 2
<#
.SYNOPSIS
  Runs maintenance commands and outputs a log.

.DESCRIPTION
  Simple script to run a few maintenance commands on the PC,
  like sfc, DISM, and disk optimization. 
  Outputs the logging to C:\temp.

.PARAMETER ComputerName
    Allows for QuickFix to be ran against a remote PC or list of
    remote PCs.

.INPUTS
  None

.OUTPUTS
  Logs are sent to:
  C:\Windows\Logs\QuickFix

.NOTES
  Version:        0.1 (Module)
  Author:         Aaron
  Creation Date:  9/27/23 (Updated 11-26-2023)
  For:            CEDC IT Dept.
  Planned Updates: Keep PS window open after module runs
  
.EXAMPLE
  Run on an array of PCs
  .\QuickFix.ps1 -ComputerName $NC2413

  Run the Module Version from a PS prompt (alias)
  QF

  Run the Module version with a list of PCs from a PS prompt (another alias)
  QuickFix -ComputerName "Test-PC"

  Using the Full (non-aliased) name from a PS prompt
  Invoke-QuickFix

  #FOG Snapin Arguments for calling the function for the local PC
   powershell.exe -ExecutionPolicy Bypass -Command "& {. .\QuickFix.ps1; & QuickFix}" 
#>

#--------------------------------------------------------------[Privilege Escalation]---------------------------------------------------------------

#When admin rights are needed
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}
#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Downloading the latest version of the modules & script(s) via Github if non-existant
If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Logging-Functions")){  
Write-Verbose 'Downloading the latest Logging-Functions module and placing in C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\' -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psm1' -Force)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psd1' -Force)
}

#Import Modules
Import-Module -Name Logging-Functions -DisableNameChecking

#Create Quickfix aliases
New-Alias -Name QuickFix -value Invoke-QuickFix -Description "Runs routine maintenance comamnds like SFC, disk check, disk optimize, DISM, and clears cookies & cache on a local or remote PC(s)."
New-Alias -Name QF -value Invoke-QuickFix -Description "Runs routine maintenance comamnds like SFC, disk check, disk optimize, DISM, and clears cookies & cache on a local or remote PC(s)."

#Create the Log folder if non-existant
If (!(Test-Path "C:\Windows\Logs\QuickFix")){New-Item -ItemType Directory "C:\Windows\Logs\Quickfix\" -Force}


#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "0.1"

#Variables 
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"
$hostname = hostname

#Log File Info
$sLogPath = "C:\Windows\Logs\QuickFix\"
$sLogName = "QuickFix$date.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Invoke-QuickFix{
  [cmdletbinding()]
  Param(
    [Parameter(Mandatory=$false,
    ValueFromPipeline=$true)]
    [string[]]$ComputerName
  )
  
  Begin{
    Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Log-Write -LogPath $sLogFile -LineValue "Begin Section"
  }
  
  Process{
    Try{
      Log-Write -LogPath $sLogFile -LineValue "Process (code) Section"
      If ($null -eq $ComputerName){  
        Log-Write -LogPath $sLogFile -LineValue "QuickFix is running on: Localhost ($hostname)"

        # Configuration in case SFC says "Windows Resource Protection could not start the repair service
        sc.exe config trustedinstaller "start=auto"
        net start trustedinstaller

        #The fixes
        #start-job -Name Defrag -ScriptBlock {defrag C: /B /U /V | defrag C: /D /U /V}
        start-job -Name OptimizeVolume -ScriptBlock {Optimize-Volume -DriveLetter C -ReTrim -Verbose} -Verbose

        #Disk check that schedules next reboot if can't run now. Best to control the reboot at the snap-in level
        start-job -Name DiskCheck -ScriptBlock {"y" | chkdsk C: /F /R | chkntfs C: /c} -Verbose

        #DISM
        start-job -Name DISM -ScriptBlock {DISM /Online /Cleanup-Image /RestoreHealth} -Verbose

        #SFC
        Start-Job -Name SFC -ScriptBlock {sfc /scannow} -Verbose

        #Clear Cache & Cookies
        start-job -Name Cache1 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue -Verbose}

        start-job -Name Cache2 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache2\entries\*" -Recurse -Force -EA SilentlyContinue -Verbose}

        start-job -Name Cache3 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Media Cache" -Recurse -Force -EA SilentlyContinue -Verbose}

        start-job -Name Cookies1 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies" -Recurse -Force -EA SilentlyContinue -Verbose}

        start-job -Name Cookies2 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies-Journal" -Recurse -Force -EA SilentlyContinue -Verbose}

        #Logging
        $date = Get-Date -Format "-MM-dd-yyyy-HH-mm"
        wait-job -name SFC,OptimizeVolume,DiskCheck,DISM,Cache1,Cache2,Cache3,Cookies1,Cookies2 -Verbose| Receive-Job -Verbose| Out-File (New-Item -Path "C:\Windows\Logs\QuickFix\QuickFix-Jobs.log" -Force)
      }
      else{
          Log-Write -LogPath $sLogFile -LineValue "QuickFix is running on: $ComputerName"  
          $ScriptBlock = {
          #Create the Log folder if non-existant
          If (!(Test-Path "C:\Windows\Logs\QuickFix")){New-Item -ItemType Directory "C:\Windows\Logs\Quickfix" -Force}

          #Configuration in case SFC says "Windows Resource Protection could not start the repair service
          sc.exe config trustedinstaller "start=auto"
          net start trustedinstaller
  
          #Optimize Volume
          #start-job -Name Defrag -ScriptBlock {defrag C: /B /U /V | defrag C: /D /U /V}
          start-job -Name OptimizeVolume -ScriptBlock {Optimize-Volume -DriveLetter C -ReTrim -Verbose} -Verbose
  
          #Disk check that schedules next reboot if can't run now. Best to control the reboot at the snap-in level
          start-job -Name DiskCheck -ScriptBlock {"y" | chkdsk C: /F /R | chkntfs C: /c} -Verbose
  
          #DISM
          start-job -Name DISM -ScriptBlock {DISM /Online /Cleanup-Image /RestoreHealth} -Verbose
  
          #SFC
          Start-Job -Name SFC -ScriptBlock {sfc /scannow} -Verbose
  
          #Clear Cache & Cookies
          start-job -Name Cache1 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue -Verbose}
  
          start-job -Name Cache2 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache2\entries\*" -Recurse -Force -EA SilentlyContinue -Verbose}
  
          start-job -Name Cache3 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Media Cache" -Recurse -Force -EA SilentlyContinue -Verbose}
  
          start-job -Name Cookies1 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies" -Recurse -Force -EA SilentlyContinue -Verbose}
  
          start-job -Name Cookies2 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies-Journal" -Recurse -Force -EA SilentlyContinue -Verbose}
  
          #Logging
          $date = Get-Date -Format "-MM-dd-yyyy-HH-mm"
          wait-job -name SFC,OptimizeVolume,DiskCheck,DISM,Cache1,Cache2,Cache3,Cookies1,Cookies2 -Verbose| Receive-Job -WriteEvents -WriteJobInResults -Verbose| Out-File (New-Item -Path "C:\Windows\Logs\QuickFix\QuickFix-Jobs$date.log" -Force)
          }
       
        foreach ($PC in $ComputerName){
          Invoke-Command -ScriptBlock $ScriptBlock -ComputerName $PC -AsJob
      }    
    }
  }
    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  
  }
  End{
    If($?){
      Log-Write -LogPath $sLogFile -LineValue "QuickFix Function Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
      Read-Host -Prompt "Press Enter to exit"
      Log-Finish -LogPath $sLogFile
    }
  }
}
#-----------------------------------------------------------[Exports]------------------------------------------------------------

#Need to be included at the end of your *psm1 file.
export-modulemember -alias * -function *