<#
  .SYNOPSIS
  Domain tool that allows one to join & unjoin objects to AD, as well as rename computers.

  .DESCRIPTION
  The DJS.ps1 script allows CEDC IT Staff to not only join and unjoin objects to the UCDENVER Active Directory,
  but also rename computers locally. The script has many failsafes and checks to make sure everything is done right.
  This script can't delete objects, as this is best done manually.

  .PARAMETER InputPath
  Specifies the path to the CSV-based input file.

  .LINK
  \\DATA\DEPT\CEAS\ITS\Software\Scripts\Domain Join Script (Testing)
  
  .INPUTS
  None. You cannot pipe objects to DJS.ps1.

  .OUTPUTS
  None. DJS.ps1 does not generate any output.

  .EXAMPLE
  PS> .\DJS.ps1
#>
#Created by Aaron S. for CU Denver CEDC IT Dept
#Import-Module ActiveDirectory
#ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
#Additions: Possible safety for each dept that, when using current hostname feature, checks that the first 4 of the hostname are equal to the dept they are in (EG BIOEs checks for BIOE- first then exits if not)

#Get admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}


$hn = hostname
$hostnameLength = $hn.length
$OldComputerName = $hn #using to keep track of old PC name
#$Username = "UNIVERSITY\svc-cedc-domainjoin" <-- redundant
$CustomHost= "0"

$key = Import-Clixml -LiteralPath ${PSScriptRoot}\Key.xml
$importObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml
$secureString = ConvertTo-SecureString -String $importObject.Password -Key $key

$Credential = New-Object System.Management.Automation.PSCredential($importObject.UserName, $secureString)

function Show-Menu
{
    param (
           [string]$Title = 'CEDC Domain Join Script'
          )
    #Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' to join the domain."
    # Domain Join contains: walking thru the domain name creation process (asking to pick predefined CEDC AD depts: BIOE, CIVL, CSCI, DEAN, ECSG, ELEC, IWKS, LABs, MECH, SRVS, Test.)
    # Labs will have second level of CART, LW840, LW844, NC2013, NC2207, NC2408, NC2413, NC2608, NC2609, NC2610
    Write-Host "2: Press '2' to unjoin the domain."
    Write-Host "3: Press '3' to rename this host locally."
    Write-Host "4: Press '4' to join the domain using current hostname."
    #Write-Host "5: Press '5' to manually join the domain with a given hostname (Advanced)" This is for adding any user input to domain, but most be able to set hostname and join without restart.
    # have manual mode that allows user to supply the branch started with ucdenver.pvt> for use with CAM or others.
    # Also a mode that supplies a file list of names typed in a .txt (or no extension) file to be added all at once.
    Write-Host "Q: Press 'Q' to quit.`n"
    "Total length of the hostname cannot exceed 15 characters. The current hostname ($hn) is $hostnameLength characters long."
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
    Write-Host "8: MECH: Mechanical Engineering"
    Write-Host "9: Test: Testing OU"
    Write-Host "Q: Press 'Q' to quit."
    Write-Host "B: Press 'B' to go back to the main menu"

}
function Show-LABS-Menu
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
function Show-Who-Menu
{
param (
       [string]$DeptTitle = 'Who is the object for?'
      )
    Clear-Host
    Write-Host "================ $DeptTitle ================"
    
    Write-Host "1: Faculty/Staff"
    Write-Host "2: Computer LABS"
    Write-Host "3: Server"
    Write-Host "Q: Press 'Q' to quit."
    Write-Host "B: Press 'B' to go back to the main menu"

}

:start do
 {
    Show-Who-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {'1'{
    }'2'{'LABS'
        $ReadOU = "LABS"
        Clear-Host
        Show-LABS-Menu
        $LABSelection = Read-Host "Please make a selection:"
        if ($LABSelection = "1"){$RoomNumber = "CART"}
        if ($LABSelection = "2"){$RoomNumber = "LW840"}
        if ($LABSelection = "3"){$RoomNumber = "LW844"}
        if ($LABSelection = "4"){$RoomNumber = "NC2013"}
        if ($LABSelection = "5"){$RoomNumber = "NC2207"}
        if ($LABSelection = "6"){$RoomNumber = "NC2408"}
        if ($LABSelection = "7"){$RoomNumber = "NC2413"}
        if ($LABSelection = "8"){$RoomNumber = "NC2608"}
        if ($LABSelection = "9"){$RoomNumber = "NC2609"}
        if ($LABSelection = "10"){$RoomNumber = "NC2610"}

        #$CustomHost = "$ReadOU-$RoomNumber-$DeviceType"

        $selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent hostname?"
    switch ($selectionCHOF)
    {'C'{ 
           $hn = hostname
           $hostnameLength = $hn.length
           While ($hostnameLength -ge 16){
           Write-Host "Current hostname ($hn) is longer than 15 characters($hostnameLength)! Exiting to main menu!"
           break next
                                         }

foreach ($server in $serverlist) {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
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
            Add-Computer -DomainName "ucdenver.pvt"  -Credential $Credential -OUPATH "OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorAction Stop -ErrorVariable computerError 
           }

        catch{
             #Write-Host "Detected errors: $computerError" -ForegroundColor Red
             Write-Host "`nDetected errors:`n" -ForegroundColor Red
             Write-Host "$_"   -ForegroundColor Red #this is the error, and shows better than $computerError
             break next
             }

             #wrote code: if error = true, write it wasn't successfully joined. if no error, ask to restart

        Write-Host "Host was successfully joined to the domain. You should restart for changing to take effect."
        $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
        switch ($RestartHost){
        'Y'{Restart-Computer 
           }'N'{break next}
                             }
    pause
         }
                                 }
        }
    'F'{
    # not needed anymore: $RoomNumber = Read-Host "What is the room number the device will be located? This will be used in the middle of the naming convention: LABS-######-D1. Please add NC if it's in North Classroom eg: NC2206"
    $DeviceType = Read-Host "What type of device is this? (D)esktop or (L)aptop? Type D for Desktop and L for laptop. This will be amended to the end of the hostname" 
    $CustomHost = "$READOU-$RoomNumber-$DeviceType"
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
       } while (Get-ADComputer -Server "ucdenver.pvt" -filter "Name -like '*$CustomHostInc'" -Credential $Credential)
                                 }

    #Rename local host, then join to domain.
    Write-Host "$CustomHostInc is the name last found to not be in AD. Renaming this pc to $CustomHostInc and joining domain..." -ForegroundColor Red
    Rename-Computer -NewName $CustomHostInc -DomainCredential $Credential -Force
    sleep 5
    Add-Computer -ComputerName $OldComputerName -DomainName "ucdenver.pvt" -Options JoinWithNewName,accountcreate -Credential $Credential #-Restart
    $computerError
    pause
        
       }
    }    


       }'3'{
    }'Q'{ exit
    }'B'{ break start}
    
 
    '2' {
    Write-Host "You chose option #2: unjoin the domain."
    remove-computer -Credential $Credential -passthru #-verbose
    Write-Host "Host was successfully unjoined from the domain. You should restart for changing to take effect."
      $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
      switch ($RestartHost){
      'Y'{Restart-Computer 
    }'N'{break next}
    }
    } '3' {
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
    } '4' {
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
      
    }
    }
    pause
 }
 until ($selection -eq 'q')