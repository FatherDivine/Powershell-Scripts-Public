#QuickFix Tool
<#
.SYNOPSIS
	Applies repair methods to remote hosts
.DESCRIPTION
	This PowerShell script runs a series of maintenance
    tools (like Checkdisk, System File Checker, & Defrag
    on a user-specified remote PC. Prior to such, this 
    tool runs PS Remote Enabler Script (PSRE.ps1) to
    make sure PS Remoting Services (WinRM) are enabled
    for these commands to work properly.
.PARAMETER 
    None yet, but there may be some in the future 
    to enable command-line use
.EXAMPLE
	PS> .\QuickFix.ps1
.LINK
	\\data\dept\CEAS\ITS\Software\Scripts\QuickFix
.NOTES
	Author: Aaron Staten for CEDC IT
#>


Use the "RUN ME-StartScript.bat if you are unable to start PS scripts on your computer (Remote Exeuction Policy is restrictive).