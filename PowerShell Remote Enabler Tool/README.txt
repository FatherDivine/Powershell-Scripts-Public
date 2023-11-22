To start, run "RUN ME-StartScript.bat". This is useful for PCs that do not have PS script execution enabled. In this way, they can still run the script without having to open PS and input a command. Premade computer lists can be found at:
\\data\dept\CEAS\ITS\Software\Scripts\PC Lists (For Scripts)

<#
  .SYNOPSIS
    Enable PS-Remoting remotely.

  .DESCRIPTION
    The PSRE.ps1 script allows the user to enable PS-Remoting on a list 
    of remote computers. It takes input from a file called "computers.txt"
    and runs an enable PS-Remoting command thru PSExec.exe, Both files 
    are in the same folder as the PSRE.ps1 script, and must be to work.

  .LINK
    \\DATA\DEPT\CEAS\ITS\Software\Scripts\PS Remote Enabler
  
  .INPUTS
    None. You cannot pipe objects to PSRE.ps1 at this time

  .OUTPUTS
    None. PSRE.ps1 does not generate any output, though I would love to
    save offline pcs to file. But given how the method works, more work
    must be done to achieve this.

  .EXAMPLE
    PS> .\PSRE.ps1

  .Author
    Created by Aaron S. for CU Denver CEDC IT Dept
 #>
