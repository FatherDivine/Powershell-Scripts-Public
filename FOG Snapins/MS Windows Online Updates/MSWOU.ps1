# A more efficient (DevOps) way of pulling the latest updated script code

# Variable declaration
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"

# Downloading the latest version of the script(s) via Github
Start-Transcript -Path "C:\Windows\Logs\MSWOU\FOG-MSWOUDownloader-$date.log"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/MS%20Windows%20Online%20Updates/Logging_Functions.ps1" -OutFile "${PSScriptRoot}\Logging_Functions.ps1"
Invoke-WebRequest -Uri "https://github.com/FatherDivine/Powershell-Scripts-Public/blob/main/MS%20Windows%20Online%20Updates/MSWOU.ps1" -OutFile "${PSScriptRoot}\MSWOU.ps1"
Stop-Transcript

# Start the script
.\MSWOU.ps1
