#First define what we are testing
$regKey1 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
$regKey2 = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
$regKey3 = "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings"


#Define our PCs


#Create our log file
New-Item -ItemType File -Path "C:\temp\ProxyLogs.txt" -Force


Foreach ($PC in $LW840){
Write-Output "$PC" -Verbose| Out-File "C:\Temp\ProxyLogs.txt" -Append
Invoke-Command -ComputerName $PC -ScriptBlock {(Get-Item $using:regkey1).Property -contains "dceasapp783:3128"} -Verbose| Out-File "C:\Temp\ProxyLogs.txt" -Append
Invoke-Command -ComputerName $PC -ScriptBlock {(Get-Item $using:regkey2).Property -contains "dceasapp783:3128"} -Verbose| Out-File "C:\Temp\ProxyLogs.txt" -Append
Invoke-Command -ComputerName $PC -ScriptBlock {New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS;(Get-Item $using:regkey3).Property -contains "dceasapp783:3128"} -Verbose| Out-File "C:\Temp\ProxyLogs.txt" -Append
}

