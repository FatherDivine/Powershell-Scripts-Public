<#
.SYNOPSIS
  Runs Driver & Windows Updates local or remotely.

.DESCRIPTION
  Runs & installs 'Dell Command | Update' driver updates as well
  as MS Windows Online Updates. This is split into 3 functions:
  
  Get-Updates = Gets all updats, both MS Windows Online Updates & Dell Command Driver Updates
  
  Get-DriverUpdates = Gets all driver updates (Dell Command)
  
  Get-WindowsUpdates = MS Windows based Updates


.PARAMETER ComputerName
    For setting a PC or array of PCs as the target

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  Log file stored in C:\Windows\Logs\Get-Updates\<name>.log

.NOTES
  Version:        0.1
  Author:         Aaron Staten
  Creation Date:  11-29-2023
  Purpose/Change: Initial script development
  
.LINK
  
.EXAMPLE
  Get-Updates -ComputerName CEDC-NC2413-P
  
  Grabs the updates of a remote PC

.EXAMPLE
  Get-DriverUpdates

  Grabs just the Driver updates of the local PC

.EXAMPLE
  Get-WindowsUpdates -ComputerName $PCList

  Grabs Windows update of all remote PCs listed
#>

#--------------------------------------------------------------[Privilege Escalation]---------------------------------------------------------------

#When admin rights are needed
<#
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}#>
#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Import Modules
Import-Module -Name Logging-Functions -DisableNameChecking

