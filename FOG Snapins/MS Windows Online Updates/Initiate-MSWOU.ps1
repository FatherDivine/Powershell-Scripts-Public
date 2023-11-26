<#
.SYNOPSIS
  Allows the ability to configure a PC for
  MS Windows updates as well as run them.

.DESCRIPTION
  This script initiates all the files
  needed for MSWOU (Microsoft Windows Online
  Updater) to run. Can be executed from any 
  location or method including FOG snap-in, 
  invoke-command, or direct. This showcases 
  a more efficient (DevOps) way of all 
  channels pulling the latest updated script
  code and fixes while developing and pushing
  from one central location (in this case, Github).
    
.INPUTS
  none

.OUTPUTS
  Logs stored in C:\Windows\Logs\MSWOU\

.NOTES
  Version:        4.0
  Author:         Aaron Staten
  Creation Date:  11/22/2023
  Purpose:        For CEDC IT Dept. use
  
.EXAMPLE
  & .\Initiate-MSWOU.ps1
#>

#----------------------------------------------------------[Initialization & Declarations]----------------------------------------------------------

#Variable declaration
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"
$MSWRemoteUpdatesPrerequisites = {. C:\temp\MSWOU.ps1 ; MSWRemoteUpdatesPrerequisites}
$MSWOnlineUpdater = {. C:\temp\MSWOU.ps1 ; MSWOnlineUpdater}

#Logging
Start-Transcript -Path "C:\Windows\Logs\MSWOU\Initiate-MSWOU$date.log"

# Downloading the latest version of the script(s) via Github
Write-Verbose 'Downloading the latest Logging-Functions and Invoke-WUInstall Modules and placing in C:\Program Files\WindowsPowerShell\Modules\' -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psm1' -Force)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psd1' -Force)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-WUInstall/Invoke-WUInstall.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\Invoke-WUInstall.psm1' -Force)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-WUInstall/Invoke-WUInstall.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\Invoke-WUInstall.psd1' -Force)

Write-Verbose 'Downloading the latest MSWOU.ps1 and placing in C:\temp\' -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/MS%20Windows%20Online%20Updates/MSWOU.ps1" -OutFile "C:\Temp\MSWOU.ps1" -Verbose

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Execute Script(s) as Jobs.
Start-Job -ScriptBlock $MSWRemoteUpdatesPrerequisites -Verbose| Wait-Job -Verbose | Receive-Job -Verbose
Start-Job -ScriptBlock $MSWOnlineUpdater -Verbose| Wait-Job -Verbose | Receive-Job -Verbose

#Stop logging
Stop-Transcript

#Housekeeping
Remove-Item C:\Temp\MSWOU.ps1 -Force
#Remove-Item -Path $MyInvocation.MyCommand.Source

exit