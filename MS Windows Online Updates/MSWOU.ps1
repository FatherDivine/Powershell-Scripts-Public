#requires -version 2
<#
.SYNOPSIS
  Runs MS Windows Updates.

.DESCRIPTION
  Installs  packages and modules necessary to run online-based
  updates with Windows Updates.

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
  Version:        1.5
  Author:         Aaron Staten
  Creation Date:  11/22/2023
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#----------------------------------------------------------[Initialization & Declarations]----------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Dot Source required Function Libraries
. "${PSScriptRoot}\Logging_Functions.ps1"

#Script Version
$sScriptVersion = "1.5"

# Variables 
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"
$hostname = hostname

#Log File Info
$sLogPath = "C:\Windows\Logs\MSWOU\"
$sLogName = "MSWindowsOnlineUpdater$date.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName


#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function MSWindowsOnlineUpdater{
  Param()
  
  Begin{
    Log-Write -LogPath $sLogFile -LineValue "Begin Section"
  }
  
  Process{
    Try{
      Log-Write -LogPath $sLogFile -LineValue "Process (code) Section"
      
      # If Nuget or PSWindowsUpdate aren't already installed, install them
      If (-not(Get-PackageProvider NuGet)){Install-PackageProvider NuGet -Forcebootstrap -Confirm:$False -Source PSGallery}
      
      If(-not(Get-InstalledModule PSWindowsUpdate -ErrorAction silentlycontinue))
      {
      Set-PSRepository PSGallery -InstallationPolicy Trusted
      Install-Module PSWindowsUpdate -Confirm:$False -Force
      }
      # Install kogged MS updates so we can keep track of what was installed if need.
      Start-Transcript -Path "C:\Windows\Logs\MSWOU\MSWindowsOnlineUpdater-Updates$date.log"
      Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -Verbose 
      Stop-Transcript 
    }
    
    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }
  
  End{
    If($?){
      Log-Write -LogPath $sLogFile -LineValue "MSWindowsOnlineUpdater Function Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
    }
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion

#Script Execution goes here
MSWindowsOnlineUpdater

Log-Finish -LogPath $sLogFile
Log-Email -LogPath $sLogPath -EmailFrom "$hostname.MSWOU@ucdenver.pwsh" -EmailTo "aaron.staten@ucdenver.pvt" -EmailSubject "MS Windows Online Updates Log - [" + (Get-Date).ToShortDateString() + "]"
