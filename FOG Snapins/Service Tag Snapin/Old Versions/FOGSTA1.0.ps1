# Fog Service Tag Aggregator: Pulls the service tag of the local PC & adds to it's own AD object
# This version is made for a snapin pack containing Cred.xml & Key.xml
# Created By: Aaron S. for CEDC IT
# Only difference between the newer FOGSTA2 and 1.0 is this version doesn't check for and then download && install RSAT which is needed for the command Set-ADObject.
Start-Transcript -Path "${PSScriptRoot}\TranscriptSTA.txt" -Force

# Variables
$hn = $env:COMPUTERNAME



# The Secure credential version
try{
    $key = Import-Clixml -LiteralPath ${PSScriptRoot}\Key.xml
    $importObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml
    $secureString = ConvertTo-SecureString -String $importObject.Password -Key $key
    $Credential = New-Object System.Management.Automation.PSCredential($importObject.UserName, $secureString)   
    }catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}

# LOGIC to pull service tag, sanitize it, and add to description in AD
$ServiceTag = Get-CimInstance -ErrorAction Stop win32_SystemEnclosure | select-object serialnumber
$ST = $ServiceTag -Replace ('\W','')
$ST2 = $ST -Replace ('serialnumber','')

# LOGIC to dessimate hostname and figure out correct OU path
$HostnameString = $hn
$HostnameArray = $HostnameString.Split("-")
$Hn1 = $HostnameArray[0]
$Hn2 = $HostnameArray[1]

switch -WildCard ($HostnameArray[0])
{
 {'BIOE','CIVL','CSCI','ELEC','IWKS','MECH' -contains $_}{Set-ADObject -Identity "CN=$hn,OU=$Hn1,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
 default {continue}
}
switch -WildCard ($HostnameArray[1])
{
 {'CART*' -like $_}{Set-ADObject -Identity "CN=$hn,OU=$HostNameArray[1],OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
 {'LW840','LW844','NC2013','NC2207','NC2408','NC2413','NC2608','NC2609','NC2610' -contains $_}{Set-ADObject -Identity "CN=$hn,OU=$hn2,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
 {'NC3034','NC3034D','NC3034E','NC3034K','NC3034G','NC3034K','NC3034Q' -like $_}{Set-ADObject -Identity "CN=$hn,OU=DEAN,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
 {'NC2612A','NC2612B','NC2612C','NC2612D' -like $_}{Set-ADObject -Identity "CN=$hn,OU=ECSG,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
 default {}
}
Stop-Transcript
exit