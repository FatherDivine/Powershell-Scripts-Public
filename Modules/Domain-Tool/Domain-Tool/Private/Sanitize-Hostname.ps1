<#
.SYNOPSIS
  Sanitizes hostnames.

.DESCRIPTION
  Sanitizes hostnames for CEDC IT environment.

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

#---------------------------------------------------------[Initialisations ]--------------------------------------------------------
#Checks the hostname to let the module know what OU the host belongs.

#region function ServiceTagWriter
function ServiceTagWriter{
  [cmdletbinding()]
  param()
<#
.TODO
    Eventually add remote support, but if winrm or other issues get-ciminstance won't work so best to not worry.
    Idea is grab remote ST and throw into it's AD object. For now only does that locally.

    If switch, return ST only (don't set)
#>
# Variables
$hn = $env:COMPUTERNAME

# LOGIC to pull service tag, sanitize it, and add to description in AD
$ServiceTag = Get-CimInstance -ErrorAction Stop win32_SystemEnclosure | select-object serialnumber
$ST = $ServiceTag -Replace ('\W','')
$ST2 = $ST -Replace ('serialnumber','')
Remove-Variable ServiceTag
$global:ServiceTag = $ST2

Switch ($PSBoundParameters.Keys){
        
    'PrintOnly'{
                Write-Host "`nService Tag of ${hostname}: $global:ServiceTag`n"
                write-host "print only exiting";pause
               }

    default{# LOGIC to dessimate hostname and figure out correct OU path
            write-host "the default section";pause
            $HostnameString = $hn
            $HostnameArray = $HostnameString.Split("-")
            $Hn1 = $HostnameArray[0]
            $Hn2 = $HostnameArray[1]

            switch -WildCard ($HostnameArray[0]){
                {'BIOE','CIVL','CSCI','ELEC','IWKS','MECH' -contains $_}{Set-ADObject -Identity "CN=$hn,OU=$Hn1,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
                default {continue}
            }
            switch -WildCard ($HostnameArray[1]){
                {'CART*' -like $_}{Set-ADObject -Identity "CN=$hn,OU=$HostNameArray[1],OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
                {'LW840','LW844','NC2013','NC2207','NC2408','NC2413','NC2608','NC2609','NC2610' -contains $_}{Set-ADObject -Identity "CN=$hn,OU=$hn2,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
                {'NC3034','NC3034D','NC3034E','NC3034K','NC3034G','NC3034K','NC3034Q' -like $_}{Set-ADObject -Identity "CN=$hn,OU=DEAN,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
                {'NC2612A','NC2612B','NC2612C','NC2612D' -like $_}{Set-ADObject -Identity "CN=$hn,OU=ECSG,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
                default {}
            }
    }
}
}
#endregion function ServiceTagWriter