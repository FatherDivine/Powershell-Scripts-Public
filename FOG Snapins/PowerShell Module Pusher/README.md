# PowerShell Module Pusher

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)

## About <a name = "about"></a>

Installs the latest version of the following PowerShell Modules:
Logging-Functions, 
Invoke-WUInstall, 
Invoke-QuickFix, 
& Javier Squid Proxy (Enable/Disable-Proxy)


## Getting Started <a name = "getting_started"></a>

Meant to be ran as a FOG Snapin, but could be ran locally like all PS code.

### Prerequisites

Nada

### Installing

Once the modules files are located in C:\Program Files\WindowsPowerShell\Modules, it will install automatically. At that point you can just type "Enable-Proxy" or "Disable-Proxy" in any PS session.

## Usage <a name = "usage"></a>


Javier's Squid Proxy:

These commands assume the Enable and Disable proxy modules are installed on the remote and local PC.
#

At any PC with the module, you can natively run the command from any PS session:

Enable-Proxy
Disable-Proxy

#
How to run remotely from any PC with admin authentication:

Invoke-Command -ComputerName $PC -ScriptBlock {Enable-Proxy}

#
If you want to separate as individual jobs so you can easily see which PC may have failed/not taken the changes, you can use the following aliased cmdlet:

$JavierLabPCS|%{icm $_ -Scriptblock {Enable-Proxy} -AsJob}


which is the same as:

Foreach ($PC in $JavierLabPCS) {Invoke-Command -ComputerName -$PC -ScriptBlock {Enable-Proxy} -AsJob}

#
Then you can check jobs by typing:

Get-Job
