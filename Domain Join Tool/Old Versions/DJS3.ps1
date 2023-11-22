# Created by Aaron S. for CU Denver CEDC IT Dept
#ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
$user = "UNIVERSITY\statena"
#$pass = Read-Host -Prompt "Enter pass for $user" -AsSecureString
#$pass = ConvertTo-SecureString "01000000d08c9ddf0115d1118c7a00c04fc297eb01000000385cedcf5d83f6489ac32b9362f104970000000002000000000003660000c00000001000000004a3a97a52a9591b271213fb96267d490000000004800000a000000010000000a77b76c605b54ec25a7a1ba046806317200000006afc44dc2b027ca39533c74167eb660513aeec544b7e131f81704092e870e94314000000e0b419c6d123b171b5d814bd8956f308ee3b2ee3"#-AsPlainText -Force
#$Cred = New-Object System.Management.Automation.PSCredential ($user,$pass)
$hostname = hostname
$hostnameLength = $hostname.Length
$OldComputerName = $hostname #using to keep tratck of old PC name
$CustomHost= 0
$KeyFile = "C:\Users\statena\OneDrive - The University of Colorado Denver\CEDC IT\Projects\Aaron S\Domain Join Script\password\Password.enc"
$Pass = Get-Content "C:\data\Password.enc" | ConvertTo-SecureString -Key $Key
$Cred = New-Object System.Management.Automation.PSCredential ($user,$Pass)

function Show-Menu
{
    param (
           [string]$Title = 'Domain Join Script'
          )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' to join the domain."
    # Domain Join contains: walking thru the domain name creation process (asking to pick predefined CEAS AD depts: BIOE, CIVL, CSCI, DEAN, ECSG, ELEC, IWKS, LABs, MECH, SRVS, Test.)
    # Labs will have second level of CART, LW840, LW844, NC2013, NC2207, NC2408, NC2413, NC2608, NC2609, NC2610
    Write-Host "2: Press '2' to unjoin the domain."
    Write-Host "3: Press '3' to rename this host locally."
    Write-Host "4: Press '4' to join the domain using current hostname (CEAS ONLY)."
    #Write-Host "5: Press '5' to manually join the domain with a given hostname (Advanced)" This is for adding any user input to domain, but most be able to set hostname and join without restart.
    # have manual mode that allows user to supply the branch started with ucdenver.pvt> for use with CAM or others.
    # Also a mode that supplies a file list of names typed in a .txt (or no extension) file to be added all at once.
    Write-Host "Q: Press 'Q' to quit."
    ""
    "Total length of the hostname cannot exceed 15 characters. The current hostname ($hostname) is $hostnameLength characters long."
}
function Show-Dept-Menu
{
param (
       [string]$DeptTitle = 'Departments'
      )
    Clear-Host
    Write-Host "================ $DeptTitle ================"
    
    Write-Host "1: BIOE: Bio Engineering"
    Write-Host "2: CIVL: Civil Engineering"
    Write-Host "3: CSCI: Computer Science"
    Write-Host "4: DEAN: Office of the Dean"
    Write-Host "5: ECSG: NC2612A and Administration OU"
    Write-Host "6: ELEC: Electrical Engineering"
    Write-Host "7: IWKS: Inworks"
    Write-Host "8: LABS: CEDC Labs"
    Write-Host "9: MECH: Mechanical Engineering"
    Write-Host "10: SRVS: Servers (Data Center)"
    Write-Host "11: Test: Testing OU"
    Write-Host "Q: Press 'Q' to quit."
    Write-Host "B: Press 'B' to go back to the main menu"
}


