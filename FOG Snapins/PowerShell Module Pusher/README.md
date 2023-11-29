# PowerShell Module Pusher

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)

## About <a name = "about"></a>

Installs the latest version of the following PowerShell Modules:
Logging-Functions
Invoke-WUInstall
Invoke-QuickFix
Javier Squid Proxy (Enable/Disable-Proxy)


## Getting Started <a name = "getting_started"></a>

Meant to be ran as a FOG Snapin, but could be ran locally like all PS code.

### Prerequisites

Nada

### Installing

Once the modules files are located in C:\Program Files\WindowsPowerShell\Modules, it will install automatically. At that point you can just type "Enable-Proxy" or "Disable-Proxy" in any PS session.

## Usage <a name = "usage"></a>

Enable-Proxy
Disable-Proxy

or you can do it for remote PCS:

Invoke-Command -ComputerName $PCs -ScriptBlock {Enable-Proxy}
