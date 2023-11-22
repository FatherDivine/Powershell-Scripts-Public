<#
  .SYNOPSIS
    Tool to pull Dell service tags.

  .DESCRIPTION
    The DSTP.ps1 not only pulls service tags on the fly, but also stores found tags to
    a mySQL database. The program then queries this database before trying to remotely
    find the service tag in the event the PC is offline/inaccesible.
    If WMI is not enabled on a computer, this won't run. You will have to run the 
    PS Remote Enabler Script (PSRE.ps1) first to enable those services.

  .PARAMETER InputPath
    n/a (use the prompt in the script for input/list files.

  .LINK
    \\DATA\DEPT\CEAS\ITS\Software\Scripts\Dell Service Tag Puller
  
  .INPUTS
    None. You cannot pipe objects to DSTP.ps1.

  .OUTPUTS
    None. DSTP.ps1 does not generate any output.

  .EXAMPLE
    PS> .\DSTP.ps1

  .Author
    Created by Aaron S. for CU Denver CEDC IT Dept

  .Todo
    add mySQL database with hostname and Service Tag.  Write list to file that Domain Join Tool can import. Save hostname and Service Tag to file via MySQL
    Flow: Rather list or single, first check csv table if exists. IF so, output with the date last saved. IF not exists, pull remotely (if possible) and give error if couldn't.
    May have to trim service tag down to just the #
    Excel's formatting layer will "swallow" the first set of quotes in the file, but it's there.
    Future additions is to have a mode that saves offline PCs to retry once online.
    Latest: Add ability to read the csv file and lookup first before initiating remote 

 #>


#Get admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}

#Because, ASCII RAWKS
function Intro
{
$t = @'

 /$$$$$$$$ /$$                       /$$$$$$$            /$$ /$$                                  
|__  $$__/| $$                      | $$__  $$          | $$| $$                                  
   | $$   | $$$$$$$   /$$$$$$       | $$  \ $$  /$$$$$$ | $$| $$                                  
   | $$   | $$__  $$ /$$__  $$      | $$  | $$ /$$__  $$| $$| $$                                  
   | $$   | $$  \ $$| $$$$$$$$      | $$  | $$| $$$$$$$$| $$| $$                                  
   | $$   | $$  | $$| $$_____/      | $$  | $$| $$_____/| $$| $$                                  
   | $$   | $$  | $$|  $$$$$$$      | $$$$$$$/|  $$$$$$$| $$| $$                                  
   |__/   |__/  |__/ \_______/      |_______/  \_______/|__/|__/                                  
  /$$$$$$                                 /$$                           /$$$$$$$$                 
 /$$__  $$                               |__/                          |__  $$__/                 
| $$  \__/  /$$$$$$   /$$$$$$  /$$    /$$ /$$  /$$$$$$$  /$$$$$$          | $$  /$$$$$$   /$$$$$$ 
|  $$$$$$  /$$__  $$ /$$__  $$|  $$  /$$/| $$ /$$_____/ /$$__  $$         | $$ |____  $$ /$$__  $$
 \____  $$| $$$$$$$$| $$  \__/ \  $$/$$/ | $$| $$      | $$$$$$$$         | $$  /$$$$$$$| $$  \ $$
 /$$  \ $$| $$_____/| $$        \  $$$/  | $$| $$      | $$_____/         | $$ /$$__  $$| $$  | $$
|  $$$$$$/|  $$$$$$$| $$         \  $/   | $$|  $$$$$$$|  $$$$$$$         | $$|  $$$$$$$|  $$$$$$$
 \______/  \_______/|__/          \_/    |__/ \_______/ \_______/         |__/ \_______/ \____  $$
 /$$$$$$$            /$$ /$$                           /$$$$$$$$                  /$$    /$$  \ $$
| $$__  $$          | $$| $$                          |__  $$__/                 | $$   |  $$$$$$/
| $$  \ $$ /$$   /$$| $$| $$  /$$$$$$   /$$$$$$          | $$  /$$$$$$   /$$$$$$ | $$    \______/ 
| $$$$$$$/| $$  | $$| $$| $$ /$$__  $$ /$$__  $$         | $$ /$$__  $$ /$$__  $$| $$             
| $$____/ | $$  | $$| $$| $$| $$$$$$$$| $$  \__/         | $$| $$  \ $$| $$  \ $$| $$             
| $$      | $$  | $$| $$| $$| $$_____/| $$               | $$| $$  | $$| $$  | $$| $$             
| $$      |  $$$$$$/| $$| $$|  $$$$$$$| $$               | $$|  $$$$$$/|  $$$$$$/| $$             
|__/       \______/ |__/|__/ \_______/|__/               |__/ \______/  \______/ |__/             

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

clear-host; Intro
Write-Host "`nDo you wish to pull the Service Tag for a (S)ingle Host or (L)istfile with multiple hostnames?"
$Selection = Read-Host "You can also (Q)uit" 
switch ($Selection)
{'S'{
     $hn = Read-Host "What is the hostname or IP Address?"
     try{   
         $ServiceTag = Get-CimInstance -computername $hn -ErrorAction Stop win32_SystemEnclosure | select serialnumber
         $ST = $ServiceTag -Replace ('\W','')
         $ST2 = $ST -Replace ('serialnumber','')
         Write-Host "$pc`: $ST2`n"


         $hn | add-member -membertype NoteProperty -name Hostname -value $hn
         $hn | add-member -membertype NoteProperty -name ServiceTag -value $ST2
         $timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
         $hn | add-member -membertype NoteProperty -name Date -value $timestamp

         $hn | Export-Csv -Path ${PSScriptRoot}\DSTPdb.csv -Delimiter ";" -NoTypeInformation -Append
        } 
         catch [System.IO.IOException], [System.IO.FileLoadException]{
               Write-Host "`nError!" -ForegroundColor Yellow -NoNewLine; Write-Host " Couldn't open the CVS file. Make sure the .csv file is closed!"  -NoNewline
                                                                      }
         catch [Microsoft.Management.Infrastructure.CimException]{
          Write-Host "`nError" -ForegroundColor Yellow -NoNewLine; Write-Host " with"  -NoNewline; Write-Host " $hn" -Foregroundcolor Yellow -NoNewline; Write-Host "! It's probably offline or WinRM service isn't running on $hn.`n" -NoNewLine
          Write-Host "If the issue is WinRM related, run PS Remote Enabler (PSRE.ps1) on $hn first then try again.`n"
          "$hn" | Out-File -FilePath ${PSScriptRoot}\OfflinePCs.txt -Append  
                                                                 }
         catch { Write-Host "Unknown Error with $hn!`n"
                 "$hn" | Out-File -FilePath ${PSScriptRoot}\OfflinePCs.txt -Append  
               }          
    }
 'L'{
     "Offline PCs:" | Out-File -FilePath ${PSScriptRoot}\OfflinePCs.txt 
     $pcs = Get-Content ${PSScriptRoot}\computers.txt
     foreach($pc in $pcs){
                          try{   
                              $ServiceTag = Get-CimInstance -computername $pc -ErrorAction Stop win32_SystemEnclosure | select serialnumber
                              $ST = $ServiceTag -Replace ('\W','')
                              $ST2 = $ST -Replace ('serialnumber','')
                              Write-Host "$pc`: $ST2`n"

                              $hn | add-member -membertype NoteProperty -name Hostname -value $hn
                              $hn | add-member -membertype NoteProperty -name ServiceTag -value $ST2
                              $timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
                              $hn | add-member -membertype NoteProperty -name Date -value $timestamp

                              $hn | Export-Csv -Path ${PSScriptRoot}\DSTPdb.csv -Delimiter ";" -NoTypeInformation -Append -Force
                             } 
                              catch [System.IO.IOException], [System.IO.FileLoadException]{
                                    Write-Host "`nError!" -ForegroundColor Yellow -NoNewLine; Write-Host " Couldn't open the CVS file. Make sure the .csv file is closed!"  -NoNewline
                                                                                          }
                              catch [Microsoft.Management.Infrastructure.CimException]{
                              Write-Host "`nError" -ForegroundColor Yellow -NoNewLine; Write-Host " with"  -NoNewline; Write-Host " $hn" -Foregroundcolor Yellow -NoNewline; Write-Host "! It's probably offline or WinRM service isn't running on $hn.`n" -NoNewLine
                              Write-Host "If the issue is WinRM related, run PS Remote Enabler (PSRE.ps1) on $hn first then try again.`n"
                              "$hn" | Out-File -FilePath ${PSScriptRoot}\OfflinePCs.txt -Append  
                                                                                      }
                              catch { Write-Host "Unknown Error with $hn!`n"
                                      "$hn" | Out-File -FilePath ${PSScriptRoot}\OfflinePCs.txt -Append -Force
                                    }
                         }  
    }
 'Q'{exit}
} 
pause

