# FOG Housekeeping Script
# This script simply housekeeps the c:\temp and c:\program files x86)\FOG\tmp
# This is useful if a script writes log files or gets stuck in the FOG/tmp folder
# two things FOG won't delete and can get stuck.
# Created by Aaron S. for CEDC IT 9-5-23

#Stop cmd, in case of a Batch script getting stuck keeping a folder open. May need a batch version to close PowerShell if stuck as well.
Stop-Process -Name "cmd"

# Housekeeping
Remove-Item -Path "C:\Temp\*" -Recurse -Force

# Protect the public certificate in the tmp folder from deletion
Remove-Item -Path "C:\Program Files (x86)\FOG\tmp\*" -Exclude "public.cer" -Recurse -Force

Exit