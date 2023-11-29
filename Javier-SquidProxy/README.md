# Javier's Squid Proxy

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Prerequisites](#prerequisites)
- [Usage](#usage)

## About <a name = "about"></a>

This script enables Javiar's Squid proxy for exams in the CEDC, specifically Computer Science.
The purpose is to prevent cheating by only allowing the websites needed for the exam (like Github and Canvas for example).

The base process is making registry changes to enable (and lock down the changes to prevent editing) and then deleting those changes by reversing them.

## Getting Started <a name = "getting_started"></a>

Javier will make all edits to the Squid proxy configuration file itself on the Ubuntu server, so we don’t have to ever login there, once we control the enable and disablement of the proxy. 

The only issues may be if when Javier moves the logs manually (after using the proxy, so no impact on the exam), the read/write permissions are messed and squid will fail to start. Fastest way to solve is backup everything in /etc/squid (config) and logs (/var/log/squid likely) and uninstall/reinstall squid proxy, and place back the config files.


When it comes to activating the proxy, Javier will comment the parts of /etc/squid/squid.conf between:

############################
# START JP
#########################3

and 

 #####################
## END JP
#####################

while restarting squid proxy (systemctl restart squid). This will disable the proxying portion so internet works again as normal. At this time, we can remove the above changes by deploying the Disable-Proxy.ps1 script/snapin.

 
Links to changing the browsers (chrome, FF, edge) homepages  (for use in changing the home page to one allowed by the proxy, so there’s a less chance of “tipping off” students). Plan is to make a snap-in that changes all three at once to something like instructure.ucdenver.edu, or whatever page is allowed in the squid proxy config. 
https://gist.github.com/aldodelgado/ab70809ed513fa59c1a50f532d47297a 
https://devblogs.microsoft.com/powershell-community/how-to-change-the-start-page-for-the-edge-browser/ 


## Prerequisites <a name = "prerequisites"></a>

No real prerequisites, other than a laptop, the scripts, and/or FOG snapin deployment knowledge.



## Usage <a name = "usage"></a>

There are many ways to enable/disable the proxy. The best methods are

1.) Use the FOG snap-ins entitled "Javier Proxy Enable" and "Javier Proxy Disable",
deploying to the FOG group named "Javier LW840-LW844-NC2413" which already has all
the PCs for all 3 labs in it.

##


2.) Using invoke-commands. Using this method means having the "Enable-Proxy.ps1" and "Disable-Proxy.ps1" files on your local PC, using an account with admin credentials (CEDC IT Dept Staff), and executing
the below command from an Administrative Powershell Session that's in the same folder as the files
themself. Note you must specify the computers. You can creat a computer list.txt file (using the lists
located in \\data\..\Software\Scripts\PC LISTS (FOR SCRIPTS)) or use the below code:


##

