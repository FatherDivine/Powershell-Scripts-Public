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
  https://github.com/FatherDivine/Powershell-Scripts-Public/tree/main/Modules/Get-Updates
  
.EXAMPLE
  Get-Updates -ComputerName CEDC-NC2413-P
  
  Grabs the updates of a remote PC

.EXAMPLE
  Get-DriverUpdates

  Grabs just the Driver updates of the local PC

.EXAMPLE
  Get-WindowsUpdates -ComputerName $PCList

  Grabs Windows update of all remote PCs listed May have issues starting the schedule job this way.
  That is, until I code the name of the job to change each iteration for each PC. The better way to
  run this cmdlet for all PCs is the example below.

.EXAMPLE
  Invoke-Command -ComputerName $PCList -ScriptBlock {Get-Updates}

  The best way to grab updates from a remote list of PCs. This method requires that the module be
  installed on the remote PCs it is ran against. This command will start the module on the
  remote pcs. If you want to be fancier and track which pcs failed and which succeeded, see
  the below example.

.EXAMPLE
  $PCList|%{icm $_ -ScriptBlock {Get-Updates} -AsJob}

  This command will kick off a separate invoke-command for each PC as a job, and then you can
  simply type 'Get-Job' at the same PS prompt to list all jobs, to easy see which failed
  and which succeeded.

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
Import-Module -Name Invoke-WUInstall, Logging-Functions -DisableNameChecking

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "0.1"

