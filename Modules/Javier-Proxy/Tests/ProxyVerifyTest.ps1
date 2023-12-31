﻿#Simple open-ended tool for testing if the proxy is on or off (in instances before I started logging this info to C:\Windows\Logs\Proxy\ProxyStatus.txt.
#The best test now is checking that ProxyStatus.txt file)

#First define what we are testing
$regKey1 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
$regKey2 = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
$regKey3 = "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings"


#Define our PCs
$PCs = @("CSCI-LW840-A1","CSCI-LW840-A2","CSCI-LW840-A4","CSCI-LW840-A5","CSCI-LW840-B3","CSCI-LW840-B4","CSCI-LW840-B5","CSCI-LW840-C3","CSCI-LW840-C4","CSCI-LW840-C5","CSCI-LW840-D1","CSCI-LW840-E2","CSCI-LW840-E3","CSCI-LW840-E4","CSCI-LW840-E5","CSCI-LW840-F1","CSCI-LW840-F4","CSCI-LW840-F5","CSCI-LW840-G1","CSCI-LW840-G2","CSCI-LW840-G3","CSCI-LW840-G5","CSCI-LW840-H2","CSCI-LW840-H4","CSCI-LW840-PROF","CSCI-LW844-A1","CSCI-LW844-A2","CSCI-LW844-A4","CSCI-LW844-A5","CSCI-LW844-B1","CSCI-LW844-B2","CSCI-LW844-B3","CSCI-LW844-C2","CSCI-LW844-C4","CSCI-LW844-D1","CSCI-LW844-D2","CSCI-LW844-D3","CSCI-LW844-D4","CSCI-LW844-D5","CSCI-LW844-E1","CSCI-LW844-E2","CSCI-LW844-E3","CSCI-LW844-E4","CSCI-LW844-E5","CSCI-LW844-F1","CSCI-LW844-F2","CSCI-LW844-F4","CSCI-LW844-G1","CSCI-LW844-G2","CSCI-LW844-G3","CSCI-LW844-G4","CSCI-LW844-G5","CSCI-LW844-H1","CSCI-LW844-H2","CSCI-LW844-H3","CSCI-LW844-H4","CSCI-LW844-PROF","CEDC-NC2413-A1","CEDC-NC2413-A2","CEDC-NC2413-A3","CEDC-NC2413-A4","CEDC-NC2413-A6","CEDC-NC2413-B1","CEDC-NC2413-B2","CEDC-NC2413-B3","CEDC-NC2413-B4","CEDC-NC2413-B5","CEDC-NC2413-B6","CEDC-NC2413-C1","CEDC-NC2413-C2","CEDC-NC2413-C3","CEDC-NC2413-C4","CEDC-NC2413-C5","CEDC-NC2413-C6","CEDC-NC2413-D1","CEDC-NC2413-D2","CEDC-NC2413-D3","CEDC-NC2413-D4","CEDC-NC2413-D5","CEDC-NC2413-D6","CEDC-NC2413-E1","CEDC-NC2413-E2","CEDC-NC2413-E3","CEDC-NC2413-E4","CEDC-NC2413-E5","CEDC-NC2413-E6","CEDC-NC2413-F1","CEDC-NC2413-F2","CEDC-NC2413-F3","CEDC-NC2413-F4","CEDC-NC2413-F5","CEDC-NC2413-F6","CEDC-NC2413-G1","CEDC-NC2413-G2","CEDC-NC2413-G3","CEDC-NC2413-G4","CEDC-NC2413-P")

#Skip PCs that are Offline as reported by FOG > Tasks. Speeds the script up
#"CSCI-LW840-A3",,"CSCI-LW840-B1","CSCI-LW840-B2","CSCI-LW840-C1","CSCI-LW840-C2","CSCI-LW840-D2","CSCI-LW840-D3","CSCI-LW840-D4","CSCI-LW840-D5","CSCI-LW840-E1","CSCI-LW840-F2","CSCI-LW840-F3","CSCI-LW840-G4","CSCI-LW840-H1","CSCI-LW840-H3","CSCI-LW840-H5",
#"CSCI-LW844-A3","CSCI-LW844-B4","CSCI-LW844-B5","CSCI-LW844-C1","CSCI-LW844-C3","CSCI-LW844-C5","CSCI-LW844-F3","CSCI-LW844-F5","CSCI-LW844-H5",
#"CEDC-NC2413-A5"

#Create our log file
New-Item -ItemType File -Path "C:\temp\ProxyLogs.txt" -Force

$PCs = "cedc-nc2413-a2"
Foreach ($PC in $PCs){
Write-Output "$PC" -Verbose| Out-File "C:\Temp\ProxyLogs.txt" -Append
Invoke-Command -ComputerName $PC -ScriptBlock {(Get-Item $using:regkey1).Property -contains "dceasapp783:3128"} -Verbose| Out-File "C:\Temp\ProxyLogs.txt" -Append
Invoke-Command -ComputerName $PC -ScriptBlock {(Get-Item $using:regkey2).Property -contains "dceasapp783:3128"} -Verbose| Out-File "C:\Temp\ProxyLogs.txt" -Append
Invoke-Command -ComputerName $PC -ScriptBlock {New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS;(Get-Item $using:regkey3).Property -contains "dceasapp783:3128"} -Verbose| Out-File "C:\Temp\ProxyLogs.txt" -Append
}