#Create array with all PCs needing the Proxy
$PCList = @("CSCI-LW840-A1","CSCI-LW840-A2","CSCI-LW840-A3","CSCI-LW840-A4","CSCI-LW840-A5","CSCI-LW840-B1","CSCI-LW840-B2","CSCI-LW840-B3","CSCI-LW840-B4","CSCI-LW840-B5","CSCI-LW840-C1","CSCI-LW840-C2","CSCI-LW840-C3","CSCI-LW840-C4","CSCI-LW840-C5","CSCI-LW840-D1","CSCI-LW840-D2","CSCI-LW840-D3","CSCI-LW840-D4","CSCI-LW840-D5","CSCI-LW840-E1","CSCI-LW840-E2","CSCI-LW840-E3","CSCI-LW840-E4","CSCI-LW840-E5","CSCI-LW840-F1","CSCI-LW840-F2","CSCI-LW840-F3","CSCI-LW840-F4","CSCI-LW840-F5","CSCI-LW840-G1","CSCI-LW840-G2","CSCI-LW840-G3","CSCI-LW840-G4","CSCI-LW840-G5","CSCI-LW840-H1","CSCI-LW840-H2","CSCI-LW840-H3","CSCI-LW840-H4","CSCI-LW840-H5","CSCI-LW844-A1","CSCI-LW844-A2","CSCI-LW844-A3","CSCI-LW844-A4","CSCI-LW844-A5","CSCI-LW844-B1","CSCI-LW844-B2","CSCI-LW844-B3","CSCI-LW844-B4","CSCI-LW844-B5","CSCI-LW844-C1","CSCI-LW844-C2","CSCI-LW844-C3","CSCI-LW844-C4","CSCI-LW844-C5","CSCI-LW844-D1","CSCI-LW844-D2","CSCI-LW844-D3","CSCI-LW844-D4","CSCI-LW844-D5","CSCI-LW844-E1","CSCI-LW844-E2","CSCI-LW844-E3","CSCI-LW844-E4","CSCI-LW844-E5","CSCI-LW844-F1","CSCI-LW844-F2","CSCI-LW844-F3","CSCI-LW844-F4","CSCI-LW844-F5","CSCI-LW844-G1","CSCI-LW844-G2","CSCI-LW844-G3","CSCI-LW844-G4","CSCI-LW844-G5","CSCI-LW844-H1","CSCI-LW844-H2","CSCI-LW844-H3","CSCI-LW844-H4","CSCI-LW844-H5","CEDC-NC2413-A1","CEDC-NC2413-A2","CEDC-NC2413-A3","CEDC-NC2413-A4","CEDC-NC2413-A5","CEDC-NC2413-A6","CEDC-NC2413-B1","CEDC-NC2413-B2","CEDC-NC2413-B3","CEDC-NC2413-B4","CEDC-NC2413-B5","CEDC-NC2413-B6","CEDC-NC2413-C1","CEDC-NC2413-C2","CEDC-NC2413-C3","CEDC-NC2413-C4","CEDC-NC2413-C5","CEDC-NC2413-C6","CEDC-NC2413-D1","CEDC-NC2413-D2","CEDC-NC2413-D3","CEDC-NC2413-D4","CEDC-NC2413-D5","CEDC-NC2413-D6","CEDC-NC2413-E1","CEDC-NC2413-E2","CEDC-NC2413-E3","CEDC-NC2413-E4","CEDC-NC2413-E5","CEDC-NC2413-E6","CEDC-NC2413-F1","CEDC-NC2413-F2","CEDC-NC2413-F3","CEDC-NC2413-F4","CEDC-NC2413-F5","CEDC-NC2413-F6","CEDC-NC2413-G1","CEDC-NC2413-G2","CEDC-NC2413-G3","CEDC-NC2413-G4")




#And run only ONE of the below cmdlets:

Foreach($PC in $PCList){Invoke-Command -ComputerName $PC -FilePath .\Enable-Proxy.ps1 -AsJob}



#OR

$PCList | ForEach-Object {Invoke-Command -ComputerName $_ -FilePath .\Enable-Proxy.ps1 -AsJob}
 



Two ways to skin the same cat, both above methods keep each individual PC (in this case all 120) as a separate job to easily identify which PC may have failed and not had the proxy settings applied/disabled



We can check the jobs using the below command:

get-jobs
 

You'll see something like:

"
Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
5      Job5            RemoteJob       Running       True            hostname-here        Disable-Proxy
7      Job7            RemoteJob       Running       True            cedc-hostname        Disable-Proxy"



##


3.) If using the PS Module form, define the computers you wish to deploy and type:  


Invoke-Command -ComputerName $PCList -ScriptBlock {Enable-Proxy}


We could also wrap that into separate jobs as well using aliases to make things look cryptic:

$PCList|%{icm $_ -ScriptBlock {Enable-Proxy} -AsJob}


The module is available here: https://github.com/FatherDivine/Powershell-Scripts-Public/tree/main/Modules/Javier-SquidProxy) 




Lastly, you can check the Proxy Status (if enabled/disabled) by navigating to C:\Windows\Logs\Proxy\
and reading the "ProxyStatus.txt" file. This shows if It's enabled or disabled, as well as
the date & time it last was. If this is a remote PC, you can do something like the below from File explorer:

\\PCHostname\c$\Windows\Logs\Proxy to open the folder and read the logs.