#Create the Log folder if non-existant
If (!(Test-Path "C:\Windows\Logs\Get-Updates")){New-Item -ItemType Directory "C:\Windows\Logs\Get-Updates\" -Force}


#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "0.1"

#Variables 
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"

#Log File Info
$sLogPath = "C:\Windows\Logs\Get-Updates\"
$sLogName = "Get-Updates.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#Our Scriptblock
$DCUScriptBlock = {
    #Dell Command Updates Section

    #Download and install Dell Command | Update if not already installed
    If (!(Test-Path "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe")){
        Write-Verbose "Installing Dell Command | Update" -Verbose 
        Invoke-WebRequest -Uri "https://dl.dell.com/FOLDER10791716M/1/Dell-Command-Update-Windows-Universal-Application_JCVW3_WIN_5.1.0_A00.EXE" -OutFile (New-Item -Path 'C:\Temp\Dell-Command-Update-WUA_JCVW3.EXE' -Force) -Verbose
        
        #Start the installer
        Start-Process -FilePath 'C:\Temp\Dell-Command-Update-WUA_JCVW3.EXE' -ArgumentList /s -Wait
    }

    #Apply Updates
    Start-Process -FilePath "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList @("/version") -Wait -Verbose | Out-File (New-Item -Path 'C:\Windows\Log\Get-Updates\Get-Updates-DCU.log' -Force)
    Start-Process -FilePath "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList @("/scan") -Wait -Verbose | Out-File -FilePath 'C:\Windows\Log\Get-Updates\Get-Updates-DCU.log' -Append
    Start-Process -FilePath "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList @("/applyUpdates") -Wait -Verbose | Out-File -FilePath 'C:\Windows\Log\Get-Updates\Get-Updates-DCU.log' -Append

    }

    $WUScriptBlock = {
    #Windows Updates Section

    #First trust all PCs.
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*.ucdenver.pvt" -Force -Verbose

    #Install updates on remote pc(s). Can't add date to log file no matter what I tried (Blaming Michal Gajda).
    Invoke-WUInstall -ComputerName $ComputerName -Script {Import-Module PSWindowsUpdate; Install-WindowsUpdate -AcceptAll -AutoReboot -MicrosoftUpdate -Verbose | Format-Table -AutoSize -Wrap | Out-File (New-Item -Path "C:\Windows\Logs\Get-Updates\Get-WindowsUpdates-List.log" -Force)} -Confirm:$false -SkipModuleTest -RunNow -Verbose

    #Waits 13 minutes for updates to finish to check the status of the last 100 updates and logs to file.
    Register-ScheduledJob -Name WUHistoryJob -ScriptBlock {Get-WUHistory -last 100 -ComputerName $ComputerName | Format-Table -AutoSize -Wrap | Out-File (New-Item -Path "C:\Windows\Logs\Get-Updates\Get-WindowsUpdates-WUHistory.log" -Force)} `
        -Trigger $Global:trigger -ScheduledJobOption $Global:options -Verbose        

    }

#-----------------------------------------------------------[Functions]------------------------------------------------------------


Function Get-Updates{
  <#
  .PARAMETER ComputerName
    Allows for QuickFix to be ran against a remote PC or list of
    remote PCs.
  #>
  [cmdletbinding()]
  Param(
    [Parameter(Mandatory=$false,
    ValueFromPipeline=$true)]
    [string[]]$ComputerName = 'localhost'
  )
  
  Begin{
    Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Log-Write -LogPath $sLogFile -LineValue "Get-Updates is running on: $ComputerName"
    Log-Write -LogPath $sLogFile -LineValue "Begin Section"
    Start-Transcript -Path "C:\Windows\Logs\Get-Updates\Get-Updates$Global:date.log"
  }
  
  Process{
    Try{
        Log-Write -LogPath $sLogFile -LineValue "Process (code) Section"
        
        #If running locally
        If ($ComputerName -eq 'localhost'){& $DCUScriptBlock;& $WUScriptBlock}

        #If running on remote PCs
        Else{
            foreach ($PC in $ComputerName){
            Invoke-Command -ScriptBlock $DCUScriptBlock -ComputerName $PC -AsJob
            Invoke-Command -ScriptBlock $WUScriptBlock -ComputerName $PC -AsJob
            }           
        }     
    }
    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }
  
  End{
    If($?){
      Log-Write -LogPath $sLogFile -LineValue "Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
      Log-Finish -LogPath $sLogFile
      Stop-Transcript
    }
  }
}
Function Get-DriverUpdates{
    <#
    .PARAMETER ComputerName
      Allows for QuickFix to be ran against a remote PC or list of
      remote PCs.
    #>
    [cmdletbinding()]
    Param(
      [Parameter(Mandatory=$false,
      ValueFromPipeline=$true)]
      [string[]]$ComputerName = 'localhost'
    )
    
    Begin{
      Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
      Log-Write -LogPath $sLogFile -LineValue "Get-Updates is running on: $ComputerName"
      Log-Write -LogPath $sLogFile -LineValue "Begin Section"
      Start-Transcript -Path "C:\Windows\Logs\Get-Updates\Get-DriverUpdates$Global:date.log"
    }
    
    Process{
      Try{      
        #If running locally
        If ($ComputerName -eq 'localhost'){& $DCUScriptBlock}

        #If running on remote PCs
        Else{
            foreach ($PC in $ComputerName){
            Invoke-Command -ScriptBlock $DCUScriptBlock -ComputerName $PC -AsJob
            }           
        }          
        }
      
      Catch{
        Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
        Break
      }
    }
    
    End{
      If($?){
        Log-Write -LogPath $sLogFile -LineValue "Completed Successfully."
        Log-Write -LogPath $sLogFile -LineValue " "
        Log-Finish -LogPath $sLogFile
        Stop-Transcript
      }
    }
  }

  Function Get-WindowsUpdates{
    <#
    .PARAMETER ComputerName
      Allows for QuickFix to be ran against a remote PC or list of
      remote PCs.
    #>
    [cmdletbinding()]
    Param(
      [Parameter(Mandatory=$false,
      ValueFromPipeline=$true)]
      [string[]]$ComputerName = 'localhost'
    )
    
    Begin{
      Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
      Log-Write -LogPath $sLogFile -LineValue "Get-Updates is running on: $ComputerName"
      Log-Write -LogPath $sLogFile -LineValue "Begin Section"
      Start-Transcript -Path "C:\Windows\Logs\Get-Updates\Get-WindowsUpdates$Global:date.log"
    }
    
    Process{
      Try{
        #If running locally
        If ($ComputerName -eq 'localhost'){& $WUScriptBlock}

        #If running on remote PCs
        Else{
            foreach ($PC in $ComputerName){
            Invoke-Command -ScriptBlock $WUScriptBlock -ComputerName $PC -AsJob
            }           
        } 
        }
      
      Catch{
        Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
        Break
      }
    }
    
    End{
      If($?){
        Log-Write -LogPath $sLogFile -LineValue "Completed Successfully."
        Log-Write -LogPath $sLogFile -LineValue " "
        Log-Finish -LogPath $sLogFile
        Stop-Transcript
      }
    }
  }
  


#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion

#Script Execution goes here

#Log-Finish -LogPath $sLogFile