$hn = "a"

$selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent hostname?"
    switch ($selectionCHOF)
    {'C'{ 
          $hn = Read-Host "What is the hostname?" 
          $hostnameLength = $hn.length
          $hostnameLength           
           While ($hostnameLength -ge 16){
           Write-Host "Current hostname ($hn) is longer than 15 characters! Exiting to main menu! $hostnameLength."
           $hn = Read-Host "What is the hostname again" 
           $hostnameLength = $hn.length
           }
           pause
           }'F'{pause}
    }