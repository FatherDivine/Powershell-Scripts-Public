 <#
        .SYNOPSIS
           A script for generating credentials.
        
        .DESCRIPTION
            This script will generate XML-based credentials for use in scripts created by
            Aaron Staten for CEDC IT Dept. This includes the Domain Join Tool (DJS),
            PS Remote Enabler Tool (PSRE.ps1) and more. In the case of tools that don't
            specifically need credential files (like PSRE.ps1), the script defaults to
            no credentials as they aren't needed when used inside of the University.
            On the other hand, for at-home testing, the credential files are needed
            to overcome being logged into a local account with no rights to managing 
            remoted University computers. Even with GlobalProtect VPN on, the credential
            files would be needed for the script to work in an off-campus environment.
            So as such, the script is backwards compatible by checking for Cred.xml &
            Key.xml in the folder. If they are they, the script uses them. If not, 
            it doesn't.      

            still good for local use cases where it will only run on the same PC. 
            problem is it doesn't set the padding, cipher block, or anything else. 
            This means PCs use the default settings which can vary, and some will give padding errors and not work.
            Best to use the new PowershellAES.ps1 or Encryption Test.ps1

           
        .Link
            \\data\dept\CEAS\ITS\Software\Scripts\Remote Mass Disk Size Finder
        
         .OUTPUTS
            Generated output files include: Results.txt, OfflinePCs.txt, & LessThan1TBPCs.txt. Results.txt has the hostname,
            total space, free space, and percentage information. OfflinePCs.txt has all PCs that were unreachable (probably turned
            off). LessThan1TBPCs.txt lists computers that have a C: partition of less than 900 GB signalling a less than 1TB Drive.
        
        .NOTES
            Nothing yet.
        .TODO
            Will swap to using functions and params, the better way. 
 #>
[cmdletbinding()]
                                #Enables all Verbose messages to show. Comment out to allow manual use of -Verbose flags behind each Write-Verbose command.
$VerbosePreference = "Continue"

                                #First, asks for the credentials to be converted.
Clear-Host
Write-Verbose "Please input your University credentials to generate a secure key & encrypted credential file."
Write-Verbose "Store the key in a safe place."
Write-Verbose "Both key & credential file must be in the same folder as the tool to work."
$creds = Get-Credential

                                #Here, we'll randomly generate a 32-byte encryption key.
$key = New-Object Byte[] 32

#or instead, [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($CreateKey)
# https://stackoverflow.com/questions/67883498/powershell-password-encryption-decryption-with-key
$rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
$rng.GetBytes($key)

$exportObject = New-Object psobject -Property @{
    UserName = $creds.UserName
    Password = ConvertFrom-SecureString -SecureString $creds.Password -Key $key
}

                                #Saves to the same folder, but depending how PS is run this may be C:\Windows\System32 folder
Clear-Host
Write-Verbose "What would you like to name the credential and key files?" 
Write-Verbose "This script will add 'Cred.xml' and 'Key.xml' to the end of the files automatically."
$FileName = Read-Host "If you wish to plug these credentials directly into the script without altering code, just press enter" #Couldn't get script to look for *Cred.xml and *Key.xml so all names work... yet!
$FileNameCred = "$Filename" + "Cred.xml"
$FileNameKey =  "$Filename" + "Key.xml"
$key | Export-Clixml -LiteralPath ${PSScriptRoot}\$FileNameKey
$exportObject | Export-Clixml -LiteralPath ${PSScriptRoot}\$FileNameCred
Write-Host "`nSuccessfully created $FileNameCred & $FileNameKey in the folder ${PSScriptRoot}`n" -ForegroundColor Yellow
pause
