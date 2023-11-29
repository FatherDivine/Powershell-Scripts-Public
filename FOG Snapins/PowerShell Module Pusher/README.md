# PowerShell Module Pusher

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)

## About <a name = "about"></a>

Installs the latest version of the following PowerShell Modules:<br>
Logging-Functions <br>
Invoke-WUInstall <br>
Invoke-QuickFix <br>
Javier Squid Proxy (Enable/Disable-Proxy)<br>


## Getting Started <a name = "getting_started"></a>

Meant to be ran as a FOG Snapin, but could be ran locally like all PS code.

### Prerequisites

Nada

### Installing

Once the modules files are located in C:\Program Files\WindowsPowerShell\Modules, it will install automatically. At that point you can just type "Enable-Proxy" or "Disable-Proxy" in any PS session.

## Usage <a name = "usage"></a>


Javier's Squid Proxy:<br><br>

These commands assume the Enable and Disable proxy modules are installed on the remote and local PC.
#

At any PC with the module, you can natively run the command from any PS session:<br>

Enable-Proxy<br>
Disable-Proxy<br>

#
How to run remotely from any PC with admin authentication:<br><br>

Invoke-Command -ComputerName $PC -ScriptBlock {Enable-Proxy}

# 
If you want to separate as individual jobs so you can easily see which PC may have failed/not taken the changes, you can use the following aliased cmdlet:<br><br>

$JavierLabPCS|%{icm $_ -Scriptblock {Enable-Proxy} -AsJob} <br><br>


which is the same as:<br><br>

Foreach ($PC in $JavierLabPCS) {Invoke-Command -ComputerName -$PC -ScriptBlock {Enable-Proxy} -AsJob}

#
Then you can check jobs by typing:

Get-Job
