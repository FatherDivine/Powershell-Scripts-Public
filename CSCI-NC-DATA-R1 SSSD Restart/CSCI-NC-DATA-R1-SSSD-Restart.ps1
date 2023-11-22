if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process pwsh -Verb runAs -ArgumentList $arguments
  Break
  }

try {Invoke-Command -HostName csci-nc-data-r1 -ScriptBlock {printf "PasswordHERE\n" | sudo -S systemctl restart sssd}
}catch{Write-Error "$_"}
Write-Host "Complete!"
pause
exit