#Our Scriptblock
$DCUScriptBlock = {
  #Create the Log folder if non-existant
  If (!(Test-Path "C:\Windows\Logs\Get-Updates" -ErrorAction SilentlyContinue)){New-Item -ItemType Directory "C:\Windows\Logs\Get-Updates\" -Force}

  #Variables
  $date = Get-Date -Format "-MM-dd-yyyy-HH-mm"

  #Dell Command Updates Section

  Write-Verbose 'Download and install Dell Command | Update if not already installed.' -Verbose
  If (!(Test-Path "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe")){
    Write-Verbose 'Installing Dell Command | Update.' -Verbose 
    Invoke-WebRequest -Uri "https://dl.dell.com/FOLDER10791716M/1/Dell-Command-Update-Windows-Universal-Application_JCVW3_WIN_5.1.0_A00.EXE" -OutFile (New-Item -Path 'C:\Temp\Dell-Command-Update-WUA_JCVW3.EXE' -Force) -Verbose
        
    Write-Verbose 'Starting Dell command | Update installer.' -Verbose
    Start-Process -FilePath 'C:\Temp\Dell-Command-Update-WUA_JCVW3.EXE' -ArgumentList @("/s") -Wait -Verbose -NoNewWindow
  }

    Write-Verbose "Applying Updates." -Verbose
    Start-Process -FilePath "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList @("/version") -Wait -Verbose -NoNewWindow
    Start-Process -FilePath "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList @("/scan") -Wait -Verbose -NoNewWindow
    Start-Process -FilePath "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList @("/applyUpdates") -Wait -Verbose -NoNewWindow -RedirectStandardOutput (New-Item -Path "C:\Windows\Logs\Get-Updates\Get-DriverUpdates-List.log" -Force)

    #Delete temporary files
    If (Test-Path 'C:\Temp\Dell-Command-Update-WUA_JCVW3.EXE'){Remove-Item -Path 'C:\Temp\Dell-Command-Update-WUA_JCVW3.EXE' -Force}
}

    $WUScriptBlock = {
    #Create the Log folder if non-existant
    If (!(Test-Path "C:\Windows\Logs\Get-Updates" -ErrorAction SilentlyContinue)){New-Item -ItemType Directory "C:\Windows\Logs\Get-Updates\" -Force}  
    
    #Variables 
    #$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"
    $trigger = New-Jobtrigger -Once -at (Get-Date).AddMinutes(13)
    $options = New-ScheduledJobOption -StartIfOnBattery

    #Windows Updates Section

    Write-Verbose "Trust all local PCs to allow remote updates." -Verbose
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*.ucdenver.pvt" -Force -Verbose

    Write-Verbose "Install updates on remote pc(s). Can't add date to log file no matter what I tried (Blaming Michal Gajda)." -Verbose
    Invoke-WUInstall -ComputerName $ComputerName -Script {Import-Module PSWindowsUpdate; Install-WindowsUpdate -AcceptAll -AutoReboot -MicrosoftUpdate -Verbose | Format-Table -AutoSize -Wrap} -Confirm:$false -SkipModuleTest -RunNow -Verbose

    Write-Verbose "Set a scheduled job 13 minutes in the future, after updates finish, to check the status of the last 100 updates and logs to file." -Verbose
    if (Get-ScheduledJob -Name WUHistoryJob -ErrorAction SilentlyContinue){Unregister-ScheduledJob -Name WUHistoryJob}
    Register-ScheduledJob -Name WUHistoryJob -ScriptBlock {Get-WUHistory -last 100 -ComputerName $ComputerName | Format-Table -AutoSize -Wrap | Out-File (New-Item -Path "C:\Windows\Logs\Get-Updates\Get-WindowsUpdates-List.log" -Force)} -Trigger $trigger -ScheduledJobOption $options -Verbose        
    }

#-----------------------------------------------------------[Functions]------------------------------------------------------------


Function Get-Updates{
  <#
  .PARAMETER ComputerName
      Allows for Get-DriverUpdates to be ran against a remote PC or 
      list of remote PCs.
  #>
  [cmdletbinding()]
  Param(
    [Parameter(Mandatory=$false,
    ValueFromPipeline=$true)]
    [string[]]$ComputerName = 'localhost'
  )
  
  Begin{

    #Variables
    $date = Get-Date -Format "-MM-dd-yyyy-HH-mm"
    $hostname = hostname

    #Log File Info
    $sLogPath = "C:\Windows\Logs\Get-Updates\"
    $sLogName = "Get-Updates$date.log"
    $sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName
    
    Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Log-Write -LogPath $sLogFile -LineValue "Get-Updates is running on: $ComputerName"
    Log-Write -LogPath $sLogFile -LineValue "Begin Section"
    Start-Transcript -Path "C:\Windows\Logs\Get-Updates\Get-Updates-T$date.log"
  }
  
  Process{
    Try{
        Log-Write -LogPath $sLogFile -LineValue "Process (code) Section"
        
        #If running locally
        If ('localhost' -eq $ComputerName){
          Write-Verbose "Running Get-Updates on the localhost ($hostname)." -Verbose
          #& $DCUScriptBlock
          #& $WUScriptBlock
          Start-Job -Name DCUScript -ScriptBlock {$DCUScriptBlock} | wait-job -Verbose | Receive-Job -WriteEvents -WriteJobInResults -Wait -Verbose
          Start-Job -Name WUScript -ScriptBlock {$WUScriptBlock} | wait-job -Verbose | Receive-Job -WriteEvents -WriteJobInResults -Wait -Verbose
        }

        #If running on remote PCs
        Else{
            foreach ($PC in $ComputerName){
            Write-Verbose "Running Get-Updates on $PC." -Verbose
            Invoke-Command -ScriptBlock $DCUScriptBlock -ComputerName $PC -AsJob -JobName 'DCUScript'
            Invoke-Command -ScriptBlock $WUScriptBlock -ComputerName $PC -AsJob -JobName 'WUScript'
            #Wait-Job -Name DCUScript,WUScript -Verbose | Receive-Job -WriteEvents -WriteJobInResults -Wait -Verbose | Out-File (New-Item -Path "C:\Windows\Logs\Get-Updates\Get-Updates-RecieveTest.log" -Force)

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
      Log-Write -LogPath $sLogFile -LineValue "Get-Updates Function Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
      Stop-Transcript
      Log-Finish -LogPath $sLogFile -NoExit $True
      
    }
  }
}
Function Get-DriverUpdates{
    <#
    .PARAMETER ComputerName
      Allows for Get-DriverUpdates to be ran against a remote PC or 
      list of remote PCs.
    #>
    [cmdletbinding()]
    Param(
      [Parameter(Mandatory=$false,
      ValueFromPipeline=$true)]
      [string[]]$ComputerName = 'localhost'
    )
    
    Begin{
      #Variables
      $date = Get-Date -Format "-MM-dd-yyyy-HH-mm"

      #Log File Info
      $sLogPath = "C:\Windows\Logs\Get-Updates\"
      $sLogName = "Get-DriverUpdates$date.log"
      $sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName      
      Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
      Log-Write -LogPath $sLogFile -LineValue "Get-Updates is running on: $ComputerName"
      Log-Write -LogPath $sLogFile -LineValue "Begin Section"
      Start-Transcript -Path "C:\Windows\Logs\Get-Updates\Get-DriverUpdates-T$date.log"
    }
    
    Process{
      Try{      
        #If running locally
        Write-Verbose "Running Get-Updates on the localhost ($hostname)." -Verbose
        If ('localhost' -eq $ComputerName){& $DCUScriptBlock}

        #If running on remote PCs
        Else{
            foreach ($PC in $ComputerName){
            Write-Verbose "Running Get-Updates on $PC" -Verbose
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
        Log-Write -LogPath $sLogFile -LineValue "Get-DriverUpdates Function Completed Successfully."
        Log-Write -LogPath $sLogFile -LineValue " "
        Log-Finish -LogPath $sLogFile -NoExit $True
        Stop-Transcript
      }
    }
  }

  Function Get-WindowsUpdates{
    <#
    .PARAMETER ComputerName
      Allows for Get-DriverUpdates to be ran against a remote PC or 
      list of remote PCs.
    #>
    [cmdletbinding()]
    Param(
      [Parameter(Mandatory=$false,
      ValueFromPipeline=$true)]
      [string[]]$ComputerName = 'localhost'
    )
    
    Begin{
      #Variables
      $date = Get-Date -Format "-MM-dd-yyyy-HH-mm"

      #Log File Info
      $sLogPath = "C:\Windows\Logs\Get-Updates\"
      $sLogName = "Get-WindowsUpdates$date.log"
      $sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName
      Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
      Log-Write -LogPath $sLogFile -LineValue "Get-Updates is running on: $ComputerName"
      Log-Write -LogPath $sLogFile -LineValue "Begin Section"
      Start-Transcript -Path "C:\Windows\Logs\Get-Updates\Get-WindowsUpdates-T$date.log"
    }
    
    Process{
      Try{
        #If running locally
        If ('localhost' -eq $ComputerName){Write-Verbose "Running Get-Updates on the localhost ($hostname)." -Verbose;& $WUScriptBlock}

        #If running on remote PCs
        Else{
            foreach ($PC in $ComputerName){
            Write-Verbose "Running Get-Updates on $PC" -Verbose
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
        Log-Write -LogPath $sLogFile -LineValue "Get-WindowsUpdates Function Completed Successfully."
        Log-Write -LogPath $sLogFile -LineValue " "     
        Log-Finish -LogPath $sLogFile -NoExit $True
        Stop-Transcript
      }
    }
  }
  
#-----------------------------------------------------------[Execution]------------------------------------------------------------
& Get-Updates