#Commands used to test modules:

Invoke-Pester -Show Summary
#for fails: Invoke-Pester -Show Summary, Failed
#to output to a variable, file: $result = Invoke-Pester -PassThru
Invoke-ScriptAnalyzer -Path  "Path\To\Root\Folder\To\Scan\All\Files" -Recurse
Invoke-ScriptAnalyzer -path .\Javier-Proxy\ -recurse -verbose -IncludeSuppressed -ReportSummary

Invoke-ScriptAnalyzer -path * -recurse -Verbose -IncludeSuppressed -ReportSummary