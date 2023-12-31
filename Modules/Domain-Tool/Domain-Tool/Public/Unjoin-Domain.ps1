<#
.SYNOPSIS
  Unjoins host(s) from the domain.

.DESCRIPTION
  <Brief description of script>

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
  Version:        0.1
  Author:         Aaron Staten
  Creation Date:  12-6-2023
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

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Dot Source required Function Libraries
#. "${PSScriptRoot}\Logging_Functions.ps1"

#Import Modules
Import-Module -Name Logging-Functions -DisableNameChecking

#Create the Log folder if non-existant
If (!(Test-Path "C:\Windows\Logs\<FolderName>")){New-Item -ItemType Directory "C:\Windows\Logs\<FolderName>\" -Force}

New-Alias -Name "Domain-Unjoin" -value Unjoin-Domain -Description "Joins host(s) to the domain."

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Variables
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"

#Log File Info
$sLogPath = "C:\Windows\Logs\Domain-Tool"
$sLogName = "Unjoin-Domain$date.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Remove-Domain{
  [CmdletBinding()]
param()
  <#
  .PARAMETER ComputerName
    Allows for QuickFix to be ran against a remote PC or list of
    remote PCs.

  [cmdletbinding()]
  Param(
    [Parameter(Mandatory=$false,
    ValueFromPipeline=$true)]
    [string[]]$ComputerName = 'localhost'
  )
#>
  Begin{
    Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Log-Write -LogPath $sLogFile -LineValue "<FunctionName> is running on: $ComputerName"
    Log-Write -LogPath $sLogFile -LineValue "Begin Section"
  }

  Process{
    Try{
      Write-Verbose "code goes here" -Verbose
    }

    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }

  End{
    If($?){
      Log-Write -LogPath $sLogFile -LineValue "<FunctionName> Function Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
      #Read-Host -Prompt "Press Enter to exit"
      Log-Finish -LogPath $sLogFile
    }
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here, when not using as a Module
#Need to be included at the end of your *psm1 file.
export-modulemember -alias * -function *