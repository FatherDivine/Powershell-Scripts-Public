REM created by Aaron S. for CEDC IT Dept. Latest update --> 10-12-23 (Joined the icon renaming snap-in to the installer so it's AIO now)
START /WAIT setup /s /f1"%CD%\setup.iss"
rename "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Respondus\LockDown Browser 2 Lab.lnk" "Respondus LockDown Browser 2 Lab.lnk"