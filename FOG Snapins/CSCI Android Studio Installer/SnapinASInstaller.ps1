# Scripted by: Aaron S. for CEDC IT 6/23/2023 Zendesk Ticket #8158

# For Debugging purposes
Start-Transcript -Path "C:\Temp\FullTranscript.txt" -Force

# Checks to see if Android Studio is already installed. If not, starts installer and waits until it finishes before moving on.
if (!(Test-Path -Path "C:\Program Files\Android\Android Studio")){
    try{Start-Process -FilePath "${PSScriptRoot}\android-studio-2022.2.1.20-windows.exe" -ArgumentList "/S","/AllUsers" -Wait
    }catch{$Error | Out-File c:\temp\ASerrors.txt -Append}
}


# Copies the SDK files to the Public folder with force if it doesn't exist already. Script waits until complete so zip isn't deleted prior by Housekeeping.
if (!(Test-Path -Path "C:\Users\Public\Libraries\Android")){
    try{Expand-Archive -Path "${PSScriptRoot}\sdk.zip" -DestinationPath "C:\Users\Public\Libraries\" -Force
    }catch{$Error | Out-File C:\Temp\ASSDKerrors.txt -Append}
}


# Set system environmental variable for public Sdk folder, if it doesn't exist already
if (-not [Environment]::GetEnvironmentVariable('ANDROID_HOME', 'Machine')){
    try{[Environment]::SetEnvironmentVariable('ANDROID_HOME','C:\Users\Public\Libraries\Android\Sdk','Machine')
    }catch{$Error | Out-File C:\Temp\ASENVErrors.txt -Append}
}


# NON-Android Studio CSCI class user accounts we wish to exclude from the copying to save hard drive space.
$excluded = @("cladmin", "public", "statena", "siscok", "sojdehee", "elamot", "mohameez", "wubeshes")


# Create the Google (settings) folder, then extract the files to them. -Force writes to hidden folder (Default).
if (!(Test-Path -Path "C:\Users\Default\AppData\Roaming\Google\AndroidStudio2022.2")){    
    try{
        $Users = (Get-ChildItem -Exclude $excluded -Force C:\Users).Name
        ForEach($User in $Users) {
            New-Item -Path "C:\Users\$User\AppData\Roaming\" -Name "Google" -ItemType "directory" -ErrorAction SilentlyContinue
            Expand-Archive -Path "${PSScriptRoot}\google.zip" -DestinationPath "C:\Users\$User\AppData\Roaming\Google" -Force
            Start-Sleep -Seconds 1
        } 
    }catch{$Error | Out-File C:\Temp\ASGoogleErrors.txt -Append}
}


# Create the .android (AVD) folder, then extract the files to them. -Force writes to hidden folder (Default)
if (!(Test-Path -Path "C:\Users\Default\.android\avd")){    
    try{
        $Users = (Get-ChildItem -Exclude $excluded -Force C:\Users).Name
        ForEach($User in $Users) {
            New-Item -Path "C:\Users\$User\" -Name ".android" -ItemType "directory" -ErrorAction SilentlyContinue
            Expand-Archive -Path "${PSScriptRoot}\android.zip" -DestinationPath "C:\Users\$User\.android" -Force
            Start-Sleep -Seconds 1
        }
    }catch{$Error | Out-File C:\Temp\ASAndroidErrors.txt -Append}
}    


# Housekeeping. FOG Snap-in deletes everything in the folder it extracted upon the exit command of this script, but "just in case". 
    try{
        Remove-Item -Path "${PSScriptRoot}\android-studio-2022.2.1.20-windows.exe" -Force
        #Remove-Item -Path "${PSScriptRoot}\*" -include *.zip -Force
    }catch{$Error | Out-File C:\Temp\ASerrors.txt -Append}

Stop-Transcript
exit