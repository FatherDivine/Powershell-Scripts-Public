# Created by Aaron S. for CU Denver CEDC IT Dept

#New-Variable -Name ADUN -Value statena -Scope "Global"
#New-Variable -Name ADPW -Value testing -Scope "Global"
$ADUN = 'statena'
$ADPW = 'test'
$password = ConvertTo-SecureString "" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ("UNIVERSITY\statena", $password)
$hostname = hostname
$computername = $hostname
$CustomHost= 0 #$Dept(set when they click on dept for first time)-$room-$DeviceType(D=desktop, L=Laptop, M=Mac)# (number +1 if exists infinitely)

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
    Write-Host "4: Press '4' to join the domain manually(Advanced)."
    # have manual mode that allows user to supply the branch started with ucdenver.pvt> for use with CAM or others.
    # Also a mode that supplies a file list of names typed in a .txt (or no extension) file to be added all at once.
    Write-Host "Q: Press 'Q' to quit."
    ""
    "Remember, total length of the hostname must be 15 characters or less."
}$
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
    $selectionDJ = Read-Host "Will you be adding a single computer or multiple (list file)? (type (S) for single or (M) for multiple)"
    switch ($selectionDJ)
    {
    'S' {'You choose adding a single host to AD'
    :next do{
    Show-Dept-Menu
    $selectionSHD = Read-Host "Which Department would you like to place the host in?"
    switch ($selectionSHD)
    {
    '1'{'BIOE'
    $selectionCHOF = Read-Host "Do you wish to use the current hostname of the computer or find a working hostname? (type (C) for current hostname or (F) for find a working hostname)"
    switch ($selectionCHOF)
    {'C'{ 
     $serverlist = $hostname
 #$serverlist = get-content ServerList.txt
foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "###############################"  
        Write-Host "Computer object already exists"
        Write-Host "###############################"
        break next
    }
    else {
        Write-Host "########################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "########################################"
 

    Add-Computer  -LocalCredential cladmin -DomainName "Ucdenver.pvt"  -Credential UNIVERSITY\statena -OUPATH "OU=BIOE,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{
    $RoomNumber = Read-Host "What is the room number the device will be located? This will be used in the middle of the naming convention: BIOE-######-D1. Please add NC if it's in North Classroom eg NC2206"
    $DeviceType = Read-Host "Lastly, what type of device is this? Enter D for desktop, L for laptop, M for Mac (Desktop and laptops), or AIO for All-in-Ones" 
    $CustomHost = "BIOE-$RoomNumber-$DeviceType"
    $i = 1
    $serverlist = $CustomHost
    $CustomHostInc = $CustomHost

foreach ($server in $serverlist) {
    #Import-Module ActiveDirectory
    Do {
        Write-Host "######################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "######################################################################################################"
        $CustomHostInc = $CustomHost + $i++
    } while (Get-ADComputer -Server "132.194.70.65" -filter "Name -like '*$CustomHostInc'" -Credential $Cred)
    }
 

    #Rename local host, then join to domain.
    "$CustomHostInc is the name last found to not be in AD"
    #Rename-Computer -NewName $CustomHost -DomainCredential UNIVERSITY\statena #-Restart
    #Rename-Computer -NewName $CustomHost -Credential $Cred
    (Get-WmiObject win32_computersystem).Rename( $CustomHostInc,$password,'UNIVERSITY\statena')
    #Add-Computer  -LocalCredential cladmin -DomainName "Ucdenver.pvt"  -Credential UNIVERSITY\statena -OUPATH "OU=BIOE,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    Add-Computer -DomainName "Ucdenver.pvt"  -Credential $Cred -OUPATH "OU=BIOE,OU=CEAS,DC=ucdenver,DC=pvt" -force -Options JoinWithNewName -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       
}
    #Now check if custom host exists in AD
    #Ask for the room # so can form hostname: CEDC-NC2612A-L2. Use naming convention document on \\data\dept\ceas\its
    #combine parts eg: $customHost= $Dept(set when they click on dept for first time)-$room-$DeviceType(D=desktop, L=Laptop, M=Mac)# (number +1 if exists infinitely)
    }
   }


    '2'{'CIVL'
        $selectionCHOF = Read-Host "Do you wish to use the current hostname of the computer or find a working hostname? (type (C) for current hostname or (F) for find a working hostname)"
    switch ($selectionCHOF)
    {'C'{ 
     $serverlist = $hostname
 #$serverlist = get-content ServerList.txt
foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "###############################"  
        Write-Host "Computer object already exists"
        Write-Host "###############################"
        break next
    }
    else {
        Write-Host "########################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "########################################"
 

    Add-Computer  -LocalCredential cladmin -DomainName "Ucdenver.pvt"  -Credential UNIVERSITY\statena -OUPATH "OU=CIVL,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{}
    }
    }
    '3'{'CSCI'
        $selectionCHOF = Read-Host "Do you wish to use the current hostname of the computer or find a working hostname? (type (C) for current hostname or (F) for find a working hostname)"
    switch ($selectionCHOF)
    {'C'{ 
     $serverlist = $hostname
 #$serverlist = get-content ServerList.txt
foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "###############################"  
        Write-Host "Computer object already exists"
        Write-Host "###############################"
        break next
    }
    else {
        Write-Host "########################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "########################################"
 

    Add-Computer  -LocalCredential cladmin -DomainName "Ucdenver.pvt"  -Credential UNIVERSITY\statena -OUPATH "OU=CSCI,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{}
    }    
    }
    '4'{'DEAN'
        $selectionCHOF = Read-Host "Do you wish to use the current hostname of the computer or find a working hostname? (type (C) for current hostname or (F) for find a working hostname)"
    switch ($selectionCHOF)
    {'C'{ 
     $serverlist = $hostname
 #$serverlist = get-content ServerList.txt
foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "###############################"  
        Write-Host "Computer object already exists"
        Write-Host "###############################"
        break next
    }
    else {
        Write-Host "########################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "########################################"
 

    Add-Computer  -LocalCredential cladmin -DomainName "Ucdenver.pvt"  -Credential UNIVERSITY\statena -OUPATH "OU=DEAN,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{}
    }    
    }
    '5'{'ECSG'
    $selectionCHOF = Read-Host "Do you wish to use the current hostname of the computer or find a working hostname? (type (C) for current hostname or (F) for find a working hostname)"
    switch ($selectionCHOF)
    {'C'{ 
    
 $serverlist = $hostname
 #$serverlist = get-content ServerList.txt
foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "###############################"  
        Write-Host "Computer object already exists"
        Write-Host "###############################"
        break next
    }
    else {
        Write-Host "########################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "########################################"
 

    Add-Computer  -LocalCredential cladmin -DomainName "Ucdenver.pvt"  -Credential UNIVERSITY\statena -OUPATH "OU=ECSG,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{}
    }
    }
    '6'{'ELEC'
        $selectionCHOF = Read-Host "Do you wish to use the current hostname of the computer or find a working hostname? (type (C) for current hostname or (F) for find a working hostname)"
    switch ($selectionCHOF)
    {'C'{ 
     $serverlist = $hostname
 #$serverlist = get-content ServerList.txt
foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "###############################"  
        Write-Host "Computer object already exists"
        Write-Host "###############################"
        break next
    }
    else {
        Write-Host "########################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "########################################"
 

    Add-Computer  -LocalCredential cladmin -DomainName "Ucdenver.pvt"  -Credential UNIVERSITY\statena -OUPATH "OU=ELEC,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{}
    }    
    }
    '7'{'IWKS'
        $selectionCHOF = Read-Host "Do you wish to use the current hostname of the computer or find a working hostname? (type (C) for current hostname or (F) for find a working hostname)"
    switch ($selectionCHOF)
    {'C'{ 
     $serverlist = $hostname
 #$serverlist = get-content ServerList.txt
foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "###############################"  
        Write-Host "Computer object already exists"
        Write-Host "###############################"
        break next
    }
    else {
        Write-Host "########################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "########################################"
 

    Add-Computer  -LocalCredential cladmin -DomainName "Ucdenver.pvt"  -Credential UNIVERSITY\statena -OUPATH "OU=IWKS,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{}
    }    
    }
    '8'{'LABS'
        $selectionCHOF = Read-Host "Do you wish to use the current hostname of the computer or find a working hostname? (type (C) for current hostname or (F) for find a working hostname)"
    switch ($selectionCHOF)
    {'C'{ 
     $serverlist = $hostname
 #$serverlist = get-content ServerList.txt
foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "###############################"  
        Write-Host "Computer object already exists"
        Write-Host "###############################"
        break next
    }
    else {
        Write-Host "########################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "########################################"
 

    Add-Computer  -LocalCredential cladmin -DomainName "Ucdenver.pvt"  -Credential UNIVERSITY\statena -OUPATH "OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{}
    }    
    }
    '9'{'MECH'
        $selectionCHOF = Read-Host "Do you wish to use the current hostname of the computer or find a working hostname? (type (C) for current hostname or (F) for find a working hostname)"
    switch ($selectionCHOF)
    {'C'{ 
     $serverlist = $hostname
 #$serverlist = get-content ServerList.txt
foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "###############################"  
        Write-Host "Computer object already exists"
        Write-Host "###############################"
        break next
    }
    else {
        Write-Host "########################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "########################################"
 

    Add-Computer  -LocalCredential cladmin -DomainName "Ucdenver.pvt"  -Credential UNIVERSITY\statena -OUPATH "OU=MECH,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{}
    }    
    }
    '10'{'SRVS'
        $selectionCHOF = Read-Host "Do you wish to use the current hostname of the computer or find a working hostname? (type (C) for current hostname or (F) for find a working hostname)"
    switch ($selectionCHOF)
    {'C'{ 
     $serverlist = $hostname
 #$serverlist = get-content ServerList.txt
foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "###############################"  
        Write-Host "Computer object already exists"
        Write-Host "###############################"
        break next
    }
    else {
        Write-Host "########################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "########################################"
 

    Add-Computer  -LocalCredential cladmin -DomainName "Ucdenver.pvt"  -Credential UNIVERSITY\statena -OUPATH "OU=SRVS,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{}
    }    
    }
    '11'{'Test'
        $selectionCHOF = Read-Host "Do you wish to use the current hostname of the computer or find a working hostname? (type (C) for current hostname or (F) for find a working hostname)"
    switch ($selectionCHOF)
    {'C'{ 
     $serverlist = $hostname
 #$serverlist = get-content ServerList.txt
foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host "###############################"  
        Write-Host "Computer object already exists"
        Write-Host "###############################"
        break next
    }
    else {
        Write-Host "########################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "########################################"
 

    Add-Computer  -LocalCredential cladmin -DomainName "Ucdenver.pvt"  -Credential UNIVERSITY\statena -OUPATH "OU=TEST,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    pause
       }
}
    }
    'F'{}
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
    $ComputerListLocation = Read-Host "What is the name of the file (including extension)?"
    $ComputerOULocation = Read-Host "Also, what 4-digit OU code would you like these in?(BIOE, CIVL, CSCI, DEAN, ECSG, ELEC, IWKS, LABs, MECH, SRVS, or Test) "
    Add-Computer  -ComputerName (Get-Content -Path .\$ComputerListLocation) -LocalCredential cladmin -DomainName "Ucdenver.pvt"  -Credential UNIVERSITY\statena -OUPATH "OU=$ComputerOULocation,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    "One and done"
    pause
    #Above may need more testing. same as any join.
    #Add-Computer -ComputerName (Get-Content Computers.txt) -LocalCredential Administrator -DomainName IMG.local -Credential IMG\Administrator -Restart -Force
    #add-computer -computername (get-content servers.txt) -domainname ad.contoso.com –credential AD\adminuser -restart –force
    #Add-Computer -ComputerName (Get-Content Servers.txt) -DomainName Domain02 -Credential Domain02\Admin02 -Options Win9xUpgrade  -Restart
    #unjoin Add-Computer -ComputerName "Server64", "Server65", "localhost" -Domain "SS64Dom" -LocalCredential oldDom\User01 -UnjoinDomainCredential oldDom\Admin01 -Credential SS64Dom\Admin64 -Restart


    }
    } 
   


    } 
    '2' {
    'You chose option #2: unjoin the domain.'
    remove-computer -credential UNIVERSITY\statena -passthru -verbose
    # if doesn't work, try Remove-Computer -ComputerName "Server64", "localhost" -UnjoinDomainCredential ss64dom\Admin64 -WorkgroupName "Local" -Restart -Force
    "Host was successfully unjoined from the domain. You should restart for changing to take effect."
      $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
      switch ($RestartHost){
      'Y'{Restart-Computer 
    }'N'{}
    }
    } '3' {
      'You chose option #3: rename this host locally.'
      $RenameHost = Read-Host "What would you like your new hostname to be?"
      Rename-Computer -NewName $RenameHost -DomainCredential UNIVERSITY\statena #-Restart
      "Host was successfully renamed to $RenameHost. You should restart for changing to take effect."
      $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
      switch ($RestartHost){
      'Y'{Restart-Computer 
    }'N'{}
    }
    } '4' {
      'You chose option #4: join the domain manually (Advanced. Right now just joins).'
      Add-Computer -DomainName "Ucdenver.pvt"  -Credential $Cred -OUPATH "OU=BIOE,OU=CEAS,DC=ucdenver,DC=pvt" -force -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError
    }
    }
    pause
 }
 until ($selection -eq 'q')