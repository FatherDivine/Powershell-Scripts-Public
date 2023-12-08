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


#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Verbose "`r`nDownloading the latest version of the modules & script(s) via Github if module is non-existant" -Verbose

Write-Verbose "`r`nLogging-Functions for basic logging functionality in all scripts." -Verbose
If (Test-Path "C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\"){
  Write-Verbose "Removing the old version of Logging-Functions first." -Verbose
  Try {Remove-Item -Path "C:\Program Files\WindowsPowerShell\Modules\Logging-Functions" -Recurse -Force -Verbose}Catch{Write-Error "Error Occured: $_"}
}
Write-Verbose 'Downloading the latest Logging-Functions module and placing in C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\' -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psm1' -Force) -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psd1' -Force) -Verbose

Write-Verbose "`r`nRunAsUser allows you to execute scripts under the current user while running as SYSTEM using impersonation." -Verbose
If (Test-Path "C:\Program Files\WindowsPowerShell\Modules\RunAsUser\"){
  Write-Verbose "Removing the old version of RunAsUser first." -Verbose
  Try {Remove-Item -Path "C:\Program Files\WindowsPowerShell\Modules\RunAsUser" -Recurse -Force -Verbose}Catch{Write-Error "Error Occured: $_"}
}
Write-Verbose 'Downloading the latest Logging-Functions module and placing in C:\Program Files\WindowsPowerShell\Modules\RunAsUser\' -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/KelvinTegelaar/RunAsUser/master/RunAsUser.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\RunAsUser\RunAsUser.psd1' -Force) -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/KelvinTegelaar/RunAsUser/master/runasuser.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\RunAsUser\RunAsUser.psm1' -Force) -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/KelvinTegelaar/RunAsUser/master/Public/Invoke-AsCurrentUser.ps1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\RunAsUser\Public\Invoke-AsCurrentUser.ps1' -Force) -Verbose

Write-Verbose "`r`nInvoke-Ping, the fastest way to only send cmdlets to a PC that's online. Saves time from sending cmdlets to offline PCs."
If (Test-Path "C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\"){
  Write-Verbose "Removing the old version of Invoke-Ping first." -Verbose
  Try {Remove-Item -Path "C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping" -Recurse -Force -Verbose}Catch{Write-Error "Error Occured: $_"}
}
Write-Verbose 'Downloading the latest Invoke-Ping module and placing in C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\' -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-Ping/Invoke-Ping/Invoke-Ping.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\Invoke-Ping.psd1' -Force) -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-Ping/Invoke-Ping/Invoke-Ping.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\Invoke-Ping.psm1' -Force) -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-Ping/Invoke-Ping/Public/Invoke-Ping.ps1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\Public\Invoke-Ping.ps1' -Force) -Verbose


Write-Verbose "`r`nInvoke-WUInstall used for remote MS Windows updates (Used by MSWOU.ps1, a FOG snap-in and script)" -Verbose
If (Test-Path "C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\"){
  Write-Verbose "Removing the old version of Invoke-WUInstall first." -Verbose
  Try {Remove-Item -Path "C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall" -Recurse -Force -Verbose}Catch{Write-Error "Error Occured: $_"}  
}  
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-WUInstall/Invoke-WUInstall.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\Invoke-WUInstall.psm1' -Force) -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-WUInstall/Invoke-WUInstall.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\Invoke-WUInstall.psd1' -Force) -Verbose

Write-Verbose "`r`nInvoke-QuickFix for auotmatically running maintenance routines like SFC, disk check, disk optimize, DISM, clear cache & cookies." -Verbose
Write-Verbose "Just type QuickFix or QF from a PowerShell prompt." -Verbose
If (Test-Path "C:\Program Files\WindowsPowerShell\Modules\Invoke-QuickFix\"){
  Write-Verbose "Removing the old version of Invoke-QuickFix first." -Verbose
  Try {Remove-Item -Path "C:\Program Files\WindowsPowerShell\Modules\Invoke-QuickFix" -Recurse -Force -Verbose}Catch{Write-Error "Error Occured: $_"}
}
Invoke-WebRequest -Uri "https://github.com/FatherDivine/Powershell-Scripts-Public/blob/main/Modules/Invoke-QuickFix/Invoke-QuickFix/Invoke-QuickFix.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-QuickFix\Invoke-QuickFix.psm1' -Force) -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-QuickFix/Invoke-QuickFix/Invoke-QuickFix.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-QuickFix\Invoke-QuickFix.psd1' -Force) -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-QuickFix/Invoke-QuickFix/Public/Invoke-QuickFix.ps1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-QuickFix\Public\Invoke-QuickFix.ps1' -Force) -Verbose

