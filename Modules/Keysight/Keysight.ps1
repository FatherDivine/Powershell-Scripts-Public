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
    $sLogName = "ADS-FixHomePath$date.log"
    $sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

    #LogStart
    Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Log-Write -LogPath $sLogFile -LineValue "Keysight-ADS-FixHomePath is running on: $ComputerName"
    Log-Write -LogPath $sLogFile -LineValue "Begin Section"
    Start-Transcript -Path "C:\Windows\Logs\Keysight\ADS-FixHomePath-T$date.log" -Force
    Write-Verbose "Keysight-ADS-FixHomePath is running on: $ComputerName" -Verbose

    #Our heavylifting scriptblock. While @() allows the invoke-command verbose to transcript, it won't actually execute on the remote PC. 
    $KeysightScriptblock = {
      #Registry locations that need editing
      $regKeys = @(
      "HKLM:\SOFTWARE\Keysight\ADS\4.91\eeenv"
      )
      #Our registry test-path variable
      $RegistryTestValue = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Keysight\ADS\4.91\eeenv'
      
      #Test if the registry value was already set, and set if not
      $RegistryTest = Get-ItemPropertyValue $RegistryTestValue -Name HOME
      If ('C:\ADS' -eq $RegistryTest){Write-Verbose 'C:\ADS already set as HOME' -Verbose}
      else {
        Write-Verbose "Setting C:\ADS as HOME at $regKeys" -Verbose

        #Apply the changes to registry        
        $regKeys | ForEach-Object {
          Set-ItemProperty -path $_ HOME -value C:\ADS -Force #-ErrorAction SilentlyContinue
        }
      }

      #Create the directory structure if hpeesof folder is non-existant
      Write-Verbose 'Creating Directory Structure C:\ADS if non-existant.' -Verbose
      If (!(Test-Path "C:\ADS\hpeesof\config")){
        #Test for ADS, create if non-existant. Logic is in case someone created C:\ADS manually, but didn't put the files.
        If (!(Test-Path "C:\ADS")){
          #Create ADS folder (Move-Item does not create folders)
          New-Item -ItemType Directory -Path "C:\ADS" -Force -Verbose
        }
      
        #Move the files from C:\cladmin\hpeesof to C:\ADS if it exists there
        Write-Verbose 'Finding a copy of hpeesof to move to C:\ADS. Might be C:\users\cladmin or Github.' -Verbose
        If (Test-Path "C:\users\cladmin\hpeesof"){Move-Item -Path "C:\users\cladmin\hpeesof" -Destination "C:\ADS\" -Force -Verbose}
      
        #As a backup if not there, grab from Github & unzip
        else{
          Write-Verbose 'C:\users\cladmin\hpeesof was non-existant. Grabbing the latest version from Github.' -Verbose
          # Create a new temporary file
          $Extracthpeesof = ".zip"
          
          #Store the download into the temporary file
          Invoke-WebRequest -Uri https://github.com/FatherDivine/Powershell-Scripts-Public/raw/main/Modules/Keysight/hpeesof.zip  -OutFile $Extracthpeesof
          
          #Extract the temporary file
          $Extracthpeesof | Expand-Archive -DestinationPath "C:\ADS" -Force -Verbose
          
          #Remove temporary file
          $Extracthpeesof | Remove-Item
        }
      }
          #Set the correct permissions for the C:\ADS\hpeesof folder: ADS users must have write access.
          Write-Verbose 'Updating the permissions of C:\ADS\hpeesof so Authenticated Users can access.' -Verbose
          $ACLPath = "C:\ADS\hpeesof"
          $ACL  = Get-Acl -Path $ACLPath
          $user = New-Object -TypeName 'System.Security.Principal.SecurityIdentifier' -ArgumentList @([System.Security.Principal.WellKnownSidType]::AuthenticatedUserSid, $null)
          $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($user, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
          $ACL.SetAccessRule($rule)

          #Set the ACL, write any errors
          try{Set-Acl -Path $ACLPath -AclObject $ACL}catch{Write-Error "An Error occured. Could not set the folder permissions: $_" -Verbose}
         
    }
  }
  
  Process{
    Try{
      Log-Write -LogPath $sLogFile -LineValue "The Process (code) Section."
      #Execute Keysight scriptblock on localhost only
      If ('localhost' -eq $ComputerName){& $KeysightScriptblock}

      #Execute Keysight scriptblock on every PC listed in $ComputerName
      else{foreach ($PC in $ComputerName){Invoke-Command -ScriptBlock $KeysightScriptblock -ComputerName $PC -Verbose}}
      
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
      Stop-Transcript 
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
& Keysight-ADS-FixHomePath