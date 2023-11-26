# A more efficient (DevOps) way of pulling the latest updated script code

# Variable declaration
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"
$MSWRemoteUpdatesPrerequisites = {. C:\temp\MSWOU.ps1 ; MSWRemoteUpdatesPrerequisites}
$MSWOnlineUpdater = {. C:\temp\MSWOU.ps1 ; MSWOnlineUpdater}

# Downloading the latest version of the script(s) via Github
Start-Transcript -Path "C:\Windows\Logs\MSWOU\Initiate-MSWOU$date.log"
Write-Verbose 'Downloading the latest Logging-Functions and Invoke-WUInstall Modules to C:\Program Files\WindowsPowerShell\Modules\`n' -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psm1' -Force)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psd1' -Force)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-WUInstall/Invoke-WUInstall.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\Invoke-WUInstall.psm1' -Force)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-WUInstall/Invoke-WUInstall.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-WUInstall\Invoke-WUInstall.psd1' -Force)
Write-Verbose 'Downloading the latest MSWOU.ps1 and place in C:\temp\`n' -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/MS%20Windows%20Online%20Updates/MSWOU.ps1" -OutFile "C:\Temp\MSWOU.ps1" -Verbose

#Execute Script(s)
Start-Job -ScriptBlock $MSWRemoteUpdatesPrerequisites -Verbose| Wait-Job -Verbose | Receive-Job -Verbose
Start-Job -ScriptBlock $MSWOnlineUpdater -Verbose| Wait-Job -Verbose | Receive-Job -Verbose

#Stop logging
Stop-Transcript

#Housekeeping
Remove-Item C:\Temp\MSWOU.ps1 -Force
#Remove-Item -Path $MyInvocation.MyCommand.Source

exit