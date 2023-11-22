# Installs Unity License
# This is at the request of CSCI Professor Min-Hyung Choi.
# This script is meant to be ran as a FOG snap-in, where, along with this script, and 
# setup .exe file are a part of. The affected labs/hosts are ideally CSCI-LW844 and LW840.
# Developed by Aaron S. for CEDC IT Dept. 8-31-2023

# See if the path already exists, if not create it.
if(-not(Test-Path "C:\ProgramData\Unity")){
   New-Item "C:\ProgramData\Unity" -ItemType Directory -Force
   }

# Copy the license file without user input (Force parameter). THIS LIC DOES NOT WORK YET. LIC = LOCAL PC TOKEN/GENERATED
Copy-Item "${PSScriptRoot}\Unity_lic.ulf" -Destination "C:\ProgramData\Unity\Unity_lic.ulf" -Recurse -Force

#Housekeeping
exit