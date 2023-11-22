# Sets 2 registry keys in an attempt to fix the VM issue of sessions not logging off.
# First run is meant for REMOTE lab 

# Set variables to indicate value and key to set
$RegistryPath = 'HKCU:\Control Panel\Desktop'
$Name         = 'AutoEndTasks'
$Value        = '1'
# Create the key if it does not exist
If (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force | Out-Null
}  
# Now set the value
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force 


# Set variables to indicate value and key to set
$RegistryPath2 = 'HKLM:\SYSTEM\CurrentControlSet\Control'
$Name2         = 'WaitToKillAppTimeout'
$Value2        = '500'
# Create the key if it does not exist
If (-NOT (Test-Path $RegistryPath2)) {
  New-Item -Path $RegistryPath2 -Force | Out-Null
}  
# Now set the value
New-ItemProperty -Path $RegistryPath2 -Name $Name2 -Value $Value2 -PropertyType DWORD -Force 

exit