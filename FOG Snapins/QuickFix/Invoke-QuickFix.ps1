#requires -version 2
<#
.SYNOPSIS
  Runs maintenance commands and outputs a log.

.DESCRIPTION
  Simple script to run a few maintenance commands on the PC,
  like sfc, DISM, and disk optimization. 
  Outputs the logging to C:\temp.
  This is the standalone/FOG snap-in version that runs on the local PC.

.PARAMETER ComputerName
    Allows for QuickFix to be ran against a remote PC or list of
    remote PCs.

.INPUTS
  None

.OUTPUTS
  Logs are sent to:
  C:\Windows\Logs\QuickFix

.NOTES
  Version:        0.1 (Module)
  Author:         Aaron
  Creation Date:  9/27/23 (Updated 11-26-2023)
  For:            CEDC IT Dept.
  Planned Updates: Keep PS window open after module runs
  
.EXAMPLE
  Run on an array of PCs
  .\QuickFix.ps1 -ComputerName $NC2413

  Run the Module Version from a PS prompt (alias)
  QF

  Run the Module version with a list of PCs from a PS prompt (another alias)
  QuickFix -ComputerName "Test-PC"

  Using the Full (non-aliased) name from a PS prompt
  Invoke-QuickFix

  #FOG Snapin Arguments for calling the function for the local PC
   powershell.exe -ExecutionPolicy Bypass -Command "& {. .\QuickFix.ps1; & QuickFix}" 
#>

#--------------------------------------------------------------[Privilege Escalation]---------------------------------------------------------------

#When admin rights are needed
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}
#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

Write-Verbose "Downloading the latest version of Logging-Functions via Github if non-existant" -Verbose
If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\Logging-Functions")){  
Write-Verbose 'Downloading the latest Logging-Functions module and placing in C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\' -Verbose
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psm1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psm1' -Force)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FatherDivine/Powershell-Scripts-Public/main/Modules/Logging-Functions/Logging-Functions.psd1" -OutFile (New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Logging-Functions\Logging-Functions.psd1' -Force)
}

#Create Quickfix aliases
New-Alias -Name QuickFix -value Invoke-QuickFix -Description "Runs routine maintenance comamnds like SFC, disk check, disk optimize, DISM, and clears cookies & cache on a local or remote PC(s)."
New-Alias -Name QF -value Invoke-QuickFix -Description "Runs routine maintenance comamnds like SFC, disk check, disk optimize, DISM, and clears cookies & cache on a local or remote PC(s)."

