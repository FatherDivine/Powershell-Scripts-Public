# Installs Unity Hub 3.5.1.
# This is at the request of CSCI Professor Min-Hyung Choi.
# This script is meant to be ran as a FOG snap-in, where, along with this script, and 
# setup .exe file are a part of. The affected labs/hosts are ideally CSCI-LW844 and LW840.
# Developed by Aaron S. for CEDC IT Dept. 8-31-2023

# Silently install Unity Hub 3.5.1. Piped "Out-Null" makes the script wait until one setup is finish  before starting the next.
& "${PSScriptRoot}\UnityHubSetup.exe" /S | Out-Null

#Housekeeping
exit