$SVCUser = "University\Serviceaccount"
$SVCPW = ConvertTo-SecureString -String "serviceaccountpassword" -AsPlainText -Force
$SVCCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SVCUser,$SVCPW

### Adds PC to Domain
Add-Computer -ComputerName 'CEDC-TEST-ZZ' -DomainName Ucdenver.pvt -OUPath "OU=ECSG,OU=CEAS,DC=UCDENVER,DC=PVT" -Credential $SVCCredentials