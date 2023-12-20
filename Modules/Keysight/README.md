# NC Keysight License Configurator

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)

## About <a name = "about"></a>

Purpose of this Function/Module is to create functions that support Keysight software. This includes things that may be needed, like license files changes, HOME path/registry edits, or updating (and in some cases, uninstalling, reinstalling) certain softwares. 

The larger idea is to have all software license (and config) changes in module form, so if a license needs changing one can just type "<SoftwareCompany>-<SoftwareName>-<Function>" to support whatever is needed.


## Getting Started <a name = "getting_started"></a>

The code supports getting everything it needs. You may need to enable remote execution of PS code if you've never run PowerShell code in your environment. Open "PowerShell" as administrator and type:<br>

```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
```
<br><br>

Another great cmdlet to type is the one that enables psremoting. This is necessary to run invoke commands on remote PCs. In our environment, this is already enabled on all LAB pcs (and usually part of pre-req portion of a function itself): <br>

```powershell
Enable-PSRemoting
```
<br><br>

Lastly, if you downloaded the script/module online (Github), you may have to right click the script, Properties, and "Unblock" the code from being executed so you can run it.

### Prerequisites

This script automatically downloads the latest Logging-Functions from Father Divine's Github repo if non-existant. That would be the only prerequisite to this script functioning properly.


End with an example of getting some data out of the system or using it for a little demo.

## Usage <a name = "usage"></a>

Have to update this entire readme, but the important part so far is:

  This script , for now, is meant to be ran locally and not actually part of KeySight suite.
  This is because when adding someone to winRM, it causes a restart which kills the connection, 
  so the rest of the script doesn't run. As such, we run this first, then the Keysight tools.

  As such, run Add-PSSessionConfig first to add the ability to copy files from a network share like such:

  ```powershell
  Add-PSSessionConfig -ComputerName $PCList
  ```


Though this is meant to be a module/function, you can still use this with FOG by editing the .ps1(or renaming .psm1 to .ps1) and at the bottom of the script adding whatever function you need to execute. For fixing the homepath, for instance add:<br>

```powershell
Keysight-ADS-FixHomePath
```
<br><br>
That would be enough to upload as a FOG snap-in and have that function load on the local PC.

#

Another use is the function as a .ps1 file on your local PC. You could initialize the script then call the funnctions in that same PowerShell session. Once you close the window, you have to retype both commands. :

#

The #1 recommended version of using this is as a module, which can be loaded onto a PC from a  FOG SNAPIN (likely named Keysight Module Loader, PowerShell Module Pusher/Loader or likes), or thru execution of that FOG script on a local PC, as well as just copying the .psd1 and .psm1 files to C:\Program Files\WindowsPowerShell\Modules\Keysight\ folder is outlined below.<br><br>

The benefit of using modules over the above methods are:<br>
1.) The module is automatically loaded and available in every PowerShell session you open natively.<br>
2.) There is less coding necessary, saving time.<br>
3.) They are easy to update, and have a central location<br>
4.) When the entire lab has a module (like QuickFix) you can just type "QuickFix" or even it's alias "QF" at any PS prompt and it will run on that PC. From that same LAB PC you could run QuickFix on every other PC in the lab.<br><br>
#
To fix the HOME path of the Keysight ADS program on the local PC (as if you're sitting at the one needing the fix), open a PowerShell session and type:<br>

```powershell
Keysight-ADS-FixHomePath 
```
<br><br>
To fix the HOME path of a specific remote PC, open a PowerShell session and type:<br>

```powershell
Keysight-ADS-FixHomePath -ComputerName "<Hostname>"
```
<br><br>
When it comes to a list/array of computers, here are two methods. If you have a text file with a list of PCs already defined (with 1 name on each line, no extra symbols), in a PowerShell session type:<br>

$PCList = Get-Content "C:\Location\Of\Computers.txt"
<#Or if in the same folder that you are already in: $PCList = Get-Content .\Computers.txt#>
<br>
```powershell
Keysight-ADS-FixHomePath -ComputerName $PCList
```
<br><br>
The logging will take care of letting you know if a PC was turned off/not ran on.

<br><br>
  The last example is a dot-sourced one-liner, best used when the environment doesn't have the module installed nor FOG, but you need to run the script (.ps1, or .ps1m renamed to a .ps1) file. This is to be ran from the a PowerShell session, and you are in the same location that the file is:<br>

```powershell
 . .\Keysight.ps1 ; & KeySight-ADS-FixHomePath
```
<br>
If the file is somewhere else, you can use this:<br>
```powershell
. "c:\location\of\Keysight.ps1"; & KeySight-ADS-FixHomePath -ComputerName "<hostname>"
```
<br><br>
and yes, that is 2 dots in the first command, and one dot in the second. The second dit in the first signifies looking in the same directory that the PowerShell session is located. In the second command, we tell it where to look instead of in the same location. But the first dot must always be there in both commands.
#