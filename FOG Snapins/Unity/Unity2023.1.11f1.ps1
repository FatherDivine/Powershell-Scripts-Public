# Installs Unity editor version 2023.1.11f1
# This is at the request of CSCI Professor Min-Hyung Choi.
# This script is meant to be ran as a FOG snap-in, where, along with this script, and
# setup .exe file are a part of. The affected labs/hosts are ideally CSCI-LW844 and LW840.
# Developed by Aaron S. for CEDC IT Dept. 8-31-2023

# Silently install Unity editor 2023.1.11f1.
& "${PSScriptRoot}\UnitySetup64-2023.1.11f1.exe" /S /D=C:\Program Files\Unity\Hub\Editor\Unity 2023.1.11f1\ | Out-Null

#Housekeeping
exit