#First, asks for the credentials to be converted.
Write-Host "Please input your University credentials to generate a secure key & encrypted credential file."
Write-Host "Store the key in a safe place."
Write-Host "Both key & credential file must be in the same folder as the tool to work."
$creds = Get-Credential

# Here, we'll randomly generate a 32-byte encryption key.
$key = New-Object byte[](32)

$rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
$rng.GetBytes($key)

$exportObject = New-Object psobject -Property @{
    UserName = $creds.UserName
    Password = ConvertFrom-SecureString -SecureString $creds.Password -Key $key
}

#Saves to the same folder, but depending how PS is run this may be C:\Windows\System32 folder
Clear-Host
Write-Host "What would you like to name the credential and key files?" 
Write-Host "This script will add 'Cred.xml' and 'Key.xml' to the end of the files automatically."
$FileName = Read-Host "If you wish to plug these credentials directly into the script without altering code, just press enter" #Couldn't get script to look for *Cred.xml and *Key.xml so all names work... yet!
$FileNameCred = "$Filename" + "Cred.xml"
$FileNameKey =  "$Filename" + "Key.xml"
$key | Export-Clixml -LiteralPath ${PSScriptRoot}\$FileNameKey
$exportObject | Export-Clixml -LiteralPath ${PSScriptRoot}\$FileNameCred
Write-Host ""
Write-Host "Successfully created $FileNameCred & $FileNameKey in the folder ${PSScriptRoot}`n" -ForegroundColor Yellow
pause
