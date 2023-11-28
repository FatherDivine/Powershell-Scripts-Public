$nc2413c|%{write-verbose "$_" -verbose ; Get-CimInstance -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled='True'" -ComputerName $_ | 
Select-Object -Property MACAddress, Description}
