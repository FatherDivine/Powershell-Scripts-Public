#region help information
<#
  .SYNOPSIS
    Joins pneumotach to the domain.

  .DESCRIPTION
    The pneumotach.ps1 script joins hostname "pneumotach" to the
    domain. Meant to be run from the computer named "pneumotach" itself,
    this script will also pull the Service Tag & add it to it's
    own AD computer object as well.
  
  .INPUTS
    None. You cannot pipe objects to pneumotach.ps1.

  .OUTPUTS
    None. pneumotach.ps1 does not generate any output.

  .EXAMPLE
    PS> .\pneumotach.ps1
      
      Description
      -----------
      Runs the script in normal, non-command line use.    

  .EXAMPLE       
    PS> .\RUN ME-StartScript.bat
      
      Description
      -----------
      The best way to run the script. The batch will
      make sure the PS script can run (as by default
      for security reasons, most PCs disable PS 
      scripts from running).

  .AUTHOR
    Created by Aaron S. for CU Denver CEDC IT Dept
 #>
#endregion help information

#region disabled get admin privileges
#Get admin privileges.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break

  maybe a function with this: Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}
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
$OldComputerName = $global:hostname        # Using to keep track of old PC name
${hostname} = get-content env:computername
#endregion variables

#region functions section
#region function credentials
# Functions section
function Credentials{
try{
$key = Import-Clixml -LiteralPath ${PSScriptRoot}\Data.xml
  $importObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml
  $secureString = ConvertTo-SecureString -String $importObject.Password -Key $key
  $global:Credential = New-Object System.Management.Automation.PSCredential($importObject.UserName, $secureString)
  }catch{Write-Error "`nAn error occured: $($_.Exception.Message)`n"}   
  }

Credentials
#region function ServiceTagWriter
function ServiceTagWriter
{

# Variables
$hn = $env:COMPUTERNAME

# LOGIC to pull service tag, sanitize it, and add to description in AD
$ServiceTag = Get-CimInstance -ErrorAction Stop win32_SystemEnclosure | select-object serialnumber
$ST = $ServiceTag -Replace ('\W','')
$ST2 = $ST -Replace ('serialnumber','')
Remove-Variable ServiceTag 
$global:ServiceTag = $ST2
Write-Host "`nService Tag of ${hostname}: $global:ServiceTag`n"
Set-ADObject -Identity "CN=$hn,OU=BIOE,OU=CEAS,DC=ucdenver,DC=pvt" -Description "Service Tag: $ST2" -Credential $Credential -Server "ucdenver.pvt" -Verbose
}

function Intro
{
$t = @"
_______ _                                                             
|__   __| |                                                            
   | |  | |__   ___                                                    
   | |  | `'_ \ / _ \                                                   
   | |  | | | |  __/                    _             _                
   |_|  |_| |_|\___|                   | |           | |               
 _ __  _ __   ___ _   _ _ __ ___   ___ | |_ __ _  ___| |__             
| `'_ \| `'_ \ / _ \ | | | `'_ `` _ \ / _ \| __/ _`` |/ __| `'_ \            
| |_) | | | |  __/ |_| | | | | | | (_) | || (_| | (__| | | |           
| .__/|_| |_|\___|\__,_|_| |_| |_|\___/ \__\__,_|\___|_| |_|           
| |                                                                    
|_|                                                                    
 _____                        _              _       _                 
|  __ \                      (_)            | |     (_)                
| |  | | ___  _ __ ___   __ _ _ _ __        | | ___  _ _ __   ___ _ __ 
| |  | |/ _ \| `'_ `` _ \ / _`` | | `'_ \   _   | |/ _ \| | `'_ \ / _ \ `'__|
| |__| | (_) | | | | | | (_| | | | | | | |__| | (_) | | | | |  __/ |   
|_____/ \___/|_| |_| |_|\__,_|_|_| |_|  \____/ \___/|_|_| |_|\___|_|   
  _____           _       _                                            
 / ____|         (_)     | |                                           
| (___   ___ _ __ _ _ __ | |_                                          
 \___ \ / __| `'__| | `'_ \| __|                                         
 ____) | (__| |  | | |_) | |_                                          
|_____/ \___|_|  |_| .__/ \__|                                         
                   | |                                                 
                   |_|                                                 
                                                                                                                                                
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

Intro
Write-Host "`nChecking if the name of this PC is 'pneumotach' before joining."
#Logic if name != "pneumotach", rename first. possibly reboot
if (${hostname} -ne 'pneumotach' ){
  write-host "`nHostname is NOT pneumotach! Renaming the PC & Rebooting so changes take affect!`n"
  write-host "`nPlease re-run this script after reboot!`n"
  Start-Sleep 5
  Rename-Computer -NewName "pneumotach" -DomainCredential $Credential -Restart
}
else{
Write-Host "`nComputer name is already set to pneumotach. Attempting to add to the domain..."
Start-Sleep 4

try{Add-Computer -DomainName "ucdenver.pvt" -Credential $Credential -OUPATH "OU=BIOE,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorVariable computerError -ErrorAction SilentlyContinue
}catch{Write-Error "`nAn error occured: $($_.Exception.Message)`n"}

Write-Host "`nComputer was successfully joined to the domain."
Write-Host "`nWriting the Service Tag to the Active Directory Computer Object..."
ServiceTagWriter
Write-Host "Restarting the PC in 5 seconds"
Start-Sleep 5
Restart-Computer -Force
}
exit