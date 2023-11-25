# A more efficient (DevOps) way of pulling the latest updated script code

# Variable declaration
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"
$MSWRemoteUpdatesPrerequisites = {. C:\temp\MSWOU.ps1 ; MSWRemoteUpdatesPrerequisites}
$MSWOnlineUpdater = {. C:\temp\MSWOU.ps1 ; MSWOnlineUpdater}

# Downloading the latest version of the script(s) via Github
Start-Transcript -Path "C:\Windows\Logs\MSWOU\FOG-MSWOUDownloader$date.log"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psm1' -Force)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psd1' -Force)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-WUInstall/Invoke-WUInstall.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\Invoke-WUInstall.psm1' -Force)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-WUInstall/Invoke-WUInstall.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\Invoke-WUInstall.psd1' -Force)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/MS%20Windows%20Online%20Updates/MSWOU.ps1" -OutFile "C:\Temp\MSWOU.ps1" -Verbose

# Initialize the script
Import-Module Invoke-WUInstall
Import-Module Logging-Functions
. C:\Temp\MSWOU.ps1

#Start Logging
Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion

#Execute Scripts
Start-Job -ScriptBlock $MSWRemoteUpdatesPrerequisites -Verbose| Wait-Job -Verbose | Receive-Job -Verbose
Start-Job -ScriptBlock $MSWOnlineUpdater -Verbose| Wait-Job -Verbose | Receive-Job -Verbose

#Finish Logging
Log-Finish -LogPath $sLogFile
Stop-Transcript

#Housekeeping
Remove-Item C:\Temp\MSWOU.ps1 -Force
Remove-Item $PSCommandPath -Force 

exit