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

#---------------------------------------------------------[Initialisations & Declarations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Dot Source required Function Libraries
#. "${PSScriptRoot}\Logging_Functions.ps1"

#Import Modules
Import-Module -Name Logging-Functions -DisableNameChecking

#Create the Log folder if non-existant
If (!(Test-Path "C:\Windows\Logs\<FolderName>")){New-Item -ItemType Directory "C:\Windows\Logs\<FolderName>\" -Force}

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Variables
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"

#Log File Info
$sLogPath = "C:\Windows\Logs\Domain-Tool"
$sLogName = "Get-Domain$date.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#-----------------------------------------------------------[Functions]------------------------------------------------------------


Function Unjoin-Domain{
  [cmdletbinding()]
  Param()
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
      Read-Host -Prompt "Press Enter to exit"
      Log-Finish -LogPath $sLogFile
    }
  }
}


#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here, when not using as a Module


#first test (locking in credentials), talking to private folder

Write-Host "Putting hostname $JoinDomain in AD Path ucdenver.pvt>CEAS->$ou1->$ou2." #Add Force switch. if detected, don't ask if correct (for script use) or add pipe
if (!($PSBoundParameters.ContainsKey('Force'))){
$JoinNow = Read-Host "If this is the correct, would you like to join now?(Y or N)" #remove from cmd line so it's fast without need for user input
}else{$JoinNow = 'Y'}switch ($JoinNow){
'Y'{

    if (@(Get-ADComputer -Identity $JoinDomain -Server "ucdenver.pvt" -Credential $Credential -ErrorAction SilentlyContinue).Count) { #works with pasted domain join svc acct #try with svc cred w/o university for whole script. if don't work make 2 credentials
        Write-Host "###########################################################"
        Write-Host "Computer object already exists in Active Directory........." # Best to exit because domain join svc acct can't join if someone else made the object in AD either ways.
        Write-Host "###########################################################" # LOGIC split off to trying anyway (in case object WAS created by domain join svc acct.). catch the error of domain join hardening of using differ accts to create
        #break next
                                                                           }
    else {
          Write-Host "#######################################"
          Write-Host "Computer object NOT FOUND... Continuing"
          Write-Host "#######################################"
         }