# Project Title

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)
- [Contributing](../CONTRIBUTING.md)

## About <a name = "about"></a>

This project's purpose is to:
1. Configure a PC for command-line Windows update
2. Configure remote management of those Windows updates
3. Install updates using the "Check online for updates from Microsoft Update" 
   which are extended updates from "Check for Updates".

The end goal is to allow a sysadmin easier manageability of updates in an enterprise setting.
This script bakes in DevOp methodologies, like downloading the latest version of code directly
from my public GitHub. This way if it's used in scripts (or in our case, possibly a FOG snap-in)
there is no need to ever touch/modify/alter the snap-in: rather just push new code to GitHub.

## Getting Started <a name = "getting_started"></a>

The script is versatile, allowing local or remote use. All you need to run is "Initiate-MSWOU.ps1" 
which will download all required files in the same location as "Initiate-MSWOU.ps1" is located.
As such, make sure to place that script in a location you have administrative permission to
write to. Run the code as an administrator if needed. In our main use case, a FOG snap-in, FOG
runs PS scripts as the SYSTEM user so there is no need, but all files that "Initiate-MSWOU.ps1
downloads (MSWOU.ps1, MSWRUP.ps1) each have a commented-out "Privilege Escalation" section if needed.

### Prerequisites

No prerequisites oustide of Initiate-MSWOU.ps1... That's all you need.

PowerShell works but pwsh (PowerShell Core) is untested though it may work.
Likely if pwsh gives errors, a legacy module would have to be imported.


## Usage <a name = "usage"></a>

How to use as a tool to run updates remotely using the dot sourcing (.ps1) file method:

. .\MSWOU.ps1 
& MSWOnlineUpdater -ComputerName $NC2413 


How to use just to update PCs remotely after prerequisites are already installed:

. .\location\of\MSWOU.ps1
MSWOnlineUpdater -Computername $ArrayofPCs


To use it in a script or likes:

$MSWRemoteUpdatesPrerequisites = {. ${PSScriptRoot}\MSWOU.ps1 ; MSWRemoteUpdatesPrerequisites}
$MSWOnlineUpdater = {. C:\temp\MSWOU.ps1 ; MSWOnlineUpdater}

Start-Job -ScriptBlock $MSWRemoteUpdatesPrerequisites -Verbose| Wait-Job -Verbose | Receive-Job -Verbose
Start-Job -ScriptBlock $MSWOnlineUpdater -Verbose| Wait-Job -Verbose | Receive-Job -Verbose