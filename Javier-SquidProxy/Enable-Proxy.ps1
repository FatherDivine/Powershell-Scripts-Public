<#
.SYNOPSIS
  Enables a proxy.

.DESCRIPTION
  This script enables Javiar's Proxy for exams
  in the CEDC, specifically Computer Science.
  
    
.INPUTS
  none

.OUTPUTS
  The Proxy Status (Enabled/Disabled) stored in C:\Windows\Logs\Proxy\

.NOTES
  Version:        0.1
  Author:         Aaron Staten
  Creation Date:  11/28/2023
  Purpose:        For CEDC IT Dept. use
  
.EXAMPLE
  & .\Enable-Proxy.ps1
  
  Can be used as a FOG snap-in or invoked regularly:
  Invoke-Command -FilePath .\Enable-Proxy.ps1 -ComputerName $PCs 

  Or if you want to be fancy and make each it's own job
  Foreach ($PC in $PCs){Invoke-Command -FilePath .\Enable-Proxy.ps1 -ComputerName $PC -AsJob }
#>
#----------------------------------------------------------[Initialization & Declarations]----------------------------------------------------------

#Variable declaration
$date = Get-Date -Format "MM-dd-yyyy-HH-mm"

#Define HKU as it isn't there by default
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS

#Define our registry keys
$regKeys = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings",
    "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
)
$PreventProxyChanges = "HKCU:\SOFTWARE\Policies\Microsoft\Internet Explorer\Control Panel" 
#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Adding the below proxy values to the above registry keys
$regKeys | ForEach-Object {
New-ItemProperty -path $_ ProxyEnable -value 1 -Force
New-ItemProperty -path $_ ProxyServer -value "dceasapp783:3128" -Force   
New-ItemProperty -path $_ ProxyOverride -value "<local>" -Force
}
#Lockdown the ability to alter the proxy configuration
New-ItemProperty -path $PreventProxyChanges Proxy -value 1 -Force

#Log
Write-Output "Proxy Enabled on $date" | Out-File (New-Item -Path "C:\Windows\Logs\Proxy\ProxyStatus.txt" -Force)