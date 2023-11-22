function global:Credentials{
  function CreateAesManagedObject($key, $IV, $mode) {
    $aesManaged = New-Object "System.Security.Cryptography.AesManaged"

    #if ($mode="CBC") { $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC }
    #elseif ($mode="CFB") {$aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CFB}
    #elseif ($mode="CTS") {$aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CTS}
    #elseif ($mode="ECB") {$aesManaged.Mode = [System.Security.Cryptography.CipherMode]::ECB}
    #elseif ($mode="OFB"){$aesManaged.Mode = [System.Security.Cryptography.CipherMode]::OFB}


    $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $aesManaged.BlockSize = 128
    $aesManaged.KeySize = 256
    if ($IV) {
        if ($IV.getType().Name -eq "String") {
            $aesManaged.IV = [System.Convert]::FromBase64String($IV)
        }
        else {
            $aesManaged.IV = $IV
        }
    }
    if ($key) {
        if ($key.getType().Name -eq "String") {
            $aesManaged.Key = [System.Convert]::FromBase64String($key)
        }
        else {
            $aesManaged.Key = $key
        }
    }
    $aesManaged
}
  function DecryptString($key, $encryptedStringWithIV) {
    $bytes = [System.Convert]::FromBase64String($encryptedStringWithIV)
    $IV = $bytes[0..15]
    $aesManaged = CreateAesManagedObject $key $IV
    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16);
    $aesManaged.Dispose()
    [System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)
}

if ((Test-Path ${PSScriptRoot}\Key.xml -ErrorAction SilentlyContinue) -and (Test-Path ${PSScriptRoot}\Cred.xml -ErrorAction SilentlyContinue))
{
 $Key = Import-Clixml -LiteralPath ${PSScriptRoot}\Key.xml
 [securestring]$ImportObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml
 #$Key = Import-Clixml -LiteralPath ${PSScriptRoot}\Key.xml
 #$ImportObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml
 #$plain = DecryptString $key $ImportObject.Username
 #$plain2 = DecryptString $key $ImportObject.Password
 #$SecureUsername = ConvertTo-SecureString $plain -AsPlainText -Force
 #$SecurePassword = ConvertTo-SecureString $plain2 -AsPlainText -Force
 #[psobject]$Credential = New-Object System.Management.Automation.PSCredential ($SecureUsername,$SecurePassword) 
 $Credential = New-Object System.Management.Automation.PSCredential ($ImportObject.UserName,$ImportObject.Password)
 # Test Functions
 #"`nEncrypted: "+$encryptedString 
 #"`nEncrypted: "+$encryptedString2
 "Decrypted: "+$plain 
 #"Decrypted: "+$plain2

 #Remove-Variable plain -Force;Remove-Variable plain2 -Force;Remove-Variable ImportObject -Force;Remove-Variable Key -Force
}
else{
Write-Warning "`nCredential files (Cred.xml & Key.xml) were NOT detected! Activating manual credentials mode."
     Write-Host "`nPlease input the credentials you wish to use in this script. They must have Admin & AD privileges."
     $GotCredentials = $false
     [int]$GotCredentialsCounter = 0
     do{try{$global:Credential = Get-Credential;$GotCredentials = $true}catch{Write-Error "$_"; $GotCredentials = $false;}$GotCredentialsCounter++}
     until(($GotCredentialsCounter -gt 3) -or ($GotCredentials -eq $true))
     If ($GotCredentialsCounter -eq 4){Write-Warning "`nYou just don't want to enter credentials! Exiting!`n";pause;exit}}#$global:CredentialFile = '1';$CredentialFile = '1' } #Keeping it 0 to distinguish.
}
Credentials

Remove-Computer -ComputerName "cedc-nc2413-z1" -UnjoinDomainCredential $Credential -WorkgroupName "Ucdenver" -Force -PassThru -Verbose

#Invoke-Command -Computer "cedc-nc2413-z1" -ArgumentList $testfunction -ScriptBlock {Param([PSCredential]$Cred) 
#    Remove-Computer -UnjoinDomainCredential $Cred -WorkgroupName "Ucdenver" -Force -PassThru -Verbose -Restart}
pause

             