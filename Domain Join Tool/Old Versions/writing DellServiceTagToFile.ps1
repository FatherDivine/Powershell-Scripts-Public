#Add this to Domain Join Tool as well as template for Service Tag Puller (and database maker) for Erik.
#If service tag not already in mySQL database, then query the hostname/IP and add to it. If not available, add to retry list. Possible scheduled task to try again until.
#Version 1 just pulls tags on the screen.

WmiObject:

$badwmi = @()
$badserial = @()
foreach ($computer in Get-Adcomputer -filter { (enabled -eq $True) -and (serialNumber -notlike "*")}{
 $serial = Get-WmiObject win32_bios -computername $computer.name -ErrorVariable err
 if ($err) {
  $badwmi += $computer
 }
 elseif ($serial.serialnumber.Length -eq 0 {
  $badserial += $computer
 }
 else {
  set-adcomputer $computer.name -clear serialnumber
  set-adcomputer $computer.name -add @{serialNumber = $serial.serialnumber}
 }
}