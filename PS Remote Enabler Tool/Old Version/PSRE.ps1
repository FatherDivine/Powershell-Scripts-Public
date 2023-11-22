<#
  .SYNOPSIS
    Enable PS-Remoting remotely.

  .DESCRIPTION
    The PSRE.ps1 script allows the user to enable PS-Remoting on a list 
    of remote computers. It takes input from a file called "computers.txt"
    and runs an enable PS-Remoting command thru PSExec.exe, Both files 
    are in the same folder as the PSRE.ps1 script, and must be to work.

  .LINK
    \\DATA\DEPT\CEAS\ITS\Software\Scripts\PS Remote Enabler Tool
  
  .INPUTS
    None. You cannot pipe objects to PSRE.ps1 at this time

  .OUTPUTS
    None. PSRE.ps1 does not generate any output, though I would love to
    save offline pcs to file. But given how the method works, more work
    must be done to achieve this.

  .EXAMPLE
    PS> .\PSRE.ps1

  .Author
    Created by Aaron S. for CU Denver CEDC IT Dept

  .Notes
    Add the command to enable PS script execution on all listed PCs too. 2 birds with one stone! (Execution policy: powershell -NoProfile -ExecutionPolicy Bypass)
    Also add the catch back (using finding exceptions for catch.ps1      
 #>
Param
       (
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$true)]
       [string]$Server="$NULL",
       $errorlog
       )  
if ($PSBoundParameters.ContainsKey('Server'))
{
 & ${PSScriptRoot}\PsExec.exe \\$Server -accepteula  -h -s powershell.exe Enable-PSRemoting -Force
 exit
}

else{
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
Clear-Host;Intro
Write-Host "`nPlease specify the name of a file located in the same folder as this script."
$Answer = Read-Host "If no name is specified, will default to ${PSScriptRoot}\computers.txt"
if (!$Answer){$Answer = "${PSScriptRoot}\computers.txt"}
Write-Host "Going thru ${PSScriptRoot}\computers.txt..."
$wks = Get-Content ${PSScriptRoot}\$Answer

foreach($ws in $wks){
    #try{
    & ${PSScriptRoot}\PsExec.exe \\$ws -accepteula  -h -s powershell.exe Enable-PSRemoting -Force
    #   }
    #catch{
    #      Write-Host "Error with $ws! Probably offline. Writing to file!"
    #      "ws" | Out-File -FilePath ${PSScriptRoot}\OfflinePCs.txt -Append  
    #     }
        
                    }
pause
}