#This version is made for a snapin pack containing Cred.xml & Key.xml
Start-Transcript -Path "${PSScriptRoot}\TranscriptUnjoin.txt"

# Variables
$hn = $env:COMPUTERNAME

# Secure Domain Service Account Credentials
try{
    $key = Import-Clixml -LiteralPath ${PSScriptRoot}\Key.xml
    $importObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml
    $secureString = ConvertTo-SecureString -String $importObject.Password -Key $key
    $Credential = New-Object System.Management.Automation.PSCredential($importObject.UserName, $secureString)   
    }catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}

# Remove LOGIC.
 try{remove-computer -UnjoinDomainCredential $Credential -WorkgroupName "UCDenver" -Verbose -ErrorAction SilentlyContinue -Force
    Get-ADComputer -Server "ucdenver.pvt" -Identity $hn -Credential $Credential| Remove-ADComputer -Confirm:$false
    }catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}
Stop-Transcript
exit