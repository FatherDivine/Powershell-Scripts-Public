<#
Unreal Engine 5.2 Installer.

the Engine files are located on CSCI-LW844-D5
at \\lw844-d5\$C\temp

Unreal engine:
C:\Program Files\Epic Games\UE_5.2
size: 59.2GB, 235,015 files

Created by Aaron S. for CEDC IT 9-1-2023
#>

# Get admin rights
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}
Start-Transcript -Path C:\Temp\UnrealTranscript.txt


# Credentials section, needed to copy the engine files from LW844-D5
function Credentials{
try{
$key = Import-Clixml -LiteralPath ${PSScriptRoot}\Data.xml
  $importObject = Import-Clixml -LiteralPath ${PSScriptRoot}\Cred.xml
  $secureString = ConvertTo-SecureString -String $importObject.Password -Key $key
  $global:Credential = New-Object System.Management.Automation.PSCredential($importObject.UserName, $secureString)
  }catch{Write-Error "`nAn error occured: $($_.Exception.Message)`n"}   
  }

Credentials


# Copy the engine files to the local PC
New-PSDrive -Name "UnityDrive" -PSProvider "FileSystem" -Root "\\CSCI-LW844-D5\C$\Temp\UnrealPackage" -Credential $Credential
Copy-Item UnityDrive:\UE_5.2.7z -Destination "C:\Program Files\Epic Games"
Remove-PSDrive UnityDrive


# unzip in that directory (-y = assumes yes to all prompts/user interaction):
& "C:\Program Files\7-Zip\7z.exe" x "C:\Program Files\Epic Games\UE_5.2.7z" -r -o"C:\Program Files\Epic Games\" -y | Out-Null

# Delete the 7z file:
Remove-Item -Path "C:\Program Files\Epic Games\UE_5.2.7z" -Force

# Run Epic Games Launcher (Install Prerequisites and Downloads Updates). 
MsiExec.exe /i EpicInstaller-15.7.0.msi SHOULD_RUN_LAUNCHER=1 /qn


# close epic games task first if open:
Stop-Process -ProcessName EpicGamesLauncher

# Copy Epic Games Folder (PFx86EpicGames.7z). This will copy DirectXRedist and Launcher folder to Epic Games folder:
& "C:\Program Files\7-Zip\7z.exe" x ".\PFx86EpicGames.7z" -o"C:\Program Files (x86)\Epic Games\" -r -y


# Copy the manifests files:
& "C:\Program Files\7-Zip\7z.exe" x ".\Manifests.7z" -o"C:\ProgramData\Epic\EpicGamesLauncher\Data\Manifests" -r -y


# Copy BuildPatchServicesLocal:
Copy-Item -Path ".\BuildPatchServicesLocal.ini" -Destination "C:\ProgramData\Epic\EpicGamesLauncher\"


# Import registry keys:
reg import ".\UnrealProjectFile.reg"

# Housekeeping
Stop-Transcript
exit