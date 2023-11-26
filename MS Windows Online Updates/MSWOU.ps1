#requires -version 2 
<#
.SYNOPSIS
  Allows the ability to configure a PC for
  MS Windows updates as well as run them.

.DESCRIPTION
  This script runs MS Windows updates 
  remotely on a single or list/array 
  of computers. Can be the localhost.

.PARAMETER ComputerName
    Accepts a single or array/listfile of
    multiple computers. Can be fed in the
    command or from a file. When this parameter
    is not used, will default to localhost for
    script use.
    
.INPUTS
  none

.OUTPUTS
  Logs stored in C:\Windows\Logs\MSWOU\

.NOTES
  Version:        5.0
  Author:         Aaron Staten
  Creation Date:  11/22/2023
  Purpose:        For CEDC IT Dept. use
  
.EXAMPLE
  & .\MSOU.ps1 -ComputerName $NC2413
#>

#--------------------------------------------------------------[Privilege Escalation]---------------------------------------------------------------

#When admin rights are needed
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}
#----------------------------------------------------------[Initialization & Declarations]----------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Dot Source required Function Libraries if not using the Modules
#. "${PSScriptRoot}\Logging_Functions.ps1"
#. "${PSScriptRoot}\Invoke-WUInstall.ps1"

#Import Modules, better than above method
Import-Module -Name Invoke-WUInstall, Logging-Function

#Script Version
$sScriptVersion = "5.0"

# Variables 
$Global:date = Get-Date -Format "-MM-dd-yyyy-HH-mm"
$Global:trigger = New-Jobtrigger -Once -at (Get-Date).AddMinutes(13)
$Global:options = New-ScheduledJobOption -StartIfOnBattery



#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function MSWRemoteUpdatesPrerequisites{
  Param()
  
  Begin{
    #Log File Info
    $sLogPath = "C:\Windows\Logs\MSWOU\"
    $sLogName = "MSWOU-MSWRemoteUpdatesPrerequisites$Global:date.log"
    $sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

    #Start Logging
    Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Log-Write -LogPath $sLogFile -LineValue "MSWRemoteUpdatesPrerequisites Function Begin Section"
  }
  
  Process{
    Try{
      Log-Write -LogPath $sLogFile -LineValue "Process (code) Section"
      Start-Transcript -Path "C:\Windows\Logs\MSWOU\MSWOU-MSWRemoteUpdatesPrerequisites-T$Global:date.log"
      
      #If Nuget or PSWindowsUpdate module aren't already installed, install them
      Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
      
      If(-not(Get-InstalledModule PSWindowsUpdate -ErrorAction silentlycontinue))
      {
      Set-PSRepository PSGallery -InstallationPolicy Trusted -Verbose
      Install-Module PSWindowsUpdate -Confirm:$False -Force -Verbose
      }

      #Enable Remote PS management of Windows Updates as well as PS Remoting if not      
      If (-not(Test-WSMan -ComputerName 'localhost' -ErrorAction SilentlyContinue)){
        Enable-PSRemoting -Force -Verbose
      }
      Enable-WURemoting -Verbose
    }
    
    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }
  
  End{
    If($?){
      #Finish Logging
      Log-Write -LogPath $sLogFile -LineValue "MSRemoteUpdatesPrerequisites Function Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
      Log-Finish -LogPath $sLogFile
      Stop-Transcript
    }
  }
}

Function MSWOnlineUpdater{
  Param(
      [Parameter(ValueFromPipeline=$True,
      ValueFromPipelineByPropertyName=$True)]
      [String[]]$ComputerName = 'localhost'
  )
  
  Begin{
    #Log File Info
    $sLogPath = "C:\Windows\Logs\MSWOU\"
    $sLogName = "MSWOU-MSWOnlineUpdater$Global:date.log"
    $sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName
    
    #Start Logging
    Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Log-Write -LogPath $sLogFile -LineValue "MSWOnlineUpdater Function Begin Section"
  }
  
  Process{
    Try{
      Log-Write -LogPath $sLogFile -LineValue "Process (code) Section"
      Start-Transcript -Path "C:\Windows\Logs\MSWOU\MSWOU-MSWOnlineUpdater-T$Global:date.log"
      
      #Trust all PCs first.
      Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*.ucdenver.pvt" -Force -Verbose

      #Install updates on remote pc(s). Can't add date to log file no matter what I tried (Blaming Michal Gajda).
      Invoke-WUInstall -ComputerName $ComputerName -Script {Import-Module PSWindowsUpdate; Install-WindowsUpdate -AcceptAll -AutoReboot -MicrosoftUpdate | Format-Table -AutoSize -Wrap | Out-File (New-Item -Path "C:\Windows\Logs\MSWOU\PSWindowsUpdate-List.log" -Force)} `
      -Confirm:$false -SkipModuleTest -RunNow -Verbose

      #Register-ScheduledJob can't work with a SYSTEM user (case of FOG snap-ins).
      if ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name -eq 'NT AUTHORITY\SYSTEM') {
      #Checks the status of the last 100 updates and logs to file.
      Get-WUHistory -last 100 -ComputerName $ComputerName | Format-Table -AutoSize -Wrap | Out-File (New-Item -Path "C:\Windows\Logs\MSWOU\WUHistory-FOG.log" -Force) -Verbose
      }

      else{
      #Waits 13 minutes for updates to finish to check the status of the last 100 updates and logs to file.
      Register-ScheduledJob -Name WUHistoryJob -ScriptBlock {Get-WUHistory -last 100 -ComputerName $ComputerName | Format-Table -AutoSize -Wrap | Out-File (New-Item -Path "C:\Windows\Logs\MSWOU\WUHistory.log" -Force)} `
        -Trigger $Global:trigger -ScheduledJobOption $Global:options -Verbose
      }
    }
    
    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }
  
  End{
    If($?){
      #Finish Logging
      Log-Write -LogPath $sLogFile -LineValue "MSWindowsOnlineUpdater Function Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
      Log-Finish -LogPath $sLogFile
      Stop-Transcript
    }
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------