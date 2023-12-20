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
  https://github.com/FatherDivine/Powershell-Scripts-Public/tree/main/Modules/Keysight

.EXAMPLE
  Add-PSSessionConfig -ComputerName $Remote2

  This script , for now, is meant to be ran locally and not actually part of KeySight suite.
  This is because when adding someone to winRM, it causes a restart which kills the connection,
  so the rest of the script doesn't run. As such, we run this first, then the Keysight tools.
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
Import-Module -Name Invoke-Ping, Logging-Functions -DisableNameChecking

#Create the Log folder if non-existant
If (!(Test-Path "C:\Windows\Logs\KeySight")){New-Item -ItemType Directory "C:\Windows\Logs\Keysight" -Force}

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Variables
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"

#Log File Info
$sLogPath = "C:\Windows\Logs\Keysight"
$sLogName = "ADD-PSSessionConfig$date.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Add-PSSessionConfig{
 <#
  .PARAMETER ComputerName
    Allows for QuickFix to be ran against a remote PC or list of
    remote PCs.
#>
[cmdletbinding()]
Param(
    [Parameter(Mandatory=$false,
    ValueFromPipeline=$true)]
    [string[]]$ComputerName = 'localhost',
    [string]$PSSessionConfigName

)
  Begin{
    Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Log-Write -LogPath $sLogFile -LineValue "Add-PSSessionConfig is running on: $ComputerName"
    Log-Write -LogPath $sLogFile -LineValue "Begin Section"

    Write-Verbose "Enable PS-Remoting on local PC if not already enabled." -Verbose
    if (!(Test-WSMan localhost)){Enable-PSRemoting}
  }

  Process{
    Try{

        #$ConfigurationName = $credential.getNetworkCredential().username
        #send both below variables from reinstall2 to here
        $Creds = (get-credential)
        $PSSessionConfigName = $creds.getNetworkCredential().username

        #Test what Pcs are online first before sending cmdlets to speedup execution
        $WorkingPCs = Invoke-Ping -ComputerName $ComputerName -quiet
        
        #Get the offline PCs and let the user know
        $OfflinePCs = (Compare-Object $ComputerName $WorkingPCs -IncludeEqual | Where-Object { $_.SideIndicator -eq "<=" }).InputObject
        Write-Verbose "Computers detected as being offline: $OfflinePCs" -Verbose

        foreach ($PC in $WorkingPCs){
          Invoke-Command -ComputerName $PC -ScriptBlock {
            if (!(Get-PSSessionConfiguration -name $using:PSSessionConfigName)){
              Register-PSSessionConfiguration -Name $using:PSSessionConfigName -RunAsCredential ($using:Creds) -force
              }
          }
        }
    }

    Catch{
      #Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      #Break
      continue
    }
  }

  End{
    If($?){
      Write-Verbose "Clearing common variables." -Verbose
      Clear-Variable WorkingPCs, ComputerName, OfflinePCs

      Log-Write -LogPath $sLogFile -LineValue "Add-PSSessionConfig Function Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
      Log-Finish -LogPath $sLogFile -NoExit $True

      return $Creds
    }
    #return ,$Creds
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here, when not using as a Module
export-modulemember -alias * -function *