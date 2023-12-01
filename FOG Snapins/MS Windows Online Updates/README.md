# MS Windows Online Updates Installer Initiator

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

No prerequisites oustide of this file (Initiate-MSWOU.ps1)... That's all you need.

PowerShell, and not pwsh though it may work in pwsh (PowerShell Core) it is untested.
Likely if pwsh gives errors, a legacy module would have to be imported.


## Usage <a name = "usage"></a>

1. Direct command-line deployment from PowerShell:

```powershell
& .\Initiate-MSWOU.ps1
```

2. In the case of FOG, just deploy a PowerShell-based snap-in using the Initiate-MSWOU.ps1 file.


3. Deploying remotely from PowerShell using jobs (so you can see if everything succeeded or failed without accessing the logs in C:\Windows\Logs\MSWOU):

```powershell
Invoke-Command -FilePath .\Initiate-MSWOU.ps1 -ComputerName $PCList -AsJob
```

or if you want to have each job separate in the case of many PCs:

```powershell
foreach ($PC in $PCList){Invoke-Command -FilePath .\Initiate-MSWOU.ps1 -ComputerName $PC -AsJob}
```