#requires -version 2
<#
.SYNOPSIS
  Runs maintenance commands and outputs a log.

.DESCRIPTION
  Simple script to run a few maintenance commands on the PC,
  like sfc, DISM, and disk optimization. 
  Outputs the logging to C:\temp.

.PARAMETER <Parameter_Name>
    None

.INPUTS
  None

.OUTPUTS
  None

.NOTES
  Version:        2.0
  Author:         Aaron
  Creation Date:  9/27/23 (Updated 11-17-2023)
  For:            CEDC IT Dept.
  
.EXAMPLE
  .\QuickFix.ps1
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Dot Source required Function Libraries
. "${PSScriptRoot}\Logging_Functions.ps1"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "2.0"

#Log File Info
$sLogPath = "C:\Windows\Temp"
$sLogName = "QuickFix.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

# Variables 
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"
$LogFile= "C:\Windows\Temp\QuickFix$date.txt"

#-----------------------------------------------------------[Functions]------------------------------------------------------------



Function QuickFix{
  Param()
  
  Begin{
    Log-Write -LogPath $sLogFile -LineValue "Begin Section"
  }
  
  Process{
    Try{
      Log-Write -LogPath $sLogFile -LineValue "Process (code) Section"

      #If Temp directory doesn't exist, create it
      if (!(Test-Path 'C:\Temp')) {New-Item -ItemType Directory -Path "C:\Temp"}

      # Configuration in case SFC says "Windows Resource Protection could not start the repair service
      sc.exe config trustedinstaller "start=auto"
      net start trustedinstaller

      # SFC
      Start-Job -Name SFC -ScriptBlock {sfc /scannow}

      # Optimize Volume
      #start-job -Name Defrag -ScriptBlock {defrag C: /B /U /V | defrag C: /D /U /V}
      start-job -Name OptimizeVolume -ScriptBlock {Optimize-Volume -DriveLetter C -ReTrim -Verbose}

      # Disk check that schedules next reboot if can't run now. Best to control the reboot at the snap-in level
      start-job -Name DiskCheck -ScriptBlock {"y" | chkdsk C: /F /R | chkntfs C: /c}

      # DISM
      start-job -Name DISM -ScriptBlock {DISM /Online /Cleanup-Image /RestoreHealth}


      # Clear Cache & Cookies
      start-job -Name Cache1 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue -Verbose}

      start-job -Name Cache2 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache2\entries\*" -Recurse -Force -EA SilentlyContinue -Verbose}

      start-job -Name Cache3 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Media Cache" -Recurse -Force -EA SilentlyContinue -Verbose}

      start-job -Name Cookies1 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies" -Recurse -Force -EA SilentlyContinue -Verbose}

      start-job -Name Cookies2 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies-Journal" -Recurse -Force -EA SilentlyContinue -Verbose}


      # Logging
      wait-job -name SFC,OptimizeVolume,DiskCheck,DISM,Cache1,Cache2,Cache3,Cookies1,Cookies2 | Receive-Job | out-file -FilePath $LogFile

# Housekeeping
    }
    
    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }
  
  End{
    #If($?){
      Log-Write -LogPath $sLogFile -LineValue "Function Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
    #}
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion

#Script Execution goes here
QuickFix

Log-Finish -LogPath $sLogFile