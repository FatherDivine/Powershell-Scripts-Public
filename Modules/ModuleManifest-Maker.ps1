$guid2 = [guid]::NewGuid()

New-ModuleManifest -path "C:\Program Files\WindowsPowerShell\Modules\Logging-dirFunctions\Logging-Functions.psd1" -Guid $guid2 -Author 'Aaron Staten' -Description 'Various logging functions used by the CEDC PS Script Template' -ModuleVersion 0.1