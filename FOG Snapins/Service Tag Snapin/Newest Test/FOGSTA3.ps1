# Fog Service Tag Aggregator: Pulls the service tag of the local PC & adds to it's own AD object
# This version is made for a snapin pack containing Cred.xml & Key.xml
# Created By: Aaron S. for CEDC IT
# NOT working yet:  Unable to contact the server. This may be because this server does not exist, it is currently down, or it does not have the Active Directory Web Services running.
# Issues passing $Credentials outside a function. MAKE SURE not the university\ issue
#Set-Variable -Name Credential -Option AllScope
#Region Function Credentials
function global:Credentials{
    
    function Create-AesManagedObject($key, $IV) {
      $aesManaged = New-Object "System.Security.Cryptography.AesManaged"  
  
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
    $Key = Import-Clixml -LiteralPath ${PSScriptRoot}\Key.xml
    $ImportObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml
  
    $plain = Decrypt-String $key $ImportObject.UserName
    $plain2 = Decrypt-String $key $ImportObject.Password
  
    $SecureUsername = ConvertTo-SecureString $plain -AsPlainText -Force
    $SecurePassword = ConvertTo-SecureString $plain2 -AsPLainText -Force
    $Credential = New-Object  System.Management.Automation.PSCredential ($SecureUsername,$SecurePassword)
    return $Credential
}
#Credentials
$Credential2 = Credentials
#EndRegion function credentials

# For debugging purposes
Start-Transcript -Path "${PSScriptRoot}\TranscriptSTA.txt" -Force

#Installs RSAT tools needed for Set-ADObject cmdlet
if(!(get-module -list activedirectory)){
    $registryWU = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
$currentWU = Get-ItemProperty -Path $registryWU -Name "UseWUServer" | Select-Object -ExpandProperty UseWUServer

Set-ItemProperty -Path $registryWU -Name "UseWUServer" -Value 0

Restart-Service wuauserv

Get-WindowsCapability -Name RSAT.ActiveDirectory* -Online | Add-WindowsCapability –Online
Set-ItemProperty -Path $registryWU -Name "UseWUServer" -Value $currentWU

Restart-Service wuauserv -force

#Add-WindowsCapability -online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
}

# Variables
$hn = $env:COMPUTERNAME

# LOGIC to pull service tag, sanitize it, and add to description in AD
$ServiceTag = Get-CimInstance -ErrorAction Stop win32_SystemEnclosure | select-object serialnumber
$ST = $ServiceTag -Replace ('\W','')
$ST2 = $ST -Replace ('serialnumber','')

# LOGIC to dessimate hostname and figure out correct OU path
$HostnameString = $hn
$HostnameArray = $HostnameString.Split("-")
$Hn1 = $HostnameArray[0]
$Hn2 = $HostnameArray[1]

# LOGIC to detect where the object is in AD to write the service tag
switch -WildCard ($HostnameArray[1])
{
 {'CART' -like $_}{Set-ADObject -Identity "CN=$hn,OU=$HostNameArray[1],OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
 {'LW840','LW844','NC2013','NC2207','NC2408','NC2413','NC2608','NC2609','NC2610' -contains $_}{Set-ADObject -Identity "CN=$hn,OU=$hn2,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
 {'NC3034','NC3034D','NC3034E','NC3034K','NC3034G','NC3034K','NC3034Q' -like $_}{Set-ADObject -Identity "CN=$hn,OU=DEAN,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
 {'NC2612A','NC2612B','NC2612C','NC2612D' -like $_}{Set-ADObject -Server "ucdenver.pvt" -Identity "CN=$hn,OU=ECSG,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential2 -Verbose}
 default {}
}
switch -WildCard ($HostnameArray[0])
{
 {'BIOE','CIVL','CSCI','ELEC','IWKS','MECH' -contains $_}{Set-ADObject -Identity "CN=$hn,OU=$Hn1,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
 default {continue}
}
Stop-Transcript
exit