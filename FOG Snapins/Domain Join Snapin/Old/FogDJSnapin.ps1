# First make sure PS is running elevated/as admin. HAS to be ran as elevated
# Check if FOG can run elevated, or else may have to do scheduled task via cladmin (to bypass UAC).
# or use UAC disabler but must be system: https://scripts.itarian.com/frontend/web/topic/powershell-script-to-enable-and-disable-user-access-control-uac
# run this on all pcs prior -> Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0
<#
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}
#>
# Fog Snap-in to be ran on the local PC to join. 
# This was created to overcome the issue of computers that are NOT on the university are unreachable (can't ping nor send PS commands)
# So we run this script on each computer as a FOG snap-in to automatically join to the domain after imaging, 
# while also tagging the Pc's Service Tag in it's AD object description
# Last thing to add is the domain svc acct credentials. Test if it gives padding error or not. IF so fix DJT.ps1 creds first which will fix these.

function Credentials{

#if ((Test-Path ${PSScriptRoot}\Key.xml -ErrorAction SilentlyContinue) -and (Test-Path ${PSScriptRoot}\Cred.xml -ErrorAction SilentlyContinue))
#{
 #$key = Import-Clixml -LiteralPath ${PSScriptRoot}\Key.xml
 #$importObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml
 #$secureString = ConvertTo-SecureString -String $importObject.Password -Key $key
 #$global:Credential = New-Object System.Management.Automation.PSCredential($importObject.UserName, $secureString)
 $global:Credential = New-Object System.Management.Automation.PSCredential('UNIVERSITY\svc-cedc-domainjoin', 'VRU9WeoKqJOWE2O')
 <#
 last error. ONLY WAY PAST IS TO RERUN XML CREDENTIALS AND PUT SAME USER/PASS IN FOR SVC ACCT.. see if works on cedc-pc test z1 under desk now. if not, redo XML
 ConvertTo-SecureString : Padding is invalid and cannot be removed.
At \\data\dept\CEAS\ITS\Software\Scripts\FOG Domain Join Snapin\FogDJSnapin.ps1:22 char:18
+ ... ureString = ConvertTo-SecureString -String $importObject.Password -Ke ...
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (:) [ConvertTo-SecureString], CryptographicException
    + FullyQualifiedErrorId : ImportSecureString_InvalidArgument_CryptographicError,Microsoft.PowerShell.Commands.ConvertToSecureStringCommand
 
New-Object : Exception calling ".ctor" with "2" argument(s): "Cannot process argument because the value of argument "password" is null. Change the value of argument 
"password" to a non-null value."
At \\data\dept\CEAS\ITS\Software\Scripts\FOG Domain Join Snapin\FogDJSnapin.ps1:23 char:23
+ ... redential = New-Object System.Management.Automation.PSCredential($imp ...
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (:) [New-Object], MethodInvocationException
    + FullyQualifiedErrorId : ConstructorInvokedThrowException,Microsoft.PowerShell.Commands.NewObjectCommand

 #>
#}
}
Credentials

# LOGIC to dessimate hostname and figure out correct OU path

$hn = $env:computername

# LOGIC to pull service tag, sanitize it, and add to description in AD

$ServiceTag = Get-CimInstance -ErrorAction Stop win32_SystemEnclosure | Select-Object serialnumber
$ST = $ServiceTag -Replace ('\W','')
$ST2 = $ST -Replace ('serialnumber','')
#Write-Host "$hn`: $ST2`n"

# Add PC to AD in correct OU
Add-Computer -DomainName "ucdenver.pvt" -OUPATH "OU=NC2413,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -Force -Credential $Credential -Verbose

#Tag the AD PC Object with its Service Tag
Set-ADObject -Identity 'CN=CEDC-NC2413-C5,OU=NC2413,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt' -Description "Service Tag: $ST2" -Credential $Credential -Verbose