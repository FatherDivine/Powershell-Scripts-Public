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
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psm1' -Force) -Verbose
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psd1' -Force) -Verbose
}
Import-Module -Name Logging-Functions -DisableNameChecking

#Variables 
$date = Get-Date -Format "-MM-dd-yyyy-HH-mm"

#Create the Log folder if non-existant
If (!(Test-Path "C:\Windows\Logs\Keysight")){New-Item -ItemType Directory "C:\Windows\Logs\Keysight\" -Force}

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Keysight-ADS-FixHomePath{
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
    $sLogName = "Keysight-ADS-FixHomePath$date.log"
    $sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

    Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Log-Write -LogPath $sLogFile -LineValue "Keysight-ADS-FixHomePath is running on: $ComputerName"
    Log-Write -LogPath $sLogFile -LineValue "Begin Section"

    #Registry locations that need editing
    $regKeys = @(
    "HKLM:\SOFTWARE\Keysight\ADS\4.91\eeenv"
    )
    #Our registry test-path variable
    $RegistryTestValue = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Keysight\ADS\4.91\eeenv'
    
    $KeysightScriptblock = {
      #Test if the registry value was already set, and set if not
      $RegistryTest = Get-ItemPropertyValue $RegistryTestValue -Name HOME
      If ($RegistryTest -eq 'C:\ADS'){Write-Verbose 'C:\ADS already set as HOME' -Verbose}
      else {
        Write-Verbose "Setting C:\ADS as HOME at $regKeys" -Verbose

        #Apply the changes to registry        
        $regKeys | ForEach-Object {
          Set-ItemProperty -path $_ HOME -value C:\ADS -Force -ErrorAction SilentlyContinue
        }
      }

      #Create the directory structure if hpeesof folder is non-existant
      If (!(Test-Path "C:\ADS\hpeesof\config")){
        #Test for ADS, create if non-existant. Logic is in case someone created C:\ADS manually, but didn't put the files.
        If (!(Test-Path "C:\ADS")){
          #Create ADS folder (Move-Item does not create folders)
          New-Item -ItemType Directory -Path "C:\ADS" -Force -Verbose
        }
      
        #Move the files from C:\cladmin\hpeesof to C:\ADS if it exists there
        If (Test-Path "C:\users\cladmin\hpeesof"){Move-Item -Path "C:\users\cladmin\hpeesof" -Destination "C:\ADS\" -Force -Verbose}
      
        #If not there, grab from module & unzip
        else{Expand-Archive "C:\Program Files\WindowsPowerShell\Modules\Keysight\hpeesof.zip" -DestinationPath "C:\ADS" -Force -Verbose}
      }
    }
  }
  
  Process{
    Try{
      #Execute Keysight scriptblock on localhost only
      If ('localhost' -eq $ComputerName){ 
      &$KeysightScriptblock
      }

      #Execute Keysight scriptblock on every PC listed in $ComputerName
      else{
        foreach ($PC in $ComputerName){
          Invoke-Command -ScriptBlock $KeysightScriptblock -ComputerName $PC -AsJob
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
      Log-Write -LogPath $sLogFile -LineValue "Keysight-ADS-FixHomePath Function Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
      Read-Host -Prompt "Press Enter to exit"
      Log-Finish -LogPath $sLogFile
    }
  }
}

Function Keysight-VersionCheck{
  #Tells what version of Keysight is installed
  #Outputs on the screen and C:\Windows\Logs\Keysight\KeySight-Version.log~
  }

  Function KeySight-Uninstall{} 
#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here, when not using as a Module.
#Can execute a function for FOG snap-ins like this:
#& Keysight-ADS-FixHomePath