# Removes a faulty license file placed by the now defunct Unity Hub installer & licenser fog snapin


# Remove faulty license file without user input (Force parameter).
Remove-Item "C:\ProgramData\Unity\Unity_lic.ulf" -Force

#Housekeeping
exit