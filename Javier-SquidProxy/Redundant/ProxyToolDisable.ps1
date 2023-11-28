# Created by Aaron S. for CEDC IT 10-18-23

#Define HKU. If already defined prior no issues (a drive with the name 'HKU' already exists)
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS

# Define registry keys
$regKey1 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

$regKey2 = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

$regKey3 = "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
 
# Set & remove registry values
        Set-ItemProperty -Path $regKey1 -Name ProxyEnable -Value 0
        Remove-ItemProperty -path $regKey1 -Name ProxyServer
        Remove-ItemProperty -path $regKey1 -Name ProxyOverride

        Set-ItemProperty -Path $regKey2 -Name ProxyEnable -Value 0
        Remove-ItemProperty -path $regKey2 -Name ProxyServer
        Remove-ItemProperty -path $regKey2 -Name ProxyOverride

        Set-ItemProperty -Path $regKey3 -Name ProxyEnable -Value 0
        Remove-ItemProperty -path $regKey3 -Name ProxyServer
        Remove-ItemProperty -path $regKey3 -Name ProxyOverride