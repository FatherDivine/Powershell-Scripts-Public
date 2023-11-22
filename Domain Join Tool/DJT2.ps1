#region help information
<#
  .SYNOPSIS
    Domain tool that allows one to join & unjoin objects to AD, as well as rename computers.

  .DESCRIPTION
    The DJT.ps1 script allows CEDC IT Staff to not only join and unjoin objects to the UCDENVER Active Directory,
    but also rename computers locally. The script has many failsafes and checks to make sure everything is done right.
    This script can't delete objects, as this is best done manually.

  .PARAMETER JoinDomain
    Working command line for inner script use:
    DJT -JoinDomain "HostnameHere" -ou1 'BIOE' -ou2 'NC2207' -ou3 'W'
  
  .PARAMETER JoinDomainR / DomainJoinRemote / DomainJoinRemote
    Joins the domain of a remote host.

  .PARAMETER List
    Allows for a list of computers to be piped from the command line.

  .PARAMETER OU1
    Part 1 of the AD OU location 

  .PARAMETER OU2
    Part 2 of the AD OU location
  
  .PARAMETER OU3
    Part 3 of the OU location (used for servers)

  .PARAMETER OU4
    Part 4 of the OU location (used for servers)

  .PARAMETER Remote
    Used to test a remote computer's trust relationship between
    host and domain controller. USed in conjunction with
    SecureChannel parameter. Example

  .PARAMETER RenameHost
    Renames either the local, remote, or a list of hosts.
    Will automatically rename the object in Active Directory.

  .PARAMETER RenameLHost / LHostRename / LocalHostRename / RenameLocalHost
    Specifies the local computer as the target for renaming of the hostname.
    Can be used at the command line as such:
      
    .\DJT.ps1 -RenameLHost "NameToRename" -Restart N
      
    When used in conjunction with the Restart parameter.

  .PARAMETER RenameRHost / RHostRename / RenameRemoteHost / RemoteHostRename
    Specifies a remote host as the target for renaming of the hostname.
    Can be used at the command line as such:

  .PARAMETER RenameRHostList / RHostRenameList / RenameListRemoteHost / RemoteHostRenameList

  .PARAMETER Repair
    Repairs the trust relationship between host and domain controller.
    Used in conjunction with SecureChannel parameter.

  .PARAMETER Restart
    Feeds a forced restart to a remote host.
    Useful for when renaming hosts or joining the domain.

  .PARAMETER SecureChannel
    Tests and repairs the domain trust relationship.
    Defaults to local hostname when not using -Remote switch. Example:
    .\DJT.ps1 -Securechannel HostnameHere

  .PARAMETER Test
    Tests the quality of the trust relationship between host and domain
    controller. Used in conjunction with SecureChannel parameter.

  .PARAMETER UnjoinDomainL / DomainUnjoinL / DominUnjoinLocal / DomainUnjoin / UnjoinDomain
    Unjoins the local host from the domain.

  .PARAMETER UnjoinDomainR / DominUnjoinR / DomainUnjoinRemote
    Unjoins a remote host from the domain.

  .LINK
    \\DATA\DEPT\CEAS\ITS\Software\Scripts\Domain Join Tool (Testing)
  
  .INPUTS
    None. You cannot pipe objects to DJT.ps1.

  .OUTPUTS
    None. DJS.ps1 does not generate any output.
    DJT.ps1 generates 

  .EXAMPLE
    PS> .\DJT.ps1
      Runs the script in normal, non-command line use.
      Description
      -----------
      This restarts a remote computer      
  
  .EXAMPLE  
    PS> .\DJT.ps1 -Restart "Hostname Here"
      Description
      -----------
      This restarts a remote computer
 
  .EXAMPLE  
    .\DJT.ps1 -Securechannel HostnameHere -Remote
      Description
      -----------    
      tests, and if broken, repairs the domain-relationship of a remote pc.
      Omitting the -Remote flag will do the same process for the local pc.
      Just be sure to add anything as the hostname, eg:
      .\DJT.ps1 -SecureChannel asdfhjklblahblah
  
  .EXAMPLE      
      .\DJT.ps1 -RenameRHost "Remote-Host-Name" -Restart Y
        Description
        -----------      
        Renames the remote host
        When used in conjunction with the Restart parameter.
  
  .EXAMPLE    
      .\DJT.ps1 -RenameHost
        Description
        -----------      
        Renames local host

  .EXAMPLE          
      .\DJT.ps1 -RenameHost Newhostname,CurrentHostname -Remote
        Description
        -----------      
        Renames a remote host. Make sure to add the new hostname first
        For now use: .\DJT.ps1 -RenameRHost NewHostname,CurrentHostname -Remote

  .EXAMPLE       
      .\DJT.ps1 -RenameHost -Remote -List 
        Description
        -----------      

  .NOTES

  .AUTHOR
    Created by Aaron S. for CU Denver CEDC IT Dept
  
  .TESTED FUNCTIONS
  Command Line:
  - Secure Channel local & remote : .\DJT.PS1 -SecureChannel (-Remote)
  - -RenameLHost, -RenameRHost, & RenameRHostList all work, but will redo logic soon to simplify
  
  Running Script:
  - Secure Channel local & remote
  - Rename Local, Remote, and List work. 
  - -JoinDomainCH (joining using current hostname) using LABS (as $ou1) creates in AD correctly.
  - Unjoin domain works.

  .TO-DO 
   
  Add menu option to (delete first if already exists then) add a single or list of hosts to AD by OU (but not join)
  This is good for flushing an AD list to make sure all accts are made with service domainjoin acct, or even
  to add new computers w/ credentials baked in already
  
   New naming conventions:
   Offices: [DEPT]-[ROOM]-[NUMBER][OS]
   Computer Labs: [DEPT]-[ROOM]-[GRID][NUMBER]
   Servers: [DEPT]-[CATEGORY]-[PURPOSE]-[PHYSICAL/VIRTUAL][NUMBER]

   6-7-23 finish coding on line 792 (writing to descriptions in AD)

   6-15-23 When creating module, use this folder for university pcs: C:\Windows\System32\WindowsPowerShell\v1.0\Modules\DJT\DJT.psd1

   6-15-23 Think about turning DJT into smaller functions. Each switch is a function (unjoin, securechannel, PSRE, rename, etc)

   6-15-23 line 1083 #ADD to hostfinder function
   
#Error Exception Finder
[appdomain]::CurrentDomain.GetAssemblies() | ForEach {
    Try {
        $_.GetExportedTypes() | Where {
            $_.Fullname -match 'Exception'
        }
    } Catch {}
} | Select FullName
 #>
#endregion help information
#region command-line parameters
# Parameters for command line use (Ex: .\DJT.ps1 -DomainJoin "HostName" -ou1 "CSCI" -ou2 "R" -ou3 "Data" -ou4 "P"
Param
       ([cmdletbinding()]
       [decimal]$env:_vLUF,

       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
        [switch]$Force,
       
        [Parameter(Mandatory=$false,
       ValueFromPipeline=$true)]
       [Alias("DomainJoin")]
       [string]$JoinDomain=$NULL,
       $errorlog,

       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [Alias("DomainJoinRemote","DomainJoinR")]
       [string]$JoinDomainR,

       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
        [string]$List,
       
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
        [string]$ou1,
       
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
        [string]$ou2,
       
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
        [string]$ou3,
       
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
        [string]$ou4,

       [Parameter(Mandatory=$false,
        ValueFromPipeline=$false)]
        [switch]$Remote,

       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
        [string]$Restart,

       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [AllowNull()]
        [string[]]$RenameHost,
        
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$true)]
        [string]$SecureChannel,
       
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$true)]
        [string]$SecureChannelL, 

       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [AllowNull()]
        [string]$UnjoinDomain=$NULL
       )
