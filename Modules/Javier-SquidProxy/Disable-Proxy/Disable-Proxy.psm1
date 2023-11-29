<#
.SYNOPSIS
  Disables a proxy.

.DESCRIPTION
  This script disables Javiar's Squid proxy for exams
  taken in the CEDC, specifically Computer Science.
    
.INPUTS
  None. You cannot pipe objects to Disable-Proxy.ps1.

.OUTPUTS
  The Proxy Status (Enabled/Disabled) stored in C:\Windows\Logs\Proxy\

.NOTES
  Version:        0.1
  Author:         Aaron Staten
  Creation Date:  11/28/2023
  Purpose:        For CEDC IT Dept. use

.LINK
https://github.com/FatherDivine/Powershell-Scripts-Public/blob/main/Javier-SquidProxy/Disable-Proxy.ps1
  
.EXAMPLE
  & .\Enable-Proxy.ps1

  The simplest execution from a PowerShell prompt.

.EXAMPLE
  Invoke-Command -FilePath .\Enable-Proxy.ps1 -ComputerName $PCs 
  
  To invoke, thereby sending the script to a single PC or array of PCs.

.EXAMPLE
  Foreach ($PC in $PCs){Invoke-Command -FilePath .\Enable-Proxy.ps1 -ComputerName $PC -AsJob }

  If you want to be fancy and make each it's own job.
  This method is good for keeping track of which PC may have failed/offline.
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
Function Disable-Proxy{
#Delete the old saved legacy settings & default connections. Without this, Remove-ItemProperty doesn't actually remove.
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v SavedLegacySettings /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v DefaultConnectionSettings /f
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v SavedLegacySettings /f
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v DefaultConnectionSettings /f
#These don't seem to exist, but just in case
#reg delete "HKU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v SavedLegacySettings /f
#reg delete "HKU\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v DefaultConnectionSettings /f


#Undo the lockdown on editing proxy configuration
Remove-ItemProperty -path $PreventProxyChanges Proxy -Force -ErrorAction SilentlyContinue

#Remove the proxy keys
$regKeys | ForEach-Object {
Remove-ItemProperty -path $_ ProxyEnable -Force
Remove-ItemProperty -path $_ ProxyServer -Force   
Remove-ItemProperty -path $_ ProxyOverride -Force
}

Write-Output "Proxy Disabled on $date" | Out-File (New-Item -Path "C:\Windows\Logs\Proxy\ProxyStatus.txt" -Force)
}