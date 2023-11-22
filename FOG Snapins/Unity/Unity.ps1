# Installs Unity Hub 3.5.1, as well as the editor versions 2023.1.11f1 & 2022.3.8f1 LTS.
# These are at the request of CSCI Professor Min-Hyung Choi.
# This script is meant to be ran as a FOG snap-in, where, along with this script, both 
# setup .exe files are a part of. The affected labs/hosts are ideally CSCI-LW844 and LW840.
# Developed by Aaron S. for CEDC IT Dept. 8-31-2023

# Silently install Unity Hub 3.5.1. Piped "Out-Null" makes the script wait until one setup is finish  before starting the next.
& "${PSScriptRoot}\UnityHubSetup.exe" /S | Out-Null

# Copy the license file without user input (Force parameter).
Copy-Item "${PSScriptRoot}\Unity_lic.ulf" -Destination "C:\ProgramData\Unity" -Force

# Silently install Unity editor 2023.1.11f1.
& "${PSScriptRoot}\UnitySetup64-2023.1.11f1.exe" /S /D=C:\Program Files\Unity\Hub\Editor\Unity 2023.1.11f1\ | Out-Null

# Silently install Unity editor 2022.3.8f1 Long Term Support (LTS).
& "${PSScriptRoot}\UnitySetup64-2022.3.8f1.exe" /S /D=C:\Program Files\Unity\Hub\Editor\Unity 2022.3.8f1\ | Out-Null

#Housekeeping
exit