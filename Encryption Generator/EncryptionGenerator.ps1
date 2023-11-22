# Taken from https://gist.github.com/ctigeek/2a56648b923d198a6e60
# How to use: .\EncryptionGenerator.ps1 "Uname" "P@ssH3r3" CBC

function Create-AesManagedObject($key, $IV, $mode) {
    $aesManaged = New-Object "System.Security.Cryptography.AesManaged"

    if ($mode="CBC") { $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC }
    elseif ($mode="CFB") {$aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CFB}
    elseif ($mode="CTS") {$aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CTS}
    elseif ($mode="ECB") {$aesManaged.Mode = [System.Security.Cryptography.CipherMode]::ECB}
    elseif ($mode="OFB"){$aesManaged.Mode = [System.Security.Cryptography.CipherMode]::OFB}


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

function Create-AesKey() {
    $aesManaged = Create-AesManagedObject
    $aesManaged.GenerateKey()
    [System.Convert]::ToBase64String($aesManaged.Key)
}

function Encrypt-String($key, $plaintext) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($plaintext)
    $aesManaged = Create-AesManagedObject $key
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
    [byte[]] $fullData = $aesManaged.IV + $encryptedData
    [System.Convert]::ToBase64String($fullData)
}

function Decrypt-String($key, $encryptedStringWithIV) {
    $bytes = [System.Convert]::FromBase64String($encryptedStringWithIV)
    $IV = $bytes[0..15]
    $aesManaged = Create-AesManagedObject $key $IV
    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16);
    $aesManaged.Dispose()
    [System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)
}

$key = Create-AesKey

#When using the key we already made. Disable above and enable this:
#$key = Import-Clixml -LiteralPath ${PSScriptRoot}\Key.xml 


$plaintext =  $Args[0]
$password = $Args[1]
$mode =  $Args[2]

"== Powershell AES $mode Encyption=="
"`nKey: "+$key

$encryptedString = Encrypt-String $key $plaintext
$encryptedString2 = Encrypt-String $key $password

$bytes = [System.Convert]::FromBase64String($encryptedString)
$bytes2 = [System.Convert]::FromBase64String($encryptedString2)

$IV = $bytes[0..15]
"Salt: " +  [System.Convert]::ToHexString($IV)
"Salt: " +  [System.Convert]::ToBase64String($IV)

#Prob done wrong way/below salts not needed
$IV = $bytes2[0..15]
"Salt: " +  [System.Convert]::ToHexString($IV)
"Salt: " +  [System.Convert]::ToBase64String($IV)

$exportObject = New-Object psobject -Property @{
    UserName = $encryptedString
    Password = $encryptedString2
}

#Export the key we made, which can be disabled the second run thru
$key | Export-Clixml -LiteralPath ${PSScriptRoot}\Key.xml

#Export the username and password to Cred file.
$exportObject | Export-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml

#Testing Functions
#$key = Import-Clixml -LiteralPath ${PSScriptRoot}\Pass\Key.xml
#$importObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Pass\CredP.xml
#$secureString = ConvertTo-SecureString -String $importObject.Password -Key $key
#$Credential = New-Object System.Management.Automation.PSCredential($encryptedString, $encryptedString2)

$plain = Decrypt-String $key $encryptedString2
$plain2 = Decrypt-String $key $encryptedString
"`nEncrypted: "+$encryptedString 

"Decrypted: "+$plain
"Decrypted: "+$plain2
