<#
.SYNOPSIS
  Various functions related to Keysight software.

.DESCRIPTION
    The purpose of this Function/Module is to create functions that support Keysight software.
    This includes things that may be needed, like license files changes, HOME path/registry edits,
    or updating (and in some cases, uninstalling) certain softwares.

.INPUTS
  none

.OUTPUTS
  Log file stored in C:\Windows\Log\Keysight\<Logname>.log>

.NOTES
  Version:        0.1
  Author:         Aaron Staten
  Creation Date:  11-30-2023
  Purpose/Change: Initial script development

.LINK
  https://github.com/FatherDivine/Powershell-Scripts-Public/tree/main/FOG%20Snapins/Keysight

.EXAMPLE
  Keysight-ADS-FixHomePath

  When calling the function when installed as a module, will fix the HOME path of an ADS installation.

.EXAMPLE
  Keysight-ADS-FixHomePath -ComputerName "<HostnameHere>"

  When called as a function, will fix the HOME path of an ADS instlalation of a remote PC or array/list of computers.

.EXAMPLE
  . .\Keysight.ps1 ; & KeySight-ADS-FixHomePath

  Dot-sourced one-liner method of initializing the Keysight.ps1 script, then calling the function within it. This is
  for non-module (or FOG snap-in) usage.
#>

#---------------------------------------------------------[Initialisations & Declarations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Script Version
$sScriptVersion = "0.1"

#Import necessary modules, downlaod if not there already
#Logging-Functions for basic logging functionality in all scripts.
If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\")){
  Write-Verbose 'Downloading the latest Logging-Functions module and placing in C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\' -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psm1" `
  -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psm1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psd1" `
  -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psd1' -Force) -Verbose
}

If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\")){
  Write-Verbose 'Downloading the latest Logging-Functions module and placing in C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\' -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-Ping/Invoke-Ping/Invoke-Ping.psd1" `
  -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\Invoke-Ping.psd1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-Ping/Invoke-Ping/Invoke-Ping.psm1" `
  -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\Invoke-Ping.psm1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-Ping/Invoke-Ping/Public/Invoke-Ping.ps1" `
  -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\Public\Invoke-Ping.ps1' -Force) -Verbose
}

Import-Module -Name Invoke-Ping, Logging-Functions -DisableNameChecking

#Variables
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"
$ConfigName = (whoami).Split("\")[1]


#Create the Log folder if non-existant
If (!(Test-Path "C:\Windows\Logs\Keysight")){New-Item -ItemType Directory "C:\Windows\Logs\Keysight\" -Force}

Write-Verbose "Enable ps-remoting on local PC if not already enabled." -Verbose
if (!(Test-WSMan localhost)){Enable-PSRemoting}

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Keysight-ADS-Reinstall2{
  <#
  .PARAMETER ComputerName
    Allows for Keysight  to be ran against a remote PC or list of remote PCs.
  #>
  [cmdletbinding()]
  Param(
    [Parameter(Mandatory=$false,
    ValueFromPipeline=$true)]
    [string[]]$ComputerName = 'localhost'
  )

  Begin{ 
    #Log File Info
    $sLogPath = "C:\Windows\Logs\Keysight"
    $sLogName = "ADS-Uninstall$date.log"
    $sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

    #LogStart
    Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Log-Write -LogPath $sLogFile -LineValue "Keysight-ADS-Uninstall is running on: $ComputerName"
    Log-Write -LogPath $sLogFile -LineValue "Begin Section"
    Start-Transcript -Path "C:\Windows\Logs\Keysight\ADS-Uninstall-T$date.log" -Force
    Write-Verbose "Keysight-ADS-Uninstall is running on: $ComputerName" -Verbose
    
    $ScriptBlock = {
        #Uninstall if uninstaller is present, meaning it is installed.
        if (Test-Path -Path "C:\Program Files\Uninstall_ADS2019_Update1\uninstall.exe" ){
            Write-Verbose "Uninstalling ADS 2019 Update 1." -Verbose
            Start-Process -FilePath "C:\Program Files\Uninstall_ADS2019_Update1\uninstall.exe" -ArgumentList @("-i silent") -Wait -Verbose
        }
      
        if (Test-Path -Path "C:\temp\ads_2019_update1.0_win_x64.exe"){Write-Verbose "ads_2019_update1.0_win_x64.exe is already in c:\temp! No need to download." -Verbose}
        else{
        Write-Verbose "Downloading ADS from fileshare. This may take a while as it's over 2GB." -Verbose
        Copy-Item -Path "\\data\dept\ceas\its\software\applications\Keysight\ADS\ADS\ads_2019_update1.0_win_x64.exe" -Destination "C:\temp\ads_2019_update1.0_win_x64.exe" -Force -Verbose
        }
        Install
        Write-Verbose "Installing ADS 2019 Update 1.0." -Verbose
        Start-Process -FilePath "C:\temp\ads_2019_update1.0_win_x64.exe" -ArgumentList @('-i silent -f C:\Program" "Files\WindowsPowerShell\Modules\Keysight\Public\installer.properties') -Wait -Verbose -NoNewWindow
        }
  }

  Process{
    Try{
       
          if ($ComputerName = 'localhost'){
            write-verbose "localhost" -verbose
            invoke-command -ScriptBlock $ScriptBlock -ComputerName cedc-remote-3 -Verbose -ConfigurationName $ConfigName
            write-verbose "past invoke" -verbose
          }
          else{
            Register-ScheduledJob -Name PSSessionBlock -ScriptBlock {Invoke-Command -ScriptBlock $PSSessionBlock -ConfigurationName statena -Verbose} -Trigger $trigger1 -ScheduledJobOption $options1 -Verbose
            Register-ScheduledJob -Name ADSScriptBlock -ScriptBlock {Invoke-Command -ScriptBlock $ScriptBlock -ConfigurationName statena -Verbose} -Trigger $trigger2 -ScheduledJobOption $options2 -Verbose        
          }
    }

    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }
  End{
    If($?){
      Log-Write -LogPath $sLogFile -LineValue "Deleting ads_2019_update1.0_win_x64.exe."
      Invoke-Command -ComputerName cedc-remote-3 -ScriptBlock {Remove-Item -Path "C:\temp\ads_2019_update1.0_win_x64.exe" -Force -Verbose}

      Log-Write -LogPath $sLogFile -LineValue "Keysight-ADS-Uninstall Function Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
      Stop-Transcript
      Log-Finish -LogPath $sLogFile -NoExit $True
    }
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here, when not using as a Module.
#Can execute a function for FOG snap-ins like this:
#& Keysight-ADS-Uninstall

export-modulemember -alias * -function *