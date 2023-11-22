 <#
        .SYNOPSIS
           A tool for listing disk properties of remote computers.
        
        .DESCRIPTION
            Asks for a file containing a list of computers and finds their hostname, total space, free space, and percentage free.
            You can create your own credentials using the "XML Credentials Generator Script.ps1" file prior to running this file.
            Or better yet, just run "RUN ME-StartScript.bat" to not only not worry about if running PS scripts is enabled on the 
            computer, but to also run the credentials generator first then the remote mass disk size finder tool, in that order.     
           
        .Link
            \\data\dept\CEAS\ITS\Software\Scripts\Remote Mass Disk Size Finder
        
         .OUTPUTS
            Generated output files include: Results.txt, OfflinePCs.txt, & LessThan1TBPCs.txt. Results.txt has the hostname,
            total space, free space, and percentage information. OfflinePCs.txt has all PCs that were unreachable (probably turned
            off). LessThan1TBPCs.txt lists computers that have a C: partition of less than 900 GB signalling a less than 1TB Drive.
        
        .NOTES
            Nothing yet.
 #>

#Credentials section. Critical to having the permissions required for querying disk information from a remote PC.
$key = Import-Clixml -LiteralPath ${PSScriptRoot}\Key.xml
$importObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml
$secureString = ConvertTo-SecureString -String $importObject.Password -Key $key
$Credential = New-Object System.Management.Automation.PSCredential($importObject.UserName, $secureString)

$fileName = "PCLISTS\nada.txt"

#Because, ASCII RAWKS
function Intro
{
$t = @"
  _______  _
 |__   __|| |
    | |   | |__    ___
    | |   | '_ \  / _ \
    | |   | | | ||  __/
  __|_|   |_| |_| \___|          _          __  __
 |  __ \                        | |        |  \/  |
 | |__) | ___  _ __ ___    ___  | |_  ___  | \  / |  __ _  ___  ___
 |  _  / / _ \| '_ `` _ \  / _ \ | __|/ _ \ | |\/| | / _`` |/ __|/ __|
 | | \ \|  __/| | | | | || (_) || |_|  __/ | |  | || (_| |\__ \\__ \
 |_|  \_\\___||_| |_| |_| \___/  \__|\___| |_|  |_| \__,_||___/|___/
  _____   _       _       _____  _             ______  _             _
 |  __ \ (_)     | |     / ____|(_)           |  ____|(_)           | |
 | |  | | _  ___ | | __ | (___   _  ____ ___  | |__    _  _ __    __| |  ___  _ __
 | |  | || |/ __|| |/ /  \___ \ | ||_  // _ \ |  __|  | || '_ \  / _`` | / _ \| '__|
 | |__| || |\__ \|   <   ____) || | / /|  __/ | |     | || | | || (_| ||  __/| |
 |_____/_|_||___/|_|\_\ |_____/ |_|/___|\___| |_|     |_||_| |_| \__,_| \___||_|
 |__   __|           | |
    | |  ___    ___  | |
    | | / _ \  / _ \ | |
    | || (_) || (_) || |
    |_| \___/  \___/ |_|
                                                                                   
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

Clear-Host ; Intro
Write-Host "`n`nWhat is the filename listing the computers? Make sure it's in the same folder as this script." 
while (!(Test-Path ${PSScriptRoot}\$fileName)){ 
                                               $fileName = Read-Host "Also add the extension to the name. (Ex: PCLists\DeepFreeze.txt)"
                                              }
$selection = Read-Host "Would you like to print to (S)creen and file or only to (F)ile?"
switch ($selection){
'F'{
#Creating files without -append which will wipe out any old results prior.
"Offline PCs:" | Out-File -FilePath ${PSScriptRoot}\OfflinePCs.txt  #Lists all Offline PCs
"Computers with less than 1TB C Drive:" | Out-File -FilePath ${PSScriptRoot}\LessThan1TBPCs.txt #Lists out the Files less than 1 TB
Out-File -FilePath ${PSScriptRoot}\Results.txt

$output = ForEach ($item in (Get-Content ${PSScriptRoot}\$filename)) { 
try{ 
   $disk = Get-WmiObject -Credential $Credential -Class Win32_LogicalDisk -ComputerName $item -Filter "DeviceID='C:'" -ErrorAction SilentlyContinue |
    Select-Object Size,FreeSpace
    
    "`nInformation for $item`:" | Out-File -FilePath ${PSScriptRoot}\Results.txt -Append
    "Total Space: $([math]::round($disk.Size / 1GB,2)) GB" | Out-File -FilePath ${PSScriptRoot}\Results.txt -Append
    "Free Space: $([math]::round($disk.FreeSpace / 1GB,2)) GB" | Out-File -FilePath ${PSScriptRoot}\Results.txt -Append
    "Percent Free: $([math]::round(($disk.FreeSpace / $disk.Size) * 100,2))%" | Out-File -FilePath ${PSScriptRoot}\Results.txt -Append
    
    #If total space less than 900gb, then write to differ file.
    $TotalSpace = "$([math]::round($disk.Size / 1GB,2))"
    if ($TotalSpace -lt "900"){
                               "$item`n" | Out-File -FilePath ${PSScriptRoot}\LessThan1TBPCs.txt -Append
                              }
    } catch{
            "$item" | Out-File -FilePath ${PSScriptRoot}\OfflinePCs.txt -Append
           }
}
}'S'{

#Creating files without -append which will wipe out any old results prior.
"Offline PCs:" | Out-File -FilePath ${PSScriptRoot}\OfflinePCs.txt  #Lists all Offline PCs
"Computers with less than 1TB C Drive:" | Out-File -FilePath ${PSScriptRoot}\LessThan1TBPCs.txt #Lists out the Files less than 1 TB

Write-host "`n"
Start-Transcript -IncludeInvocationHeader -Path ${PSScriptRoot}\Results.txt # -useminimalheader only works in PS 6.3+. Would make Transcript header much smaller
$output = ForEach ($item in (Get-Content ${PSScriptRoot}\PCList.txt)) {
try {  
   $disk = Get-WmiObject -Credential $Credential -Class Win32_LogicalDisk -ComputerName $item -Filter "DeviceID='C:'" -ErrorAction SilentlyContinue |
    Select-Object Size,FreeSpace
    
    Write-Host "`nInformation for $item`:" 
    Write-Host "Total Space: $([math]::round($disk.Size / 1GB,2)) GB"
    Write-Host "Free Space: $([math]::round($disk.FreeSpace / 1GB,2)) GB"
    Write-Host "Percent Free: $([math]::round(($disk.FreeSpace / $disk.Size) * 100,2))%"
    $TotalSpace = $([math]::round($disk.Size / 1GB,2))

#if total space less than 900gb, then write to differ file.
    if ($TotalSpace -lt "900"){
                               "$item`n" | Out-File -FilePath ${PSScriptRoot}\LessThan1TBPCs.txt -Append
                              }
    }catch {
            "$item" | Out-File -FilePath ${PSScriptRoot}\OfflinePCs.txt -Append
           }
}
Write-Host ""
Stop-Transcript
Write-Host "`nSuccessfully wrote results to ${PSScriptRoot}\Results.txt, OfflinePCs.txt, & LessThan1TBPCs.txt."
Write-Host ""
pause
}
}