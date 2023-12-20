<#
.SYNOPSIS
  Installs Keysight module.

.DESCRIPTION
  Installs the latest Keysight module from Github.

.INPUTS
  None

.OUTPUTS
  None

.NOTES
  Version:        0.1
  Author:         Aaron Staten
  Creation Date:  11-30-23
  Purpose/Change: Initial script development

.LINK
https://github.com/FatherDivine/Powershell-Scripts-Public/tree/main/Modules/Keysight

#>

#---------------------------------------------------------[Initialisations & Declarations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#-----------------------------------------------------------[Functions]------------------------------------------------------------

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here, when not using as a Module

Write-Verbose "`r`nKeysight Module to fix various issues with Keysight programs" -Verbose
If (Test-Path "C:\Program Files\WindowsPowerShell\Modules\Keysight"){
  Write-Verbose "Removing the old version of Keysight first." -Verbose
  Try {Remove-Item -Path "C:\Program Files\WindowsPowerShell\Modules\Keysight" -Recurse -Force -Verbose}Catch{Write-Error "Error Occured: $_"}
}
  Write-Verbose 'Downloading the latest Keysight module and placing in C:\Program Files\WindowsPowerShell\Modules\Keysight\' -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/Keysight/Keysight.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\Keysight.psd1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/Keysight/Keysight.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\Keysight.psm1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/Keysight/Public/Keysight-ADS-FixHomePath.ps1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\Public\Keysight-ADS-FixHomePath.ps1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/Keysight/Public/Keysight-ADS-Uninstall.ps1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\Public\Keysight-ADS-Uninstall.ps1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/Keysight/Public/Add-PSSessionConfig.ps1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\Public\Add-PSSessionConfig.ps1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/Keysight/Public/Keysight-ADS-Reinstall.ps1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\Public\Keysight-ADS-Reinstall.ps1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/Keysight/Public/Keysight-ADS-SetEnvVariable.ps1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\Public\Keysight-ADS-SetEnvVariable.ps1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/README.md" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\README.md' -Force) -Verbose
  #Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/Keysight/Public/Keysight-ADS-VersionCheck.ps1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\Public\Keysight-ADS-VersionCheck.ps1' -Force) -Verbose

  Import-Module -Name Keysight -DisableNameChecking
  exit