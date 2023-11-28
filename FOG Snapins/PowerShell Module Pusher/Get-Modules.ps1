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

#----------------------------------------------------------[Initialization & Declarations]----------------------------------------------------------

#Variable declaration
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"

#Start Logging
Start-Transcript -Path "C:\Windows\Logs\Get-Modules\Get-Modules$date.log"

#Downloading the latest version of the modules & script(s) via Github if module is non-existant
If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\")){  
  Write-Verbose 'Downloading the latest Logging-Functions module and placing in C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\' -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psm1' -Force)
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psd1' -Force)
}If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\")){  
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-WUInstall/Invoke-WUInstall.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\Invoke-WUInstall.psm1' -Force)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-WUInstall/Invoke-WUInstall.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\Invoke-WUInstall.psd1' -Force)
}If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Invoke-QuickFix\")){  
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-QuickFix/Invoke-QuickFix.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-QuickFix\Invoke-QuickFix.psm1' -Force)
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-QuickFix/Invoke-QuickFix.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-QuickFix\Invoke-QuickFix.psd1' -Force)
  }

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Stop logging
Stop-Transcript

#Housekeeping
exit