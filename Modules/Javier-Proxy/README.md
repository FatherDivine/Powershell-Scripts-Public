# Javier's Squid Proxy

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Todo](#todo)

## About <a name = "about"></a>

This Module enables Javiar's Squid proxy for exams in the CEDC, specifically Computer Science.
The purpose is to prevent cheating by only allowing the websites needed for the exam (like Github and Canvas for example).

The base process is making registry changes to enable (and lock down the changes to prevent editing) and then deleting those changes by reversing them.

## Getting Started <a name = "getting_started"></a>

Javier will make all edits to the Squid proxy configuration file itself on the Ubuntu server, so we don’t have to ever login there, once we control the enable and disablement of the proxy. 

The only issues may be if when Javier moves the logs manually (after using the proxy, so no impact on the exam), the read/write permissions are messed and squid will fail to start. Fastest way to solve is backup everything in /etc/squid (config) and logs (/var/log/squid likely) and uninstall/reinstall squid proxy, and place back the config files.


When it comes to activating the proxy, Javier will comment the parts of /etc/squid/squid.conf between:

############################
# START JP
############################

and 

 #####################
# END JP
#####################

while restarting squid proxy (systemctl restart squid). This will disable the proxying portion so internet works again as normal. At this time, we can remove the above changes by deploying the Disable-Proxy.ps1 script/snapin.

 
Links to changing the browsers (chrome, FF, edge) homepages  (for use in changing the home page to one allowed by the proxy, so there’s a less chance of “tipping off” students). Plan is to make a snap-in that changes all three at once to something like instructure.ucdenver.edu, or whatever page is allowed in the squid proxy config. 
https://gist.github.com/aldodelgado/ab70809ed513fa59c1a50f532d47297a 
https://devblogs.microsoft.com/powershell-community/how-to-change-the-start-page-for-the-edge-browser/ 


## Prerequisites <a name = "prerequisites"></a>

This script must be run as SYSTEM user, so best to use as a FOG snap-in which automatically does this, or by using the Invoke-CommandAs module to run it as SYSTEM locally.

The PC actually executing the script must have RunAsUser which allows the script to run as the currently logged in user. This is necessary to make the proxy changes for whomever is actually logged in. Without this part, the changes will only be done to the user's registry who ran the script (in this case the admin/IT staff, or SYSTEM user if using FOG).

Installing the required modules:

To add directly to code you can use

```powershell
#Install required modules
if(! (Get-Module RunAsUser -ListAvailable)){
  install-module RunAsUser
}

#Install required modules
if(! (Get-Module Invoke-CommandAs -ListAvailable)){
  install-module Invoke-CommandAs
}
```

I use a Get-Modules module and FOG snap-in to grab the latest version of modules directly from Github. That is the recommended setup.




## Usage <a name = "usage"></a>

There are many ways to enable/disable the proxy. The best methods are

1.) Use the FOG snap-ins entitled "Javier Proxy Enable" and "Javier Proxy Disable",
deploying to the FOG group named "Javier LW840-LW844-NC2413" which already has all
the PCs for all 3 labs in it.<br>

As such, you can also grab the Enable-Proxy.ps1 and Disable-Proxy.ps1 files in the "Public" folder to upload to FOG or execute without a module. Just make sure you call the function at the bottom of that ps1 ile... Just add "& Enable-Proxy" or "& Disable-Proxy" to the end of the .ps1 script file.

#


2.) Using invoke-commands. Using this method means having the "Enable-Proxy.ps1" and "Disable-Proxy.ps1" files on your local PC, using an account with admin credentials (CEDC IT Dept Staff), and executing
the below command from an Administrative Powershell Session that's in the same folder as the files
themself. Note you must specify the computers. You can creat a computer list.txt file (using the lists
located in \\data\..\Software\Scripts\PC LISTS (FOR SCRIPTS)) or use the below code:<br><br>


#Create array with all PCs needing the Proxy<br>
```powershell
$PCList = @("Test-PC1","Test-PC2")
```


<br><br>
And run only ONE of the below cmdlets:<br>

```powershell
  Invoke-CommandAs -ComputerName PCNameHere -FilePath .\Script.ps1 -AsSystem
```
or
```powershell
  Invoke-CommandAs -ComputerName PCNameHere -ScriptBlock {enable-proxy} -Assystem
```
or
```Powershell
  $PCList|% {Invoke-CommandAs $_ -AsSystem -ScriptBlock {enable-proxy} -AsJob}
```
or
```powershell
  foreach ($PC in $PCList) {Invoke-CommandAs -ComputerName $PC -AsSystem -ScriptBlock {enable-proxy} -AsJob
```
  This runs as SYSTEM user, the only way to do it. FOG automatically picks this up, but for local use,
  install the module "Invoke-CommandAs" and type the above.



<br><br>
Two ways to skin the same cat, both above methods keep each individual PC (in this case all 120) as a separate job to easily identify which PC may have failed and not had the proxy settings applied/disabled


<br><br>
We can check the jobs using the below command:

```powershell
get-job | receive-job
```

#


3.) If using the PS Module form, define the computers you wish to deploy and type: <br>

```powershell
Invoke-Command -ComputerName $PCList -ScriptBlock {Enable-Proxy}
```

<br><br>
We could also wrap that into separate jobs as well using aliases to make things look cryptic:<br>

```powershell
$PCList|%{icm $_ -ScriptBlock {Enable-Proxy} -AsJob}
```
<br><br>
The module is available here: https://github.com/FatherDivine/Powershell-Scripts-Public/tree/main/Modules/Javier-SquidProxy) 



<br><br>
Lastly, you can check the Proxy Status (if enabled/disabled) by navigating to C:\Windows\Logs\Proxy\
and reading the "ProxyStatus.txt" file. This shows if It's enabled or disabled, as well as
the date & time it last was. If this is a remote PC, you can do something like the below from File explorer:<br>

\\PCHostname\c$\Windows\Logs\Proxy to open the folder and read the logs.


## Todo <a name = "todo"></a>
<br>
I'd like to add the ability to do this as a service (new pub function) so it'll set upon first login by students when labs are cleared, then disable upon logoff in an infinite loop. Disable both tasks with a separate script. This is in case students change computers or just log off by accident and back on.
<br>
Also if the ability to do this as good as group policy is achieved, use that instead of tasks. 
<br>
lastly fix the proxy lockout. works for local user without RunAsUser and via group policy, but not thru the new script.