#endregion command-line parameters
#region disabled get admin privileges
<# Get admin privileges. dont work with params above
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break

  maybe a function with this: Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}#>
#endregion disabled get admin privileges 
#region PS version specific module loading
#Below allows PS >= 6 (when PS went from .Net Framework to .NET CORE to support *nix & OSX) to use the built-in modules (like Test-ComputerSecureChannel, AD commands) that exists in WinPS (PS < 6).
if ($PSVersionTable.PSVersion.Major -ge 6)
{
  import-module Microsoft.PowerShell.Management -UseWindowsPowerShell #-SkipEditionCheck 
}
#endregion PS version specific module loading
#region variables
$WarningPreference = "Continue"
$global:hostname = $env:COMPUTERNAME       # Leaning towards just using this once, and not updating as soon as the command runs, as you should not be changing hostnames manually while this is running
$hostnameLength = $hostname.length
$OldComputerName = $global:hostname        # Using to keep track of old PC name
$CustomHost= "0"                           # Couldn't be null to begin
$IntroPlayed = "F"                         # Controls if intro graphic will play or not. Speeds up having to go back to the main menu.
$global:PSRERan = "0"                      # Keeps track of if PS Remote Enable tool ran to enable remoting.
$global:domain = 'ucdenver.pvt'            # Static domain for compatibility.
$global:CredentialFile = '0'               # Tracks if Credential file was found or not.
#endregion variables
#region functions section
#region function credentials
#Functions section
function Credentials{
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
 [PSCredential]$global:Credential = New-Object System.Management.Automation.PSCredential ("$SecureUsername","$SecurePassword") 
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
Credentials
#region function ServiceTagWriter
function ServiceTagWriter
{
Param
       ([cmdletbinding()]
       
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$true)]
        [Switch]$PrintOnly,
        $errorlog
)
<#
.TODO
    Eventually add remote support, but if winrm or other issues get-ciminstance won't work so best to not worry. 
    Idea is grab remote ST and throw into it's AD object. For now only does that locally.

    If switch, return ST only (don't set)
#>
# Variables
$hn = $env:COMPUTERNAME

# LOGIC to pull service tag, sanitize it, and add to description in AD
$ServiceTag = Get-CimInstance -ErrorAction Stop win32_SystemEnclosure | select-object serialnumber
$ST = $ServiceTag -Replace ('\W','')
$ST2 = $ST -Replace ('serialnumber','')
Remove-Variable ServiceTag 
$global:ServiceTag = $ST2

Switch ($PSBoundParameters.Keys){ 
        
    'PrintOnly'{
                Write-Host "`nService Tag of ${hostname}: $global:ServiceTag`n"
                write-host "print only exiting";pause
               }

    default{# LOGIC to dessimate hostname and figure out correct OU path
            write-host "the default section";pause
            $HostnameString = $hn
            $HostnameArray = $HostnameString.Split("-")
            $Hn1 = $HostnameArray[0]
            $Hn2 = $HostnameArray[1]

            switch -WildCard ($HostnameArray[0]){
                {'BIOE','CIVL','CSCI','ELEC','IWKS','MECH' -contains $_}{Set-ADObject -Identity "CN=$hn,OU=$Hn1,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
                default {continue}
            }
            switch -WildCard ($HostnameArray[1]){
                {'CART*' -like $_}{Set-ADObject -Identity "CN=$hn,OU=$HostNameArray[1],OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
                {'LW840','LW844','NC2013','NC2207','NC2408','NC2413','NC2608','NC2609','NC2610' -contains $_}{Set-ADObject -Identity "CN=$hn,OU=$hn2,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
                {'NC3034','NC3034D','NC3034E','NC3034K','NC3034G','NC3034K','NC3034Q' -like $_}{Set-ADObject -Identity "CN=$hn,OU=DEAN,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
                {'NC2612A','NC2612B','NC2612C','NC2612D' -like $_}{Set-ADObject -Identity "CN=$hn,OU=ECSG,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Verbose}
                default {}
            }
    }
}
}
#endregion function ServiceTagWriter
#endregion function credentials
#region function Intro ASCII Art
#Because, ASCII RAWKS
function Intro
{
$t = @"

████████ ██   ██ ███████
   ██    ██   ██ ██
   ██    ███████ █████
   ██    ██   ██ ██
   ██    ██   ██ ███████


██████   ██████  ███    ███  █████  ██ ███    ██          ██  ██████  ██ ███    ██     ████████  ██████   ██████  ██
██   ██ ██    ██ ████  ████ ██   ██ ██ ████   ██          ██ ██    ██ ██ ████   ██        ██    ██    ██ ██    ██ ██
██   ██ ██    ██ ██ ████ ██ ███████ ██ ██ ██  ██          ██ ██    ██ ██ ██ ██  ██        ██    ██    ██ ██    ██ ██
██   ██ ██    ██ ██  ██  ██ ██   ██ ██ ██  ██ ██     ██   ██ ██    ██ ██ ██  ██ ██        ██    ██    ██ ██    ██ ██
██████   ██████  ██      ██ ██   ██ ██ ██   ████      █████   ██████  ██ ██   ████        ██     ██████   ██████  ███████

"@

for ($i=0;$i -lt $t.length;$i++) {
if ($i%2) {
 $c = "white"
}
elseif ($i%5) {
 $c = "white"
}
elseif ($i%7) {
 $c = "white"
}
else {
   $c = "white"
}
write-host $t[$i] -NoNewline -ForegroundColor $c
}
}
#endregion function Intro ASCII Art
#region function menus
function Show-Menu
{
    param (
           [string]$Title = 'CEDC Domain Join Tool'
          )
    #Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' to join the domain."
    Write-Host "2: Press '2' to unjoin the domain." #ADD LOGIC for local or remote
    Write-Host "3: Press '3' to rename hostname(s)."
    Write-Host "4: Press '4' to write the local PC's service tag to it's AD object."
    Write-Host "4: Press '5' to join the domain using the current hostname." #re-evaluate name
    Write-Host "5: Press '6' to repair the trust relationship (SecureChannel)."
    Write-Host "6: Press '7' to enable PS Remote Services (WinRM/WSMan)"
    Write-Host "Q: Press 'Q' to quit.`n"
    Write-Host "Total length of the hostname cannot exceed 15 characters." 
    Write-Host "The current hostname ($hostname) is $hostnameLength characters long."
}
function Show-Dept-Menu
{
param (
       [string]$DeptTitle = 'Faculty & Staff Departments'
      )
    Clear-Host
    Write-Host "================ $DeptTitle ================"
    
    Write-Host "1: BIOE: Bio Engineering"
    Write-Host "2: CIVL: Civil Engineering"
    Write-Host "3: CSCI: Computer Science"
    Write-Host "4: DEAN: Office of the Dean"
    Write-Host "5: ECSG: NC2612A and Administration OU"
    Write-Host "6: ELEC: Electrical Engineering"
    Write-Host "7: IWKS: Inworks"
    Write-Host "8: MECH: Mechanical Engineering"
    Write-Host "9: Test: Testing OU"
    Write-Host "B: Press 'B' to go back to the main menu."
    Write-Host "Q: Press 'Q' to quit."
}
function Show-LABS-Menu
{
param (
       [string]$DeptTitle = 'Computer Labs'
      )
    Clear-Host
    Write-Host "================ $DeptTitle ================"
    
    Write-Host "1: Laptop Cart"
    Write-Host "2: LW840"
    Write-Host "3: LW844"
    Write-Host "4: NC2013"
    Write-Host "5: NC2207"
    Write-Host "6: NC2408"
    Write-Host "7: NC2413"
    Write-Host "8: NC2608"
    Write-Host "9: NC2609"
    Write-Host "10: NC2610"
    Write-Host "B: Press 'B' to go back to the main menu."
    Write-Host "Q: Press 'Q' to quit."

}
function Show-Who-Menu
{
param (
       [string]$DeptTitle = 'Where does the object belong?'
      )
    Clear-Host
    Write-Host "================ $DeptTitle ================"
    
    Write-Host "1: Faculty/Staff"
    Write-Host "2: Computer Labs"
    Write-Host "3: Server"
    Write-Host "B: Press 'B' to go back to the main menu."
    Write-Host "Q: Press 'Q' to quit."
}
function Show-Server-Dept-Menu
{
param (
       [string]$DeptTitle = 'Server Departments'
      )
    Clear-Host
    Write-Host "================ $DeptTitle ================"
    
    Write-Host "1: BIOE: Bio Engineering"
    Write-Host "2: CIVL: Civil Engineering"
    Write-Host "3: CSCI: Computer Science"
    Write-Host "4: DEAN: Office of the Dean"
    Write-Host "5: ECSG: NC2612A and Administration OU"
    Write-Host "6: ELEC: Electrical Engineering"
    Write-Host "7: MECH: Mechanical Engineering"
    Write-Host "8: Test: Testing OU"
    Write-Host "B: Press 'B' to go back to the main menu."
    Write-Host "Q: Press 'Q' to quit."
}
function Show-Server-Category-Menu
{
param (
       [string]$DeptTitle = 'What category does this server belon?'
      )
    Clear-Host
    Write-Host "================ $DeptTitle ================"
    
    Write-Host "1: Administration"
    Write-Host "2: Instructional"
    Write-Host "3: Research`n"
    Write-Host "B: Press 'B' to go back to the main menu."
    Write-Host "Q: Press 'Q' to quit."
}
function Show-Server-Purpose-Menu
{
param (
       [string]$DeptTitle = 'What is the Purpose of the Server?'
      )
    Clear-Host
    Write-Host "================ $DeptTitle ================"
    
    Write-Host "1: APP: Application Server     | 5: FOG: FOG Server"
    Write-Host "2: DATA: Data Storage Server   | 6: LIC: License Server"
    Write-Host "3: DB: Database Server         | 7: PRNT: Print Server"
    Write-Host "4: FILE: File Server           | 8 : WWW: Webserver`n"
    Write-Host "B: Press 'B' to go back to the main menu."
    Write-Host "Q: Press 'Q' to quit."
}
#endregion function menus
#region function PSRE Power Shell Remote Enabler
function global:PowerShellRemoteEnabler()
{
[cmdletbinding()]
Param 
         (
         [Parameter(Mandatory=$false,
         ValueFromPipeline=$false)]
         [Alias("DomainJoin")]
         [string]$Server,
         $errorlog
         )
  begin{}
  process{
    try{& ${PSScriptRoot}\PSRE.ps1 -Server $Server 
       }catch{}#Catch if PSRE.ps1 is non-existent.
         }    
  end{
    
     }  
}
#endregion function PSRE Power Shell Remote Enabler
#region function DJT Domain Join Tool
# Function to rename computer, function to join domain, function to unjoin, etc. Just feed info into function. simplify script
function global:DJT()
{
[cmdletbinding()]
Param 
      (
        [Parameter(Mandatory=$false,
        ValueFromPipeline=$false)]
        [switch]$Force,
 
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [Alias("DomainJoin")]
       [string]$JoinDomain,
       $errorlog,

       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [Alias("DomainJoinCH")]
       [string]$JoinDomainCH,

       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [Alias("DomainJoinRemote","DomainJoinR")]
       [string]$JoinDomainR,

       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
        [string]$List,
       
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [string]$ou1,
       
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [string]$ou2,
       
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [string]$ou3,
       
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [string]$ou4,
       
       [Parameter(Mandatory=$false,
        ValueFromPipeline=$false)]
        [AllowNull()]
        [switch]$Remote,
       
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
        [string]$Restart,
       
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [AllowNull()]
        [string[]]$RenameHost,
        
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
        [string[]]$SecureChannel,
 
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
        [switch]$SecureChannelL,

       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
        [string]$UnjoinDomain=$NULL
       )
begin {
        # setup our return object
        $result = [PSCustomObject]@{

            SuccessOne = $false
            SuccessTwo = $false
                                   }
        $LoopCounter = 1
      }
process {

        switch ($PSBoundParameters.Keys) {

            'JoinDomain'{ #JoinDomainL for local join if can't combine both
                # perform actions if DomainJoin Param is used

#Input hostname length check here
#IF force on, don't ask if hosename too long (just exit). If no force, ask for name again.

# LOGIC to dessimate hostname and figure out correct OU path Maybe remove all old code
$HostnameString = $JoinDomain
$HostnameArray = $HostnameString.Split("-")
$Hn1 = $HostnameArray[0]
$Hn2 = $HostnameArray[1]

#write-Verbose "Here's what we have:String $HostnameString. JoinDomain = $JoinDomain. HN1 = $Hn1. HN2 = $Hn2. The Array $HostNameArray. OU1 = $ou1. OU2 = $ou2  " -verbose;pause
switch -WildCard ($HostnameArray[1])
{
 {'CART' -like $_}{Write-Verbose "LaptopCart Detected" -Verbose;pause; }
 {'LW840','LW844','NC2013','NC2207','NC2408','NC2413','NC2608','NC2609','NC2610' -contains $_}{Write-Verbose "LW8*/NC2610/LABS Detected" -Verbose;pause;} #if join fails, function hostnamefinder
 {'NC3034','NC3034D','NC3034E','NC3034K','NC3034G','NC3034K','NC3034Q' -like $_}{Write-Verbose "Deans Office" -Verbose;pause;}
 {'NC2612A','NC2612B','NC2612C','NC2612D' -like $_}{Write-Verbose "Local NC2612A detected" -Verbose;pause;}
 default {continue}
}
switch -WildCard ($HostnameArray[0])
{
 {'BIOE','CIVL','CSCI','ELEC','IWKS','MECH' -contains $_}{Write-Verbose "BIOE/CSCI/CIVL/ELEC/IWKS/MECH detected" -Verbose;pause;}
 default {Write-Error "Unknown Host!" -ErrorAction SilentlyContinue}
}
pause;pause

                Write-Host "Putting hostname $JoinDomain in AD Path ucdenver.pvt>CEAS->$ou1->$ou2." #Add Force switch. if detected, don't ask if correct (for script use) or add pipe
                if (!($PSBoundParameters.ContainsKey('Force'))){
                $JoinNow = Read-Host "If this is the correct, would you like to join now?(Y or N)" #remove from cmd line so it's fast without need for user input
                }else{$JoinNow = 'Y'}switch ($JoinNow){
                'Y'{
                
                    if (@(Get-ADComputer -Identity $JoinDomain -Server "ucdenver.pvt" -Credential $Credential -ErrorAction SilentlyContinue).Count) { #works with pasted domain join svc acct #try with svc cred w/o university for whole script. if don't work make 2 credentials
                        Write-Host "###########################################################"  
                        Write-Host "Computer object already exists in Active Directory........." # Best to exit because domain join svc acct can't join if someone else made the object in AD either ways.
                        Write-Host "###########################################################" # LOGIC split off to trying anyway (in case object WAS created by domain join svc acct.). catch the error of domain join hardening of using differ accts to create
                        #break next
                                                                                           }
                    else {
                          Write-Host "#######################################"  
                          Write-Host "Computer object NOT FOUND... Continuing"
                          Write-Host "#######################################"
                         }

                #For detected LABS
                if($ou1 -contains 'LABS'){ Write-Verbose "LABS DETECTED" -Verbose #HAVE to Test. Swap to -eq or -match if need be 

                  try{<#Invoke-command -computername $JoinDomain -scriptblock {#>Add-Computer -Credential $Credential -DomainName "ucdenver.pvt" -OUPATH "OU=$ou2,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorVariable computerError -Restart #}
                  }catch{Write-Error "`n$_"} 
                                                       }
                else{Write-Verbose "LABS NOT DETECTED!" -Verbose
                     try{Add-Computer -ComputerName $JoinDomain -DomainName "ucdenver.pvt" -Credential $Credential -OUPATH "OU=$ou1,OU=CEAS,DC=ucdenver,DC=pvt" -force  -ErrorVariable computerError #-ErrorAction SilentlyContinue
                     }catch{Write-Error "`n$_"}
                    } 
                }'N'{break next}
                }
                
                do{$RestartHost = Read-Host "Would you like to restart now?(Y or N)"
                    }while ($RestartHost -notmatch "^(N|Q|Y)$")
                    if ($RestartHost -eq 'Y'){Restart-Computer -ComputerName $JoinDomain -Credential $Credential -Force}                    
                    elseif ($RestartHost -eq 'N'){ break next}
                    elseif ($RestartHost -eq 'Q'){exit}
                    else {continue} 
                $result.SuccessOne = $true
                
            }'JoinDomainR'{

              try{
              Invoke-command -computername $JoinDomainR -Credential $Credential -scriptblock {Add-Computer -DomainName "ucdenver.pvt" -Credential $Credential -OUPATH "OU=$ou2,OU=$ou1,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorVariable computerError -Restart
              Write-Host "`n$JoinDomainR Successfully joined the domain and is restarting."    
              }
              }catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}                

            }'JoinDomainCH'{
              Write-Host "`nWhat is the first part (Department) of the OU/hostname? EX: 'XXXX'-Location-Device Code"
              $1ou = Read-Host "If this is a lab pc for a classroom (including CSCI) or for the laptop cart, type LABS"
              $2ou = Read-Host "`nWhat is the second part (Location/Room #) of the OU/hostname? EX: $1ou-'XXXXXX'-Device Code"
              DJT -JoinDomain "$JoinDomainCH" -ou1 "$1ou" -ou2 "$2ou"


            }'JoinDomainCHR'{

              Read-Host "What is the first part (Department) of the OU/hostname? EX: 'XXXX'-Location-Device Code"
              $1ou = Read-Host "If this is a lab pc for a classroom (including CSCI) or for the laptop cart, type LABS"
              $2ou = Read-Host "`nWhat is the second part (Location/Room #) of the OU/hostname? EX: $1ou-'XXXXXX'-Device Code"
              DJT -JoinDomainR "$JoinDomainCHR" -ou1 "$1ou" -ou2 "$2ou" #TEST

            }'RenameHost'{

            if ($PSBoundParameters.ContainsKey('RenameHost') -and $PSBoundParameters.ContainsKey('Remote') -and ($PSBoundParameters.ContainsKey('List'))){
              write-verbose "rename, remote, and list" -verbose
              $ListFile = $list
              if($PSBoundParameters.ContainsKey('list')-and -not $list){ #contains null key
                Write-Host "What is the filename with the list of computers to rename?"
              $ListFile = Read-Host 'File format: must be colon (:) separated with the old computer name on the left of the colon, no spaces.'  
                                                                       }
   
              [string[]]$Contents = (Get-Content ${PSScriptRoot}\$ListFile) -split ':'
              [int]$Num1 = '0'
              [int]$Num2 = '1'
              Write-Host "`nThis will also change the old name to reflet the new name in AD" 
              Foreach ($pc in Get-Content ${PSScriptRoot}\$ListFile){ #make it check both old name on left of ; and new name to rename to on right

              $OldName  = $Contents[$Num1]
              $NewName = $Contents[$Num2]

              $test = Get-ADComputer -Server "ucdenver.pvt" -filter "Name -like '*$NewName'" -Credential $Credential
              If ($test){
              Write-Host "#################################################################################################################"  
              Write-Host "Computer object $NewName already exists in AD (Or can't be used as it has no trailing #), incrementing by 1..."
              Write-Host "#################################################################################################################"
              }else {
              try{
              Rename-Computer -ComputerName $OldName -NewName $NewName -DomainCredential $Credential -Force -ErrorAction SilentlyContinue
              Write-Host "$OldName was successfully renamed to $NewName."
              }catch{ Write-Warning "Error Detected! $_"} #Later add ability to write to file: WMI/RPC server unavailable errors
              }
              $Num1++;$Num1++
              $Num2++;$Num2++
                                                                      }
              Write-Host "You should restart all the renamed PCs."
              $RestartHost = Read-Host "Would you like to restart them now?(Y or N)"
                    
              do{$RestartHost = Read-Host "Would you like to restart now?(Y or N)"
              }while ($RestartHost -notmatch "^(N|Q|Y)$")
              if ($RestartHost -eq 'Y'){
              [int]$Num1 = '0'
              Foreach ($pc in Get-Content ${PSScriptRoot}\$ListFile){
              # may not be needed as original variable still has. so just reset as below [string[]]$Contents = (Get-Content ${PSScriptRoot}\$ListFile) -split ':'

              $NewName = $Contents[$Num1]
              Restart-Computer -ComputerName $NewName -Force
              $Num1++;$Num1++
                                                                          }
              pause
              exit
              }                    
              elseif ($RestartHost -eq 'N'){ break next}
              elseif ($RestartHost -eq 'Q'){exit}
              else {continue} 
            }

            elseif (($PSBoundParameters.ContainsKey('RenameHost')) -and ($PSBoundParameters.ContainsKey('Remote'))){
              Write-Host "Rename Host and Remote";pause #TURN $RenameHost into array, check first name and last. so cmd = .\DJT.ps1 -RenmeHost "CurrentName" "NewName"
              
              if (!($RenameHost)){
                do{ 
                  $OldName = Read-Host "What is the current name of the remote host you wish to rename?"
                  $RenameHostR = Read-Host "What would you like the remote host's new name to be? (Will keep asking until 15 characters or less)"
                }while($RenameHostR.Length -gt 15)
                                          }
              else{$OldName = $RenameHost[0];$RenameHostR=$RenameHost[1]}
              if ($RenameHostR.Length -lt 16){
              try{invoke-command -ComputerName $OldName -scriptblock {Rename-Computer -NewName $using:RenameHostR -DomainCredential $using:Credential -Force}
              }catch{ Write-Warning "Error Detected! $_"}
              Write-Host = "Host was successfully renamed to $RenameHostR. You should restart for changing to take effect."
              }
              do{$RestartHost = Read-Host "Would you like to restart now?(Y or N)"
              }while ($RestartHost -notmatch "^(N|Q|Y)$")
              if ($RestartHost -eq 'Y'){Restart-Computer -ComputerName $OldName -Force} #svc-domain acct can't restart, so try without creds.                    
              elseif ($RestartHost -eq 'N'){ break next}
              elseif ($RestartHost -eq 'Q'){exit}
              else {continue}
            }
            
            elseif ($PSBoundParameters.ContainsKey('RenameHost')){
              write-verbose "Plain RenameHost Local" -verbose;pause

              if (($PSBoundParameters.ContainsKey('RenameHost')) -and (!($RenameHost))){
                [string]$RenameHost = $null
              do {$RenameHost = Read-Host "What would you like your new hostname to be? (Will keep asking until 15 characters or less)"
              }while($RenameHost.Length -gt 15)}
                while ($RenameHost.Length -lt 16){ #If came here thru cmd prompt where theres no length checking
                Rename-Computer -NewName $RenameHost -DomainCredential $Credential -Force
                "Host was successfully renamed to $RenameHost. You should restart for changing to take effect."
              do{$RestartHost = Read-Host "Would you like to restart now?(Y or N)"
              }while ($RestartHost -notmatch "^(N|Q|Y)$")
              if ($RestartHost -eq 'Y'){Restart-Computer}                    
              elseif ($RestartHost -eq 'N'){ break next}
              elseif ($RestartHost -eq 'Q'){exit}
              else {continue}                   }
                                                                }
            else{
              Write-Error “`nAn error occurred: $($_.Exception.Message)`n"
                }
                           
            }'Restart'{
              # or If cred  = 1, then.
              Credentials
              if ($CredentialFile -eq '1'){Write-Host "`nRestarting $Restart`n";Restart-Computer -ComputerName $Restart -Credential $Credential -Force;exit}
              else{Write-Host "`nRestarting $Restart`n";Restart-Computer -ComputerName $Restart -Force;exit}
                

            }'SecureChannel'{

              if ($PSBoundParameters.ContainsKey('Remote')) {
                #LOGIC to see if PS remoting is enabled, if not enables. exits to menu (break next) if host is not even pingable
                PowerShellRemoteEnabler -Server $SecureChannel[0]
                if ($global:status -eq "offline"){break next}

                try{$FirstReturnValue = Invoke-Command -ComputerName $SecureChannel[0] -ScriptBlock {Test-ComputerSecureChannel;$lastexitcode}}catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}
                                        #Invoke-Command only works once logged in as a user with rights, aka our university names. Will error if used under cladmin.
                                        #Better to keep invoke, because if local pc is having domain issues (like change hostname w/o restarting) it will still work. when broken, it only checks local pc and won't check (nor repair) remote. invoke-command bypasses this
                if ($FirstReturnValue) { # couldn't use $lastexitcode w/o adding new logic. $lastexitcode = 0/1, $FirstReturnValue = True/False
                  Write-Verbose "The secure channel between the remote computer and the domain $domain is in good condition." -Verbose
                  break next
                                       }
                                          
                elseif (!($FirstReturnValue)){
                  write-Warning "The secure channel is in bad condition/broken and needs repair."
                  Write-Host "Trying to repair 4 times before giving up (Some computers take more than one pass to repair)."
                while((!($SecondReturnValue)) -or ($LoopCounter -le 4))
                {
                    start-sleep -Seconds 2
                    $LoopCounter++
                try{$SecondReturnValue = Invoke-Command -ComputerName $SecureChannel -ScriptBlock {Test-ComputerSecureChannel -Repair;$lastexitcode}}catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}
                }
                               }
                                                            }
              else {
                  try{$FirstReturnValue = Test-ComputerSecureChannel}catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}
                  if ($FirstReturnValue) {
                    Write-Verbose "The secure channel between the local computer and the domain $domain is in good condition." -Verbose
                    break next
                                         }
                  elseif (!($FirstReturnValue)){
                    write-Warning "The secure channel is in bad condition/broken and needs repair."
                    Write-Host "Trying to repair 4 times before giving up (Some computers take more than one pass to repair)."
                    while((!($SecondReturnValue)) -or ($LoopCounter -le 4))
                      {
                        start-sleep -Seconds 2
                        $LoopCounter++
                        try{$SecondReturnValue = Test-ComputerSecureChannel -Repair -verbose}catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}
                      }
                                               }
                    }
            }'UnjoinDomain'{

              if ($PSBoundParameters.ContainsKey('UnjoinDomain') -and $PSBoundParameters.ContainsKey('Remote') -and ($PSBoundParameters.ContainsKey('List'))){
                Write-Verbose "This is with a list" -verbose
                if($PSBoundParameters.ContainsKey('list') -and -not $list){ #contains null key
                  $ListFile = Write-Host "What is the filename with the list of computers to rename?"
                  $Restart = Write-Host "Do you wish to restart the computers upon unjoining the domain as well? (Y or N)"
                  if ($Restart -eq "Y"){$Restart = '-Restart'}
                  else {$Restart = $null}
                }
                else {$ListFile = $List} 

                $UnjoinParameters = @{
                  ComputerName = (Get-Content ${PSScriptRoot}\$ListFile)
                  ScriptBlock  = {remove-computer -Force -PassThru -Verbose $Restart}
                  #ArgumentList = 'Process', 'Service'
                }
                try{Invoke-Command @UnjoinParameters}catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}
                write-host "Successfully Removed all pcs located in $ListFile."
                break next
              }

              elseif (($PSBoundParameters.ContainsKey('Remote')) -and (!($PSBoundParameters.ContainsKey('List')))){   
              $Restart = Read-Host "Do you wish to restart $UnjoinDomain upon unjoining the domain as well? (Y or N)"
              if ($Restart -eq "Y"){$Restart = '-Restart'
              try{Invoke-Command -Computer $UnjoinDomain -ArgumentList $Credential,$Restart -ScriptBlock {
                Param([PSCredential]$Cred) 
                Remove-Computer  -UnjoinDomainCredential $Cred -WorkgroupName "Ucdenver" -Force -Verbose -Restart
              }}catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}
            }
              else {$Restart = $null
                try{Invoke-Command -Computer $UnjoinDomain -ArgumentList $Credential,$Restart -ScriptBlock {
                  Param([PSCredential]$Cred) 
                  Remove-Computer  -UnjoinDomainCredential $Cred -WorkgroupName "Ucdenver" -Force -Verbose
                }}catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}
              }

              Write-Host "Host was successfully unjoined from the domain."
              $result.SuccessTwo = $true
              break next
              }

              else{# Then its local
                write-verbose "This is local" -Verbose;pause
                try{remove-computer -UnjoinDomaincredential $Credential -PassThru -Verbose
                }catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}
                try{Add-Computer -WorkgroupName "UCDenver"}catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}
  
                Write-Host "Host was successfully unjoined from the domain. You should restart for changing to take effect."
                do{$RestartHost = Read-Host "Would you like to restart now?(Y or N)"
                }while ($RestartHost -notmatch "^(N|Q|Y)$")
                $result.SuccessTwo = $true
                if ($RestartHost -eq 'Y'){Restart-Computer}
                elseif ($RestartHost -eq 'N'){break next}
                elseif ($RestartHost -eq 'Q'){exit}
                else {continue}
              }

                
            }Default{
              Write-Warning "Unhandled parameter -> [$($_)]"
                    }
        }        
    }

    end {

        #return $result

    }
}
#endregion function DJT Domain Join Tool
#endregion functions section
#region command-line parameter switches
    # Cmd line switches
