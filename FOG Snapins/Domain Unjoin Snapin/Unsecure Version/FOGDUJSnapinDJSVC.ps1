Start-Transcript -Path "${PSScriptRoot}\TranscriptUnjoin.txt"

# Variables
$hn = $env:COMPUTERNAME

#The unsecure credential version (but works!)
$secPassword = ConvertTo-SecureString "VRU9WeoKqJOWE2O" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ("svc-cedc-domainjoin", $secPassword)


# Remove LOGIC. remove-ad removes from AD alltogether. remove-computer is local
 try{remove-computer -UnjoinDomaincredential $Credential -WorkgroupName "UCDenver" -Verbose -ErrorAction SilentlyContinue -Force
    Get-ADComputer -Server "ucdenver.pvt" -Identity $hn -Credential $Credential| Remove-ADComputer -Confirm:$false
    }catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}
Stop-Transcript
exit