Write-Verbose "`r`nGet-Updates used for local and remote Dell driver updates using Dell Command | Update" -Verbose
If (Test-Path "C:\Program Files\WindowsPowerShell\Modules\Get-Updates\"){
  Write-Verbose "Removing the old version of Get-Updates first." -Verbose
  Try {Remove-Item -Path "C:\Program Files\WindowsPowerShell\Modules\Get-Updates" -Recurse -Force -Verbose}Catch{Write-Error "Error Occured: $_"}
}
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Get-Updates/Get-Updates/Get-Updates.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Get-Updates\Get-Updates.psm1' -Force) -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Get-Updates/Get-Updates/Get-Updates.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Get-Updates\Get-Updates.psd1' -Force) -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Get-Updates/Get-Updates/Public/Get-Updates.ps1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Get-Updates\Public\Get-Updates.ps1' -Force) -Verbose

Write-Verbose "`r`nKeysight Module to fix various issues with Keysight programs" -Verbose
If (Test-Path "C:\Program Files\WindowsPowerShell\Modules\Keysight"){
  Write-Verbose "Removing the old version of Keysight first." -Verbose
  Try {Remove-Item -Path "C:\Program Files\WindowsPowerShell\Modules\Keysight" -Recurse -Force -Verbose}Catch{Write-Error "Error Occured: $_"}
}
Write-Verbose 'Downloading the latest Keysight module and placing in C:\Program Files\WindowsPowerShell\Modules\Keysight\' -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/Keysight/Keysight.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\Keysight.psd1' -Force) -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/Keysight/Keysight.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\Keysight.psm1' -Force) -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/Keysight/Public/Keysight-ADS-FixHomePath.ps1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\Public\Keysight-ADS-FixHomePath.ps1' -Force) -Verbose
#Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/Keysight/Public/Keysight-ADS-VersionCheck.ps1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\Public\Keysight-ADS-VersionCheck.ps1' -Force) -Verbose
#Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/Keysight/Public/Keysight-ADS-Uninstall.ps1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\Public\Keysight-ADS-Uninstall.ps1' -Force) -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Keysight/README.md" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Keysight\README.md' -Force) -Verbose


Write-Verbose "`r`nJavier's Squid proxy enable module used for Exams in Computer Science. Easy remote deployment with RunAsUser:" -Verbose
Write-Verbose '$PCList|% {Invoke-CommandAs $_ -AsSystem -ScriptBlock {enable-proxy} -AsJob}' -Verbose
Write-Verbose "or" -Verbose
Write-Verbose 'foreach ($PC in $test) {Invoke-CommandAs -ComputerName $PC -AsSystem -ScriptBlock {enable-proxy} -AsJob}' -Verbose
Write-Verbose 'Then get job info with: get-job | receive-job' -Verbose
If ((Test-Path "C:\Program Files\WindowsPowerShell\Modules\Javier-Proxy") -or (Test-Path "C:\Program Files\WindowsPowerShell\Modules\Javier-SquidProxy")  ){
  Write-Verbose "Removing the old version of Javier-Proxy first." -Verbose
  Try {Remove-Item -Path "C:\Program Files\WindowsPowerShell\Modules\Javier-*" -Recurse -Force -Verbose}Catch{Write-Error "Error Occured: $_"}
}
Write-Verbose "Downloading the latest Javier-Proxy module and placing in C:\Program Files\WindowsPowerShell\Modules\$Module\" -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Javier-Proxy/Javier-Proxy/Javier-Proxy.psd1" `
-OutFile (New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\Javier-Proxy\Javier-Proxy.psd1" -Force)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Javier-Proxy/Javier-Proxy/Javier-Proxy.psm1" `
-OutFile (New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\Javier-Proxy\Javier-Proxy.psm1" -Force)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Javier-Proxy/Javier-Proxy/Public/Enable-Proxy.ps1" `
-OutFile (New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\Javier-Proxy\Public\Enable-Proxy.ps1" -Force)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Javier-Proxy/Javier-Proxy/Public/Disable-Proxy.ps1" `
-OutFile (New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\Javier-Proxy\Public\Disable-Proxy.ps1" -Force)
#Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Javier-Proxy/Javier-Proxy/Public/Enable-ASProxy.ps1" `
#-OutFile (New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\Javier-Proxy\Public\Enable-ASProxy.ps1" -Force)
#Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Javier-Proxy/Javier-Proxy/Public/Disable-ASProxy.ps1" `
#-OutFile (New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\Javier-Proxy\Public\Disable-ASProxy.ps1" -Force)

<#Set PS profile when our Github license is up:
Write-Verbose 'Updating AllUsersAllHosts PS Profile.' -Verbose
          # Create a new temporary file
          $Extracthpeesof = ".ps1"
          
          #Store the download into the temporary file
          Invoke-WebRequest -Uri https://github.com/FatherDivine/Powershell-Scripts-Public/raw/main/Modules/Get-PSProfile\  -OutFile $Extracthpeesof
          
          #Extract the temporary file
          $Extracthpeesof | Copy-Item -DestinationPath $PSProfile.AllUsersAllHosts -Force -Verbose
          
          #Remove temporary file
          $Extracthpeesof | Remove-Item
#>
#Stop logging
Stop-Transcript

#Housekeeping
exit