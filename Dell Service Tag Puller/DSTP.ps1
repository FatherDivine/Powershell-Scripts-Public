<#
  .SYNOPSIS
    Tool to pull Dell service tags.

  .DESCRIPTION
    The DSTP.ps1 not only pulls service tags on the fly, but also stores found tags to
    a mySQL database. The program then queries this database before trying to remotely
    find the service tag in the event the PC is offline/inaccesible.
    If WMI/WinRM is not enabled on a computer, will automatically run PS Remote Enabler script
    to enable WinRM, then retry to join.

  .PARAMETER InputPath
    Specifies the path to the CSV-based input file.
        if (Test-Path -Path $Directory)
  
  .PARAMETER Server
    
  
  .PARAMETER ServerList
    
    {
	Get-ChildItem -Path $Directory -File | ForEach-Object {$size += $_.Length}
	[PSCustomObject]@{'Directory' = $Directory; 'SizeInMB' = $size / 1MB}	
    }
    else
    {
	Write-Error "Cannot find directory: $Directory"
    }


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

    6-4-23 TEST (@ University) export logic and make sure now adds up to import (removed delimiter last)

    # Admin Rights if needed:
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}
 #>
Param
       ([cmdletbinding()]
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$true)]
       [string]${Hostname},
       $errorlog,

       [Parameter(Mandatory=$false,
       ValueFromPipeline=$true)]
        [string]
        $HostList
       )     
if ($PSBoundParameters.ContainsKey('Hostname'))
{try{
$ServiceTag = Get-CimInstance -computername ${hostname} -ErrorAction Stop win32_SystemEnclosure | select serialnumber
         $ST = $ServiceTag -Replace ('\W','')
         $ST2 = $ST -Replace ('serialnumber','')
         Write-Host "${hostname}`: $ST2`n"}catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n”}
         exit
}
if ($PSBoundParameters.ContainsKey('HostList'))
{
try{
$pcs = Get-Content ${PSScriptRoot}\$HostList
}catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n”}
     foreach($pc in $pcs){
            try{
                $hn = "placeholder"
                $ServiceTag = Get-CimInstance -computername $pc -ErrorAction Stop win32_SystemEnclosure | select serialnumber
                $ST = $ServiceTag -Replace ('\W','')
                $ST2 = $ST -Replace ('serialnumber','')
                Write-Host "$pc`: $ST2`n"
                }catch{Write-Error “`nAn error occurred: $($_.Exception.Message)`n”}}
