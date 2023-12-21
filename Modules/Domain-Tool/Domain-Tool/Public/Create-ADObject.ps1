<#
.SYNOPSIS
  Creates a computer object in AD.

.DESCRIPTION
  Creates a computer object in Active Directory.

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  None

.OUTPUTS
  Log file stored in C:\Windows\Temp\<name>.log

.NOTES
  Version:        0.1
  Author:         Aaron Staten
  Creation Date:  12-6-2023
  Purpose/Change: Initial script development
                  Learned the svc acct can't delete/unjoin from COMPUTERS given limited permissions.
                  Also Add-Computer adds a PC already on the network to the domain, whereas
                  New-ADComputer creates a new object that may not already exist.
 12-20-2023 This Function is UNTESTED and need to check syntax of New-ADComputer

.LINK
  https://github.com/FatherDivine/Powershell-Scripts-Public/tree/main/Modules/Domain-Tool

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
#if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
#{
#  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
#  Start-Process powershell -Verb runAs -ArgumentList $arguments
#  Break
#}

#---------------------------------------------------------[Initialisations ]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Dot Source required Function Libraries
#. "${PSScriptRoot}\Logging_Functions.ps1"

#Import Modules
Import-Module -Name Logging-Functions -DisableNameChecking

#Create the Log folder if non-existant
If (!(Test-Path "C:\Windows\Logs\<FolderName>")){New-Item -ItemType Directory "C:\Windows\Logs\<FolderName>\" -Force}

New-Alias -Name "Domain-Join" -value Join-Domain -Description "Joins host(s) to the domain."

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Variables
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"
$hn = "cedc-cart-l1" #"$env:COMPUTERNAME"
$Credential = Get-Credentials


#Log File Info
$sLogPath = "C:\Windows\Logs\Domain-Tool"
$sLogName = "Create-ADObject$date.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#-----------------------------------------------------------[Functions]------------------------------------------------------------


Function Create-ADObject{
  [cmdletbinding()]
  param()
  <#
  .PARAMETER ComputerName
    Allows for QuickFix to be ran against a remote PC or list of
    remote PCs.
#>
  Begin{
    Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Log-Write -LogPath $sLogFile -LineValue "<FunctionName> is running on: $ComputerName"
    Log-Write -LogPath $sLogFile -LineValue "Begin Section"

    # LOGIC to dessimate hostname and figure out correct OU path
    $HostnameString = $hn
    $HostnameArray = $HostnameString.Split("-")
    $Hn1 = $HostnameArray[0]
    $Hn2 = $HostnameArray[1]

    # LOGIC to pull service tag, sanitize it, and add to description in AD
    $ServiceTag = Get-CimInstance -ErrorAction Stop win32_SystemEnclosure | select-object serialnumber
    $ST = $ServiceTag -Replace ('\W','')
    $ST2 = $ST -Replace ('serialnumber','')
  }

  Process{
    Try{
# Add PC to AD in correct OU
switch -WildCard ($HostnameArray[1])
{
 {'CART' -like $_}{Write-Verbose "Cart" -Verbose; New-ADComputer -ComputerName $hn -DomainName "ucdenver.pvt" -OUPATH "OU=CART,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Credential $Credential -Verbose -WhatIf}
 {'LW840','LW844','NC2013','NC2207','NC2408','NC2413','NC2608','NC2609','NC2610' -contains $_}{Write-Verbose "LW840 or Lab" -Verbose;New-ADComputer -ComputerName $hn -DomainName "ucdenver.pvt" -OUPATH "OU=$hn2,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Force -Credential $Credential -Verbose -WhatIf}
 {'NC3034','NC3034D','NC3034E','NC3034K','NC3034G','NC3034K','NC3034Q' -like $_}{Write-Verbose "NC3034 Dean" -Verbose;New-ADComputer -ComputerName $hn -DomainName "ucdenver.pvt" -OUPATH "OU=DEAN,OU=CEAS,DC=ucdenver,DC=pvt" -Force -Credential $Credential -Verbose -WhatIf}
 {'NC2612A','NC2612B','NC2612C','NC2612D' -like $_}{Write-Verbose "NC2612A or likes" -Verbose;New-ADComputer -ComputerName $hn -DomainName "ucdenver.pvt" -OUPATH "OU=ECSG,OU=CEAS,DC=ucdenver,DC=pvt" -Force -Credential $Credential -Verbose -WhatIf}
 default {}
}
switch -WildCard ($HostnameArray[0])
{
 {'BIOE','CIVL','CSCI','ELEC','IWKS','MECH' -contains $_}{Write-Verbose "BIOE,CIVL,CSCI,ELEC non lab" -Verbose;New-ADComputer -ComputerName $hn -DomainName "ucdenver.pvt" -OUPATH "OU=$Hn1,OU=CEAS,DC=ucdenver,DC=pvt" -Force -Credential $Credential -Verbose -whatif}
 default {continue}
}

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
      Log-Finish -LogPath $sLogFile
    }
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here, when not using as a Module
#Need to be included at the end of your *psm1 file.
export-modulemember -alias * -function *