#Tester without cred and key file

$secPassword = ConvertTo-SecureString "VRU9WeoKqJOWE2O" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ("UNIVERSITY\svc-cedc-domainjoin", $secPassword)


# LOGIC to dessimate hostname and figure out correct OU path
$hn = $env:computername


# LOGIC to pull service tag, sanitize it, and add to description in AD
$ServiceTag = Get-CimInstance -ErrorAction Stop win32_SystemEnclosure | select serialnumber
$ST = $ServiceTag -Replace ('\W','')
$ST2 = $ST -Replace ('serialnumber','')
#Write-Host "$hn`: $ST2`n"

 try{remove-computer -UnjoinDomaincredential $Credential -PassThru -Verbose -ErrorAction SilentlyContinue
                }catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}
                try{Add-Computer -WorkgroupName "UCDenver" -ErrorAction SilentlyContinue}catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}

# Add PC to AD in correct OU
#Add-Computer -DomainName "ucdenver.pvt" -OUPATH "OU=NC2413,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Force -Credential $Credential -Verbose

#Tag the AD PC Object with its Service Tag
#Set-ADObject -Identity 'CN=CEDC-NC2413-C5,OU=NC2413,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt' -Description "Service Tag: $ST2" -Credential $Credential -Verbose