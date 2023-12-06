<#
.SYNOPSIS
  Installs the Javier-Proxy module.

.DESCRIPTION
  This script installs the Javier-Proxy module
  in addition to my personal proxy module. 
    
.INPUTS
  none

.OUTPUTS
  The Proxy Status (Enabled/Disabled) stored in C:\Windows\Logs\Proxy

.NOTES
  Version:        0.1
  Author:         Aaron Staten
  Creation Date:  12/6/2023
  Purpose:        For CEDC IT Dept. use

.LINK
https://github.com/FatherDivine/Powershell-Scripts-Public/tree/main/Modules/Javier-Proxy
.EXAMPLE
  & .\Install-Javier-Proxy.ps1
#>

#----------------------------------------------------------[Initialization & Declarations]----------------------------------------------------------

#Variable declaration
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"
$Module = 'Javier-Proxy'


#Start Logging
Start-Transcript -Path "C:\Windows\Logs\Proxy\Install-Javier-Proxy$date.log"



#-----------------------------------------------------------[Execution]------------------------------------------------------------
#Downloading the latest version of the modules & script(s) via Github if module is non-existant
#If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Javier-Proxy")){  
  Write-Verbose "Downloading the latest $Module module and placing in C:\Program Files\WindowsPowerShell\Modules\$Module\" -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Javier-Proxy/Javier-Proxy/Javier-Proxy.psd1" -OutFile (New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\$Module\$Module.psd1" -Force)
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Javier-Proxy/Javier-Proxy/Javier-Proxy.psm1" -OutFile (New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\$Module\$Module.psm1" -Force)
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Javier-Proxy/Javier-Proxy/Public/Enable-Proxy.ps1" -OutFile (New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\$Module\Public\Enable-Proxy.ps1" -Force)
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Javier-Proxy/Javier-Proxy/Public/Disable-Proxy.ps1" -OutFile (New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\$Module\Public\Disable-Proxy.ps1" -Force)
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Javier-Proxy/Javier-Proxy/Public/Enable-ASProxy.ps1" -OutFile (New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\$Module\Public\Enable-ASProxy.ps1" -Force)
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Javier-Proxy/Javier-Proxy/Public/Disable-ASProxy.ps1" -OutFile (New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\$Module\Public\Disable-ASProxy.ps1" -Force)
#}

#Stop logging
Stop-Transcript

#Housekeeping
#Remove-Item C:\Temp\Install-Javier-Proxy.ps1 -Force
#Remove-Item -Path $MyInvocation.MyCommand.Source
exit