If the snap-in pack is not loaded in FOG (as we only have 8 GIG total shared snapin space on FOG-01), here's the settings:

Create New Snapin
Snapin Name: CSCI Android Studio Installer

Snapin Description: For use in LW840. Installs Android Studio with the professor's specifications (SDK/API 28, Pixel 4 (28) as an AVD aka Android Virtual Device). SDK folder is public (C:\users\public\Libraries) whose location is read by Android Studio by a system environmental variable (ANDROID_HOME) set by this script.
Other configuration files are placed in the user's \Appdata\Roaming\Google folder. This script adds to users who already exist in the c:\users\ folder on each PC and also adds those configuration files to the DEFAULT folder for users who have not yet logged into the PC.
Script skips steps if already done (eg: Android Studio already installed, SDK folder exists, etc).

Snapin Type: Snapin Pack (VERY IMPORTANT)

Snapin Pack Template: Powershell x64 Script

Snapin Pack Arguments: -ExecutionPolicy Bypass -File "[FOG_SNAPIN_PATH]\SnapinASInstaller.ps1" (YOU HAVE TO CHANGE MyScript.ps1 to SnapinASInstaller.ps1 for this to work!)

Hit BROWSE and select CSCI-Android-Studio-Installer.zip

You can disable: "replicate" & "reboot after install"

Click "Update". Thing is since the snapin-pack is so big, you may not see a pop-up that says "snap-in successfully created" or the likes. the only way to check is to login to fog-01 via ssh, and do a "ls -l" in the /opt/fog/snapins folder. If "CSCI-Android-Studio-Installer.zip" is red it's not done uploading.. if it's green it's done. and it should be the size of 3009974959

SnapinASInstaller.ps1 (in this folder) is only there to see what's in the code easier than extracting a 3 GB zip. But that file is already in the zip.
