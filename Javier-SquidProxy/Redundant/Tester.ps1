$Pcs = Get-Content "${PSScriptRoot}\LW840.txt"
foreach ($pc in $pcs){
Invoke-Command -ComputerName $pc -ScriptBlock{
New-Item "HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings"
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxySettingsPerUser -Value 0
}
}