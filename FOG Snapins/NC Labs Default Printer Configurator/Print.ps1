<#
This script makes the Main Lab Black & White Printer as the default.
I had to use a workaround (seen below using arrays) as the full name is hard to code
The full name is '\\PRNT-01\Main Lab Copier Black&White' & '\\PRNT-01\Main Lab Copier Color'

To find the printer names use this command: Get-Printer | Format-Table name

Which will output:

name                    
----                    
OneNote (Desktop)       
Microsoft Print to PDF  
\\PRNT-01\Main Lab Color


Created by Aaron S. for CEDC IT 9-7-23. Updated 9-13-23


#>

# Set Black&White as the default printer
$Printers = Get-CimInstance -class win32_printer -Filter "name like '\\%'"
$MainColorPrinter = $Printers[0]
$MainBlackNWhitePrinter = $Printers[1]

Invoke-CimMethod -InputObject $MainBlackNWhitePrinter -MethodName SetDefaultPrinter


# Can't rename Main Lab Copier w/o doing it on prnt-01 itself (changing share name), and then it will break everyone elses' print abilities
#Rename-Printer -NewName '1 Main Lab Copier Black&White' -Name '\\PRNT-01\Main Lab Copier Black&White'
#Rename-Printer -NewName '2 Main Lab Copier Color' -Name '\\PRNT-01\Main Lab Copier Color'

Rename-Printer -NewName ' 3 Microsoft Print to PDF' -Name 'Microsoft Print to PDF'
Rename-Printer -NewName ' 4 Bluebeam PDF' -Name 'Bluebeam PDF'
Rename-Printer -NewName ' 5 OrCADPS_17.2' -Name 'OrCADPS_17.2'
Rename-Printer -NewName ' 6 Fax' -Name 'Fax'
Rename-Printer -NewName ' 7 OneNote (Desktop)' -Name 'OneNote (Desktop)'
Rename-Printer -NewName ' 8 Microsoft XPS Document Writer' -Name 'Microsoft XPS Document Writer'
Rename-Printer -NewName ' 9 OneNote for Windows 10' -Name 'OneNote for Windows 10'

#Housekeeping
exit