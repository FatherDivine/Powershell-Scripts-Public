#requires -version 2
<#
.SYNOPSIS
  Configures a PC for remote MS Updates.

.DESCRIPTION
  Installs  packages and modules necessary to run online-based
  MS updates remotely. Meant to be ran locally or as part of a
  FOG snap-in (Use Initiate-MSWOU.ps1 to install MSWRUP.ps1 automatically).
  This is standalone for certain cases, as this function is integrated 
  within MSWOU.ps1.

.INPUTS
  none

.OUTPUTS
  Logs stored in C:\Windows\Logs\MSWOU\

.NOTES
  Version:        2.0
  Author:         Aaron Staten
  Creation Date:  11/22/2023
  Purpose:        For CEDC IT Dept. use
  
.EXAMPLE
  & .\MSWRUP.ps1
#>

#--------------------------------------------------------------[Privilege Escalation]---------------------------------------------------------------

#When admin rights are needed
<#if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}#>
#----------------------------------------------------------[Initialization & Declarations]----------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Dot Source required Function Libraries
. "${PSScriptRoot}\Logging_Functions.ps1"

#Script Version
$sScriptVersion = "2.0"

# Variables 
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"

#Log File Info
$sLogPath = "C:\Windows\Logs\MSWOU\"
$sLogName = "MSRemoteUpdatesPrereq$date.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function MSWRemoteUpdatesPrerequisites{
  Param()
  
  Begin{
    Log-Write -LogPath $sLogFile -LineValue "Begin Section"
  }
  
  Process{
    Try{
      Log-Write -LogPath $sLogFile -LineValue "Process (code) Section"
      Start-Transcript -Path "C:\Windows\Logs\MSWOU\MSRemoteUpdatesPrereq2$date.log"
      
      #If Nuget or PSWindowsUpdate module aren't already installed, install them
      Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
      
      If(-not(Get-InstalledModule PSWindowsUpdate -ErrorAction silentlycontinue))
      {
      Set-PSRepository PSGallery -InstallationPolicy Trusted -Verbose
      Install-Module PSWindowsUpdate -Confirm:$False -Force -Verbose
      }

      #Enable Remote PS management of Windows Updates
      Enable-WURemoting -Verbose
    }
    
    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }
  
  End{
    If($?){
      Log-Write -LogPath $sLogFile -LineValue "MSRemoteUpdatesPrerequisites Function Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
      Stop-Transcript
    }
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion

#Script Execution goes here
MSWRemoteUpdatesPrerequisites

Log-Finish -LogPath $sLogFile

#Housekeeping
exit
