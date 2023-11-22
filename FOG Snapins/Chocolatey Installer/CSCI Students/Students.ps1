<#
  .SYNOPSIS
    Installs Chocolatey for CEDC CSCI Students.

  .DESCRIPTION
    This script installs Chocolatey with the
    settings necessary for CEDC CSCI Students.
    This includes the Students repo w/ credentials.

  .LINK
    \\DATA\DEPT\CEAS\ITS\Software\Scripts\Chocolatey Installer
  
  .INPUTS
    None. You cannot pipe objects to this script.

  .OUTPUTS
    None. This script does not generate any output.

  .EXAMPLE
    PS> .\Students.ps1
    Intended use is to load in FOG and use as a snap-in,
    but this can be ran from the command line.

  .Author
    Created by Aaron S. for CU Denver CEDC IT Dept
  
  .Snapin Description
    Installs Chocolatey with the internal student repo using encrypted credentials. (using test environment repo: cedc-nc2413-z1:8081)
    This snapin also installs Chocolatey GUI, disables the Chocolatey Community Repository, 
    creates a desktop icon called "Software Installer (Chocolatey)", installs any necessary software in Chocolatey 
    (none right now... but possibly things like Office, Chrome, Firefox, Adobe Reader, etc), & performs Housekeeping.
 #>
 #region Functions
 function Credentials{
  function Create-AesManagedObject($key, $IV, $mode) {
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

if ((Test-Path ${PSScriptRoot}\Key.xml -ErrorAction SilentlyContinue) -and (Test-Path ${PSScriptRoot}\Cred.xml -ErrorAction SilentlyContinue))
{
 $Key = Import-Clixml -LiteralPath ${PSScriptRoot}\Key.xml
 $ImportObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml
 $global:Username = Decrypt-String $key $ImportObject.Username
 $global:Password = Decrypt-String $key $ImportObject.Password
}
else{continue}
}
Credentials
 #endregion Functions

# For debugging purposes
Start-Transcript -Path "C:\Temp\ChocolateyTranscript.txt" -Force

# Install Chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-WebRequest https://community.chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

# Install Chocolatey GUI. Have to test the -y
Write-Output 'A' | choco install chocolateygui -y

# Create Chocolatey desktop icon in the Public folder named "Software Installer" so it's easy for Faculty/Staff to identify
Copy-Item 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Chocolatey GUI.lnk' 'C:\users\public\desktop\Software Installer (Chocolatey).lnk' 

# Add the correct internal repository for CEDC Faculty/Staff . Change "cedc-nc2413-z1 to correct name"
choco source add --name="'CEDC Student'" --source="'http://cedc-nc2413-z1:8081/repository/CSCIS/'" --priority="'0'" -u="$global:Username" -p="$global:Password"

# Disable the Chocolatey Community Repository
choco source disable -n=chocolatey

# Install the necessary software, if applicable (alternatively just invoke remote PC with -scriptblock{choco install s0ftw@r3z})
# If not pre-installed in the image, we would install things like: Adobe Reader, Chrome, Firefox, Office. 
# In the future choco will do all software installs so no more manual installation via FOG images.

# Housekeeping (Fog deletes everything in the snapin folder, but could be useful for the Transcript Log.)
# Remove-item -Path 'C:\Temp\ChocolateyTranscript.txt' -Force

Stop-Transcript
exit