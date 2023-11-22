<#
  .SYNOPSIS
    Domain tool that allows one to join & unjoin objects to AD, as well as rename computers.

  .DESCRIPTION
    The DJT.ps1 script allows CEDC IT Staff to not only join and unjoin objects to the UCDENVER Active Directory,
    but also rename computers locally. The script has many failsafes and checks to make sure everything is done right.
    This script can't delete objects, as this is best done manually.

  .PARAMETER Join Domain
    Working command line for inner script use:
    DJT -JoinDomain "HostnameHere" -ou1 'BIOE' -ou2 'NC2207' -ou3 'W'
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

   New naming conventions:
   Offices: [DEPT]-[ROOM]-[NUMBER][OS]
   Computer Labs: [DEPT]-[ROOM]-[GRID][NUMBER]
   Servers: [DEPT]-[CATEGORY]-[PURPOSE]-[PHYSICAL/VIRTUAL][NUMBER]

   6-2-23 finish coding on line 624 (writing to descriptions in AD

   If Key & Cred not detected, set variable that if -eq 1 then continue, if -ne 1 ask for credentials manually. background job checks that Cred&Key exists, if not popup window to put back or run key maker

   Differentiate command line vs script use. 
   Command line = no user input , flags for Restart on each command to auto restart or not. sleep-timer if i'm feeling myself. 
   sciprt use = ask to restart, maybe more logic and checks than cmd prompt use. But if name longer than allowed, don't do it and error on cmd line

#Error Exception Finder
[appdomain]::CurrentDomain.GetAssemblies() | ForEach {
    Try {
        $_.GetExportedTypes() | Where {
            $_.Fullname -match 'Exception'
        }
    } Catch {}
} | Select FullName
 #>

 #ADD PARAM for command line use outside of script

#Get admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}

$WarningPreference = "Continue"
$global:hostname = $env:COMPUTERNAME #Leaning towards just using this once, and not updating as soon as the command runs, as you should not be changing hostnames manually while this is running
$hostnameLength = $hostname.length
$OldComputerName = $hostname #Using to keep track of old PC name
$CustomHost= "0" #Couldn't be null to begin
$IntroPlayed = "F" #Controls if intro graphic will play or not. Speeds up having to go back to the main menu.

#Credentials section. If credential file isn't detected, will ask for manual credentials up to 4 times before exiting.
If ((Test-Path ${PSScriptRoot}\Key.xml -ErrorAction SilentlyContinue) -and (Test-Path ${PSScriptRoot}\Cred.xml -ErrorAction SilentlyContinue))
{
 $key = Import-Clixml -LiteralPath ${PSScriptRoot}\Key.xml
 $importObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml
 $secureString = ConvertTo-SecureString -String $importObject.Password -Key $key
 $global:Credential = New-Object System.Management.Automation.PSCredential($importObject.UserName, $secureString)
 $global:UserName = $Credential.UserName;$UserName = $Credential.UserName #Not needed in this script but nice to have
 $global:Password = $Credential.GetNetworkCredential().Password;$Password = $Credential.GetNetworkCredential().Password #Not needed in this script but nice to have
}
else{Write-Warning "`nCredential files (Cred.xml & Key.xml) were NOT detected! Activating manual credentials mode."
     Write-Host "`nPlease input the credentials you wish to use in this script. They must have Admin & AD privileges."
     $GotCredentials = $false
     [int]$GotCredentialsCounter = 0
     do{try{$global:Credential = Get-Credential;$GotCredentials = $true}catch{Write-Error "$_"; $GotCredentials = $false;}$GotCredentialsCounter++}
     until(($GotCredentialsCounter -gt 3) -or ($GotCredentials -eq $true))
     If ($GotCredentialsCounter -eq 4){Write-Warning "`nYou just don't want to enter credentials! Exiting!`n";pause;exit}
    }
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
    Write-Host "The current hostname ($hostname) is $hostnameLength characters long."
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

# Function to rename computer, function to join domain, function to unjoin, etc. Just feed info into function. simplify script
function DJT(){
[cmdletbinding()]
Param
       (
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [Alias("DomainJoin")]
       [string]$JoinDomain,
       $errorlog,
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [Alias("UnjoinDomain")]
       [Alias("DomainUnjoin")]
       [Alias("DomainUnjoinL")]
       [switch]$UnjoinDomainL=$NULL,
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [Alias("DomainUnjoinR")]
       [switch]$UnJoinDomainR=$NULL,
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [Alias("LHostRename")]
       [switch]$RenameLHost,
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [Alias("RHostRename")]
       [switch]$RenameRHost,
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [Alias("RHostRenameList")]
       [switch]$RenameRHostList, #Maybe swap back to string and accept the file location natively. AT least for the param cmd line version.
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [string[]]$ou1,
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [string[]]$ou2,
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [string[]]$ou3,
       [Parameter(Mandatory=$false,
       ValueFromPipeline=$false)]
       [string[]]$ou4
       )
begin {
        # setup our return object
        $result = [PSCustomObject]@{

            SuccessOne = $false
            SuccessTwo = $false
        
        # Redundant Creds
        # Credentials section. If Key & Cred not detected, set variable that if -eq 1 then continue, if -ne 1 ask for credentials manually.
        #$key = Import-Clixml -LiteralPath ${PSScriptRoot}\Key.xml
        #$importObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml
        #$secureString = ConvertTo-SecureString -String $importObject.Password -Key $key
        #$global:Credential = New-Object System.Management.Automation.PSCredential($importObject.UserName, $secureString)#If needed --> ;Credential = New-Object System.Management.Automation.PSCredential($importObject.UserName, $secureString)
                                   }        
    }
process {
        
        # use a switch statement to take actions based on passed in 

        switch ($PSBoundParameters.Keys) {

            'JoinDomain'{ #JoinDomainL for local join if can't combine both

                # perform actions if DomainJoin Param is used

                Write-Host "Putting hostname $JoinDomain in AD Path ucdenver.pvt>CEAS->$ou1->$ou2."
                $JoinNow = Read-Host "If this is the correct, would you like to join now?(Y or N)" #remove from cmd line so it's fast without need for user input
                switch ($JoinNow){
                'Y'{

                    if (@(Get-ADComputer $JoinDomain -ErrorAction SilentlyContinue).Count) {
                        Write-Host "###########################################################"  
                        Write-Host "Computer object already exists in Active Directory. Exiting"
                        Write-Host "###########################################################"
                        break next
                                                                                           }
                    else {
                          Write-Host "#######################################"  
                          Write-Host "Computer object NOT FOUND... Continuing"
                          Write-Host "#######################################"
                         }

                #For detected LABS
                if($ou1 -contains 'LABS'){ Write-Verbose "LABS DETECTED" -Verbose #HAVE to Test. Swap to -eq or -match if need be 
                    
                  try{Add-Computer -ComputerName $JoinDomain -DomainName "ucdenver.pvt"  -Credential $Credential -OUPATH "OU=$ou2,OU=LABS,OU=CEAS,DC=ucdenver,DC=pvt" -ErrorVariable computerError -WhatIf #-ErrorAction Stop
                  }catch{Write-Error "`n$_"} 
                                                       }
                else{Write-Verbose "LABS NOT DETECTED!" -Verbose
                     
                     try{Add-Computer -ComputerName $JoinDomain -DomainName "ucdenver.pvt" -Credential $Credential -OUPATH "OU=$ou1,OU=CEAS,DC=ucdenver,DC=pvt" -force  -ErrorVariable computerError -WhatIf #-ErrorAction SilentlyContinue
                     }catch{Write-Error "`n$_"}
                    } 
                }'N'{break next}
                }
                $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
                switch ($RestartHost){
                'Y'{Restart-Computer -ComputerName $JoinDomain -Credential $Credential -Force 
                }'N'{break next}
                                     }
                
                $result.SuccessOne = $true
                
            }
            'UnjoinDomainL' { #Aliased to UnjoinDomain as most will want to unjoin a local account and not a list

                # Perform logic if UnjoinDomain is used
                # Using -WhatIf so remove-pc tests for now (Don't want to go removing pcs from the AD by accident!                
               
                remove-computer -Credential $Credential -PassThru -WhatIf -Verbose
                Write-Host "Host was successfully unjoined from the domain. You should restart for changing to take effect."
                $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
                switch ($RestartHost){
                              'Y'{Restart-Computer 
                                 }'N'{break next}
                                     }
                $result.SuccessTwo = $true

            }
            'UnjoinDomainR' { 

                # Perform logic if UnjoinDomain is used                
                # commented-out while testing. Maybe add section to unjoin a list of computers as well
                remove-computer -Credential $Credential -PassThru -WhatIf -Verbose
                Write-Host "Host was successfully unjoined from the domain. You should restart for changing to take effect."
                $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
                switch ($RestartHost){
                              'Y'{Restart-Computer 
                                 }'N'{break next}
                                     }
                $result.SuccessTwo = $true

            }

            #Remove-Computer -ComputerName (Get-Content OldServers.txt) -LocalCredential Domain01\Admin01 -UnJoinDomainCredential Domain01\Admin01 -WorkgroupName "Legacy" -Force -Restart

            'RenameLHost' { #If can be switch and/or string, see if can detect if no input, then ask for $RenameHost. If input already provided, skip. Will automatically skip for cmd line PARAMS
                    do {$RenameHost = Read-Host "What would you like your new hostname to be? (Will keep asking until 15 characters or less)"
                    }while($RenameHost.Length -gt 15)
                    Rename-Computer -NewName $RenameLHost  -DomainCredential $Credential -Force
                    "Host was successfully renamed to $RenameHost. You should restart for changing to take effect."
                    $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
                    switch ($RestartHost){
                    'Y'{Restart-Computer 
                    }'N'{break next}
                           }
                    }
            'RenameRHost' {
                do {
                    $OldName = Read-Host "What is the current name of the remote host you wish to rename?"
                    $RenameHost = Read-Host "What would you like the remote host's new name to be? (Will keep asking until 15 characters or less)"
                    } while($RenameHost.Length -gt 15)
                    Rename-Computer -ComputerName $OldName -NewName $RenameHost -DomainCredential $Credential -Force
                    "Host was successfully renamed to $RenameHost. You should restart for changing to take effect."
                    $RestartHost = Read-Host "Would you like to restart now?(Y or N)"
                    switch ($RestartHost){
                    'Y'{Restart-Computer -ComputerName $OldName -Credential $Credential -Force 
                    }'N'{break next}
                           }
                    }
            'RenameRHostList' {
                                    
                    Write-Host "What is the filename with the list of computers to rename?"
                    $ListFile = Read-Host 'Must be colon (:) separated with the old computer name on the left of the colon, no spaces.'
                    
                    #have to pipe this. eg $RenameHost | DJS -RenameRHost 
                    [string[]]$Contents = (Get-Content ${PSScriptRoot}\$ListFile) -split ':'
                    [int]$Num1 = '0'
                    [int]$Num2 = '1'
                    Write-Host "`nThis will also change the old name to reflet the new name in AD" 
                    Foreach ($pc in Get-Content ${PSScriptRoot}\$ListFile){ #make it check both old name on left of ; and new name to rename to on right

                    $OldName  = $Contents[$Num1]
                    $NewName = $Contents[$Num2]

                    # New Untested 'Fool-Proof' Logic 6-1-23-2pm
                    $test = Get-ADComputer -Server "ucdenver.pvt" -filter "Name -like '*$NewName'" -Credential $Credential
                    If ($test){
                        Write-Host "#################################################################################################################"  
                        Write-Host "Computer object $NewName already exists in AD (Or can't be used as it has no trailing #), incrementing by 1..."
                        Write-Host "#################################################################################################################"
                              }else {
                    try{
                    Rename-Computer -ComputerName $OldName -NewName $NewName -DomainCredential $Credential -Force -ErrorAction Stop
                    Write-Host "$OldName was successfully renamed to $NewName."
                    }catch{ Write-Warning "Error Detected! $_"} #Later add ability to write to file: WMI/RPC server unavailable errors
                                    }
                    $Num1++;$Num1++
                    $Num2++;$Num2++
                                                                          }
                    Write-Host "You should restart all the renamed PCs."
                    $RestartHost = Read-Host "Would you like to restart them now?(Y or N)"
                    switch ($RestartHost){
                    'Y'{
                    [int]$Num1 = '0'
                    Foreach ($pc in Get-Content ${PSScriptRoot}\$ListFile){
                    # may not be needed as original variable still has. so just reset as below [string[]]$Contents = (Get-Content ${PSScriptRoot}\$ListFile) -split ':'

                    $NewName = $Contents[$Num1]
                    Restart-Computer -ComputerName $NewName -Credential $Credential -Force
                    $Num1++;$Num1++
                                                                          }
                    pause
                    exit
                    }'N'{break next}
                           }
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
    #Tester Functions
    #DJT -RenameRHostList 
    #DJT -JoinDomain "Tester2" -ou1 'BIOE' -ou2 'NC2207' -ou3 'W'  # WORKING . Don't really need ou2 to be room, only if LABS. Detect if that ou = predefined list (or not null). 
    #DJT -JoinDomain "Tester3" -ou1 'LABS' -ou2 'LW840' -ou3 'L' # If @ou1 == LABS, then  special add-computer w/ labs setup. If @ou1 = predefined list (or not labs), then regular setup.
    #DJT -JoinDomain "Tester4" -ou1 'CIVL' -ou2 'LW840'  -ou3 'L'

    while ($IntroPlayed -ne "T"){Intro ; $IntroPlayed = "T"} # To speed up the graphics if having to go back to the menu.
    
    Show-Menu # swap out to if they are joining or what first, then to faculty/staff, labs etc. 
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
           $hostname = hostname
           $hostnameLength = $hostname.length
           While ($hostnameLength -ge 16){
           Write-Host "Current hostname ($hostname) is longer than 15 characters($hostnameLength)! Exiting to main menu!"
           break next
                                         }
           #Make sure starts with a dept string eg: BIOE-
           $CutLength = hostname
           $ReadOU = $CutLength.SubString(0,5)
           Write-Host "$ReadOU" #Test function

           if($DEPT -eq 'BIOE' -and $ReadOU -notmatch 'BIOE-'){Write-Host "Current hostname ($hostname) does NOT start with `"BIOE-`". Exiting!";break next}
           elseif($DEPT -eq 'CIVL' -and $ReadOU -notmatch 'CIVL-'){Write-Host "Current hostname ($hostname) does NOT start with `"CIVL-`". Exiting!";break next}
           elseif($DEPT -eq 'CSCI' -and $ReadOU -notmatch 'CSCI-'){Write-Host "Current hostname ($hostname) does NOT start with `"CSCI-`". Exiting!";break next}
           elseif($DEPT -eq 'DEAN' -and $ReadOU -notmatch 'CEDC-'){Write-Host "Current hostname ($hostname) does NOT start with `"CEDC-`". Exiting!";break next}
           elseif($DEPT -eq 'ECSG' -and $ReadOU -notmatch 'CEDC-'){Write-Host "Current hostname ($hostname) does NOT start with `"CEDC-`". Exiting!";break next}
           elseif($DEPT -eq 'ELEC' -and $ReadOU -notmatch 'ELEC-'){Write-Host "Current hostname ($hostname) does NOT start with `"ELEC-`". Exiting!";break next}
           elseif($DEPT -eq 'IWKS' -and $ReadOU -notmatch 'IWKS-'){Write-Host "Current hostname ($hostname) does NOT start with `"IWKS-`". Exiting!";break next}
           elseif($DEPT -eq 'MECH' -and $ReadOU -notmatch 'MECH-'){Write-Host "Current hostname ($hostname) does NOT start with `"MECH-`". Exiting!";break next}
           #elseif($DEPT -eq 'Test' -and $ReadOU -notmatch 'CIVL-'){Write-Host "Current hostname ($hostname) does NOT start with `"CEDC-`". Exiting!";break next}
           else{continue}


    if (@(Get-ADComputer $hostname -ErrorAction SilentlyContinue).Count) {
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

        #$CustomHost = "CEDC-$Location-$DeviceType" Not Ready yet (DeviceType)

        $selectionCHOF = Read-Host "Do you wish to (F)ind a working hostname or use the (C)urrent one?"
    switch ($selectionCHOF)
    {'C'{ 
           $hostnameLength = $hostname.length
           While ($hostnameLength -ge 16){
           Write-Host "Current hostname ($hostname) is longer than 15 characters($hostnameLength)! Exiting to main menu!"
           break next
                                         }
           #Make sure starts with string eg CEDC-
           $CutLength = $hostname
           $ReadOU = $CutLength.SubString(0,5)
           Write-Host "$ReadOU" #Test function

           if($Location -eq 'LW840' -or $Location -eq 'LW844' -and $ReadOU -notmatch 'CSCI-')
           {
           Write-Host "Current hostname ($hostname) does NOT start with `"CSCI-`". Exiting!"
           }

           elseif($ReadOU -notmatch "CEDC-")
           {
           Write-Host "Current hostname ($hostname) does NOT start with `"CEDC-`". Exiting!"
           break next
           }
    if (@(Get-ADComputer $hostname -ErrorAction SilentlyContinue).Count) {
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
    }  # PARAM End of 1
    '2'{
        Write-Host "You chose option #2: Unjoin the local PC from the domain." #Add unjoin a listfile to main menu
        DJT -UnjoinDomain 
    }'3'{'You chose option #3: Rename this host locally.' #Add rename list and remote renaming of PCs to main men

         #LOGIC for local or remote
         do{$LocalOrRemote = Read-Host "Do you wish to rename the (L)ocalhost or a (R)emote host?"}
         while ($LocalOrRemote -notmatch "^(B|L|Q|R)$")
         if ($LocalOrRemote -eq 'L'){DJT -RenameLHost}                    
         elseif ($LocalOrRemote -eq 'R'){ DJT -RenameRHost}
         elseif ($LocalOrRemote -eq 'B'){break next}
         elseif ($LocalOrRemote -eq 'Q'){exit}
         else {continue}
    }'4'{
         'You chose option #4: Join the domain using the current hostname.'
         #LOGIC for local or remote
         do{$LocalOrRemote = Read-Host "Do you wish to join the domain of the (L)ocalhost or a (R)emote host?"}
         while ($LocalOrRemote -notmatch "^(B|L|Q|R)$")
         if ($LocalOrRemote -eq 'L'){ #DJT -JoinDomainL
            #Ask for OU spots first
            $1ou = Read-Host "What is the first part (Department) of the OU/hostname? EX: 'XXXX'-Location-Device Code"
            $2ou = Read-Host "What is the second part (Location) of the OU/hostname? EX: $1ou-'XXXXXX'-Device Code"
            # $3ou is not needed to join a domain, but needed for hostname creation
            # $3ou = Read-Host "What is the third part (Single-digit Device Code or Labs Grid #) of the OU/hostname? (W)indows, (L)inux, or (M)ac? EX: $1ou-$2ou-X1"
            DJT -JoinDomain "$hostname" -ou1 "$1ou" -ou2 "$2ou"  #-ou3 "$3ou"
                                    }
         elseif ($LocalOrRemote -eq 'R'){ DJT -JoinDomainR
            $1ou = Read-Host "What is the first part (Department) of the OU/hostname? EX: 'XXXX'-Location-Device Code"
            $2ou = Read-Host "What is the second part (Location) of the OU/hostname? EX: $1ou-'XXXXXX'-Device Code"
            # $3ou is not needed to join a domain, but needed for hostname creation
            # $3ou = Read-Host "What is the third part (Single-digit Device Code or Labs Grid #) of the OU/hostname? (W)indows, (L)inux, or (M)ac? EX: $1ou-$2ou-X1"
            DJT -JoinDomain "$hostname" -ou1 "$1ou" -ou2 "$2ou"  #-ou3 "$3ou"
                                        }
         elseif ($LocalOrRemote -eq 'B'){break next}
         elseif ($LocalOrRemote -eq 'Q'){exit}
         else {continue}
         
    }'Q'{exit}
     Default {
        Write-Warning "No matches"
             } 
    }    
    pause
 }until ($selection -eq 'q')