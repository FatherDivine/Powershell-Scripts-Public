#region help information
<#l
  .SYNOPSIS
    Enable PS-Remoting (WinRM) and Sets PS execution policy to bypass so PS scripts/tools can run. 

  .DESCRIPTION
    The PSRE.ps1 script allows the user to enable PS-Remoting & Execution Policy
    bypass on a list of remote computers. It takes input from a file called 
    "computers.txt" and runs an enable PS-Remoting command thru PSExec.exe, 
    Both files are in the same folder as the PSRE.ps1 script, and must be to work.

  .PARAMETER Server
    Allows to pipe a hostname/IP address to the Enable PS Remoting command
    via the command prompt/PS. Specifically used by the Dell Service Tag 
    Puller Tool (DSTP.ps1) to enable PS Remoting before the second attempt
    at pulling the service tag remotely.
  .PAREMETER ServerList
    Allows to pipe the filename of a list of computers to have PS Enabler
    run on. Can set  folder by specifying "Folder\File.txt" as the answer.

  #.LINK
    
  
  .INPUTS
    A -Server flag can be piped into PSRE.ps1 (or any other script). Here's an example:
    
    .\PSRE.ps1 -Server "$Hostname here"
    
    And in the case of inside another script:
    & ${PSScriptRoot}\PSRE.ps1 -Server Host-Name-Here
    
    Once that input is detected by PSRE.ps1, the Enable-PSRemoting
    command is launched using PsExec.exe and the piped $Server.

    A -ServerList flag can be piped into PSRE.ps1 as well. Here's an example:

    .\PSRE.ps1 -ServerList "Folder\computerlist.txt"

    And in the case of accessing inside another script:
    & ${PSScriptRoot}\PSRE.ps1 -ServerList "computers.txt"

  .OUTPUTS
    None. But PSRE.ps1 may one day output to ${PSScriptRoot}\OfflinePCs.txt
    to record PCs not online. More work has to be done on a method that can
    achieve this.

  .EXAMPLE
    PS> .\PSRE.ps1

  .Author
    Created by Aaron S. for CU Denver CEDC IT Dept

  .To-do
    Also add the catch back (using finding exceptions for catch.ps1
    If policy bypass don't work, try all of these in this order:
    powershell "Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force"
    powershell "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force"
    powershell "Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force"
    If issues with bypass, can use 'Get-ExecutionPolicy -List' to see and select new scope.

    WinRM can be enabled using RDP, psexec, or GPO.
    function PowerShellRemoteEnabler()
{
[cmdletbinding()]
Param 
         (
         [Parameter(Mandatory=$false,
         ValueFromPipeline=$false)]
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
 #>
#endregion help information
#region command-line parameters
                                        # This first Param statement allows to use pipeline -Server from command line. ex: .\PSRE.ps1 -Server "hostname"
Param
       ([cmdletbinding()]
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [string]$Server=$NULL,
       $errorlog,

       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
        [string]$ServerList=$NULL,
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
        [string]$Status=$NULL
       )
#endregion command-line parameters    

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

Write-Verbose "Downloading the latest version of Logging-Functions via Github if non-existant" -Verbose
If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Logging-Functions")){  
Write-Verbose 'Downloading the latest Logging-Functions module and placing in C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\' -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psm1' -Force)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psd1' -Force)
}


#Create the Log folder if non-existant
If (!(Test-Path "C:\Windows\Logs\QuickFix")){New-Item -ItemType Directory "C:\Windows\Logs\Quickfix\" -Force}

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "0.1"

#-----------------------------------------------------------[Functions]------------------------------------------------------------
#region functions

#region function PSRemoteStatus
function PSRemoteStatus{

[CmdletBinding()]
    Param (
        # Grabs remote hostname for use in function
        [Parameter(Mandatory=$false,
        ValueFromPipeline=$true)]
        [string]$HN,
        $errorlog
        
    )

    begin {
            #setup our return object
            $status = $null
          }
    process{ #first test if connection is alive with test, then exit? this part isn't right. cant tell if services are enabled, test connection can only see if reachable or not. 
            write-host "`nFirst checking if the host can be reached..."
            if (Test-Connection -ComputerName $HN -Quiet) {
                if([bool](Test-WsMan $HN -ErrorAction SilentlyContinue)){
                    $global:status = "true"
                    #redundant (hopefully) $global:status
                    Write-Host "PS Remote Services are already ENABLED for $HN! Exiting."
                    continue
                }elseif(![bool](Test-WSMan $HN -ErrorAction SilentlyContinue)){
                    $global:status = "false"
                    #redundant (hopefully) $global:status
                    Write-Host "`nPS Remote Services are DISABLED for $HN!`n"
                                                                              }
                                                          }
            elseif (!(Test-Connection -ComputerName $HN -Quiet)){
            $global:status = "offline"
            #$global:status
            Write-Host "`n"
            Write-Warning "$HN was NOT reachable! It is probably powered off!!`n" -ErrorAction Continue} #;exit
           }
    end{
       }
}
#endregion function PSRemoteStatus
#region function PSRemote
function Enable-PSRemote{
    <#
        .Synopsis
            Does 2 things: enable powershell remoting rervices & unrestrict PS remote execution policy.
        .Description
            Enables Powershell Remoting Services on remote windows-based clients so things like pulling the service tag is possible.
            Also enables pwsh execution policy so scripts can run easier.
        .Example
            Enable-PSRemote -ServerList $Answer
            Enable-PSRemote -Server $HostPC
            .\PSRE.ps1 -Server "CEDC-NC2413-A1"
            .\PSRE.ps1 -ServerList computers.txt
        .Notes
    #>
    [cmdletbinding()]
    Param
       (
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$true)]
       [string]$Server=$NULL,
       $errorlog,
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$true)]
        [string]$ServerList=$NULL
       )
    begin {

      Get-Credentials
      #Setup our return object
      $result = [PSCustomObject]@{

        SuccessOne = $false
        SuccessTwo = $false
      }        
    }
    process { 
      #use a switch statement to take actions based on passed in parameters
      switch ($PSBoundParameters.Keys) {
        'Server' {
                                        #perform logic if Server parameter is used.
          PSRemoteStatus -HN $Server
          $CredentialFile = '0'
          if ($global:status -eq "true"){exit}
          elseif ($global:status -eq "false") {
          If ($CredentialFile -eq '1'){try{& ${PSScriptRoot}\PsExec.exe \\$Server -accepteula  -u $username -p $password -h -s powershell.exe Enable-PSRemoting -Force;Invoke-command -computername $Server -Credential $Credential -scriptblock {Set-ExecutionPolicy bypass -force}}catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n”}}
          else {try{& ${PSScriptRoot}\PsExec.exe \\$Server -accepteula -h -s powershell.exe Enable-PSRemoting -Force;Invoke-command -computername $Server -scriptblock {Set-ExecutionPolicy bypass -force}}catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n"}}
          $global:status = "true"
          $result.SuccessOne = $true; exit}
          else { Write-Warning "Unhandled parameter -> $_";pause}
        }

        'ServerList' {
          #perform logic if ServerList parameter is used
          if ($CredentialFile -eq '1'){
            try{
              $wks = Get-Content "$ServerList"
              foreach($ws in $wks){PSRemoteStatus -HN $ws
              if ($global:status -eq "true"){exit}
              elseif ($global:status -eq "false"){
              & ${PSScriptRoot}\PsExec.exe \\$ws -accepteula  -u $username -p $password -h -s powershell.exe Enable-PSRemoting -Force  
              Invoke-command -computername $ws -Credential $Credential -scriptblock {Set-ExecutionPolicy bypass -force}
                                                                 }
                                        } 
            }catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n”}}
          else{
            try{
              $wks = Get-Content "$ServerList"
              foreach($ws in $wks){PSRemoteStatus -HN $ws
              if ($global:status -eq "true"){exit}
              elseif ($global:status -eq "false"){
              & ${PSScriptRoot}\PsExec.exe \\$ws -accepteula -h -s powershell.exe Enable-PSRemoting -Force
              Invoke-command -computername $ws -scriptblock {Set-ExecutionPolicy bypass -force}
              }
              }
    }catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n”}}
exit         
                         }   
            Default {
                
                Write-Warning "Unhandled parameter -> [$($_)]"
                    }
                                         }        
            }
    end {

        #return $result
         }
                               }
