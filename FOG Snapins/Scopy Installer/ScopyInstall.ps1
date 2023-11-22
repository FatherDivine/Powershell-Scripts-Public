# Created by John Greene 09/15/2023
# Uninstalls old version of Scopy and installs newer version (v1.4.1)
# If the folder for it exists the program is probably there (not the best method but it works) unistall the program.
if (Test-Path -Path "C:\Program Files\Analog Devices\Scopy"){
		Start-Process -FilePath "C:\Program Files\Analog Devices\Scopy\unins000.exe" -ArgumentList "/SILENT" -Verb RunAs -Wait
        Start-Process -FilePath "${PSScriptRoot}\scopy-v1.4.1-Windows-setup.exe" -ArgumentList "/SILENT" -Verb RunAs -Wait
        Start-Sleep 60
        Stop-Process -Name "scopy-v1.4.1-Windows-setup" -Force
        Stop-Process -Name "scopy-v1.4.1-Windows-setup.tmp" -Force
        Exit	
}
else {
    Start-Process -FilePath "${PSScriptRoot}\scopy-v1.4.1-Windows-setup.exe" -ArgumentList "/SILENT" -Wait 
    Exit
    }