exit
}
#region function Intro ASCII
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
#endregion function Intro ASCII
$PSRERan = '0'
function STPuller{
    <#
        .Synopsis
            Functions to pull Service Tags from remote hosts.
        .Description
            2 Parameter function to pull Service tags on either single hosts
            or a listfile of hosts. Will add to a CSV database for future 
            use (searching offline for faster results as well as for use
            in the Domain Join Tool (DJT) to pull service tags into
            AD OU description.
        .Example
            STPuller -Host "hostname"
            STPuller -HostList 'computers.txt'
            .\DSTP.ps1 -Host "CEDC-NC2413-A1"
            .\DSTP.ps1 -HostList computers.txt
        .Notes
    #>
[cmdletbinding()]
Param
       (
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [string]${Hostname},
       $errorlog,
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
        [string]$HostList
        )
begin {

        #setup our return object
        $result = [PSCustomObject]@{

            SuccessOne = $false
            SuccessTwo = $false
        }        
    }
    process {
                                        #use a switch statement to take actions based on passed in parameters
        switch ($PSBoundParameters.Keys) {
            'Hostname' {
                                        #perform actions if ParamOne is used

                                        #First checks if the host is already in the database. Saves time traversing the network.
     try{
         $PCObjects = @()
         Import-CSV -Path ${PSScriptRoot}\DSTPdbtest.csv | ForEach { #change to real database once in production
         
         $PCObjects += $_.Hostname
         $PCObjects += $_.ServiceTag
         $PCObjects += $_.Date
         }

     if ($PCObjects.Contains(${hostname}) ){
        write-host "PC Found in offline CSV File:`n"
        write-host ""
        [int]$index = $PCObjects.IndexOf($hn)
        [int]$index2 = $index+1
        [int]$index3 = $index2+1
        Write-Host "Hostname: "$PCObjects[$index]
        Write-Host "Service Tag: "$PCObjects[$index2]
        write-host "Date last saved to CSV: " $PCObjects[$index3]
        
     do{$StillSearch = Read-Host "Do you wish to still search the network for this host's service tag? (Y) or (N)"}
     while ($StillSearch -notmatch "^(N|Y)$")
     if ($StillSearch -eq 'N'){exit}
     else {continue}
    }
		
    else {
         $ServiceTag = Get-CimInstance -computername $hn -ErrorAction Stop win32_SystemEnclosure | select serialnumber
         $ST = $ServiceTag -Replace ('\W','')
         $ST2 = $ST -Replace ('serialnumber','')
         Write-Host "$pc`: $ST2`n"


         $hn | add-member -membertype NoteProperty -name Hostname -value $hn
         $hn | add-member -membertype NoteProperty -name ServiceTag -value $ST2
         $timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
         $hn | add-member -membertype NoteProperty -name Date -value $timestamp

         $hn | Export-Csv -Path ${PSScriptRoot}\DSTPdb2.csv -Encoding UTF8 -NoTypeInformation -Append -Force
         }
        } 
         catch [System.IO.IOException],[System.IO.FileLoadException]{
               Write-Host "`nError!" -ForegroundColor Yellow -NoNewLine; Write-Host " Couldn't open the CVS file. Make sure the .csv file is closed!`n"  -NoNewline
                                                                    }
         catch [Microsoft.Management.Infrastructure.CimException]{
               Write-Host "`nError" -ForegroundColor Yellow -NoNewLine; Write-Host " with"  -NoNewline; Write-Host " $hn" -Foregroundcolor Yellow -NoNewline; Write-Host "! It's probably offline or WinRM service isn't running on $hn.`n" -NoNewLine
               Write-Host "Running PSRE.ps1 on $hn to enable WinRM services...`n"
               & ${PSScriptRoot}\PSRE.ps1 -Server "$hn"
               $PSRERan = '1' 
                                                                 }
         catch{Write-Host "`nUnknown Error with $hn! Writing to ${PSScriptRoot}\OfflinePCs.txt!`n"
               "$hn" | Out-File -FilePath ${PSScriptRoot}\OfflinePCs.txt -Append
               Write-Host "Trying to run PSRE.ps1 on $hn..."
               & ${PSScriptRoot}\PSRE.ps1 -Server "$hn"
               #$PSRERan = '2'
              } 
                 while ($PSRERan -match "^(1)$")
                 {
                    Write-Host "`nTrying to pull the service tag from $hn again...`n"
                    $ServiceTag = Get-CimInstance -computername $hn -ErrorAction Stop win32_SystemEnclosure | select serialnumber
                    $ST = $ServiceTag -Replace ('\W','')
                    $ST2 = $ST -Replace ('serialnumber','')
                    Write-Host "$pc`: $ST2`n"

                    $hn | add-member -membertype NoteProperty -name Hostname -value $hn
                    $hn | add-member -membertype NoteProperty -name ServiceTag -value $ST2
                    $timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
                    $hn | add-member -membertype NoteProperty -name Date -value $timestamp

                    $hn | Export-Csv -Path ${PSScriptRoot}\DSTPdb2.csv -Encoding UTF8 -NoTypeInformation -Append -Force
                    $PSRERan = '2'
                    $result.SuccessOne = $true
                    }  
                     }
            'HostList' {
                                        #perform logic if ParamTwo is used
     
     $pcs = Get-Content ${PSScriptRoot}\$HostList
     foreach($pc in $pcs){
            try{
                $hn = "placeholder"
                $ServiceTag = Get-CimInstance -computername $pc -ErrorAction Stop win32_SystemEnclosure | select serialnumber
                $ST = $ServiceTag -Replace ('\W','')
                $ST2 = $ST -Replace ('serialnumber','')
                Write-Host "$pc`: $ST2`n"

                $hn | add-member -membertype NoteProperty -name Hostname -value $pc
                $hn | add-member -membertype NoteProperty -name ServiceTag -value $ST2
                $timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
                $hn | add-member -membertype NoteProperty -name Date -value $timestamp

                $hn | Export-Csv -Path ${PSScriptRoot}\DSTPdb2.csv -NoTypeInformation -Append -Force
                } 
                catch [System.IO.IOException],[System.IO.FileLoadException]{
                      Write-Host "`nError!" -ForegroundColor Yellow -NoNewLine; Write-Host " Couldn't open the CVS file. Make sure the .csv file is closed!`n"  -NoNewline
                                                                           }
                catch [Microsoft.Management.Infrastructure.CimException]{
                      Write-Host "`nError" -ForegroundColor Yellow -NoNewLine; Write-Host " with"  -NoNewline; Write-Host " $pc" -Foregroundcolor Yellow -NoNewline; Write-Host "! It's probably offline or WinRM service isn't running on $pc.`n" -NoNewLine
                      Write-Host "`nRunning PS Remote Enabler Script (PSRE.ps1) on $pc to enable WinRM services...`n"
                      & ${PSScriptRoot}\PSRE.ps1 -Server "$pc"
                      $PSRERan = '1' 
                                                                        }
                catch{Write-Host "`nUnknown Error with $pc! Writing to ${PSScriptRoot}\OfflinePCs.txt!`n"
                      "$pc" | Out-File -FilePath ${PSScriptRoot}\OfflinePCs.txt -Append
                      Write-Host "Trying to run PSRE.ps1 on $pc..."
                      & ${PSScriptRoot}\PSRE.ps1 -Server "$pc"                 #If Couldn't access, the handle is invalid then exit everything or go back to main menu w/ :start next:
                      #$PSRERan = '2'
                      }
                      while ($PSRERan -match "^(1)$")
                      {
                       Write-Host "`nTrying to pull the service tag from $pc again...`n"
                       $ServiceTag = Get-CimInstance -computername $pc win32_SystemEnclosure | select serialnumber
                       $ST = $ServiceTag -Replace ('\W','')
                       $ST2 = $ST -Replace ('serialnumber','')
                       Write-Host "$pc`: $ST2`n"

                       $hn | add-member -membertype NoteProperty -name Hostname -value $pc
                       $hn | add-member -membertype NoteProperty -name ServiceTag -value $ST2
                       $timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
                       $hn | add-member -membertype NoteProperty -name Date -value $timestamp
                       $hn | Export-Csv -Path ${PSScriptRoot}\DSTPdb.csv -Delimiter ";" -NoTypeInformation -Append -Force
                       $PSRERan = '2'
                      }
                         }  
                $result.SuccessTwo = $true
                         }
            Default {
                
                Write-Warning "Unhandled parameter -> [$($_)]"
                    }
                                         }        
    }
    end {
        #return $result
    }}
clear-host; Intro
Write-Host "`nDo you wish to pull the Service Tag for a (S)ingle Host or a (L)istfile named Computers.txt with multiple hostnames?"
$Selection = Read-Host "You can also (Q)uit" 
switch ($Selection) #Swap to do/while with if/else if's so can catch other letters and repeat.
{'S'{
     $hn = Read-Host "What is the hostname or IP Address?"
     STPuller -Hostname $hn
    }
 'L'{
     "Offline PCs:" | Out-File -FilePath ${PSScriptRoot}\OfflinePCs.txt
     Write-Host "`nWhat's the name of the List file?"
     $Answer = Read-Host "If no name is specified, will default to ${PSScriptRoot}\computers.txt"
     if (!$Answer){$Answer = "computers.txt"} 
     STPuller -HostList $Answer
    }
 'Q'{exit}
}
Write-Host "`nDatabase file is located in ${PSScriptRoot}\DSTPdb.csv.`n`n"
Write-Host "Inaccessible PCs are saved to ${PSScriptRoot}\OfflinePCs.txt.`n"
pause