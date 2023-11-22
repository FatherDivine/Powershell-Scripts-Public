# Simply renames the Respondus LockDOWN browser icon, so students can more easily find it in the labs.
# This stems from seeing a student search for "Respondus" to find the program in NC2608, a lab where there are no desktop icons.
# Before this snap-in is applied, searching for Respondus will not show the app, only the words "Lockdown Browser" will.
# Created by Aaron S. for CEDC IT Dept 10-12-23

Rename-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Respondus\LockDown Browser 2 Lab.lnk" -NewName "Respondus LockDown Browser 2 Lab.lnk" -Force