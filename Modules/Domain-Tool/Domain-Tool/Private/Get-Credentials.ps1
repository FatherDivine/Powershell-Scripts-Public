<#
.SYNOPSIS
  Processes credentials.

.DESCRIPTION
  <Brief description of script>

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
  Version:        0.1
  Author:         Aaron Staten
  Creation Date:  12-6-2023
  Purpose/Change: Initial script development
 
.LINK
GitHub README or script link

.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>
#---------------------------------------------------------[Force Module Elevation]--------------------------------------------------------
#With this code, the script/module/function won't run unless elevated, thus local users can't use off the bat.
<#
$Elevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ( -not $Elevated ) {
  throw "This module requires elevation."
}
#>

#--------------------------------------------------------------[Privilege Escalation]---------------------------------------------------------------

#When admin rights are needed
#if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
#{  
#  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
#  Start-Process powershell -Verb runAs -ArgumentList $arguments
#  Break
#}

#---------------------------------------------------------[Initialisations ]--------------------------------------------------------
#proceses credentials for domain cmdlets
function Get-Credentials{
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
  function Decrypt-String($key, $encryptedStringWithIV) {
    $bytes = [System.Convert]::FromBase64String($encryptedStringWithIV)
    $IV = $bytes[0..15]
    $aesManaged = Create-AesManagedObject $key $IV
    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16);
    $aesManaged.Dispose()
    [System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)
}

if ((Test-Path ${PSScriptRoot}\Key.xml -ErrorAction SilentlyContinue) -and (Test-Path ${PSScriptRoot}\Cred.xml -ErrorAction SilentlyContinue))
{
 $Key = Import-Clixml -LiteralPath ${PSScriptRoot}\Key.xml
 $ImportObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml
 $plain = Decrypt-String $key $ImportObject.Username
 $plain2 = Decrypt-String $key $ImportObject.Password
 $SecureUsername = ConvertTo-SecureString $plain -AsPlainText -Force
 $SecurePassword = ConvertTo-SecureString $plain2 -AsPlainText -Force
 [PSCredential]$global:Credential = New-Object System.Management.Automation.PSCredential ($SecureUsername,$SecurePassword) 
 # Custards last stand: use the plain form instead of secure
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
  Get-Credentials
  Return ,$Credential