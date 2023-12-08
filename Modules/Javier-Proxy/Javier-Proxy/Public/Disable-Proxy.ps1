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
  Version:        0.2
  Author:         Aaron Staten
  Creation Date:  11/28/2023 (Last updated 12/5/2023)
  Purpose:        For CEDC IT Dept. use

.LINK
https://github.com/FatherDivine/Powershell-Scripts-Public/blob/main/Javier-SquidProxy/Disable-Proxy.ps1

.EXAMPLE
  Invoke-CommandAs -ComputerName PCNameHere -FilePath .\Script.ps1 -AsSystem

  This runs as SYSTEM user, the only way to do it. FOG automatically picks this up, but for local use,
  install the module "Invoke-CommandAs" and type the above.

.EXAMPLE
  Invoke-CommandAs -ComputerName PCNameHere -ScriptBlock {disable-proxy} -Assystem

  This runs as SYSTEM user, the only way to do it. FOG automatically picks this up, but for local use,
  install the module "Invoke-CommandAs" and type the above.

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

#Install required modules
if(! (Get-Module RunAsUser -ListAvailable)){
  install-module RunAsUser
}

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Disable-Proxy{
  [cmdletbinding()]
  Param()

  Begin{
    $scriptblock = {
    #Define HKU as it isn't there by default
    New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS

    #Define our registry keys
    $regKeys1 = @(
      "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections",
      "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections",
      "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections"
    )
    $regKeys2 = @(
      "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings",
      "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings",
      "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    )
    $PreventProxyChanges = "HKCU:\SOFTWARE\Policies\Microsoft\Internet Explorer\Control Panel"

      #Undo the lockdown on editing proxy configuration
      Remove-ItemProperty -path $PreventProxyChanges Proxy -Force -ErrorAction SilentlyContinue

      #Remove the proxy keys
      $regKeys1 | ForEach-Object {
      Remove-ItemProperty -Path $_ SavedLegacySettings -Force -ErrorAction SilentlyContinue
      Remove-ItemProperty -Path $_ DefaultConnectionSettings -Force -ErrorAction SilentlyContinue
      }
      $regKeys2 | ForEach-Object {
      Remove-ItemProperty -Path $_ ProxyEnable -Force -ErrorAction SilentlyContinue
      Remove-ItemProperty -Path $_ ProxyServer -Force -ErrorAction SilentlyContinue
      Remove-ItemProperty -Path $_ ProxyOverride -Force -ErrorAction SilentlyContinue
      }

      #Log
      Write-Output "Proxy Disabled on $date" | Out-File (New-Item -Path "C:\Windows\Logs\Proxy\ProxyStatus.txt" -Force)    
    }
  }

  Process{
    Try{
      #This runs as SYSTEM user, the only way to do it. FOG automatically picks this up, but for local use,
      #install the module "Invoke-CommandAs" and type this: Invoke-CommandAs -ComputerName PCNameHere -FilePath .\Script.ps1 -AsSystem
      Invoke-AsCurrentUser -scriptblock $Scriptblock
      
      }
    Catch{
      Write-Verbose "Error Detected: $_.Exception" -Verbose
      Break
    }
  }
  End{
    If($?){}
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------