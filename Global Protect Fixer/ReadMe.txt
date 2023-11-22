This tool is "Global Protect Fixer" Version 0.1 and was created in response to issues Jeffrey Selman (Jeffrey.Selman@ucdenver.edu) faced with his Global Protect on May 23, 2023.

Simply put you double left-click the file "RUN ME-StartScript.bat" (can't be run as admin) and it does the rest. Just make sure both files (RUN ME-StartScript.bat & GlobalProtext-Fixer.ps1) are in the same folder.

You may ask why is there a batch script to open a PowerShell script. Well all Windows computers natively disable the running of Powershell scripts, so to get around having to have people open Powershell and input a command all before running the script, I simplified it to the batch bypassing said restriction, opening an elevator (administrative) Powershell window and running the script in said window. 

What does it exactly do?
1.) Kills the PanGPA.exe & PanGPS.exe processes (which is the Global Protect app in the bottom right tray)
2.) Restart the PanGPS service (Wanted to restart the RPC service as well but couldn't due to dependencies)
3.) Restarts the PanGPA.exe (which automatically restarts PanGPS.exe as well).
4.) Shows any errors on screen. Also, if any are detected the last line changes from one of success to one detailing errors detected.

/profit
