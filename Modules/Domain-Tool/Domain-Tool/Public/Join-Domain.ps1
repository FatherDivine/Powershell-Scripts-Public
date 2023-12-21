<#
.SYNOPSIS
  Joins host(s) to the domain.

.DESCRIPTION
  Domain joins host(s) to Active Directory.

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

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Dot Source required Function Libraries
#. "${PSScriptRoot}\Logging_Functions.ps1"

If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\")){
  Write-Verbose 'Downloading the latest Invoke-Ping module and placing in C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\' -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-Ping/Invoke-Ping/Invoke-Ping.psd1" `
  -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\Invoke-Ping.psd1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-Ping/Invoke-Ping/Invoke-Ping.psm1" `
  -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\Invoke-Ping.psm1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-Ping/Invoke-Ping/Public/Invoke-Ping.ps1" `
  -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\Public\Invoke-Ping.ps1' -Force) -Verbose
}

#Import Modules
Import-Module -Name Invoke-Ping, Logging-Functions -DisableNameChecking

#Create the Log folder if non-existant
If (!(Test-Path "C:\Windows\Logs\Domain-Tool")){New-Item -ItemType Directory "C:\Windows\Logs\Domain-Tool\" -Force}

New-Alias -Name "Domain-Join" -value Join-Domain -Description "Joins host(s) to the domain."

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Variables
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"
$hn = "$env:COMPUTERNAME"
$Credential = Get-Credentials


#Log File Info
$sLogPath = "C:\Windows\Logs\Domain-Tool"
$sLogName = "Join-Domain$date.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#-----------------------------------------------------------[Functions]------------------------------------------------------------


Function Join-Domain{
  [cmdletbinding()]
  param()
  <#
  .PARAMETER ComputerName
    Allows for QuickFix to be ran against a remote PC or list of
    remote PCs.
#>
  Begin{
    Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Log-Write -LogPath $sLogFile -LineValue "Join-Domain is running on: $ComputerName"
    Log-Write -LogPath $sLogFile -LineValue "Begin Section"

    # LOGIC to dessimate hostname and figure out correct OU path
    #$HostnameString = $hn
    #$HostnameArray = $HostnameString.Split("-")
    #$Hn1 = $HostnameArray[0]
    #$Hn2 = $HostnameArray[1]
  }

  Process{

    Try{
      #Test what Pcs are online first before sending cmdlets to speedup execution
      $WorkingPCs = Invoke-Ping -ComputerName $ComputerName -Quiet

      #Get the offline PCs and let the user know
      $OfflinePCs = (Compare-Object $ComputerName $WorkingPCs -IncludeEqual | Where-Object { $_.SideIndicator -eq "<=" }).InputObject
      Write-Verbose "Computers detected as being offline: $OfflinePCs" -Verbose

      foreach ($PC in $WorkingPCs){
        # LOGIC to dessimate hostname and figure out correct OU path
        $HostnameString = $PC
        $HostnameArray = $HostnameString.Split("-")
        $Hn1 = $HostnameArray[0]
        $Hn2 = $HostnameArray[1]


        # Add PC to AD in correct OU
        switch -WildCard ($HostnameArray[1])
        {
          {'CART' -like $_}{Write-Verbose "Cart" -Verbose; Add-Computer -ComputerName $hn -DomainName "ucdenver.pvt" -OUPATH "OU=CART,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Credential $Credential -Verbose -WhatIf}
          {'LW840','LW844','NC2013','NC2207','NC2408','NC2413','NC2608','NC2609','NC2610' -contains $_}{Write-Verbose "LW840 or Lab" -Verbose;Add-Computer -ComputerName $hn -DomainName "ucdenver.pvt" -OUPATH "OU=$hn2,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Force -Credential $Credential -Verbose -WhatIf}
          {'NC3034','NC3034D','NC3034E','NC3034K','NC3034G','NC3034K','NC3034Q' -like $_}{Write-Verbose "NC3034 Dean" -Verbose;Add-Computer -ComputerName $hn -DomainName "ucdenver.pvt" -OUPATH "OU=DEAN,OU=CEAS,DC=ucdenver,DC=pvt" -Force -Credential $Credential -Verbose -WhatIf}
          {'NC2612A','NC2612B','NC2612C','NC2612D' -like $_}{Write-Verbose "NC2612A or likes" -Verbose;Add-Computer -ComputerName $hn -DomainName "ucdenver.pvt" -OUPATH "OU=ECSG,OU=CEAS,DC=ucdenver,DC=pvt" -Force -Credential $Credential -Verbose -WhatIf}
          default {}
        }
        switch -WildCard ($HostnameArray[0])
        {
          {'BIOE','CIVL','CSCI','ELEC','IWKS','MECH' -contains $_}{Write-Verbose "BIOE,CIVL,CSCI,ELEC non lab" -Verbose;Add-Computer -ComputerName $hn -DomainName "ucdenver.pvt" -OUPATH "OU=$Hn1,OU=CEAS,DC=ucdenver,DC=pvt" -Force -Credential $Credential -Verbose -whatif}
          default {continue}
        }
        #Clear the variables for use again
        Clear-Variable HostnameString, HostnameArray, Hn1, Hn2
      }
    }

    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }

  End{
    If($?){
      Log-Write -LogPath $sLogFile -LineValue "Join-Domain Function Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
      Log-Finish -LogPath $sLogFile -NoExit $True
    }
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here, when not using as a Module
#Need to be included at the end of your *psm1 file.
export-modulemember -alias * -function *