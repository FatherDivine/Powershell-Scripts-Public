#requires -version 2
<#
.SYNOPSIS
  Deletes excess files on PCs

.DESCRIPTION
  This script goes thru an array of locations with redundant
  files and deletes the folders and their contents. 
  The intention is for this script to be ran on North Classroom
  lab PCs with hard drives less than 1TB in size.
  On those PCs only 20-30~ GB is avaiable, and this script
  will free up over 45GB. Typically you should see over
  70GB free when this is done.

.PARAMETER <Parameter_Name>
    None

.INPUTS
  None

.OUTPUTS
  None

.NOTES
  Version:        2.0
  Author:         Aaron
  Creation Date:  11-17-2023
  For:            CEDC IT Dept.
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Dot Source required Function Libraries
. "${PSScriptRoot}\Logging_Functions.ps1"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "2.0"

#Log File Info
$sLogPath = "C:\Windows\Temp"
$sLogName = "NCLabCleaner.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

# Define our folder locations for deletion
$folders = "C:\Autodesk","C:\FME"

#-----------------------------------------------------------[Functions]------------------------------------------------------------



Function Delete{
  Param()
  
  Begin{
    Log-Write -LogPath $sLogFile -LineValue "Begin Section"
  }
  
  Process{
    Try{
      Log-Write -LogPath $sLogFile -LineValue "Process (code) Section"

      # Delete unecessary folders hogging up space
      foreach ($folder in $folders){
          if (Test-Path $folder){
          Remove-Item -Path $folder -Recurse -Force
          }
          else{continue}
      }
    }
    
    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }
  
  End{
    #If($?){
      Log-Write -LogPath $sLogFile -LineValue "Function Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
    #}
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion

#Script Execution goes here
Delete

Log-Finish -LogPath $sLogFile