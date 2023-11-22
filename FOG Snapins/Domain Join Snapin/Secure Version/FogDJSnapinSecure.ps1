#This version is made for a snapin pack containing Cred.xml & Key.xml
Start-Transcript -Path "${PSScriptRoot}\TranscriptJoin.txt"

# Variables
$hn = $env:COMPUTERNAME


# The Secure credential version
try{
    $key = Import-Clixml -LiteralPath ${PSScriptRoot}\Key.xml
    $importObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml
    $secureString = ConvertTo-SecureString -String $importObject.Password -Key $key
    $Credential = New-Object System.Management.Automation.PSCredential($importObject.UserName, $secureString)   
    }catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}

# LOGIC to dessimate hostname and figure out correct OU path
$HostnameString = $hn
$HostnameArray = $HostnameString.Split("-")
$Hn1 = $HostnameArray[0]
$Hn2 = $HostnameArray[1]


# LOGIC to pull service tag, sanitize it, and add to description in AD
$ServiceTag = Get-CimInstance -ErrorAction Stop win32_SystemEnclosure | select-object serialnumber
$ST = $ServiceTag -Replace ('\W','')
$ST2 = $ST -Replace ('serialnumber','')


# Add PC to AD in correct OU
switch -WildCard ($HostnameArray[1])
{
 {'CART' -like $_}{Add-Computer -DomainName "ucdenver.pvt" -OUPATH "OU=$Hn2,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Force -Credential $Credential -Verbose}
 {'LW840','LW844','NC2013','NC2207','NC2408','NC2413','NC2608','NC2609','NC2610' -contains $_}{Add-Computer -DomainName "ucdenver.pvt" -OUPath "OU=$Hn2,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Force -Credential $Credential -Verbose}
 {'NC3034','NC3034D','NC3034E','NC3034K','NC3034G','NC3034K','NC3034Q' -like $_}{Add-Computer -DomainName "ucdenver.pvt" -OUPath "OU=DEAN,OU=CEAS,DC=ucdenver,DC=pvt" -Force -Credential $Credential -Verbose}
 {'NC2612A','NC2612B','NC2612C','NC2612D' -like $_}{Add-Computer -DomainName "ucdenver.pvt" -OUPATH "OU=ECSG,OU=CEAS,DC=ucdenver,DC=pvt" -Force -Credential $Credential -Verbose}
 default {}
}
switch -WildCard ($HostnameArray[0])
{
 {'BIOE','CIVL','CSCI','ELEC','IWKS','MECH' -contains $_}{Add-Computer -DomainName "ucdenver.pvt" -OUPATH "OU=$Hn1,OU=CEAS,DC=ucdenver,DC=pvt" -Force -Credential $Credential -Verbose}
 default {continue}
}
Stop-Transcript
exit