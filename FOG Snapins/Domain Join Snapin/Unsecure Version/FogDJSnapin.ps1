Start-Transcript -Path "${PSScriptRoot}\TranscriptJoin.txt"

# Variables
$hn = $env:COMPUTERNAME

# Unsecure Domain Service Account Credentials (but works!)
try{
    $secPassword = ConvertTo-SecureString "VRU9WeoKqJOWE2O" -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ("UNIVERSITY\svc-cedc-domainjoin", $secPassword)
    }catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}

# LOGIC to dessimate hostname and figure out correct OU path


# LOGIC to pull service tag, sanitize it, and add to description in AD
$ServiceTag = Get-CimInstance -ErrorAction Stop win32_SystemEnclosure | select-object serialnumber
$ST = $ServiceTag -Replace ('\W','')
$ST2 = $ST -Replace ('serialnumber','')


# Add PC to AD in correct OU
Add-Computer -DomainName "ucdenver.pvt" -OUPATH "OU=NC2413,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Force -Credential $Credential -Verbose

#Tag the AD PC Object with its Service Tag
Set-ADObject -Identity "CN=$hn,OU=NC2413,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose
Stop-Transcript
exit