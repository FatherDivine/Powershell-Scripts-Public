<#
  .SYNOPSIS
    Domain tool that allows one to join & unjoin objects to AD, as well as rename computers.

  .DESCRIPTION
    The DJT.ps1 script allows CEDC IT Staff to not only join and unjoin objects to the UCDENVER Active Directory,
    but also rename computers locally. The script has many failsafes and checks to make sure everything is done right.
    This script can't delete objects, as this is best done manually.

  .PARAMETER RHost
    Specifies a remote host that can be piped thru command line as such:
    
    When piped thru the script (with the other mandatory parameters like at least 2-3 OU's,
    will check if exists as typed and if not join to the domain. Ping the host first.
    
  .PARAMETER LHost
    Specifies the local computer as the target for joining to the domain.
    Can be used at the command line as such:
    .\DJT.ps1 -LHost -OU1 "BIOE" 

  .PARAMETER RenameRHost
    Specifies a remote host as the target for renaming of the hostname.
    Can be used at the command line as such:

    .\DJT.ps1 -RenameRHost "Remote-Host-Name" -Restart Y

    When used in conjunction with the Restart parameter.

  .PARAMETER RenameLHost
    Specifies the local computer as the target for renaming of the hostname.
    Can be used at the command line as such:
      
    .\DJT.ps1 -RenameLHost "NameToRename" -Restart N
      
    When used in conjunction with the Restart parameter.

  .PARAMETER Restart
    Feeds a forced restart that can be Yes or No.
    Useful for when renaming hosts or joining the domain.


  .PARAMETER List
    Allows for a list of computers to be piped from the command line.

  .LINK
    \\DATA\DEPT\CEAS\ITS\Software\Scripts\Domain Join Tool (Testing)
  
  .INPUTS
    None. You cannot pipe objects to DJT.ps1.

  .OUTPUTS
    None. DJS.ps1 does not generate any output.
    DJT.ps1 generates 

  .EXAMPLE
    PS> .\DJT.ps1

  .Author
    Created by Aaron S. for CU Denver CEDC IT Dept
  
  .Notes
   
  .To-Do 
   Multiple methods of running tool: sign-on script that just joins current domain without user intervention
   Also FOG script (like linux rename_host) that auto joins
   Additions: Possible safety for each dept that, when using current hostname feature, checks that the first 4 of the hostname are equal to the dept they are in (EG BIOEs checks for BIOE- first then exits if not)
   Addition: Add manual AD mode that allows to edit description (for Service Tag), OS, Managed by, and other variables in AD by manually inputting a hostname (checks if something written firsts, outputs then asks if wants to rewrite or append


#Error Exception Finder
[appdomain]::CurrentDomain.GetAssemblies() | ForEach {
    Try {
        $_.GetExportedTypes() | Where {
            $_.Fullname -match 'Exception'
        }
    } Catch {}
} | Select FullName
  
System.DirectoryServices.DirectoryServicesCOMException                
System.DirectoryServices.ActiveDirectory.ActiveDirectoryObjectNotFo...
System.DirectoryServices.ActiveDirectory.ActiveDirectoryOperationEx...
System.DirectoryServices.ActiveDirectory.ActiveDirectoryServerDownE...
System.DirectoryServices.ActiveDirectory.ActiveDirectoryObjectExist...
System.DirectoryServices.ActiveDirectory.SyncFromAllServersOperatio...
System.DirectoryServices.ActiveDirectory.ForestTrustCollisionException
 #>

#Get admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}

$WarningPreference = "Continue"
$hn = hostname
$hostnameLength = $hn.length
$OldComputerName = $hn #Using to keep track of old PC name
$CustomHost= "0" #Couldn't be null to begin
$IntroPlayed = "F" #Controls if intro graphic will play or not. Speeds up having to go back to the main menu.

#Credentials section
$key = Import-Clixml -LiteralPath ${PSScriptRoot}\Key.xml
$importObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml
$secureString = ConvertTo-SecureString -String $importObject.Password -Key $key
$Credential = New-Object System.Management.Automation.PSCredential($importObject.UserName, $secureString)

#Functions section
#Because, ASCII RAWKS
function Intro
{
$t = @"

████████ ██   ██ ███████
   ██    ██   ██ ██
   ██    ███████ █████
   ██    ██   ██ ██
   ██    ██   ██ ███████


██████   ██████  ███    ███  █████  ██ ███    ██          ██  ██████  ██ ███    ██     ████████  ██████   ██████  ██
██   ██ ██    ██ ████  ████ ██   ██ ██ ████   ██          ██ ██    ██ ██ ████   ██        ██    ██    ██ ██    ██ ██
██   ██ ██    ██ ██ ████ ██ ███████ ██ ██ ██  ██          ██ ██    ██ ██ ██ ██  ██        ██    ██    ██ ██    ██ ██
██   ██ ██    ██ ██  ██  ██ ██   ██ ██ ██  ██ ██     ██   ██ ██    ██ ██ ██  ██ ██        ██    ██    ██ ██    ██ ██
██████   ██████  ██      ██ ██   ██ ██ ██   ████      █████   ██████  ██ ██   ████        ██     ██████   ██████  ███████

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
function Show-Menu
{
    param (
           [string]$Title = 'CEDC Domain Join Tool'
          )
    #Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' to join the domain."
    Write-Host "2: Press '2' to unjoin the domain."
    Write-Host "3: Press '3' to rename this host locally."
    Write-Host "4: Press '4' to join the domain using current hostname."
    Write-Host "Q: Press 'Q' to quit.`n"
    Write-Host "Total length of the hostname cannot exceed 15 characters." 
    Write-Host "The current hostname ($hn) is $hostnameLength characters long."
}
function Show-Dept-Menu
{
param (
       [string]$DeptTitle = 'Faculty & Staff Departments'
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
    Write-Host "8: MECH: Mechanical Engineering"
    Write-Host "9: Test: Testing OU"
    Write-Host "B: Press 'B' to go back to the main menu."
    Write-Host "Q: Press 'Q' to quit."
}
function Show-LABS-Menu
{
param (
       [string]$DeptTitle = 'Computer Labs'
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
    Write-Host "B: Press 'B' to go back to the main menu."
    Write-Host "Q: Press 'Q' to quit."

}
function Show-Who-Menu
{
param (
       [string]$DeptTitle = 'Where does the object belong?'
      )
    Clear-Host
    Write-Host "================ $DeptTitle ================"
    
    Write-Host "1: Faculty/Staff"
    Write-Host "2: Computer Labs"
    Write-Host "3: Server"
    Write-Host "B: Press 'B' to go back to the main menu."
    Write-Host "Q: Press 'Q' to quit."
}
function Show-Server-Dept-Menu
{
param (
       [string]$DeptTitle = 'Server Departments'
      )
    Clear-Host
    Write-Host "================ $DeptTitle ================"
    
    Write-Host "1: BIOE: Bio Engineering"
    Write-Host "2: CIVL: Civil Engineering"
    Write-Host "3: CSCI: Computer Science"
    Write-Host "4: DEAN: Office of the Dean"
    Write-Host "5: ECSG: NC2612A and Administration OU"
    Write-Host "6: ELEC: Electrical Engineering"
    Write-Host "7: MECH: Mechanical Engineering"
    Write-Host "8: Test: Testing OU"
    Write-Host "B: Press 'B' to go back to the main menu."
    Write-Host "Q: Press 'Q' to quit."
}
function Show-Server-Category-Menu
{
param (
       [string]$DeptTitle = 'What category does this server belon?'
      )
    Clear-Host
    Write-Host "================ $DeptTitle ================"
    
    Write-Host "1: Administration"
    Write-Host "2: Instructional"
    Write-Host "3: Research`n"
    Write-Host "B: Press 'B' to go back to the main menu."
    Write-Host "Q: Press 'Q' to quit."
}
function Show-Server-Purpose-Menu
{
param (
       [string]$DeptTitle = 'What is the Purpose of the Server?'
      )
    Clear-Host
    Write-Host "================ $DeptTitle ================"
    
    Write-Host "1: APP: Application Server     | 5: FOG: FOG Server"
    Write-Host "2: DATA: Data Storage Server   | 6: LIC: License Server"
    Write-Host "3: DB: Database Server         | 7: PRNT: Print Server"
    Write-Host "4: FILE: File Server           | 8 : WWW: Webserver`n"
    Write-Host "B: Press 'B' to go back to the main menu."
    Write-Host "Q: Press 'Q' to quit."
}

#Function to rename computer, function to join domain, function to unjoin, etc. Just feed info into function. simplify script
 function DJT{
 [cmdletbinding()]
Param
       (
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$true)]
       [string]$JoinDomain=$NULL,
       $errorlog,
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$true)]
       [string]$UnjoinDomain=$NULL,
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$true)]
       [string]$RenameLHost
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

            'DomainJoin' {

                #perform actions if ParamOne is used
                
                $result.SuccessOne = $true
                
            }

            'ParamTwo' {

                #perform logic if ParamTwo is used
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
:start do
 {
    Clear-Host
    while ($IntroPlayed -ne "T"){Intro ; $IntroPlayed = "T"} #To speed up the graphics if having to go back to the menu.
    
    Show-Menu #swap out to if they are joining or what first, then to faculty/staff, labs etc. 
    $selection = Read-Host "Please make a selection"
    :next switch ($selection)
    {'1'{
    $DEPT = 'F'
    $DEPTSelection = '99'
    Show-Who-Menu
    $selection2 = Read-Host "Please make a selection"
    switch ($selection2)
    {'1'{'Faculty/Staff'
    
    Clear-Host
    Show-Dept-Menu
    do{$DEPTSelection = Read-Host "Please make a selection"} 
       while ($DEPTSelection -notmatch "^(1|2|3|4|5|6|7|8|9|10|B|Q)$")
       if ($DEPTSelection -eq '1'){$DEPT = 'BIOE';$DescLocation = 'North Classroom Floor 2'}
       elseif ($DEPTSelection -eq '2'){$DEPT = 'CIVL';$DescLocation = 'North Classroom Floor 2'}
       elseif ($DEPTSelection -eq '3'){$DEPT = 'CSCI';$DescLocation = 'Lawrence Street Floor 8'}
       elseif ($DEPTSelection -eq '4'){$DEPT = 'DEAN';$DescLocation = 'North Classroom Floor 3'}
       elseif ($DEPTSelection -eq '5'){$DEPT = 'ECSG';$DescLocation = 'North Classroom Floor 2 #2612'}
       elseif ($DEPTSelection -eq '6'){$DEPT = 'ELEC';$DescLocation = 'North Classroom Floor 2'}
       elseif ($DEPTSelection -eq '7'){$DEPT = 'IWKS';$DescLocation = 'Lawrence Court and UC Denver Buildings, 1250 14th St #1300'}
       elseif ($DEPTSelection -eq '8'){$DEPT = 'MECH';$DescLocation = 'North Classroom Floor 2'}
       elseif ($DEPTSelection -eq '9'){$DEPT = 'Test';$DescLocation = 'Testing Location'}
       elseif ($DEPTSelection -eq 'B'){break next}
       elseif ($DEPTSelection -eq 'Q'){exit}
       else{continue}

       #BEG of param.
       $selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent one?"
    switch ($selectionCHOF)
    {'C'{ 
           $hn = hostname
           $hostnameLength = $hn.length
           While ($hostnameLength -ge 16){
           Write-Host "Current hostname ($hn) is longer than 15 characters($hostnameLength)! Exiting to main menu!"
           break next
                                         }
           #Make sure starts with a dept string eg: BIOE-
           $CutLength = hostname
           $ReadOU = $CutLength.SubString(0,5)
           Write-Host "$ReadOU" #Test function

           if($DEPT -eq 'BIOE' -and $ReadOU -notmatch 'BIOE-'){Write-Host "Current hostname ($hn) does NOT start with `"BIOE-`". Exiting!";break next}
           elseif($DEPT -eq 'CIVL' -and $ReadOU -notmatch 'CIVL-'){Write-Host "Current hostname ($hn) does NOT start with `"CIVL-`". Exiting!";break next}
           elseif($DEPT -eq 'CSCI' -and $ReadOU -notmatch 'CSCI-'){Write-Host "Current hostname ($hn) does NOT start with `"CSCI-`". Exiting!";break next}
           elseif($DEPT -eq 'DEAN' -and $ReadOU -notmatch 'CEDC-'){Write-Host "Current hostname ($hn) does NOT start with `"CEDC-`". Exiting!";break next}
           elseif($DEPT -eq 'ECSG' -and $ReadOU -notmatch 'CEDC-'){Write-Host "Current hostname ($hn) does NOT start with `"CEDC-`". Exiting!";break next}
           elseif($DEPT -eq 'ELEC' -and $ReadOU -notmatch 'ELEC-'){Write-Host "Current hostname ($hn) does NOT start with `"ELEC-`". Exiting!";break next}
           elseif($DEPT -eq 'IWKS' -and $ReadOU -notmatch 'IWKS-'){Write-Host "Current hostname ($hn) does NOT start with `"IWKS-`". Exiting!";break next}
           elseif($DEPT -eq 'MECH' -and $ReadOU -notmatch 'MECH-'){Write-Host "Current hostname ($hn) does NOT start with `"MECH-`". Exiting!";break next}
           #elseif($DEPT -eq 'Test' -and $ReadOU -notmatch 'CIVL-'){Write-Host "Current hostname ($hn) does NOT start with `"CEDC-`". Exiting!";break next}
           else{continue}


    if (@(Get-ADComputer $hn -ErrorAction SilentlyContinue).Count) {
        Write-Host "###########################################################"  
        Write-Host "Computer object already exists in Active Directory. Exiting"
        Write-Host "###########################################################"
        break next
                                                                   }
    else {
        Write-Host "#######################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "#######################################"
 
        try{
            Add-Computer -DomainName "ucdenver.pvt"  -Credential $Credential -OUPATH "OU=$DEPT,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction Stop -ErrorVariable computerError 
           }

        catch{
             Write-Warning "`nDetected errors:`n"
             Write-Error "$_"
             break start
             }
        Write-Host "Host was successfully joined to the domain. You should restart for changing to take effect."
        $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
        switch ($RestartHost){
        'Y'{Restart-Computer 
           }'N'{break next}
                             }
    pause
         }
        }'F'{
    #Get $Location first. Read-Host
    $Location = Read-Host "What is the room number? This is the center portion of the hostname (Ex: BIOE-XXXXXXX-D1):"
    #Write-Host "What type of device is this? (D)esktop or (L)aptop?"
    #$DeviceType = Read-Host "Type D for Desktop or L for laptop. This will be amended to the hostname:" 
    do{$OSSelection = Read-Host "What OS is this for? (W)indows, (L)inux, or (M)ac?"}
    while ($OSSelection -notmatch "^(B|L|M|Q|W)$")
    if ($OSSelection -eq 'W'){$OSFull = 'Windows'}
     elseif ($OSSelection -eq 'L'){$OSFull = 'Linux'}
     elseif ($OSSelection -eq 'M'){$OSFull = 'Mac OSX'}
     elseif ($LABSelection -eq 'B'){break next}
     elseif ($LABSelection -eq 'Q'){exit}
     else {continue}

    $CustomHost = "$DEPT-$Location-"
    $i = 1
    #redundant $serverlist = $CustomHost
    #$CustomHostInc = $CustomHost

    Do {
        Write-Host "#################################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "#################################################################################################################"
        $CustomHostInc = $CustomHost + $i++ + $OS #IF don't work, turn to like to see if up to BIOE-XXXX-1 exists, if so just skip it.
       } while (Get-ADComputer -Server "ucdenver.pvt" -filter "Name -like '*$CustomHostInc'" -Credential $Credential) #test using -match instead of -like

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." #-ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Credential -Force
    sleep 5
    Add-Computer -ComputerName $OldComputerName -DomainName "ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Credential #-Restart
    Write-Error "$computerError"

    #After joining to domain, pull service tag and set other object parameters 
    Write-Host "`nAttempting to set description information for $CustomHostInc in AD..."
    $ADPC = Get-ADComputer -Identity "$CustomHostInc" 
    $ADPC.Location = "$DescLocation"
    $ADPC.Company = "UC Denver/CEDC ID Dept"
    $ADPC.Department = "$DepartmentFull" #Create off $DEPT to have full name eg Computer Science not CSCI
    # May have to be a real domain account, so no go $ADPC.ManagedBy = "CN=CEDC IT Department,OU=UserAccounts,OU=CEAS,DC=USER04,DC=COM"
    $ADPC.OperatingSystem = "$OSFull" #Windows, Linux, or Mac
    $ADPC.Description = "Service Tag: $ServiceTag" #try catch so try uses remote script, and catch is local serial find command. catch = wmic bios get serialnumber, but trim() space and/or words "SerialNumber" and spaces get-ciminstance win32_bios | format-list serialnumber
    Set-ADComputer -Instance $ADPC
    pause
            }
    }

    }'2'{'LABS'
        $ReadOU = "CEDC"
        $LABSelection = "F"
        Clear-Host
        Show-LABS-Menu
        
        do{$LABSelection = Read-Host "Please make a selection"} 
        while ($LABSelection -notmatch "^(1|2|3|4|5|6|7|8|9|10|B|Q)$")
        if ($LABSelection -eq '1'){$Location = 'CART'}
         elseif ($LABSelection -eq '2'){$Location = 'LW840'}
         elseif ($LABSelection -eq '3'){$Location = 'LW844'}
         elseif ($LABSelection -eq '4'){$Location = 'NC2013'}
         elseif ($LABSelection -eq '5'){$Location = 'NC2207'}
         elseif ($LABSelection -eq '6'){$Location = 'NC2408'}
         elseif ($LABSelection -eq '7'){$Location = 'NC2413'}
         elseif ($LABSelection -eq '8'){$Location = 'NC2608'}
         elseif ($LABSelection -eq '9'){$Location = 'NC2609'}
         elseif ($LABSelection -eq '10'){$Location = 'NC2610'}
         elseif ($LABSelection -eq 'B'){break next}
         elseif ($LABSelection -eq 'Q'){exit}
         else {continue}

        #Test Functions
        #Write-Host "$LabSelection"
        #Write-Host "$Location"

        #$CustomHost = "CEDC-$Location-$DeviceType" Not Ready yet (DeviceType)

        $selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent one?"
    switch ($selectionCHOF)
    {'C'{ 
           $hn = hostname
           $hostnameLength = $hn.length
           While ($hostnameLength -ge 16){
           Write-Host "Current hostname ($hn) is longer than 15 characters($hostnameLength)! Exiting to main menu!"
           break next
                                         }
           #Make sure starts with string eg CEDC-
           $CutLength = hostname
           $ReadOU = $CutLength.SubString(0,5)
           Write-Host "$ReadOU" #Test function

           if($Location -eq 'LW840' -or $Location -eq 'LW844' -and $ReadOU -notmatch 'CSCI-')
           {
           Write-Host "Current hostname ($hn) does NOT start with `"CSCI-`". Exiting!"
           }

           elseif($ReadOU -notmatch "CEDC-")
           {
           Write-Host "Current hostname ($hn) does NOT start with `"CEDC-`". Exiting!"
           break next
           }
    if (@(Get-ADComputer $hn -ErrorAction SilentlyContinue).Count) {
        Write-Host "###########################################################"  
        Write-Host "Computer object already exists in Active Directory. Exiting"
        Write-Host "###########################################################"
        break next
                                                                   }
    else {
        Write-Host "#######################################"  
        Write-Host "Computer object NOT FOUND... Continuing"
        Write-Host "#######################################"
 
        try{
            Add-Computer -DomainName "ucdenver.pvt"  -Credential $Credential -OUPATH "OU=$Location,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction Stop -ErrorVariable computerError 
           }

        catch{
             Write-Host "`nDetected errors:`n" #-ForegroundColor Red
             Write-Host "$_"   #-ForegroundColor Red
             break start
             }
        Write-Host "Host was successfully joined to the domain. You should restart for changing to take effect."
        $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
        switch ($RestartHost){
        'Y'{Restart-Computer 
           }'N'{break next}
                             }
    pause
         }
        }'F'{
    $Location = Read-Host "What is the room number? This is the center portion of the hostname (Ex: BIOE-XXXXXXX-D1):"
    #Write-Host "What type of device is this? (D)esktop or (L)aptop?"
    #$DeviceType = Read-Host "Type D for Desktop or L for laptop. This will be amended to the end of the hostname:"
    $OS = Read-Host "What OS is this for? (W)indows, (L)inux, or (M)ac?" 
    $CustomHost = "$DEPT-$Location-"
    $i = 1
    #$serverlist = $CustomHost
    #$CustomHostInc = $CustomHost

    Do {
        Write-Host "#################################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "#################################################################################################################"
        $CustomHostInc = $CustomHost + $i++ + $OS
       } while (Get-ADComputer -Server "ucdenver.pvt" -filter "Name -like '*$CustomHostInc'" -Credential $Credential) #test using -match instead of -like

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." #-ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Credential -Force
    sleep 5
    Add-Computer -ComputerName $OldComputerName -DomainName "ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Credential #-Restart
    Write-Error "$computerError"
    pause
            }
    }
    }'3'{'Server' #Finish Server Portion
         Show-Server-Dept-Menu #Make sure this menu needs to be different than the faculty/staff dept menu.
         do{$ServerDeptSelection = Read-Host "Please make a selection"} 
         while ($ServerDeptSelection -notmatch "^(1|2|3|4|5|6|7|8|B|Q)$")
         if ($ServerDeptSelection -eq '1'){$ServerDept = 'BIOE'}
          elseif ($ServerDeptSelection -eq '2'){$ServerDept = 'CIVL'}
          elseif ($ServerDeptSelection -eq '3'){$ServerDept = 'CSCI'}
          elseif ($ServerDeptSelection -eq '4'){$ServerDept = 'DEAN'}
          elseif ($ServerDeptSelection -eq '5'){$ServerDept = 'ECSG'}
          elseif ($ServerDeptSelection -eq '6'){$ServerDept = 'ELEC'}
          elseif ($ServerDeptSelection -eq '7'){$ServerDept = 'MECH'}
          elseif ($ServerDeptSelection -eq '8'){$ServerDept = 'Test'}
          elseif ($ServerDeptSelection -eq 'B'){break next}
          elseif ($ServerDeptSelection -eq 'Q'){exit}
          else {continue}

          #Clear-Host
          Show-Server-Category-Menu
          #do {$ServerCategory = Read-Host "What is the purpose of this server? (A)dministration, (I)nstructional, or (R)esearch?"}
          do {$ServerCategorySelection = Read-Host "Please Make a selection"}
          while ($ServerCategorySelection -notmatch "^(1|2|3|B|Q)$")
          if ($ServerCategorySelection -eq '1'){$ServerCategory = 'BIOE'}
          elseif ($ServerCategorySelection -eq '2'){$ServerCategory = 'CIVL'}
          elseif ($ServerCategorySelection -eq '3'){$ServerCategory = 'CSCI'}
          elseif ($ServerCategorySelection -eq 'B'){break next}
          elseif ($ServerCategorySelection -eq 'Q'){exit}
          else {continue}

         clear-Host
         Show-Server-Purpose-Menu
         $ServerPurposeSelection = Read-Host "Please make a selection"
         do {$ServerPurposeSelection = Read-Host "Please Make a selection"}
         while ($ServerPurposeSelection -notmatch "^(1|2|3|4|5|6|7|B|Q)$")
         if ($ServerPurposeSelection -eq '1'){$ServerCategory = 'APP'}
          elseif ($ServerPurposeSelection -eq '2'){$ServerPurpose = 'DATA'}
          elseif ($ServerPurposeSelection -eq '3'){$ServerPurpose = 'DB'}
          elseif ($ServerPurposeSelection -eq '4'){$ServerPurpose = 'FILE'}
          elseif ($ServerPurposeSelection -eq '5'){$ServerPurpose = 'FOG'}
          elseif ($ServerPurposeSelection -eq '6'){$ServerPurpose = 'LIC'}
          elseif ($ServerPurposeSelection -eq '7'){$ServerPurpose = 'PRNT'}
          elseif ($ServerPurposeSelection -eq '8'){$ServerPurpose = 'WWW'}
          elseif ($ServerPurposeSelection -eq 'B'){break next}
          elseif ($ServerPurposeSelection -eq 'Q'){exit}
          else {continue}

         do {$ServerVorPSelection = Read-Host "Lastly, is this server (P)hysical or (V)irtual?"}
         while($ServerVorPSelection -notmatch "^(P|V|B|Q)$")
         if ($ServerVorPSelection -eq 'P'){$ServerVorP = 'P'}
          elseif ($ServerVorPSelection -eq 'V'){$ServerVorP = 'V'}
          elseif ($ServerVorPSelection -eq 'B'){break next}
          elseif ($ServerVorPSelection -eq 'Q'){exit}
          else {continue}

    $CustomServerHost = "$ServerDept-$ServerCategory-$ServerPurpose-" # add $ServerVorP after end of number incrementing
    $i = 1
    #$CustomHostInc = $CustomServerHost

    Clear-Host
    Write-Host "Attempting to find an unused hostname and join to the domain..."
    Do {
        Write-Host "#################################################################################################################"  
        Write-Host "Computer object $CustomHostInc already exists (Or can't be used as it has no trailing #), incrementing by 1..."
        Write-Host "#################################################################################################################"
        $CustomHostInc = $CustomHost + $i++ + $ServerVOrP
       } while (Get-ADComputer -Server "ucdenver.pvt" -filter "Name -like '*$CustomHostInc'" -Credential $Credential) #test -match instead of -like. If ussues add @ .count method.

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." #-ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Credential -Force
    sleep 5
    Add-Computer -ComputerName $OldComputerName -DomainName "ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Credential #-Restart
    Write-Error "$computerError"
    pause


    }'B'{break next}'Q'{exit}
    }
    } 
    '2'{
        Write-Host "You chose option #2: unjoin the domain."
        remove-computer -Credential $Credential -passthru #-verbose
        Write-Host "Host was successfully unjoined from the domain. You should restart for changing to take effect."
        $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
        switch ($RestartHost){
                              'Y'{Restart-Computer 
                                 }'N'{break next}
                             }
    }'3'{
         'You chose option #3: rename this host locally.'
      do {
          $RenameHost = Read-Host "What would you like your new hostname to be? (Will keep asking until 15 characters or less)"
         } while($RenameHost.Length -gt 15)
      Rename-Computer -NewName $RenameHost  -DomainCredential $Credential -Force
      "Host was successfully renamed to $RenameHost. You should restart for changing to take effect."
      $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
      switch ($RestartHost){
      'Y'{Restart-Computer 
    }'N'{break next}
                           }
    }'4'{
         'You chose option #4: join the domain using the current hostname.'
      $CutLength = hostname
      $ReadOU = $CutLength.SubString(0,4)
      Write-Host "To join the domain, we will use the first 4 letters of your current hostname to set the correct OU path. Those first four are $ReadOU."  
      $JoinNow = Read-Host "If this is the correct OU/folder in CEDC, would you like to join now?(Y or N)"
      switch ($JoinNow){
      'Y'{
      Add-Computer -DomainName "ucdenver.pvt" -Credential $Credential -OUPATH "OU=$ReadOU,OU=CEAS,DC=ucdenver,DC=pvt" -force -ErrorAction SilentlyContinue -ErrorVariable computerError
    $computerError 
    }'N'{break next}
    }
      $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
      switch ($RestartHost){
      'Y'{Restart-Computer 
     }'N'{break next}
                           }
    }'Q'{exit}
     Default {
        Write-Warning "No matches"
             } 
    }    
    pause
 }until ($selection -eq 'q')