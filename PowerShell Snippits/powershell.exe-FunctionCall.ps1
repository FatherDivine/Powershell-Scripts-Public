#Oneliner to call a function from a module-based script with no native execution:
powershell.exe -ExecutionPolicy Bypass -Command "& {. .\QuickFixTest.ps1; & QuickFix}"
 