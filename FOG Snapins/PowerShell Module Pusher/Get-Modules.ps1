<#
.SYNOPSIS
  Downloads the latest Modules via Github.

.DESCRIPTION
  This script downloads the latest modules
  for use with CEDC IT from Father Divine's 
  Github.
    
.INPUTS
  none

.OUTPUTS
  Logs stored in C:\Windows\Logs\Get-Modules\

.NOTES
  Version:        0.1
  Author:         Aaron Staten
  Creation Date:  11/22/2023
  Purpose:        For CEDC IT Dept. use
  
.EXAMPLE
  & .\Get-Modules.ps1
  
  Can be used as a FOG snap-in or invoked regularly:
  Invoke-Command -FilePath .\Get-Modules.ps1 -ComputerName $PCs 

  Or if you want to be fancy and make each it's own job
  Foreach ($PC in $PCs){Invoke-Command -FilePath .\Get-Modules.ps1 -ComputerName $PC -AsJob }
#>
[cmdletbinding()]
#----------------------------------------------------------[Initialization & Declarations]----------------------------------------------------------

#Variable declaration
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"

#Enable verbose output
$VerbosePreference = 'Continue'

#Start Logging
Start-Transcript -Path "C:\Windows\Logs\Get-Modules\Get-Modules$date.log" -Force -Verbose

#Downloading the latest version of the modules & script(s) via Github if module is non-existant

#Logging-Functions for basic logging functionality in all scripts.
#If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\")){  
  Write-Verbose 'Downloading the latest Logging-Functions module and placing in C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\' -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psm1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psd1' -Force) -Verbose

#Invoke-WUInstall used for remote MS Windows updates (Used by MSWOU.ps1, a FOG snap-in and script)
#}If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\")){  
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-WUInstall/Invoke-WUInstall.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\Invoke-WUInstall.psm1' -Force) -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-WUInstall/Invoke-WUInstall.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\Invoke-WUInstall.psd1' -Force) -Verbose

#QuickFix for auotmatically running maintenance routines like SFC, disk check, disk optimize, DISM, clear cache & cookies. Just type "QuickFix" or "QF" from PS prompt
#}If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Invoke-QuickFix\")){  
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-QuickFix/Invoke-QuickFix.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-QuickFix\Invoke-QuickFix.psm1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-QuickFix/Invoke-QuickFix.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-QuickFix\Invoke-QuickFix.psd1' -Force) -Verbose
#  }

#Javier's Squid proxy modules used for Exams in Computer Science. Easy remote deployment: $JavierLabPCS|%{icm -ComputerName $_ -Scriptblock {Enable-Proxy} -AsJob}
#}If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Enable-Proxy\")){  
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Javier-SquidProxy/Enable-Proxy/Enable-Proxy.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Javier-SquidProxy\Enable-Proxy\Enable-Proxy.psm1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Javier-SquidProxy/Enable-Proxy/Enable-Proxy.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Javier-SquidProxy\Enable-Proxy\Enable-Proxy.psd1' -Force) -Verbose
#  }
#Javier's Squid proxy modules used for Exams in Computer Science. Easy remote deployment: $JavierLabPCS|%{icm -ComputerName $_ -Scriptblock {Disable-Proxy} -AsJob}
#}If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Disable-Proxy\")){  
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Javier-SquidProxy/Disable-Proxy/Disable-Proxy.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Javier-SquidProxy\Disable-Proxy\Disable-Proxy.psm1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Javier-SquidProxy/Disable-Proxy/Disable-Proxy.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Javier-SquidProxy\Disable-Proxy\Disable-Proxy.psd1' -Force) -Verbose
#  }
#Keysight Module to fix various issues with Keysight programs
#If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Keysight")){  
  Write-Verbose 'Downloading the latest Keysight module and placing in C:\Program Files\WindowsPowerShell\Modules\Keysight\' -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/Keysight.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\Keysight.psm1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/Keysight.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\Keysight.psd1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/README.md" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\README.md' -Force) -Verbose
#}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Stop logging
Stop-Transcript

#Housekeeping
exit