# Push Files
 $csv = (Get-Content ${PSScriptRoot}\computers.txt) 

 #$Source = "${PSScriptRoot}\android-studio-2022.2.1.20-windows.exe" #read-host in future
 $dest = "C:\temp\"  
 $Output = "${PSScriptRoot}\OfflinePCs.csv"  
 $items = @()  

 # For future use
 $SourceFile = Read-Host "What is the name of the file/folder/zip you wish to copy to?"
 [string[]]$Source = (Get-Content ${PSScriptRoot}\$SourceFile)

 #reads .csv for workstation NAME.  
 foreach ($line in $csv)  
 {  
 #pings each Host. If true, Copy file.  
     if (Test-Connection $line -count 1 -quiet)  
     {  
         write-Host "true", $line  
         $name = "\\" + $line  
             
         #copies the file over to target machine  
         Copy-Item -path $Source -Destination $name\$dest  
      }  
 #if ping fails, log which workstation and that workstation's IP in a new CSV.  
     else  
     {  
         write-host "false" $line  
         $items += New-Object psobject -Property @{Hostname=$line}  
     }  
 }  
 #exports array of workstations that were unreachable for manual processing at a later date.  
 $items | Export-Csv -NoTypeInformation -Path $Output  