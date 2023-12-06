﻿<#
.SYNOPSIS
  Enables a proxy.

.DESCRIPTION
  This script enables Javiar's Squid proxy for exams
  taken in the CEDC, specifically Computer Science.
    
.INPUTS
   None. You cannot pipe objects to Enable-Proxy.ps1.

.OUTPUTS
  The Proxy Status (Enabled/Disabled) stored in C:\Windows\Logs\Proxy\

.NOTES
  Version:        0.1
  Author:         Aaron Staten
  Creation Date:  11/28/2023
  Purpose:        For CEDC IT Dept. use
  
.LINK
https://github.com/FatherDivine/Powershell-Scripts-Public/blob/main/Javier-SquidProxy/Enable-Proxy.ps1

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

#-----------------------------------------------------------[Execution]------------------------------------------------------------
Function Enable-Proxy{
  [cmdletbinding()]
  Param()
  
  Begin{
    #Define HKU as it isn't there by default
    New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS

    #Define our registry keys
    $regKeys = @(
      "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings",
      "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings",
      "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    )

    $PreventProxyChanges = "HKCU:\SOFTWARE\Policies\Microsoft\Internet Explorer\Control Panel" 
  }

  Process{
    Try{
    #Adding the below values to the above registry keys
    $regKeys | ForEach-Object {
      New-ItemProperty -path $_ ProxyEnable -value 1 -Force -ErrorAction SilentlyContinue
      New-ItemProperty -path $_ ProxyServer -value "dceasapp783:3128" -Force -ErrorAction SilentlyContinue
      New-ItemProperty -path $_ ProxyOverride -value "<local>" -Force -ErrorAction SilentlyContinue
    }
    #Lockdown the changes
    New-ItemProperty -path $PreventProxyChanges Proxy -value 1 -Force -ErrorAction SilentlyContinue

    #Log
    Write-Output "Proxy Enabled on $date" | Out-File (New-Item -Path "C:\Windows\Logs\Proxy\ProxyStatus.txt" -Force)
    }

    Catch{
      Write-Verbose "Error Detected: $_.Exception" -Verbose
      Break
    }
  }

  end{
    If($?){}
  }
}