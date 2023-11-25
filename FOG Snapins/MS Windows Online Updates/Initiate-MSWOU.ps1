# A more efficient (DevOps) way of pulling the latest updated script code

# Variable declaration
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"

# Downloading the latest version of the script(s) via Github
Start-Transcript -Path "C:\Windows\Logs\MSWOU\FOG-MSWOUDownloader$date.log"
Invoke-WebRequest -Uri "" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psm1' -Force)
Invoke-WebRequest -Uri "" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psd1' -Force)
Invoke-WebRequest -Uri "" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\Invoke-WUInstall.psm1' -Force)
Invoke-WebRequest -Uri "" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\Invoke-WUInstall.psd1' -Force)

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/MS%20Windows%20Online%20Updates/MSWOU.ps1" -OutFile "${PSScriptRoot}\MSWOU.ps1" -Verbose
Stop-Transcript

# Initialize the script
Import-Module 'C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\Invoke-WUInstall.psm1'
Import-Module 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psm1'
. \MSWOU.ps1

#Start Logging
Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion

#Execute Scripts
Start-Job -Name MSWRemoteUpdatesPrerequisites -ScriptBlock {MSWRemoteUpdatesPrerequisites} -Verbose
Wait-Job -Name MSWRemoteUpdatesPrerequisites -Verbose
Receive-Job -Name MSWRemoteUpdatesPrerequisites -Verbose

Start-Job -Name MSWOnlineUpdater -ScriptBlock {MSWOnlineUpdater} -Verbose
Wait-Job -Name MSWOnlineUpdater -Verbose
Receive-Job -Name MSWOnlineUpdater -Verbose

#Finish Logging
Log-Finish -LogPath $sLogFile


#Housekeeping
Remove-Item .\Logging_Functions.ps1 -Force
Remove-Item .\MSWRUP.ps1 -Force
Remove-Item .\MSWOU.ps1 -Force
Remove-Item $PSCommandPath -Force 
exit