#endregion function PSRemote
#region function Intro ASCII
function Intro
{
$t = @'
  _______ _
 |__   __| |
    | |  | |__   ___
    | |  | '_ \ / _ \
    | |  | | | |  __/
    |_|  |_| |_|\___|
  _____   _____   _____                      _
 |  __ \ / ____| |  __ \                    | |
 | |__) | (___   | |__) |___ _ __ ___   ___ | |_ ___
 |  ___/ \___ \  |  _  // _ \ '_ ` _ \ / _ \| __/ _ \
 | |     ____) | | | \ \  __/ | | | | | (_) | ||  __/
 |_|    |_____/  |_|  \_\___|_| |_| |_|\___/ \__\___|
  ______             _     _             _______          _ 
 |  ____|           | |   | |           |__   __|        | |
 | |__   _ __   __ _| |__ | | ___ _ __     | | ___   ___ | |
 |  __| | '_ \ / _` | '_ \| |/ _ \ '__|    | |/ _ \ / _ \| |
 | |____| | | | (_| | |_) | |  __/ |       | | (_) | (_) | |
 |______|_| |_|\__,_|_.__/|_|\___|_|       |_|\___/ \___/|_|

'@

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

# Return a value 0-3 or so, 0 = was off and turned on, 1 = already was on, 2 = error (or maybe just throw for first time)