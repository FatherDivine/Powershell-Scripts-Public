if (!(Test-Path "C:\Program Files\PowerShell\7\pwsh.exe"))
{ winget install --id Microsoft.Powershell --source winget --force
}