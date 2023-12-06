#Global variables
$script:here = "C:\Users\statena\OneDrive - The University of Colorado Denver\CEDC IT\Projects\Aaron S\Powershell-Scripts-Public\Modules\Javier-Proxy\Javier-Proxy"
$script:pubFunctions = ('Enable-Proxy','Disable-Proxy')
$script:TemplatePowerShellModule = 'Javier-Proxy'
$script:Folders = ('Public')

Describe "$TemplatePowerShellModule PowerShell Module Tests" {

    Context 'Module Setup' {
        It "has the root module $TemplatePowerShellModule.psm1" {
            "$here\$TemplatePowerShellModule.psm1" | Should -Exist
        }
        It "has the manifest file $TemplatePowerShellModule.psd1" {
            "$here\$TemplatePowerShellModule.psd1" | Should -Exist
        }
        It "$TemplatePowerShellModule has functions" {
            "$here\Public\*.ps1" | Should -exist
           # "$here\Private\*.ps1" | Should -exist
        }
        It "$TemplatePowerShellModule is valid PowerShell Code" {
            $psFile = Get-Content -Path "$here\$TemplatePowerShellModule.psm1" -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            $errors.count | Should -be 0
        }
    }
}

    Describe 'Folders Tests' {

        It "$Folders Should exist" {
            "$here\$Folders" | Should -Exist
        }
    }

Describe 'Function Tests' {

        Context 'Public Functions' -ForEach $pubFunctions { 
            It "$_.ps1 Should exist" {
                "$here\Public\$_.ps1" | Should -Exist
            }
            It "$_.ps1 Should have help block" {
                "$here\Public\$_.ps1" | Should -FileContentMatch '<#'
                "$here\Public\$_.ps1" | Should -FileContentMatch '#>'
            }
            It "$_.ps1 Should have a SYNOPSIS section in the help block" {
                "$here\Public\$_.ps1" | Should -FileContentMatch '.SYNOPSIS'
            }
            It "$_.ps1 Should have a DESCRIPTION section in the help block" {
                "$here\Public\$_.ps1" | Should -FileContentMatch '.DESCRIPTION'
            }
            It "$_.ps1 Should have a EXAMPLE section in the help block" {
                "$here\Public\$_.ps1" | Should -FileContentMatch '.EXAMPLE'
            }
            It "$_.ps1 Should be an advanced function" {
                "$here\Public\$_.ps1" | Should -FileContentMatch 'function'
                "$here\Public\$_.ps1" | Should -FileContentMatch 'CmdLetBinding'
                "$here\Public\$_.ps1" | Should -FileContentMatch 'param'
            }
            It "$_.ps1 Should contain Write-Verbose blocks" {
                "$here\Public\$_.ps1" | Should -FileContentMatch 'Write-Verbose'
            }
            It "$_.ps1 is valid PowerShell code" {
                $psFile = Get-Content -Path "$here\Public\$_.ps1" -ErrorAction Stop
                $errors = $null
                $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
                $errors.count | Should -be 0
            }
        }# Context Public Function Tests
} # end of describe block