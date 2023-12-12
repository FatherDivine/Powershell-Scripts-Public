<#
.SYNOPSIS
  <Overview of script>

.DESCRIPTION
  <Brief description of script>

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development

.LINK
GitHub README or script link

.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>
#---------------------------------------------------------[Force Module Elevation]--------------------------------------------------------
#With this code, the script/module/function won't run unless elevated, thus local users can't use off the bat.
<#
$Elevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ( -not $Elevated ) {
  throw "This module requires elevation."
}
#>

#--------------------------------------------------------------[Privilege Escalation]---------------------------------------------------------------

#When admin rights are needed
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}

#---------------------------------------------------------[Initialisations & Declarations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Dot Source required Function Libraries
#. "${PSScriptRoot}\Logging_Functions.ps1"

Write-Verbose "`r`nLogging-Functions for basic logging functionality in all scripts." -Verbose
#If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\")){
  Write-Verbose 'Downloading the latest Logging-Functions module and placing in C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\' -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psm1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psd1' -Force) -Verbose
#}
Write-Verbose "`r`nInvoke-Ping, the fastest way to only send cmdlets to a PC that's online. Saves time from sending cmdlets to offline PCs."
#If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\")){
    Write-Verbose 'Downloading the latest Logging-Functions module and placing in C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\' -Verbose
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-Ping/Invoke-Ping/Invoke-Ping.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\Invoke-Ping.psd1' -Force) -Verbose
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-Ping/Invoke-Ping/Invoke-Ping.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\Invoke-Ping.psm1' -Force) -Verbose
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-Ping/Invoke-Ping/Public/Invoke-Ping.ps1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\Public\Invoke-Ping.ps1' -Force) -Verbose
#}

#Import Modules
Import-Module -Name Logging-Functions -DisableNameChecking

#Create the Log folder if non-existant
If (!(Test-Path "C:\Windows\Logs\KeySight")){New-Item -ItemType Directory "C:\Windows\Logs\Keysight" -Force}

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Variables
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"

#Log File Info
$sLogPath = "C:\Windows\Logs\Keysight"
$sLogName = "ADD-PSSessionConfiguration.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Add-PSSessionConfiguration{
 <#
  .PARAMETER ComputerName
    Allows for QuickFix to be ran against a remote PC or list of
    remote PCs.
#>
[cmdletbinding()]
Param(
    [Parameter(Mandatory=$false,
    ValueFromPipeline=$true)]
    [string[]]$RunAsName = 'localhost',
    [string]$PSSessionConfigurationName

)
  Begin{
    Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Log-Write -LogPath $sLogFile -LineValue "Add-PSSessionConfiguration is running on: $ComputerName"
    Log-Write -LogPath $sLogFile -LineValue "Begin Section"
  }

  Process{
    Try{

        #$ConfigurationName = $credential.getNetworkCredential().username
        #send both below variables from reinstall2 to here 
        Register-PSSessionConfiguration -Name $PSSessionConfigurationName -RunAsCredential $RunAsName -Force -Verbose 
        
    }

    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }

  End{
    If($?){
      Log-Write -LogPath $sLogFile -LineValue "Add-PSSessionConfiguration Function Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
      Read-Host -Prompt "Press Enter to exit"
      Log-Finish -LogPath $sLogFile
    }
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here, when not using as a Module
export-modulemember -alias * -function *