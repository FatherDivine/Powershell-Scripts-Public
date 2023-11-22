# Domain Trust Fix Tool
# Fixes the domain trust relationship locally.
# Used when logging into windows with university account
# and get an error like: "The trust relationship between 
# this workstation and the primary domain failed." 
# 
# Will add ability to do a list of computers soon.
# And of course, command-line parameter use.

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break

  maybe a function with this: Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}
$global:CredentialFile = $NULL       
if ((Test-Path ${PSScriptRoot}\Key.xml -ErrorAction SilentlyContinue) -and (Test-Path ${PSScriptRoot}\Cred.xml -ErrorAction SilentlyContinue))
{
 $key = Import-Clixml -LiteralPath ${PSScriptRoot}\Key.xml
 $importObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml
 $secureString = ConvertTo-SecureString -String $importObject.Password -Key $key
 $global:Credential = New-Object System.Management.Automation.PSCredential($importObject.UserName, $secureString)
 $global:UserName = $Credential.UserName;$UserName = $Credential.UserName
 $global:Password = $Credential.GetNetworkCredential().Password;$Password = $Credential.GetNetworkCredential().Password
 $global:CredentialFile = '1';$CredentialFile = '1'           # First is for the entire script, second is for PARAM/command-line use
}
else{
Write-Warning "`nCredential File (Key.xml and Cred.xml) NOT detected. You will have to enter them manually`n"
$global:Credential = Get-Credential}

do{$LOrR = Read-Host "Is this for a (L)ocal PC or a (R)emote PC?"
  }while($LorR -notmatch "^(L|R|Q)$")
    if ($LorR -eq 'L'){
                       $FirstReturnValue = Test-ComputerSecureChannel -verbose ;pause
                       if (!($FirstReturnValue)) {
                       do {Write-Host "Trying to repair infinitely until success (Some computers take more than one pass to repair)."
                           $SecondReturnValue = Test-ComputerSecureChannel -Repair -Credential $Credential -verbose
                          }while(!($SecondReturnValue))
                                                 }
                       else {exit}
                       }
       elseif ($LorR -eq 'R'){            # TEST new LOGIC if return works
                              $hn = Read-Host "What is the hostname of the Remote PC?"
                              $FirstReturnValue = Invoke-command -computername $hn -scriptblock {Test-ComputerSecureChannel -verbose}
                              pause
                              if (!($FirstReturnValue)) { 

                              <#If Possible, split this if with one that can detect the below (which means PS Remote services aren't enabled (PSRE.ps1)
                              Without such detection, if PS is disabled it will keep trying to repair
                              [cedc-nc2413-b1] Connecting to remote server cedc-nc2413-b1 failed with the following error message : The client
                              cannot connect to the destination specified in the request. Verify that the service on the destination is running and
                              is accepting requests. Consult the logs and documentation for the WS-Management service running on the destination,
                              most commonly IIS or WinRM. If the destination is the WinRM service, run the following command on the destination to
                              analyze and configure the WinRM service: "winrm quickconfig". For more information, see the
                              about_Remote_Troubleshooting Help topic.
                              + CategoryInfo          : OpenError: (cedc-nc2413-b1:String) [], PSRemotingTransportException  <--- see if can if statement off this
                              + FullyQualifiedErrorId : CannotConnect,PSSessionStateBroken#>
                              do {Write-Host "Trying to repair infinitely until success (Some computers take more than one pass to repair)."
                                  $SecondReturnValue = Invoke-command -computername $hn -scriptblock {Test-ComputerSecureChannel -Repair -Credential $Credential -verbose}
                                 }while(!($SecondReturnValue))
                                                        }
                              else {Write-Host "Success";exit}       
                             }
       elseif ($LorR -eq 'Q'){exit}
pause
