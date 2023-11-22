 <#
        .SYNOPSIS
           Tool to fix Global Protect VPN issues..
        
        .DESCRIPTION
            Created by Aaron S. on 5-23-23 in response to an e-mail from Jeffrey Selman (CU Denver) about his GlobalProtect VPN issues.     
           
        .Link
            \\data\dept\CEAS\ITS\Software\Scripts\Global Protect Fixer
        
         .OUTPUTS
            None
        
        .NOTES
            Nothing yet.
 #>

#Get admin privileges to be able to manipulate windows services.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}


#Because, ASCII Rawks!
function Intro
{
$t = @"
___                                            
 |  |_   _                                     
 |  | ) (-                                     
 __                     __                     
/ _  |  _  |_   _  |   |__)  _  _  |_  _  _ |_ 
\__) | (_) |_) (_| |   |    |  (_) |_ (- (_ |_ 
 __              ___                           
|_  .     _  _    |   _   _  |                 
|   | )( (- |     |  (_) (_) |                 
  
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

$error.clear() #Clear errors for use in closing statement
Clear-Host ; Intro
Write-Host "`nFirst let's kill the 2 Global Protect processes...`n" -ForegroundColor Yellow
try{taskkill /IM PanGPA.exe /F}catch{Write-Host "ERROR! Couldn't kill PanGPA.exe! Exiting!" -ForegroundColor Red;pause;exit}
try{taskkill /IM PanGPS.exe /F}catch{Write-Host "ERROR! Couldn't kill PanGPS.exe! Exiting!" -ForegroundColor Red;pause;exit}
Write-Host "`nSleeping for 3 to give those processes time to close out all the way." -ForegroundColor Yellow
sleep 3
Write-Host "`nNow to restart the Paolo Alto Networks GPS (PanGPS) Service." -ForegroundColor Yellow
#Restart-Service -Name RpcSs -Force : Couldn't restart RPC as it has dependencies so....
#sleep 5
try{Restart-Service -Name PanGPS -Force}catch{Write-Host "ERROR! Couldn't restart PanGPS Service!" -ForegroundColor Red;pause;exit}
Write-Host "`nSleeping for 4 to allow services to properly restart." -ForegroundColor Yellow
sleep 4
Write-Host "`nLastly, restarting Global Protect VPN application..." -ForegroundColor Yellow
try{Start-Process -FilePath "C:\Program Files\Palo Alto Networks\GlobalProtect\PanGPA.exe" -WindowStyle Hidden}catch{Write-Host "ERROR! Couldn't start PanGPA.exe!" -ForegroundColor Red;pause;exit}

if (!$error) {Write-Host "`n`nScript Complete. 8-)`n" -ForegroundColor Yellow}
elseif ($error) {1..15 | foreach {[system.console]::ForegroundColor = $_; Write-Host "Warning! Errors Detected! Check the terminal for errors!!!`r" -nonewline; sleep 1}}
pause
exit