New-PSDrive HKU Registry HKEY_USERS
$regKey="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
$regKey2="HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"   
$regKey3="HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

If(Get-ItemProperty -Path $regKey -Name "ProxyServer" -ErrorAction SilentlyContinue){	
        Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "ProxyEnable"
        Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "ProxyServer" 
        Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "ProxyOverride" 
}
Else {continue}

		#$reg = "HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings"
        #        New-Item -Path $reg
		#New-ItemProperty -Path $reg -Name ProxySettingsPerUser  -Value 0

        #Set-ItemProperty -path $regKey2 ProxyEnable -value 1
        #Set-ItemProperty -path $regKey2 ProxyServer -value "dceasapp783:3128"   
        #Set-ItemProperty -path $regKey2 ProxyOverride -value "<local>"


        New-ItemProperty -path $regKey3 ProxyOverride -value "<local>"
        New-ItemProperty -path $regKey3 ProxyServer -value "dceasapp783:3128"
        New-ItemProperty -path $regKey3 ProxyEnable -value 1
		



#Read more: https://www.sharepointdiary.com/2021/04/manage-windows-registry-in-powershell.html#ixzz8FqYd7jn4        


#To lock down policy change,
#You need to enable the policy 
#"User Configuration > Administrative Templates > Windows Components > Internet Explorer > Prevent changing proxy settings

#     