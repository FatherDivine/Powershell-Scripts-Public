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

#Script Version
$sScriptVersion = "0.1"

#-----------------------------------------------------------[Functions]------------------------------------------------------------

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here, when not using as a Module

#If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Keysight")){
    Write-Verbose 'Downloading the latest Keysight module and placing in C:\Program Files\WindowsPowerShell\Modules\Keysight\' -Verbose
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/Keysight.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\Keysight.psm1' -Force) -Verbose
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/Keysight.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\Keysight.psd1' -Force) -Verbose
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/README.md" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\README.md' -Force) -Verbose
  #}
  Import-Module -Name Keysight -DisableNameChecking
  exit