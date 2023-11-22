 <#
        .SYNOPSIS
           A tool for listing disk properties.
        
        .DESCRIPTION
            Takes a file asks for a list of computers and finds their hostname, total space, free space, and percentage free.
            You can create your own credentials using the "XML Credentials Generator Script.ps1" file prior to running this file.
                       
    
           
        .Link
            \\data\dept\CEAS\ITS\Software\Scripts\
        
        .NOTES
            None yet
            
    #>


#Credentials section. Needed to be able to have the permissions to get disk information from a remote PC
$key = Import-Clixml -LiteralPath ${PSScriptRoot}\DJSKey.xml
$importObject = Import-Clixml -LiteralPath ${PSScriptRoot}\DJSCred.xml
$secureString = ConvertTo-SecureString -String $importObject.Password -Key $key
$Credential = New-Object System.Management.Automation.PSCredential($importObject.UserName, $secureString)

#Because, ASCII RAWKS
function Menu
{
param (
       [string]$DeptTitle = 'LABS'
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
    Write-Host "B: Press 'B' to go back to the main menu"
}

Clear-Host
Menu
Write-Host "What is the name of the file with the list of computers?" 
$fileName = Read-Host "Please make sure it's in the same folder as this script & add the extension to the name(EG: PCList.txt)"
$selection = Read-Host "Would you like to print to (S)creen and file or only to (F)ile?"
switch ($selection){'F'{
$output = ForEach ($item in (Get-Content ${PSScriptRoot}\$filename)) {  
   $disk = Get-WmiObject -Credential $Credential -Class Win32_LogicalDisk -ComputerName $item -Filter "DeviceID='C:'" |
    Select-Object Size,FreeSpace
    
    "Information for $item`:" | Out-File -FilePath ${PSScriptRoot}\Results.txt -Append
    "Total Space: $([math]::round($disk.Size / 1GB,2)) GB" | Out-File -FilePath ${PSScriptRoot}\Results.txt -Append
    "Free Space: $([math]::round($disk.FreeSpace / 1GB,2)) GB" | Out-File -FilePath ${PSScriptRoot}\Results.txt -Append
    "Percent Free: $([math]::round(($disk.FreeSpace / $disk.Size) * 100,2))%`n" | Out-File -FilePath ${PSScriptRoot}\Results.txt -Append
}
}'S'{
Start-Transcript -Path ${PSScriptRoot}\Results.txt
$output = ForEach ($item in (Get-Content ${PSScriptRoot}\PCList.txt)) {  
   $disk = Get-WmiObject -Credential $Credential -Class Win32_LogicalDisk -ComputerName $item -Filter "DeviceID='C:'" |
    Select-Object Size,FreeSpace
    
    Write-Host "`nInformation for $item`:" 
    Write-Host "Total Space: $([math]::round($disk.Size / 1GB,2)) GB"
    Write-Host "Free Space: $([math]::round($disk.FreeSpace / 1GB,2)) GB"
    Write-Host "Percent Free: $([math]::round(($disk.FreeSpace / $disk.Size) * 100,2))%"
}
""
Stop-Transcript
Write-Host "successfully wrote results to ${PSScriptRoot}\Results.txt"
pause
}
}