switch ($PSBoundParameters.Keys) {

            #Add remote enabler possibly. But if not just make PSRE a module itself

             'JoinDomain'{ #Smaller function than above for cmd line use

                # perform actions if DomainJoin Param is used
                DJT -JoinDomain $JoinDomain -ou1 $ou1 -ou2 $ou2
                
            }'JoinDomainR'{
                try{
                Invoke-command -computername $JoinDomainR -Credential $Credential -scriptblock {Add-Computer -DomainName "ucdenver.pvt" -Credential $Credential -OUPATH "OU=$ou2,OU=$ou1,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorVariable computerError -Restart
                Write-Host "`n$JoinDomainR Successfully joined the domain and is restarting."    
                                                                                               }
                }catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}                

            }'RenameHost'{

              if ($PSBoundParameters.ContainsKey('RenameHost') -and $PSBoundParameters.ContainsKey('Remote') -and ($PSBoundParameters.ContainsKey('List'))){DJT -RenameHost $RenameHost -Remote -List $List}
              elseif (($PSBoundParameters.ContainsKey('RenameHost')) -and ($PSBoundParameters.ContainsKey('Remote'))){DJT -RenameHost $RenameHost -Remote}
              elseif ($PSBoundParameters.ContainsKey('RenameHost')){DJT -RenameHost $RenameHost}
              else{
                Write-Error “`nAn error occurred: $($_.Exception.Message)`n"
                  }
              Write-Host "Under Construction";pause

            }'Restart'{
              DJT -Restart $Restart
                
            }'SecureChannel'{ #LOGIC to send cmd prompt to DJT function.
              if ($remote -eq $true){DJT -SecureChannel $SecureChannel -Remote}
              else {DJT -SecureChannel ${hostname}}

            }'UnjoinDomain'{
              if (($PSBoundParameters.ContainsKey('Remote')) -and ($PSBoundParameters.ContainsKey('List'))){write-host "got to list";pause;DJT -UnjoinDomain $UnjoinDomain -Remote -List $List}
              elseif (($PSBoundParameters.ContainsKey('Remote')) -and (!($PSBoundParameters.ContainsKey('List')))){write-host "Got to no list";pause;DJT -UnjoinDomain $UnjoinDomain -Remote} 
              else {DJT -UnJoinDomain $UnjoinDomain}

            }Default{    
                Write-Warning "Unhandled parameter -> [$($_)]"
                     }
}
#endregion command-line parameter switches
#region non-command line script
:start do
 {
    #Clear-Host


    while ($IntroPlayed -ne "T"){Intro ; $IntroPlayed = "T"} # To speed up the graphics if having to go back to the menu.
    
    Show-Menu
    $selection = Read-Host "Please make a selection"
    :next switch ($selection)
    {'1'{
    $DEPT = 'F'
    $DEPTSelection = $null
    Show-Who-Menu
    $selection2 = Read-Host "Please make a selection"
    switch ($selection2)
    {'1'{'Faculty/Staff'
    
    Clear-Host
    Show-Dept-Menu
    do{$DEPTSelection = Read-Host "Please make a selection"} 
       while ($DEPTSelection -notmatch "^(1|2|3|4|5|6|7|8|9|10|B|Q)$")
       if ($DEPTSelection -eq '1'){$DEPT = 'BIOE';$DescLocation = 'North Classroom, Floor 2'}
       elseif ($DEPTSelection -eq '2'){$DEPT = 'CIVL';$Location = 'North Classroom, Floor 2'}
       elseif ($DEPTSelection -eq '3'){$DEPT = 'CSCI';$Location = '1380 Lawrence Street, Floor 8'}
       elseif ($DEPTSelection -eq '4'){$DEPT = 'DEAN';$Location = 'North Classroom, Floor 3'}
       elseif ($DEPTSelection -eq '5'){$DEPT = 'ECSG';$Location = 'North Classroom, Floor 2 #2612'}
       elseif ($DEPTSelection -eq '6'){$DEPT = 'ELEC';$Location = 'North Classroom, Floor 2'}
       elseif ($DEPTSelection -eq '7'){$DEPT = 'IWKS';$Location = 'Lawrence Court and UC Denver Buildings, 1250 14th St #1300'}
       elseif ($DEPTSelection -eq '8'){$DEPT = 'MECH';$Location = 'North Classroom, Floor 2'}
       elseif ($DEPTSelection -eq '9'){$DEPT = 'Test';$Location = 'Testing Location'}
       elseif ($DEPTSelection -eq 'B'){break next}
       elseif ($DEPTSelection -eq 'Q'){exit}
       else{continue}

       $selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent one?"
    switch ($selectionCHOF)
    {'C'{ 
           ${hostname} = hostname
           $hostnameLength = $hostname.length
           While ($hostnameLength -ge 16){
           Write-Host "Current hostname ($hostname) is longer than 15 characters($hostnameLength)! Exiting to main menu!"
           break next
                                         }
           
           # Check to make sure hostname starts with a dept string eg: BIOE-
           $CutLength = hostname
           $ReadOU = $CutLength.SubString(0,5)
           Write-Host "$ReadOU" #Test function
           if($DEPT -eq 'BIOE' -and $ReadOU -notmatch 'BIOE-'){Write-Host "Current hostname ($hostname) does NOT start with `"BIOE-`". Exiting!";break next}
           elseif($DEPT -eq 'CIVL' -and $ReadOU -notmatch 'CIVL-'){Write-Host "Current hostname ($hostname) does NOT start with `"CIVL-`". Exiting!";break next}
           elseif($DEPT -eq 'CSCI' -and $ReadOU -notmatch 'CSCI-'){Write-Host "Current hostname ($hostname) does NOT start with `"CSCI-`". Exiting!";break next}
           elseif($DEPT -eq 'DEAN' -and $ReadOU -notmatch 'CEDC-'){Write-Host "Current hostname ($hostname) does NOT start with `"CEDC-`". Exiting!";break next}
           elseif($DEPT -eq 'ECSG' -and $ReadOU -notmatch 'CEDC-'){Write-Host "Current hostname ($hostname) does NOT start with `"CEDC-`". Exiting!";break next}
           elseif($DEPT -eq 'ELEC' -and $ReadOU -notmatch 'ELEC-'){Write-Host "Current hostname ($hostname) does NOT start with `"ELEC-`". Exiting!";break next}
           elseif($DEPT -eq 'IWKS' -and $ReadOU -notmatch 'IWKS-'){Write-Host "Current hostname ($hostname) does NOT start with `"IWKS-`". Exiting!";break next}
           elseif($DEPT -eq 'MECH' -and $ReadOU -notmatch 'MECH-'){Write-Host "Current hostname ($hostname) does NOT start with `"MECH-`". Exiting!";break next}
           #elseif($DEPT -eq 'Test' -and $ReadOU -notmatch 'CIVL-'){Write-Host "Current hostname ($hostname) does NOT start with `"CEDC-`". Exiting!";break next}
           else{continue}

#function CheckIfHNExistsinAD
    if (@(Get-ADComputer -Server "ucdenver.pvt" -Identity ${hostname} -Credential $Credential -ErrorAction SilentlyContinue).Count) {
        Write-Host "###########################################################"  
        Write-Host "Computer object already exists in Active Directory. Exiting"
        Write-Host "###########################################################"
        break next
                                                                   }
    else {
        Write-Host "#######################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "#######################################"
 
        try{
            Add-Computer -DomainName "ucdenver.pvt"  -Credential $Credential -OUPATH "OU=$DEPT,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction Stop -ErrorVariable computerError 
            ServiceTagWriter
           }

        catch{
             Write-Warning "`nDetected errors:`n"
             Write-Error "$_"
             break start
             }
        Write-Host "Host was successfully joined to the domain. You should restart for changing to take effect."
        $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
        switch ($RestartHost){
        'Y'{Restart-Computer 
           }'N'{break next}
                             }
    pause
         }
        }'F'{ #FIND a hostname
    #Get $Location first. Read-Host
    $Location = Read-Host "What is the room number? This is the center portion of the hostname (Ex: BIOE-XXXXXXX-D1):"
    do{$OSSelection = Read-Host "What OS is this for? (W)indows, (L)inux, or (M)ac?"}
    while ($OSSelection -notmatch "^(B|L|M|Q|W)$")
    if ($OSSelection -eq 'W'){$OSFull = 'Windows'}
     elseif ($OSSelection -eq 'L'){$OSFull = 'Linux'}
     elseif ($OSSelection -eq 'M'){$OSFull = 'Mac OSX'}
     elseif ($LABSelection -eq 'B'){break next}
     elseif ($LABSelection -eq 'Q'){exit}
     else {continue}

    $CustomHost = "$DEPT-$Location-"
    $i = 1
    #redundant $serverlist = $CustomHost
    #$CustomHostInc = $CustomHost

    Do { #ADD to hostfinder function
        Write-Host "#################################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "#################################################################################################################"
        $CustomHostInc = $CustomHost + $i++ + $OS #IF don't work, turn to like to see if up to BIOE-XXXX-1 exists, if so just skip it.
       } while (Get-ADComputer -Server "ucdenver.pvt" -filter "Name -like '*$CustomHostInc'" -Credential $Credential) #test using -match instead of -like

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." #-ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Credential -Force
    start-sleep 2
    Add-Computer -ComputerName $OldComputerName -DomainName "ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Credential #-Restart
    ServiceTagWriter
    Write-Error "$computerError"

    #After joining to domain, pull service tag and set other object parameters 
    Write-Host "`nAttempting to set description information for $CustomHostInc in AD..."
    $comp = Get-ADComputer -Identity "$CUstomHostInc" -Credential $Credential

    #Add logic to ServiceTagWriter, return ST as variable
    #$ServiceTag2 = Get-CimInstance -ErrorAction Stop win32_SystemEnclosure | select-object serialnumber
    #$ST = $ServiceTag -Replace ('\W','')
    #$ST2 = $ST -Replace ('serialnumber','')
    ServiceTagWriter -PrintOnly
    write-host "Testing... Global: $global:ServiceTag. nonglobal: $ServiceTag";pause
    $ADPC = @{
                  Identity = $comp
                  Location = $Location
                  #OperatingSystem = "Winblows"
                  Description = "Service Tag: $global:ServiceTag" 
                  Credential = $Credential
             }
    Set-ADComputer @ADPC
    #ServiceTagWriter
            }
    }

    }'2'{'LABS'
        $ReadOU = "CEDC"
        $LABSelection = "F"
        Clear-Host
        Show-LABS-Menu
        
        do{$LABSelection = Read-Host "Please make a selection"} 
        while ($LABSelection -notmatch "^(1|2|3|4|5|6|7|8|9|10|B|Q)$")
        if ($LABSelection -eq '1'){$Location = 'CART'}
         elseif ($LABSelection -eq '2'){$Location = '(LW840) 1380 Lawrence Street, Floor 8, Room 840'}
         elseif ($LABSelection -eq '3'){$Location = '(LW844) 1380 Lawrence Street, Floor 8, Room 844'}
         elseif ($LABSelection -eq '4'){$Location = '(NC2013) North Classroom, Floor 2, Room 2013'}
         elseif ($LABSelection -eq '5'){$Location = '(NC2207) North Classroom, Floor 2, Room 2207'}
         elseif ($LABSelection -eq '6'){$Location = '(NC2408) North Classroom, Floor 2, Room 2408'}
         elseif ($LABSelection -eq '7'){$Location = '(NC2413) North Classroom, Floor 2, Room 2413'}
         elseif ($LABSelection -eq '8'){$Location = '(NC2608) North Classroom, Floor 2, Room 2608'}
         elseif ($LABSelection -eq '9'){$Location = '(NC2609) North Classroom, Floor 2, Room 2609'}
         elseif ($LABSelection -eq '10'){$Location = '(NC2610) North Classroom, Floor 2, Room 2610'}
         elseif ($LABSelection -eq 'B'){break next}
         elseif ($LABSelection -eq 'Q'){exit}
         else {continue}

        #$CustomHost = "CEDC-$Location-$DeviceType" Not Ready yet (DeviceType)

        $selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent one?"
    switch ($selectionCHOF)
    {'C'{ 
           $hostnameLength = $hostname.length
           While ($hostnameLength -ge 16){
           Write-Host "Current hostname ($hostname) is longer than 15 characters($hostnameLength)! Exiting to main menu!"
           break next
                                         }
           #Make sure starts with string eg CEDC-
           $CutLength = $hostname
           $ReadOU = $CutLength.SubString(0,5)


           if(($Location -eq 'LW840') -or ($Location -eq 'LW844') -and ($ReadOU -notmatch 'CSCI-'))
           {
           Write-Host "Current hostname ($hostname) does NOT start with `"CSCI-`". Exiting!";pause
           }

           elseif($ReadOU -notmatch 'CEDC-')
           {
           Write-Host "Current hostname ($hostname) does NOT start with `"CEDC-`". Exiting!";pause
           break next
           }
    if (@(Get-ADComputer -Server "ucdenver.pvt" -Identity ${hostname} -Credential $Credential -ErrorAction SilentlyContinue).Count) {
        Write-Host "###########################################################"  
        Write-Host "Computer object already exists in Active Directory. Exiting"
        Write-Host "###########################################################"
        break next
                                                                   }
    else {
        Write-Host "#######################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "#######################################"


        try{
            Add-Computer -DomainName "ucdenver.pvt"  -Credential $Credential -OUPATH "OU=$Location,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction Stop -ErrorVariable computerError
            ServiceTagWriter -PrintOnly
            $comp = Get-ADComputer -Identity "${hostname}" -Credential $Credential
            $ADPC = @{
                  Identity = $comp
                  Location = $Location
                  #OperatingSystem = "Winblows"
                  Description = "Service Tag: $global:ServiceTag" 
                  Credential = $Credential
             }
    Set-ADComputer @ADPC
           }

        catch{
             Write-Host "`nDetected errors:`n"
             Write-Host "$_"
             break start
             }
        Write-Host "Host was successfully joined to the domain. You should restart for changing to take effect."
        $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
        switch ($RestartHost){
        'Y'{Restart-Computer 
           }'N'{break next}
                             }
    pause
         }
        }'F'{
    $Location = Read-Host "What is the room number? This is the center portion of the hostname (Ex: BIOE-XXXXXXX-D1):"
    $OS = Read-Host "What OS is this for? (W)indows, (L)inux, or (M)ac?" 
    $CustomHost = "$DEPT-$Location-"
    $i = 1
    #$serverlist = $CustomHost
    #$CustomHostInc = $CustomHost

    Do {
        Write-Host "#################################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "#################################################################################################################"
        $CustomHostInc = $CustomHost + $i++ + $OS
       } while (Get-ADComputer -Server "ucdenver.pvt" -filter "Name -like '*$CustomHostInc'" -Credential $Credential)

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." #-ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Credential -Force
    start-sleep 2
    Add-Computer -ComputerName $OldComputerName -DomainName "ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Credential #-Restart
    ServiceTagWriter
    Write-Error "$computerError"
    pause
            }
    }
    }'3'{'Server' #Finish Server Portion. Command line automatically recognizes all the OU's (if $ou4 !null) as server (LOGIC)
         Show-Server-Dept-Menu #Make sure this menu needs to be different than the faculty/staff dept menu.
         do{$ServerDeptSelection = Read-Host "Please make a selection"} 
         while ($ServerDeptSelection -notmatch "^(1|2|3|4|5|6|7|8|B|Q)$")
         if ($ServerDeptSelection -eq '1'){$ServerDept = 'BIOE'}
          elseif ($ServerDeptSelection -eq '2'){$ServerDept = 'CIVL'}
          elseif ($ServerDeptSelection -eq '3'){$ServerDept = 'CSCI'}
          elseif ($ServerDeptSelection -eq '4'){$ServerDept = 'DEAN'}
          elseif ($ServerDeptSelection -eq '5'){$ServerDept = 'ECSG'}
          elseif ($ServerDeptSelection -eq '6'){$ServerDept = 'ELEC'}
          elseif ($ServerDeptSelection -eq '7'){$ServerDept = 'MECH'}
          elseif ($ServerDeptSelection -eq '8'){$ServerDept = 'Test'}
          elseif ($ServerDeptSelection -eq 'B'){break next}
          elseif ($ServerDeptSelection -eq 'Q'){exit}
          else {continue}

          #Clear-Host
          Show-Server-Category-Menu
          #do {$ServerCategory = Read-Host "What is the purpose of this server? (A)dministration, (I)nstructional, or (R)esearch?"}
          do {$ServerCategorySelection = Read-Host "Please Make a selection"}
          while ($ServerCategorySelection -notmatch "^(1|2|3|B|Q)$")
          if ($ServerCategorySelection -eq '1'){$ServerCategory = 'BIOE'}
          elseif ($ServerCategorySelection -eq '2'){$ServerCategory = 'CIVL'}
          elseif ($ServerCategorySelection -eq '3'){$ServerCategory = 'CSCI'}
          elseif ($ServerCategorySelection -eq 'B'){break next}
          elseif ($ServerCategorySelection -eq 'Q'){exit}
          else {continue}

         clear-Host
         Show-Server-Purpose-Menu
         $ServerPurposeSelection = Read-Host "Please make a selection"
         do {$ServerPurposeSelection = Read-Host "Please Make a selection"}
         while ($ServerPurposeSelection -notmatch "^(1|2|3|4|5|6|7|B|Q)$")
         if ($ServerPurposeSelection -eq '1'){$ServerCategory = 'APP'}
          elseif ($ServerPurposeSelection -eq '2'){$ServerPurpose = 'DATA'}
          elseif ($ServerPurposeSelection -eq '3'){$ServerPurpose = 'DB'}
          elseif ($ServerPurposeSelection -eq '4'){$ServerPurpose = 'FILE'}
          elseif ($ServerPurposeSelection -eq '5'){$ServerPurpose = 'FOG'}
          elseif ($ServerPurposeSelection -eq '6'){$ServerPurpose = 'LIC'}
          elseif ($ServerPurposeSelection -eq '7'){$ServerPurpose = 'PRNT'}
          elseif ($ServerPurposeSelection -eq '8'){$ServerPurpose = 'WWW'}
          elseif ($ServerPurposeSelection -eq 'B'){break next}
          elseif ($ServerPurposeSelection -eq 'Q'){exit}
          else {continue}

         do {$ServerVorPSelection = Read-Host "Lastly, is this server (P)hysical or (V)irtual?"}
         while($ServerVorPSelection -notmatch "^(P|V|B|Q)$")
         if ($ServerVorPSelection -eq 'P'){$ServerVorP = 'P'}
          elseif ($ServerVorPSelection -eq 'V'){$ServerVorP = 'V'}
          elseif ($ServerVorPSelection -eq 'B'){break next}
          elseif ($ServerVorPSelection -eq 'Q'){exit}
          else {continue}

    $CustomServerHost = "$ServerDept-$ServerCategory-$ServerPurpose-" # add $ServerVorP after end of number incrementing
    $i = 1

    Clear-Host
    Write-Host "Attempting to find an unused hostname and join to the domain..."
    Do {
        Write-Host "#################################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "#################################################################################################################"
        $CustomHostInc = $CustomServerHost + $i++ + $ServerVOrP
       } while (Get-ADComputer -Server "ucdenver.pvt" -filter "Name -like '*$CustomHostInc'" -Credential $Credential) #test -match instead of -like. If ussues add @ .count method.

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." #-ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Credential -Force
    start-sleep 2
    Add-Computer -ComputerName $OldComputerName -DomainName "ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Credential #-Restart
    ServiceTagWriter
    Write-Error "$computerError"
    pause
    }'B'{break next}'Q'{exit}
    }
    }'2'{Write-Host "You chose option #2: Unjoin the domain."

        do{$RorL = Read-Host "Is this for the (L)ocal PC, a (R)emote PC, or a list of (C)omputers?"}
         while ($RorL -notmatch "^(B|C|L|R|Q)$")
         If ($RorL -eq 'L'){DJT -UnjoinDomain ${hostname}}
         elseif ($RorL -eq 'R'){$UnjoinDomainHost = Read-Host "What is the hostname of the Remote PC?";DJT -UnjoinDomain $UnjoinDomainHost -Remote}
         elseif ($RorL -eq 'C'){$Listfile = Read-Host "What is the name of the listfile with computers? Please add the extension. Ex: computers.txt";DJT -UnjoinDomain $null -Remote -List $Listfile}
         elseif ($RorL -eq 'B'){break next}
         elseif ($RorL -eq 'Q'){exit}
         else {continue}

    }'3'{'You chose option #3: Rename hostname(s)'

         #LOGIC for local or remote
         do{$LocalOrRemote = Read-Host "Do you wish to rename the (L)ocalhost, (R)emote host, or a list of remote (C)omputers?"} #may change if can find better wording to give (L) to listfile
         while ($LocalOrRemote -notmatch "^(B|C|L|Q|R)$")
         if ($LocalOrRemote -eq 'L'){DJT -RenameHost $null}                    
         elseif ($LocalOrRemote -eq 'R'){DJT -RenameHost $null -Remote}
         elseif ($LocalOrRemote -eq 'C'){DJT -RenameHost $null -Remote -List $null} #logic that if press enter when asking for listfile, default computers.txt
         elseif ($LocalOrRemote -eq 'B'){break next}
         elseif ($LocalOrRemote -eq 'Q'){exit}
         else {continue}
    }'4'{'write the Service Tag to the AD object.'
          ServiceTagWriter
         
    }'5'{'You chose option #5: Join the domain using the current hostname.'
         #LOGIC for local or remote
         do{$LocalOrRemote = Read-Host "Do you wish to join the domain of the (L)ocalhost or a (R)emote host?"}
         while ($LocalOrRemote -notmatch "^(B|L|Q|R)$")
         if ($LocalOrRemote -eq 'L'){DJT -JoinDomain $hostname}
         elseif ($LocalOrRemote -eq 'R'){DJT -JoinDomain $hostname -Remote} #will need to know where to go. check joindomainCH and CHR
         elseif ($LocalOrRemote -eq 'B'){break next}
         elseif ($LocalOrRemote -eq 'Q'){exit}
         else {continue}
    }'6'{'Domain Trust Relationship Fix'
         do{$RorL = Read-Host "Is this for the (L)ocal PC or a (R)emote PC?"}
         while ($RorL -notmatch "^(B|L|R|Q)$")
         If ($RorL -eq 'L'){DJT -SecureChannel ${hostname}}
         elseif ($RorL -eq 'R'){$SecureChannelRemote = Read-Host "What is the hostname of the Remote PC?";DJT -SecureChannel $SecureChannelRemote -Remote}
         elseif ($RorL -eq 'B'){break next}
         elseif ($RorL -eq 'Q'){exit}
         else {continue}
    }'7'{ 'Enable PS Remote Services (WinRM/WSMan)'
         $PSREServer = read-host "What is the hostname you would like to enable PS Remoting services on? If it`'s the PC you are on type localhost"
         PowerShellRemoteEnabler -Server $PSREServer
         break next
    }'Q'{exit}
     Default {
        Write-Warning "No matches"
             }
    }
    pause
 }until ($selection -eq 'q')
#endregion non-command line script
