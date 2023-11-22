# This script re-adds all the computers back into the OU once erased. 
# This could sanitize and read the hostname, but for simplicity version 1
# requires you to set both PATH yourself to match. EG NC2608.txt = OU=NC2608,OU=LABs,OU=CEAS...
# Please use the username svc-cedc-domainjoin, whose password is in KEEPASS

$Credential = Get-Credential
$PCs = Get-Content -Path C:\Temp\IWKS-New.txt
foreach ($pc in $PCs)
{
    New-ADComputer -Name "$pc" -SamAccountName "$pc" -Path "OU=IWKS,OU=CEAS,DC=ucdenver,DC=pvt" -Credential $Credential
}