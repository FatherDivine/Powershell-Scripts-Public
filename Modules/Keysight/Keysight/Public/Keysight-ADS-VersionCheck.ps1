<#
.SYNOPSIS
  Checks the version of Keysight ADS.

.DESCRIPTION
    Checks the version of Keysight ADS on one or multiple PCS
    using the registry. Could also use C:\program files\Keysight\ADS*.

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
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psm1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psd1' -Force) -Verbose
}

If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\")){
  Write-Verbose 'Downloading the latest Logging-Functions module and placing in C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\' -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-Ping/Invoke-Ping/Invoke-Ping.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\Invoke-Ping.psd1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-Ping/Invoke-Ping/Invoke-Ping.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\Invoke-Ping.psm1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Invoke-Ping/Invoke-Ping/Public/Invoke-Ping.ps1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Invoke-Ping\Public\Invoke-Ping.ps1' -Force) -Verbose
}

Import-Module -Name Invoke-Ping, Logging-Functions -DisableNameChecking

#Variables
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"

#Create the Log folder if non-existant
If (!(Test-Path "C:\Windows\Logs\Keysight")){New-Item -ItemType Directory "C:\Windows\Logs\Keysight\" -Force}

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Keysight-ADS-VersionCheck{
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
    $sLogName = "Keysight-ADS-VersionCheck$date.log"
    $sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

    #LogStart
    Start-Transcript -Path "C:\Windows\Logs\Keysight\ADS-VersionCheck-T$date.log" -Force
    Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Log-Write -LogPath $sLogFile -LineValue "Keysight-ADS-VersionCheck is running on: $ComputerName"
    Log-Write -LogPath $sLogFile -LineValue "Begin Section"
    Write-Verbose "Keysight-ADS-VersionCheck is running on: $ComputerName" -Verbose
  }

  Process{
    Try{
      #Detect working PCs so script runs faster
      $WorkingPCs = Invoke-Ping -ComputerName $ComputerName -Quiet

      #Get the offline PCs and let the user know
      $OfflinePCs = (Compare-Object $ComputerName $WorkingPCs -IncludeEqual | Where-Object { $_.SideIndicator -eq "<=" }).InputObject
      Write-Verbose "Computers detected as being offline: $OfflinePCs" -Verbose
      Write-Verbose '-==ADS versions detected below==-' -Verbose
      foreach ($PC in $WorkingPCs){
        #Check Version of ADS. If need to speed up instead of watching each at the terminal,
        #just make it separate jobs per PC, and use 'get-job | receive-job -keep' to check
        $Results = Invoke-Command -ComputerName $PC -ScriptBlock{
         (Get-ItemProperty HKLM:\SOFTWARE\Keysight\ADS\*\eeenv ADS_Folder).ADS_Folder
        }
        Write-Verbose "$PC`: $Results" -Verbose
      }

    }

    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }
  End{
    If($?){
      Log-Write -LogPath $sLogFile -LineValue "Keysight-ADS-VersionCheck Function Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
      Clear-Variable WorkingPCs, ComputerName, OfflinePCs
      Stop-Transcript
      Log-Finish -LogPath $sLogFile -NoExit $True
    }
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here, when not using as a Module.

export-modulemember -alias * -function *