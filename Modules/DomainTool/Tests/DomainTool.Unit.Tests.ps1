#Global variables
$script:TemplatePowerShellModule = 'DomainTool'
$script:here = "$PSScriptRoot\..\$TemplatePowerShellModule"
$script:pubFunctions = ('Add-ServiceTag','Get-Domain','Join-Domain','Unjoin-Domain')
$script:privFunctions = ('Enable-PSRemote','Get-Credentials')#,'PSRemoteStatus','Enable-PSRemote')
$script:Folders = ('Public','Private')

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

        It "<_> Folder Should exist" -ForEach $Folders {
            "$here\$_" | Should -Exist
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

            Context 'Private Functions' -ForEach $privFunctions {
                It "$_.ps1 should exist" {
                    "$here\Private\$_.ps1" | Should -Exist
                }
                It "$_.ps1 should have help block" {
                    "$here\Private\$_.ps1" | Should -FileContentMatch '<#'
                    "$here\Private\$_.ps1" | Should -FileContentMatch '#>'
                }
                It "$_.ps1 should have a SYNOPSIS section in the help block" {
                    "$here\Private\$_.ps1" | Should -FileContentMatch '.SYNOPSIS'
                }
                It "$_.ps1 should have a DESCRIPTION section in the help block" {
                    "$here\Private\$_.ps1" | Should -FileContentMatch '.DESCRIPTION'
                }
                It "$_.ps1 should have a EXAMPLE section in the help block" {
                    "$here\Private\$_.ps1" | Should -FileContentMatch '.EXAMPLE'
                }
                It "$_.ps1 should be an advanced function" {
                    "$here\Private\$_.ps1" | Should -FileContentMatch 'function'
                    "$here\Private\$_.ps1" | Should -FileContentMatch 'CmdLetBinding'
                    "$here\Private\$_.ps1" | Should -FileContentMatch 'param'
                }
                It "$_.ps1 should contain Write-Verbose blocks" {
                    "$here\Private\$_.ps1" | Should -FileContentMatch 'Write-Verbose'
                }
                It "$_.ps1 is valid PowerShell code" {
                    $psFile = Get-Content -Path "$here\Private\$_.ps1" -ErrorAction Stop
                    $errors = $null
                    $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
                    $errors.count | Should be 0
                }
            } # Context Private Function Tests
} # end of describe block