#Create the Log folder if non-existant
If (!(Test-Path "C:\Windows\Logs\QuickFix")){New-Item -ItemType Directory "C:\Windows\Logs\Quickfix\" -Force}

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "0.1"

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Invoke-QuickFix{
  [cmdletbinding()]
  Param(
    [Parameter(Mandatory=$false,
    ValueFromPipeline=$true)]
    [string[]]$ComputerName
  )
  
  Begin{

    #Import Modules
    Import-Module -Name Logging-Functions -DisableNameChecking

    #Variables 
    $hostname = hostname

    #Log File Info
    $sLogPath = "C:\Windows\Logs\QuickFix\"
    $sLogName = "QuickFix$date.log"
    $sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

    Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Log-Write -LogPath $sLogFile -LineValue "Begin Section"

    #Scriptblock
    $QuickFixScriptblock = {
      Write-Verbose 'Configuring & restarting TrustedInstaller to fix issues where SFC wont run: "Windows Resource Protection could not start the repair service"' -Verbose
      sc.exe config trustedinstaller "start=auto"
      net start trustedinstaller

      Write-Verbose "Applying the fixes as individual jobs." -Verbose
      #Line below is for when a defrag is needed on an older mechanical drive. SSDs are not defragged
      #start-job -Name Defrag -ScriptBlock {defrag C: /B /U /V | defrag C: /D /U /V}
      
      #Disk Optimization
      Try {
      start-job -Name OptimizeVolume -ScriptBlock {Optimize-Volume -DriveLetter C -ReTrim -Verbose} -Verbose
      Write-Verbose "Disk optimization successfully started." -Verbose
      }catch{Write-Verbose "An error occured: $_" -Verbose}

      #Disk check that schedules next reboot if can't run now. Best to control the reboot at the snap-in level
      Try {
      start-job -Name DiskCheck -ScriptBlock {"y" | chkdsk C: /F /R | chkntfs C: /c} -Verbose
      Write-Verbose "Diskcheck successfully started." -Verbose
      }catch{Write-Verbose "An error occured: $_" -Verbose}

      #DISM
      Try {
      start-job -Name DISM -ScriptBlock {DISM /Online /Cleanup-Image /RestoreHealth} -Verbose
      Write-Verbose "DISM successfully started." -Verbose
      }catch{Write-Verbose "An error occured: $_" -Verbose}

      #SFC
      Try {
      Start-Job -Name SFC -ScriptBlock {sfc /scannow} -Verbose
      Write-Verbose "SFC successfully started." -Verbose
      }catch{Write-Verbose "An error occured: $_" -Verbose}

      #Cache & Cookies section
      Write-verbose "Clearing the cache & cookies." -Verbose
      Try {
      start-job -Name Cache1 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue -Verbose}
      Write-Verbose "Google Chrome default cache successfully cleared." -Verbose
      }catch{Write-Verbose "An error occured: $_" -Verbose}
      Try {
      start-job -Name Cache2 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache2\entries\*" -Recurse -Force -EA SilentlyContinue -Verbose}
      Write-Verbose "Google Chrome default cache2 entries successfully cleared." -Verbose
      }catch{Write-Verbose "An error occured: $_" -Verbose}
      Try {
      start-job -Name Cache3 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Media Cache" -Recurse -Force -EA SilentlyContinue -Verbose}
      Write-Verbose "Google Chrome default media cache successfully cleared." -Verbose
      }catch{Write-Verbose "An error occured: $_" -Verbose}
      Try {
      start-job -Name Cookies1 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies" -Recurse -Force -EA SilentlyContinue -Verbose}
      Write-Verbose "Google Chrome default cookies successfully cleared." -Verbose
      }catch{Write-Verbose "An error occured: $_" -Verbose}
      Try {
      start-job -Name Cookies2 -ScriptBlock {Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies-Journal" -Recurse -Force -EA SilentlyContinue -Verbose}
      Write-Verbose "Google Chrome default cookies journal successfully cleared." -Verbose
      }catch{Write-Verbose "An error occured: $_" -Verbose}

      Write-Verbose "Waiting for jobs to finish while logging everything to file." -Verbose
      $date = Get-Date -Format "-MM-dd-yyyy-HH-mm"
      wait-job -name SFC,OptimizeVolume,DiskCheck,DISM,Cache1,Cache2,Cache3,Cookies1,Cookies2 -Verbose| Receive-Job -WriteEvents -WriteJobInResults -Wait -Verbose| Out-File (New-Item -Path "C:\Windows\Logs\QuickFix\QuickFix-Jobs$date.log" -Force)
    }
  }
  
  Process{
    Try{
      Log-Write -LogPath $sLogFile -LineValue "Process (code) Section"

      #Running QuickFix on the local host.
      If ($null -eq $ComputerName){  
        Log-Write -LogPath $sLogFile -LineValue "QuickFix is running on: Localhost ($hostname)."
        & $QuickFixScriptblock
      }
      #Running QuickFix on remote pc(s).
      else{
          Log-Write -LogPath $sLogFile -LineValue "QuickFix is running on: $ComputerName."         
        foreach ($PC in $ComputerName){
          Invoke-Command -ScriptBlock $QuickFixScriptblock -ComputerName $PC -AsJob
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
      Log-Write -LogPath $sLogFile -LineValue "QuickFix Function Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
      Log-Finish -LogPath $sLogFile -NoExit
    }
  }
}
#-----------------------------------------------------------[Exports]------------------------------------------------------------

& Invoke-QuickFix

#Need to be included at the end of your *psm1 file.
export-modulemember -alias * -function *