:start do
 {
    Show-Menu 
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    '1' {
    'You chose option #1: join the domain.' 
    $selectionDJ = Read-Host "Will you be adding a (S)ingle computer or (M)ultiple using a .txt file?"
    switch ($selectionDJ)
    {
    'S' {'You choose adding a single host to AD'
    :next do{
    Show-Dept-Menu
    $selectionSHD = Read-Host "Which Department would you like to place the host in?"
    switch ($selectionSHD)
    {
    '1'{'BIOE'
    $selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent hostname?"
    switch ($selectionCHOF)
    {'C'{ 
        $serverlist = $hostname
#Check if hostname is longer than 15 character limit. IF so, exit as the current hostname is expected and would have to be changed manually (or go into Find a hostname mode). Redirect to find hostname if possible.
        do {
            "Current hostname ($hostname) is longer than 15 characters! Exiting!"
            break next
           } while($RenameHost.Length -gt 15)
 #$serverlist = get-content ServerList.txt
foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "#######################################"  
        Write-Host "Computer object already exists. Exiting"
        Write-Host "#######################################"
        break next
                                                                       }
    else {
        Write-Host "#######################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "#######################################"
 

    Add-Computer -DomainName "Ucdenver.pvt"  -Credential $Cred -OUPATH "OU=BIOE,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError #-LocalCredential cladmin 
    $computerError
    pause
         }
                                 }
        }
    'F'{
    $RoomNumber = Read-Host "What is the room number the device will be located? This will be used in the middle of the naming convention: BIOE-######-D1. Please add NC if it's in North Classroom eg: NC2206"
    $DeviceType = Read-Host "Lastly, what type of device is this? (D)esktop, (L)aptop, (M)ac (Desktop and laptops), or (AIO) for Windows-based All-in-Ones" 
    $CustomHost = "BIOE-$RoomNumber-$DeviceType"
    $i = 1
    $serverlist = $CustomHost
    $CustomHostInc = $CustomHost

foreach ($server in $serverlist) {
    #Import-Module ActiveDirectory
    Do {
        Write-Host "#################################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "#################################################################################################################"
        $CustomHostInc = $CustomHost + $i++
       } while (Get-ADComputer -Server "132.194.70.65" -filter "Name -like '*$CustomHostInc'" -Credential $Cred) #Server = Artemis Domain Controllers 
                                 }

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." -ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Cred -Force
    sleep 5
    Add-Computer -ComputerName $OldComputerName -DomainName "Ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Cred #-Restart
    $computerError
    pause
       
       }
    }
       }

    '2'{'CIVL'
        $selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent hostname?"
    switch ($selectionCHOF)
    {'C'{ 
        $serverlist = $hostname
        do {
            "Current hostname ($hostname) is longer than 15 characters! Exiting!"
            break next
           } while($RenameHost.Length -gt 15)

foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "#######################################"  
        Write-Host "Computer object already exists. Exiting"
        Write-Host "#######################################"
        break next
                                                                       }
    else {
        Write-Host "#######################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "#######################################"
 

    Add-Computer  -DomainName "Ucdenver.pvt"  -Credential $Cred -OUPATH "OU=CIVL,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
         }
                                 }
        }
    'F'{
    $RoomNumber = Read-Host "What is the room number the device will be located? This will be used in the middle of the naming convention: CIVL-######-D1. Please add NC if it's in North Classroom eg: NC2206"
    $DeviceType = Read-Host "Lastly, what type of device is this? (D)esktop, (L)aptop, (M)ac (Desktop and laptops), or (AIO) for Windows-based All-in-Ones" 
    $CustomHost = "CIVL-$RoomNumber-$DeviceType"
    $i = 1
    $serverlist = $CustomHost
    $CustomHostInc = $CustomHost

foreach ($server in $serverlist) {
    #Import-Module ActiveDirectory
    Do {
        Write-Host "#################################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "#################################################################################################################"
        $CustomHostInc = $CustomHost + $i++
       } while (Get-ADComputer -Server "132.194.70.65" -filter "Name -like '*$CustomHostInc'" -Credential $Cred)
                                 }

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." -ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Cred -Force
    sleep 5
    Add-Computer -ComputerName $OldComputerName -DomainName "Ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Cred #-Restart
    $computerError
    pause
        
    
       }
    }
       } #Last fixed brackets alignment
    '3'{'CSCI'
        $selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent hostname?"
    switch ($selectionCHOF)
    {'C'{ 
        $serverlist = $hostname
        do {
            "Current hostname ($hostname) is longer than 15 characters! Exiting!"
            break next
           } while($RenameHost.Length -gt 15)

foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "#######################################"  
        Write-Host "Computer object already exists. Exiting"
        Write-Host "#######################################"
        break next
                                                                       }
    else {
        Write-Host "#######################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "#######################################"
 

    Add-Computer -DomainName "Ucdenver.pvt"  -Credential $Cred -OUPATH "OU=CSCI,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{
    $RoomNumber = Read-Host "What is the room number the device will be located? This will be used in the middle of the naming convention: CSCI-######-D1. Please add NC if it's in North Classroom eg: NC2206"
    $DeviceType = Read-Host "Lastly, what type of device is this? (D)esktop, (L)aptop, (M)ac (Desktop and laptops), or (AIO) for Windows-based All-in-Ones" 
    $CustomHost = "CSCI-$RoomNumber-$DeviceType"
    $i = 1
    $serverlist = $CustomHost
    $CustomHostInc = $CustomHost

foreach ($server in $serverlist) {
    #Import-Module ActiveDirectory
    Do {
        Write-Host "#################################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "#################################################################################################################"
        $CustomHostInc = $CustomHost + $i++
    } while (Get-ADComputer -Server "132.194.70.65" -filter "Name -like '*$CustomHostInc'" -Credential $Cred)
    }

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." -ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Cred -Force
    sleep 5
    Add-Computer -ComputerName $OldComputerName -DomainName "Ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Cred #-Restart
    $computerError
    pause
        
       }
    }    
    }
    '4'{'DEAN'
        $selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent hostname?"
    switch ($selectionCHOF)
    {'C'{ 
        $serverlist = $hostname
        do {
            "Current hostname ($hostname) is longer than 15 characters! Exiting!"
            break next
           } while($RenameHost.Length -gt 15)

foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "#######################################"  
        Write-Host "Computer object already exists. Exiting"
        Write-Host "#######################################"
        break next
                                                                       }
    else {
        Write-Host "#######################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "#######################################"
 

    Add-Computer -DomainName "Ucdenver.pvt"  -Credential $Cred -OUPATH "OU=DEAN,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{
    $RoomNumber = Read-Host "What is the room number the device will be located? This will be used in the middle of the naming convention: DEAN-######-D1. Please add NC if it's in North Classroom eg: NC2206"
    $DeviceType = Read-Host "Lastly, what type of device is this? (D)esktop, (L)aptop, (M)ac (Desktop and laptops), or (AIO) for Windows-based All-in-Ones" 
    $CustomHost = "DEAN-$RoomNumber-$DeviceType"
    $i = 1
    $serverlist = $CustomHost
    $CustomHostInc = $CustomHost

foreach ($server in $serverlist) {
    #Import-Module ActiveDirectory
    Do {
        Write-Host "#################################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "#################################################################################################################"
        $CustomHostInc = $CustomHost + $i++
    } while (Get-ADComputer -Server "132.194.70.65" -filter "Name -like '*$CustomHostInc'" -Credential $Cred)
    }

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." -ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Cred -Force
    sleep 5
    Add-Computer -ComputerName $OldComputerName -DomainName "Ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Cred #-Restart
    $computerError
    pause
           
       }
    }    
    }
    '5'{'ECSG'
    $selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent hostname?"
    switch ($selectionCHOF)
    {'C'{ 
        $serverlist = $hostname
        do {
            "Current hostname ($hostname) is longer than 15 characters! Exiting!"
            break next
           } while($RenameHost.Length -gt 15)

foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "#######################################"  
        Write-Host "Computer object already exists. Exiting"
        Write-Host "#######################################"
        break next
                                                                       }
    else {
        Write-Host "#######################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "#######################################"
 

    Add-Computer -DomainName "Ucdenver.pvt"  -Credential $Cred -OUPATH "OU=ECSG,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{
    $RoomNumber = Read-Host "What is the room number the device will be located? This will be used in the middle of the naming convention: ECSG-######-D1. Please add NC if it's in North Classroom eg: NC2206"
    $DeviceType = Read-Host "Lastly, what type of device is this? (D)esktop, (L)aptop, (M)ac (Desktop and laptops), or (AIO) for Windows-based All-in-Ones" 
    $CustomHost = "ECSG-$RoomNumber-$DeviceType"
    $i = 1
    $serverlist = $CustomHost
    $CustomHostInc = $CustomHost

foreach ($server in $serverlist) {
    #Import-Module ActiveDirectory
    Do {
        Write-Host "#################################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "#################################################################################################################"
        $CustomHostInc = $CustomHost + $i++
    } while (Get-ADComputer -Server "132.194.70.65" -filter "Name -like '*$CustomHostInc'" -Credential $Cred)
    }

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." -ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Cred -Force
    sleep 5
    Add-Computer -ComputerName $OldComputerName -DomainName "Ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Cred #-Restart
    $computerError
    pause
        
       }
    }
    }
    '6'{'ELEC'
        $selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent hostname?"
    switch ($selectionCHOF)
    {'C'{ 
        $serverlist = $hostname
        do {
            "Current hostname ($hostname) is longer than 15 characters! Exiting!"
            break next
           } while($RenameHost.Length -gt 15)

foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "#######################################"  
        Write-Host "Computer object already exists. Exiting"
        Write-Host "#######################################"
        break next
                                                                       }
    else {
        Write-Host "#######################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "#######################################"
 

    Add-Computer -DomainName "Ucdenver.pvt"  -Credential $Cred -OUPATH "OU=ELEC,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{
    $RoomNumber = Read-Host "What is the room number the device will be located? This will be used in the middle of the naming convention: ELEC-######-D1. Please add NC if it's in North Classroom eg: NC2206"
    $DeviceType = Read-Host "Lastly, what type of device is this? (D)esktop, (L)aptop, (M)ac (Desktop and laptops), or (AIO) for Windows-based All-in-Ones" 
    $CustomHost = "ELEC-$RoomNumber-$DeviceType"
    $i = 1
    $serverlist = $CustomHost
    $CustomHostInc = $CustomHost

foreach ($server in $serverlist) {
    #Import-Module ActiveDirectory
    Do {
        Write-Host "#################################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "#################################################################################################################"
        $CustomHostInc = $CustomHost + $i++
    } while (Get-ADComputer -Server "132.194.70.65" -filter "Name -like '*$CustomHostInc'" -Credential $Cred)
    }

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." -ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Cred -Force
    sleep 5
    Add-Computer -ComputerName $OldComputerName -DomainName "Ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Cred #-Restart
    $computerError
    pause
        
       }
    }    
    }
    '7'{'IWKS'
        $selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent hostname?"
    switch ($selectionCHOF)
    {'C'{ 
        $serverlist = $hostname
        do {
            "Current hostname ($hostname) is longer than 15 characters! Exiting!"
            break next
           } while($RenameHost.Length -gt 15)

foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "#######################################"  
        Write-Host "Computer object already exists. Exiting"
        Write-Host "#######################################"
        break next
                                                                       }
    else {
        Write-Host "#######################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "#######################################"
 

    Add-Computer -DomainName "Ucdenver.pvt"  -Credential $Cred -OUPATH "OU=IWKS,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{
    $RoomNumber = Read-Host "What is the room number the device will be located? This will be used in the middle of the naming convention: IWKS-######-D1. Please add NC if it's in North Classroom eg: NC2206"
    $DeviceType = Read-Host "Lastly, what type of device is this? (D)esktop, (L)aptop, (M)ac (Desktop and laptops), or (AIO) for Windows-based All-in-Ones" 
    $CustomHost = "IWKS-$RoomNumber-$DeviceType"
    $i = 1
    $serverlist = $CustomHost
    $CustomHostInc = $CustomHost

foreach ($server in $serverlist) {
    #Import-Module ActiveDirectory
    Do {
        Write-Host "#################################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "#################################################################################################################"
        $CustomHostInc = $CustomHost + $i++
    } while (Get-ADComputer -Server "132.194.70.65" -filter "Name -like '*$CustomHostInc'" -Credential $Cred)
    }

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." -ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Cred -Force
    sleep 5
    Add-Computer -ComputerName $OldComputerName -DomainName "Ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Cred #-Restart
    $computerError
    pause
        
       }
    }    
    }
    '8'{'LABS'
        $selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent hostname?"
    switch ($selectionCHOF)
    {'C'{ 
        $serverlist = $hostname
        do {
            "Current hostname ($hostname) is longer than 15 characters! Exiting!"
            break next
           } while($RenameHost.Length -gt 15)

foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "#######################################"  
        Write-Host "Computer object already exists. Exiting"
        Write-Host "#######################################"
        break next
                                                                       }
    else {
        Write-Host "#######################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "#######################################"
 

    Add-Computer -DomainName "Ucdenver.pvt"  -Credential $Cred -OUPATH "OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{
    $RoomNumber = Read-Host "What is the room number the device will be located? This will be used in the middle of the naming convention: LABS-######-D1. Please add NC if it's in North Classroom eg: NC2206"
    $DeviceType = Read-Host "Lastly, what type of device is this? (D)esktop, (L)aptop, (M)ac (Desktop and laptops), or (AIO) for Windows-based All-in-Ones" 
    $CustomHost = "LABS-$RoomNumber-$DeviceType"
    $i = 1
    $serverlist = $CustomHost
    $CustomHostInc = $CustomHost

foreach ($server in $serverlist) {
    #Import-Module ActiveDirectory
    Do {
        Write-Host "#################################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "#################################################################################################################"
        $CustomHostInc = $CustomHost + $i++
    } while (Get-ADComputer -Server "132.194.70.65" -filter "Name -like '*$CustomHostInc'" -Credential $Cred)
    }

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." -ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Cred -Force
    sleep 5
    Add-Computer -ComputerName $OldComputerName -DomainName "Ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Cred #-Restart
    $computerError
    pause
        
       }
    }    
    }
    '9'{'MECH'
        $selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent hostname?"
    switch ($selectionCHOF)
    {'C'{ 
        $serverlist = $hostname
        do {
            "Current hostname ($hostname) is longer than 15 characters! Exiting!"
            break next
           } while($RenameHost.Length -gt 15)

foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "#######################################"  
        Write-Host "Computer object already exists. Exiting"
        Write-Host "#######################################"
        break next
                                                                       }
    else {
        Write-Host "#######################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "#######################################"
 

    Add-Computer -DomainName "Ucdenver.pvt"  -Credential $Cred -OUPATH "OU=MECH,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{
    $RoomNumber = Read-Host "What is the room number the device will be located? This will be used in the middle of the naming convention: MECH-######-D1. Please add NC if it's in North Classroom eg: NC2206"
    $DeviceType = Read-Host "Lastly, what type of device is this? (D)esktop, (L)aptop, (M)ac (Desktop and laptops), or (AIO) for Windows-based All-in-Ones" 
    $CustomHost = "MECH-$RoomNumber-$DeviceType"
    $i = 1
    $serverlist = $CustomHost
    $CustomHostInc = $CustomHost

foreach ($server in $serverlist) {
    #Import-Module ActiveDirectory
    Do {
        Write-Host "#################################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "#################################################################################################################"
        $CustomHostInc = $CustomHost + $i++
    } while (Get-ADComputer -Server "132.194.70.65" -filter "Name -like '*$CustomHostInc'" -Credential $Cred)
    }

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." -ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Cred -Force
    sleep 5
    Add-Computer -ComputerName $OldComputerName -DomainName "Ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Cred #-Restart
    $computerError
    pause
        
       }
    }    
    }
    '10'{'SRVS'
        $selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent hostname?"
    switch ($selectionCHOF)
    {'C'{ 
        $serverlist = $hostname
        do {
            "Current hostname ($hostname) is longer than 15 characters! Exiting!"
            break next
           } while($RenameHost.Length -gt 15)

foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "#######################################"  
        Write-Host "Computer object already exists. Exiting"
        Write-Host "#######################################"
        break next
                                                                       }
    else {
        Write-Host "#######################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "#######################################"
 

    Add-Computer -DomainName "Ucdenver.pvt"  -Credential $Cred -OUPATH "OU=SRVS,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{
    $RoomNumber = Read-Host "What is the room number the device will be located? This will be used in the middle of the naming convention: SRVS-######-D1. Please add NC if it's in North Classroom eg: NC2206"
    $DeviceType = Read-Host "Lastly, what type of device is this? (D)esktop, (L)aptop, (M)ac (Desktop and laptops), or (AIO) for Windows-based All-in-Ones" 
    $CustomHost = "SRVS-$RoomNumber-$DeviceType"
    $i = 1
    $serverlist = $CustomHost
    $CustomHostInc = $CustomHost

foreach ($server in $serverlist) {
    #Import-Module ActiveDirectory
    Do {
        Write-Host "#################################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "#################################################################################################################"
        $CustomHostInc = $CustomHost + $i++
    } while (Get-ADComputer -Server "132.194.70.65" -filter "Name -like '*$CustomHostInc'" -Credential $Cred)
    }

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." -ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Cred -Force
    sleep 5
    Add-Computer -ComputerName $OldComputerName -DomainName "Ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Cred #-Restart
    $computerError
    pause
        
       }
    }    
    }
    '11'{'Test'
        $selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent hostname?"
    switch ($selectionCHOF)
    {'C'{ 
        $serverlist = $hostname
        do {
            "Current hostname ($hostname) is longer than 15 characters! Exiting!"
            break next
           } while($RenameHost.Length -gt 15)

foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "#######################################"  
        Write-Host "Computer object already exists. Exiting"
        Write-Host "#######################################"
        break next
                                                                       }
    else {
        Write-Host "#######################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "#######################################"
 

    Add-Computer -DomainName "Ucdenver.pvt"  -Credential $Cred -OUPATH "OU=TEST,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{
    $RoomNumber = Read-Host "What is the room number the device will be located? This will be used in the middle of the naming convention: TEST-######-D1. Please add NC if it's in North Classroom eg: NC2206"
    $DeviceType = Read-Host "Lastly, what type of device is this? (D)esktop, (L)aptop, (M)ac (Desktop and laptops), or (AIO) for Windows-based All-in-Ones" 
    $CustomHost = "TEST-$RoomNumber-$DeviceType"
    $i = 1
    $serverlist = $CustomHost
    $CustomHostInc = $CustomHost

foreach ($server in $serverlist) {
    #Import-Module ActiveDirectory
    Do {
        Write-Host "#################################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "#################################################################################################################"
        $CustomHostInc = $CustomHost + $i++
    } while (Get-ADComputer -Server "132.194.70.65" -filter "Name -like '*$CustomHostInc'" -Credential $Cred)
    }

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." -ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Cred -Force
    sleep 5
    Add-Computer -ComputerName $OldComputerName -DomainName "Ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Cred #-Restart
    $computerError
    pause
        
       }
    }    
    }
    'Q' {break start}
    'B' {'Going back to the main menu...' 
    break next}
    }
    }    until ($selection -eq 'q')
    

    # present list of choices: what department should the host be located in AD?. after picking, ask if they wish to use the current hostname (print on screen) or assistance
    #assistance = checking AD using current naming conventions to see if computer already exists. if not use. If it does, enumerate +1 eg: if CEDC-CART-L35 exists then use CEDC-CART-L36 
    #in future possibly have so you can add multiple in various OU's at the same time: either 2 files (one for hostname, one for OU location) or hostname space then OU in same file
    }
    'M' {'You chose adding a list of hosts to AD. Make sure the file is in the same folder as this DJS.ps1 file.'
    $ComputerListLocation = Read-Host "What is the name of the file (including extension eg: Servers.txt)?"
    $ComputerOULocation = Read-Host "Also, what 4-digit OU code would you like these in?(BIOE, CIVL, CSCI, DEAN, ECSG, ELEC, IWKS, LABs, MECH, SRVS, or Test) "
    Add-Computer  -ComputerName (Get-Content -Path .\$ComputerListLocation) -Credential $Cred -DomainName "Ucdenver.pvt" -OUPATH "OU=$ComputerOULocation,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    "One and done"
    pause
    }
    } 
   


    } 
    '2' {
    'You chose option #2: unjoin the domain.'
    remove-computer -Credential $Cred -passthru -verbose
    # if doesn't work, try Remove-Computer -ComputerName "Server64", "localhost" -UnjoinDomainCredential ss64dom\Admin64 -WorkgroupName "Local" -Restart -Force
    "Host was successfully unjoined from the domain. You should restart for changing to take effect."
      $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
      switch ($RestartHost){
      'Y'{Restart-Computer 
    }'N'{}
    }
    } '3' {
      'You chose option #3: rename this host locally.'
      do {
  $RenameHost = Read-Host "What would you like your new hostname to be? (Will keep asking until 15 characters or less)"
         } while($RenameHost.Length -gt 15)
      
      Rename-Computer -NewName $RenameHost -DomainCredential $Cred #-Restart
      "Host was successfully renamed to $RenameHost. You should restart for changing to take effect."
      $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
      switch ($RestartHost){
      'Y'{Restart-Computer 
    }'N'{}
    }
    } '4' {
      'You chose option #4: join the domain using the current hostname (CEAS only).'
      $CutLength = hostname
      $ReadOU = $CutLength.SubString(0,4)
      "This involves using the first 4 letters of your current hostname to set the correct OU path. Those first four are $ReadOU."  
      $JoinNow = Read-Host "If this is the correct OU/folder in CEAS, would you like to join now?(Y or N)"
      switch ($JoinNow){
      'Y'{Add-Computer -DomainName "Ucdenver.pvt"  -Credential $Cred -OUPATH "OU=$ReadOU,OU=CEAS,DC=ucdenver,DC=pvt" -force -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError 
    }'N'{break next}
    }
      $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
      switch ($RestartHost){
      'Y'{Restart-Computer 
    }'N'{break next}
    }
      
    }
    }
    pause
 }
 until ($selection -eq 'q')