#requires -version 2
<#
.SYNOPSIS
  Runs MS Windows Updates

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

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Dot Source required Function Libraries
. "${PSScriptRoot}\Logging_Functions.ps1"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.5"

# Variables 
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"

#Log File Info
$sLogPath = "C:\Windows\Temp"
$sLogName = "MSWindowsOnlineUpdater$date.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName


#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function MSWindowsOnlineUpdater{
  Param()
  
  Begin{
    Log-Write -LogPath $sLogFile -LineValue "<description of what is going on>..."
  }
  
  Process{
    Try{
      Log-Write -LogPath $sLogFile -LineValue "Process (code) Section"
      
      Install-PackageProvider NuGet -Force

      If(-not(Get-InstalledModule PSWindowsUpdate -ErrorAction silentlycontinue))
      {
      Set-PSRepository PSGallery -InstallationPolicy Trusted
      Install-Module PSWindowsUpdate -Confirm:$False -Force
      }
      Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -Verbose
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