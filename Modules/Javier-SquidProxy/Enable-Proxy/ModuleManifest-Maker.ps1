$guid = [guid]::NewGuid()

New-ModuleManifest -path "C:\Users\statena\OneDrive - The University of Colorado Denver\CEDC IT\Projects\Aaron S\Powershell-Scripts-Public\Modules\Javier-SquidProxy\Enable-Proxy\Enable-Proxy.psd1" -Guid $guid -Author 'Aaron Staten' -Description 'This script enables Javiar''s Squid proxy for examstaken in the CEDC, specifically Computer Science.' -ModuleVersion 0.1

#invoke-psake as well in the build folder (syntax = verb-noun.ps1)
#but first: Install-Module -Name psake


#New-ModuleManifest -Path 'C:\Users\statena\OneDrive - The University of Colorado Denver\CEDC IT\Projects\Aaron S\Powershell-Scripts-Public\Modules\Invoke-QuickFix' -ModuleToProcess 'C:\Program Files\WindowsPowerShell\Modules\Invoke-QuickFix\Invoke-QuickFix.psm1'