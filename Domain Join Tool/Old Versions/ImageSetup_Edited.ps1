### This will rename the PC and place it into the correct OU and join to the domain. Build a new local admin account if wanted. install some apps if set.
### This script was pieced together by Ethan Braddy with help from David Pierce. Steal what you want, I know I do.

### Allows the prompt boxes to popup outside of PS window
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

### The below section sets $isLaptop to true or false
$computer = "localhost"
$isLaptop = $False
 if(Get-WmiObject -Class win32_systemenclosure -ComputerName $computer | 
    Where-Object { $_.chassistypes -eq 9 -or $_.chassistypes -eq 10 `
    -or $_.chassistypes -eq 14})
   { $isLaptop = $True }
 if(Get-WmiObject -Class win32_battery -ComputerName $computer) 
   { $isLaptop = $True }

### Sets a variable (Platform) to either D or M depending on if $isLaptop
if($isLaptop -eq $False) {set-variable -Name "Platform" -Value "D"}
if($isLaptop -eq $True) {set-variable -Name "Platform" -Value "M"}

### Disables any additional auto logins
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\Currentversion\WinLogon" -Name "AutoAdminLogon" -Value 0
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\Currentversion\WinLogon" -Name "AutoLogonCount" -Value 0

### Hides hidden folders by default
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Currentversion\Explorer\Advanced" -Name "Hidden" -Value 2

### Wait so you get Edge stopped
Start-Sleep -s 3

### Taskkill Edge because its annoying
Taskkill /F /IM MicrosoftEdge.exe

### Prevent Edge first run page because its annoying
New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft -Name MicrosoftEdge -Force
New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge -Name Main -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" -Name "PreventFirstRunPage" -Type DWORD -Value "1"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" -Name "AllowPrelaunch" -Type DWORD -Value "0"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" -Name "HideFirstRunExperience" -Type DWORD -Value "1"

### Disables the local administrator acount and creates a new one if wanted (Disables at the end of script right before restart to prevent lockout from AFK)
$LocalAdminCheck = [System.Windows.MessageBox]::Show("Would you like to disable the default Administrator Account, and set a new local Admin?",'Local Admin Check','YesNo','Error')
IF ($LocalAdminCheck -eq "Yes") {
Function LACheck-Credentials{
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Local User Account Creation'
$form.Size = New-Object System.Drawing.Size(300,250)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,160)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,160)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label1 = New-Object System.Windows.Forms.Label
$label1.Location = New-Object System.Drawing.Point(10,20)
$label1.Size = New-Object System.Drawing.Size(280,20)
$label1.Text = 'Local UserName'
$form.Controls.Add($label1)

$textBox1 = New-Object System.Windows.Forms.TextBox
$textBox1.Location = New-Object System.Drawing.Point(10,40)
$textBox1.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox1)

$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(10,60)
$label2.Size = New-Object System.Drawing.Size(280,20)
$label2.Text = 'Local Password'
$form.Controls.Add($label2)

$textBox2 = New-Object System.Windows.Forms.TextBox
$textBox2.Location = New-Object System.Drawing.Point(10,80)
$textBox2.Size = New-Object System.Drawing.Size(260,20)
$textBox2.PasswordChar = "*"
$form.Controls.Add($textBox2)

$label3 = New-Object System.Windows.Forms.Label
$label3.Location = New-Object System.Drawing.Point(10,100)
$label3.Size = New-Object System.Drawing.Size(280,20)
$label3.Text = 'Confirm Local Password'
$form.Controls.Add($label3)

$textBox3 = New-Object System.Windows.Forms.TextBox
$textBox3.Location = New-Object System.Drawing.Point(10,120)
$textBox3.Size = New-Object System.Drawing.Size(260,20)
$textBox3.PasswordChar = "*"
$form.Controls.Add($textBox3)

$form.Topmost = $true

$form.Add_Shown({$Form.Activate(); $textBox1.Focus()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $Global:LocalAdminUserName = $textBox1.Text
    $Global:LocalAdminPW1 = $textBox2.Text
    $Global:LocalAdminPW2 = $textBox3.Text
}
if ($LocalAdminPW1 -cne $LocalAdminPW2)
{
Do {
LARedo-Credentials
}
Until ($LocalAdminPW1 -ceq $LocalAdminPW2)
}
}

Function LARedo-Credentials{
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Passwords Did Not Match, Please Enter Again'
$form.Size = New-Object System.Drawing.Size(300,250)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,160)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,160)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label1 = New-Object System.Windows.Forms.Label
$label1.Location = New-Object System.Drawing.Point(10,20)
$label1.Size = New-Object System.Drawing.Size(280,20)
$label1.Text = 'Local UserName'
$form.Controls.Add($label1)

$textBox1 = New-Object System.Windows.Forms.TextBox
$textBox1.Location = New-Object System.Drawing.Point(10,40)
$textBox1.Size = New-Object System.Drawing.Size(260,20)
$TextBox1.Text = "$LocalAdminUserName"
$form.Controls.Add($textBox1)

$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(10,60)
$label2.Size = New-Object System.Drawing.Size(280,20)
$label2.Text = 'Local Password'
$form.Controls.Add($label2)

$textBox2 = New-Object System.Windows.Forms.TextBox
$textBox2.Location = New-Object System.Drawing.Point(10,80)
$textBox2.Size = New-Object System.Drawing.Size(260,20)
$textBox2.PasswordChar = "*"
$form.Controls.Add($textBox2)

$label3 = New-Object System.Windows.Forms.Label
$label3.Location = New-Object System.Drawing.Point(10,100)
$label3.Size = New-Object System.Drawing.Size(280,20)
$label3.Text = 'Confirm Local Password'
$form.Controls.Add($label3)

$textBox3 = New-Object System.Windows.Forms.TextBox
$textBox3.Location = New-Object System.Drawing.Point(10,120)
$textBox3.Size = New-Object System.Drawing.Size(260,20)
$textBox3.PasswordChar = "*"
$form.Controls.Add($textBox3)

$form.Topmost = $true

$form.Add_Shown({$Form.Activate(); $textBox2.Focus()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $Global:LocalAdminUserName = $textBox1.Text
    $Global:LocalAdminPW1 = $textBox2.Text
    $Global:LocalAdminPW2 = $textBox3.Text
}
}

LACheck-Credentials

if ($LocalAdminPW1 -cne $LocalAdminPW2) {
Write-Host "Passwords Matched!"
}

$LocalAdminPW = ConvertTo-SecureString $LocalAdminPW1 -asplaintext -force

New-LocalUser -Name $LocalAdminUserName -Password $LocalAdminPW -PasswordNeverExpires
Add-LocalGroupMember -Group "Administrators" -Member $LocalAdminUserName
}

### Sets SVC account credentials (Cant do ANYTHING but add machines to that one OU)
$SVCUser = "University\Serviceaccount"
$SVCPW = ConvertTo-SecureString -String "serviceaccountpassword" -AsPlainText -Force
$SVCCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SVCUser,$SVCPW

### Adds PC to Domain
Add-Computer -DomainName Ucdenver.pvt -OUPath "OU=YOUROU,OU=PARENTOU,DC=UCDENVER,DC=PVT" -Credential $SVCCredentials

### Sets temp PS drive letter for use in the rest of the script
new-psdrive -name "x" -psprovider "FileSystem" -Root "\\ucdenver.pvt\som\SOMDEAN\Installs\ImageRepository" -credential $SVCCredentials | Out-Null

### Pulls the service tag and sets it as a variable (SerialNumber)
$SerialNumber = (gwmi win32_bios).SerialNumber

### Sets Drivers to update as they should
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -value "0"

### Gets and Sets Credentials and checks them to be correct, reprompts if wrong
Function Redo-Credentials{
$Global:Credentials = $host.ui.PromptForCredential("Authentication Failed", "Please verify your username and password","$TechUsername","")
$Global:CredentialTest = Get-ADUser -Server ucdenver.pvt -Identity "ServiceAccount" -Credential $Credentials
}

Function Check-Credentials{
$Global:Credentials = $host.ui.PromptForCredential("UNIVERSITY CREDENTIALS", "Please enter your university username and password","","")
$Global:TechUsername = $Credentials.Username
$Global:CredentialTest = Get-ADUser -Server ucdenver.pvt -Identity "ServiceAccount" -Credential $Credentials
if ($CredentialTest -eq $null)
{
Do {
Redo-Credentials
}
Until ($CredentialTest -ne $null)
}
}
Check-Credentials
Write-Host "Successfully authenticated credentials"

### Next few sections sets the prefix and OU Paths ###

### Selects first OU ###

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Select the first OU'
$form.Size = New-Object System.Drawing.Size(300,600)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,520)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,520)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please select the first OU for this PC:'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(260,20)
$listBox.Height = 480

$listBox.Items.Add('CLAC')
$listBox.Items.Add('CSA')
$listBox.Items.Add('HDC')
$listBox.Items.Add('SOM')
$listBox.Items.Add('SPH')

$form.Controls.Add($listBox)

$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $FirstOU = $listBox.SelectedItem
    $FirstOU
}

### Sets Prefix and OU Path for HDC ###
if($FirstOU -eq 'HDC') {
Set-variable -name "Prefix" -value "HDC"
Set-variable -name "SubOU" -value "HDC"
Set-variable -name "OUPath" -value "OU=HDC,DC=UCDENVER,DC=PVT"
}

### Sets Prefix and OU Path for CLAC ###
if($FirstOU -eq 'CLAC') {
Set-variable -name "Prefix" -value "CLAC"
Set-variable -name "SubOU" -value "CLAC"
Set-variable -name "OUPath" -value "OU=CLAC,DC=UCDENVER,DC=PVT"
}

$SubOUOptions = Get-ADOrganizationalUnit -Server ucdenver.pvt -LDAPFilter '(name=*)' -SearchBase "OU=$FirstOU,DC=UCDENVER,DC=PVT" -SearchScope OneLevel -Credential $Credentials | select Name

### Selects Prefix for CSA ###
if($FirstOU -eq 'CSA') {
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Select the sub OU'
$form.Size = New-Object System.Drawing.Size(300,600)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,520)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,520)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please select the sub OU for this PC:'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(260,20)
$listBox.Height = 480

foreach($ou in $SubOUOptions)
{
$listBox.Items.Add($ou.Name)
}

$form.Controls.Add($listBox)

$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $Prefix = $listBox.SelectedItem
    $Prefix
	$SubOU = $listBox.SelectedItem
}

if ($Prefix.length -gt 4)
{
    $Prefix = $prefix.substring(0,4)
    $Prefix
}

Set-variable -name "OUPath" -value "OU=$SubOU,OU=CSA,DC=UCDENVER,DC=PVT"
}

### Selects Prefix for SOM ###
if($FirstOU -eq 'SOM') {
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Select the sub OU'
$form.Size = New-Object System.Drawing.Size(300,600)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,520)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,520)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please select the sub OU for this PC:'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(260,20)
$listBox.Height = 480

foreach($ou in $SubOUOptions)
{
$listBox.Items.Add($ou.Name)
}

$form.Controls.Add($listBox)

$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $Prefix = $listBox.SelectedItem
    $Prefix
	$SubOU = $listBox.SelectedItem
}
if ($Prefix -eq 'NEUROSURG')
{
    $Prefix = 'NSG'
    $Prefix
}
if ($Prefix.length -gt 4)
{
    $Prefix = $prefix.substring(0,4)
    $Prefix
}
if ($Prefix -eq 'IMM-')
{
    $Prefix = 'IMM'
    $Prefix
}
Set-variable -name "OUPath" -value "OU=$SubOU,OU=SOM,DC=UCDENVER,DC=PVT"
}

### Sets prefix for SPH ###
if($FirstOU -eq 'SPH') {
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Select the sub OU'
$form.Size = New-Object System.Drawing.Size(300,600)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,520)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,520)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please select the sub OU for this PC:'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(260,20)
$listBox.Height = 480

foreach($ou in $SubOUOptions)
{
$listBox.Items.Add($ou.Name)
}

$form.Controls.Add($listBox)

$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $Prefix = $listBox.SelectedItem
    $Prefix
	$SubOU = $listBox.SelectedItem
	$Prefix = $prefix.substring(4)
if ($Prefix.length -gt 4)
{
    $Prefix = $prefix.substring(0,4)
    $Prefix
}
}
if ($Prefix -eq 'RMPR')
{
    $Prefix = 'RMPRC'
    $Prefix
}
Set-variable -name "OUPath" -value "OU=$SubOU,OU=SPH,DC=UCDENVER,DC=PVT"
}

### If it is a RAD machine asks if it is one of the 4 monitor project machines and sets extra installers to run if so
If ($SubOU -eq "RAD")
{
$RADProjectCheck = [System.Windows.MessageBox]::Show("Is this one of the 4 monitor RAD Project machines?",'RAD Project Check','YesNo','Error')
}

### Sets the username
$username = [Environment]::UserName

### Sets desktop path
$DesktopPath = [Environment]::GetFolderPath("Desktop")

### Sets correct name for PC as variable ($ComputerName)
Set-variable -Name "ComputerName" -Value $Prefix-$Platform-$SerialNumber

### Reads out the name for the PC and gets confirmation
$NameConfirm = [System.Windows.MessageBox]::Show("$ComputerName - Is this the correct new name?","Name check",'YesNo','Error')
switch  ($NameConfirm) {
'No' {
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
$ComputerName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter a computer name", "Computer Name", "$ComputerName")
}
}

### Checks to see if the PC Object exists already in AD and prompts to delete if it does
$PCNameConflict = Get-ADComputer -LDAPFilter "(Name=$ComputerName)" -Credential $Credentials
If ($PCNameConflict -ne $Null) {
$NameConflict = [System.Windows.MessageBox]::Show("$ComputerName already exists in AD, this can happen from reimaging a machine. Would you like to delete it?","Name Conflict",'YesNo','Error')
switch  ($NameConflict) {
'Yes' {
Remove-ADObject -Recursive -Server ucdenver.pvt -Identity $PCNameConflict.ObjectGUID -Credential $Credentials -Confirm:$False
}
}
}

### Tries to add AD CM group to local admins group
IF ($FirstOU -eq "HDC") {Add-LocalGroupMember -Group "Administrators" -Member "university\HDC_CM"}
IF ($FirstOU -eq "SOM") {Add-LocalGroupMember -Group "Administrators" -Member "university\${SubOU}_CM"}
IF ($FirstOU -eq "SPH") {Add-LocalGroupMember -Group "Administrators" -Member "university\SPH_CM"}

### Asks for user and sets as admin if wanted

###This searches for the user object, the confusing user related variables are listed below
# $PreSearch is what the tech enters to search for, this checks against username, email, and name (last, first)
# $UserSearchResults is the results that return from the Gat-ADUser
# $FriendlyUserSearchResult is the results edited to look more user friendly just last, first | *truncated OU info*
# $SelectedUser is the user that the tech selected

Function Get-Intended-User{
$Global:PreSearch = [Microsoft.VisualBasic.Interaction]::InputBox("Enter intended user's username, name (last, first), Email address, or leave blank to skip","Intended User Prompt")
$UserSearch = "$PreSearch*"
 
$UserSearchResults = Get-ADUser -Filter {CN -like $UserSearch -or samaccountname -like $UserSearch -or userprincipalname -like $UserSearch} -Credential $Credentials #| Format-Table Name,SamAccountName,DistinguishedName -A

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Form = New-Object System.Windows.Forms.Form
$Form.Text = 'Select the user, cancel setting a user, or search again'
$Form.Size = New-Object System.Drawing.Size(600,360)
$Form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,260)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$Form.AcceptButton = $OKButton
$Form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,260)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$Form.CancelButton = $CancelButton
$Form.Controls.Add($CancelButton)

$SearchAgainButton = New-Object System.Windows.Forms.Button
$SearchAgainButton.Location = New-Object System.Drawing.Point(225,260)
$SearchAgainButton.Size = New-Object System.Drawing.Size(125,23)
$SearchAgainButton.Text = 'Search Again'
$SearchAgainButton_OnClick = {
[System.Windows.Forms.Application]::DoEvents()
$Form.Close()
Write-Host "Searching again, $PreSearch was unhelpful"
$Global:SearchAgain = 'True'
}
$SearchAgainButton.Add_Click($SearchAgainButton_OnClick)
$Form.Controls.Add($SearchAgainButton)

$Label = New-Object System.Windows.Forms.Label
$Label.Location = New-Object System.Drawing.Point(10,20)
$Label.Size = New-Object System.Drawing.Size(280,20)
$Label.Text = 'Please select the intended user from the list:'
$Form.Controls.Add($Label)

$ListBox = New-Object System.Windows.Forms.ListBox
$ListBox.Location = New-Object System.Drawing.Point(10,40)
$ListBox.Size = New-Object System.Drawing.Size(500,300)
$ListBox.Height = 220

ForEach($UserSearchResult in $UserSearchResults)
{
$UserSearchResult -match "CN=(?<content>.*),DC=ucdenver,DC=pvt"
Set-variable -name FriendlyUserSearchResult -value $matches['content']
$FriendlyUserSearchResult = $FriendlyUserSearchResult -replace '[\\]',''
[regex]$pattern = ",OU="
$FriendlyUserSearchResult = $pattern.replace($FriendlyUserSearchResult, "______OU=", 1)
$ListBox.Items.Add($FriendlyUserSearchResult)
}

$Form.Controls.Add($ListBox)

$Form.Topmost = $True

### Thanks David Pierce for help with Do Until loop :)
Do
{
    $result = $form.ShowDialog()
    if ($ListBox.SelectedIndices.Count -lt 1 -and $result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        Write-Warning 'Nothing was selected, please select a user. David Pierce will let you try again'
    }
}
until ($result -eq [System.Windows.Forms.DialogResult]::OK -and $listBox.SelectedIndices.Count -ge 1 -or $result -ne [System.Windows.Forms.DialogResult]::OK)

IF ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $SelectedUser = $ListBox.SelectedItem
    $SelectedUser
}

$SelectedUser -match "(?<content>.*)______OU=*"
$SelectedUsersName = $matches['content']

$Global:SelectedUserObject = Get-ADUser -Filter {CN -like $SelectedUsersName} -Credential $Credentials
$Global:IntendedUserName = $SelectedUserObject.Name
$Global:IntendedUserSAMAccountName = $SelectedUserObject.SAMAccountName

IF ($SearchAgain -eq 'True') {
$Global:SearchAgain = 'False'
Get-Intended-User
}
}

$UserSetupCheck = [System.Windows.MessageBox]::Show("Do you know who this computer is for?","User Setup Check",'YesNo','Error')
IF ($UserSetupCheck -eq 'Yes') {
Get-Intended-User
}

IF ($SelectedUserObject -ne $Null -AND $SelectedUserObject -ne '') {
$IntendedUserAdminCheck = [System.Windows.MessageBox]::Show("Do you want $IntendedUserName to have admin rights to this machine?","User Admin Check",'YesNo','Error')
IF ($IntendedUserAdminCheck -eq 'Yes') {
Add-LocalGroupMember -Group "Administrators" -Member "university\$IntendedUserSAMAccountName"
}
IF ($IntendedUserAdminCheck -eq 'No') {
Add-LocalGroupMember -Group "Users" -Member "university\$IntendedUserSAMAccountName"
}
}

### Add user to Remote Desktop Users Group
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "university\$IntendedUserSAMAccountName"

### Get Info for prepopulated description
$Model = (Get-WmiObject -Class:Win32_ComputerSystem).Model
$Date = Get-Date -Format "MM/dd/yy"

### Prompts for AD Computer Description
$PCDesc = [Microsoft.VisualBasic.Interaction]::InputBox("Enter PCs Description for AD","PC Description Prompt","$Date $Model $IntendedUserName")

### Gets AD Computer Object, because I was having issues with it not being found even after it was created in a few tests
$ADPCObject = Get-ADComputer "$Env:ComputerName" -Credential $Credentials

### Moves PC to correct OU
Move-ADObject -Identity $ADPCObject.ObjectGUID -TargetPath "$OUPath" -Credential $Credentials

### Adds PC to Sec group $SubOU-G-GPO-BitLockerTest
add-adgroupmember -identity $SubOU-G-GPO-BitLocker -members $ADPCObject.ObjectGUID -Credential $Credentials

### Sets AD Computer Description
Set-ADComputer -Identity $ADPCObject.ObjectGUID -Description $PCDesc -Credential $Credentials

### Removes security popups for the below installs only durring this script session then sets back to default
$env:SEE_MASK_NOZONECHECKS = 1

### Sets up the checkedlistbox of what you want to install
$objForm = New-Object System.Windows.Forms.Form

$objForm.Text = "What do you want Installed"
$objForm.Size = New-Object System.Drawing.Size(500,250)
$objForm.StartPosition = "CenterScreen"

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,160)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$objform.AcceptButton = $OKButton
$objform.Controls.Add($OKButton)

$CheckedListBox = New-Object System.Windows.Forms.CheckedListBox
$CheckedListBox.Location = New-Object System.Drawing.Size(20,20)
$CheckedListBox.size = New-Object System.Drawing.Size(300,100) #THIS FIELD AND OTHERS HERE NEED TO BE DYNAMIC BASED ON FILE LENGTHS!
$CheckedListBox.CheckOnClick = $true #so we only have to click once to check a box
$CheckedListBox.Items.Add("Citrix WorkSpace")
$CheckedListBox.Items.Add("Q-Pulse")
$CheckedListBox.Items.Add("EndNote 20")
$CheckedListBox.Items.Add("Adobe Creative Cloud")
$CheckedListBox.Items.Add("VMware Horizon Client")
$CheckedListBox.Items.Add("Absolute")
$CheckedListBox.ClearSelected()
$objForm.Controls.Add($CheckedListBox)

### Adds a VPN checkbox for desktop PCs
IF ($Platform -eq "D") {
$CheckedListBox.Items.Add("GlobalProtect")
}

### Sets Citrix Workspace to default install for OUs that need it
$CitrixOUs = "DOP","RAD","ANES","EMED","RHEUM","NEUROSURG","CARD","GI","ENDO","HEMOTOL","CC","OPH","ONC","PEDS"
IF ($CitrixOus -Contains $SubOU) {
$checkedListBox.SetItemChecked(0,"True")
}

### Sets Q-Pulse to install for OUs that need it
$QPulseOUs = "GBF","GATES"
IF ($QPulseOus -Contains $SubOU) {
$checkedListBox.SetItemChecked(1,"True")
}

### Sets EndNote to install for OUs that need it
$EndNoteOUs = "Endo","GM"
IF ($EndNoteOUs -Contains $SubOU) {
$checkedListBox.SetItemChecked(2,"True")
}

### Sets GlobalProtect to install for OUs that need it
#$GlobalProtectOUs = "ANES","EMED","DHM"
#IF ($GlobalProtectOUs -Contains $SubOU) {
#$checkedListBox.SetItemChecked(4,"True")
#}

### Sets VMware Horizon Client to install for OUs that need it
$VMwareOUs = "CC"
IF ($VMwareOUs -Contains $SubOU) {
$checkedListBox.SetItemChecked(4,"True")
}

### Displays the CheckedListBox with default programs checked
IF ($RADProjectCheck -ne "Yes") {
$objForm.TopMost = $True
$DisplayForm = $objForm.ShowDialog()
}

### Installs and sets RAD Project stuff if selected earlier
IF ($RADProjectCheck -eq "Yes") {
### Encrypt
add-adgroupmember -identity $SubOU-G-GPO-BitLocker -members $ADPCObject.ObjectGUID -Credential $Credentials

### Add Computer to group for Teams GPO
add-adgroupmember -identity $SubOU-G-GPO-TeamsAutoLaunchOn -members $ADPCObject.ObjectGUID -Credential $Credentials

### Add Computer to Radiology WFH AD group for GPO's
add-adgroupmember -identity $SubOU-WFH-Machines -members $ADPCObject.ObjectGUID -Credential $Credentials

### Imports Certs
Import-Certificate -FilePath "X:\RADPROJECT\Certs\PowerScribe360\UCHealth Cert.cer" -CertStoreLocation Cert:\LocalMachine\Root
Import-Certificate -FilePath "X:\RADPROJECT\Certs\Intellispace\uchcert.cer" -CertStoreLocation Cert:\LocalMachine\Root

### NUANCE Folder Added
New-Item -Path "c:" -Name "Nuance" -ItemType "directory"
New-Item -Path "c:\Nuance" -Name "Hologic" -ItemType "directory"

###NUANCE Folder Permissions set
$NUANCEACL = Get-Acl "C:\NUANCE"
$NUANCEAR = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$NUANCEACL.SetAccessRule($NUANCEAR)
Set-Acl "C:\NUANCE" $NUANCEACL

### Set MS Teams to Auto Start
### Try Again
### New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "com.squirrel.Teams.Teams" -Type String -Value "C:\Users\%username%\AppData\Local\Microsoft\Teams\Update.exe --processStart ""Teams.exe"" --process-start-args ""--user-initiated"""
### Below didn't work
### New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "com.squirrel.Teams.Teams" -Type String -Value "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Microsoft Teams.lnk"
### The below is for current user
#Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" -Name "com.squirrel.Teams.Teams" -Type Binary -Value ([byte[]](0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00))

### Set Taskbar to only be on primary display
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbarEnabled" -Type DWord -Value 0

### Installs Absolute
Write-Host "Installing Absolute, please wait."
$AbsoluteInstall=Start-Process "X:\Absolute\Windows\MSI_Deployment\Computrace.msi" -ArgumentList "/quiet /norestart" -passthru
$AbsoluteInstall.WaitForExit()
#Start-Process msiexec.exe -Wait -ArgumentList '/i "X:\Absolute\MSI_Deployment\Computrace.msi" ALLUSERS=1 /qn /norestart /log output.log /quiet /norestart'

### Installs GlobalProtect
Write-Host "Installing GlobalProtect, please wait."
New-Item -Path "c:\itss" -Name "GlobalProtect" -ItemType "directory"
Copy-Item "X:\GlobalProtect\globalprotect64-6-0-3.msi" -Destination "C:\itss\GlobalProtect" | Out-Null
Start-Process msiexec.exe -Wait -ArgumentList '/I "C:\ITSS\GlobalProtect\globalprotect64-6-0-3.msi" /quiet PORTAL="amc-vpn.ucdenver.edu" CONNECTMETHOD="on-demand" ENABLEHIDEWELCOMEPAGE="yes"'

### Installs Citrix Workspace
Write-Host "Installing Citrix Workspace, please wait."
$CitrixInstall=Start-Process "X:\Citrix\Workspace\CitrixWorkspaceApp.exe" -ArgumentList "/silent /ALLOWADDSTORE=N" -passthru
$CitrixInstall.WaitForExit()

### Install NVIDIA Quadro Control Panel Application
Write-Host "Installing NVIDIA Quadro Control Panel Application, please wait."
$NVIDIAQuadroCPAInstall=Start-Process "X:\RADPROJECT\Installs\NVIDIA\nVIDIA-Quadro-Desktop-Control-Panel-Application_K7X00_WIN64_8.1.958.0_A00.EXE" -ArgumentList "/s /i" -passthru
$NVIDIAQuadroCPAInstall.WaitForExit()

### EPIC Warp Drive Install
Write-Host "Installing EPIC Warp Drive, please wait."
$EPICWarpDriveInstall=Start-Process "X:\RADPROJECT\Installs\EPIC Warp Drive\Epic May 2022 Warp Drive-Pack 3.msi" -ArgumentList "/quiet" -passthru
$EPICWarpDriveInstall.WaitForExit()

### EPIC Warp Drive Registry Edit
New-Item -Path "c:\itss" -Name "EPICWarpDriveReg" -ItemType "directory"
Copy-Item "X:\RADPROJECT\Installs\EPIC Warp Drive\WarpDriveConfig-Rad-Primordial-Persistence.reg" -Destination "C:\ITSS\EPICWarpDriveReg" | Out-Null
Start-process reg -ArgumentList "import ""C:\ITSS\EPICWarpDriveReg\WarpDriveConfig-Rad-Primordial-Persistence.reg"""

### Primordial Update Service Install
Write-Host "Installing Primordial Update Service, please wait."
$PrimordialUpdateServiceInstall=Start-Process "X:\RADPROJECT\Installs\Primordial Update Service Installer\PrimordialUpdateServiceInstaller_1.1.98_UCH.msi" -ArgumentList "/quiet" -passthru
$PrimordialUpdateServiceInstall.WaitForExit()

### PRISM Install (2 parts)
Write-Host "Installing PRISM XMLAPI, please wait."
$PRISMXMLAPIInstall=Start-Process "X:\RADPROJECT\Installs\PRISM\Prism.XMLAPI.Installer.msi" -ArgumentList "/quiet" -passthru
$PRISMXMLAPIInstall.WaitForExit()
Write-Host "Installing PRISM, please wait."
$PRISMInstall=Start-Process "X:\RADPROJECT\Installs\PRISM\Prism 3.0.0060.msi" -ArgumentList "/quiet" -passthru
$PRISMInstall.WaitForExit()

### QA Web Agent Install
Write-Host "Installing QA Web Agent, please wait."
$QAWebAgentInstall=Start-Process "X:\RADPROJECT\Installs\QAWA1-13-20\K5403541_21_ApplicationSw\setup.exe" -ArgumentList "/s /v/qn" -passthru
$QAWebAgentInstall.WaitForExit()

### PowerScribe360 Install (Had some issues with the WaitForExit not waiting so added the -wait peram. Seems to work but leaving both just incase.
Write-Host "Trying to launch PowerScribe360 Setup Batch, please wait."
Start-Process -Wait "X:\RADPROJECT\Installs\PowerScribe360\Setup.bat"
Write-Host "Installing PowerScribe360, please wait."
$PowerScribe360Install=Start-Process "X:\RADPROJECT\Installs\PowerScribe360\setup.exe" -ArgumentList "/s /v""/qn+ ISSETUPDRIVEN=1 ALLUSERS=1 DRAGON_INSTALL=1""" -wait -passthru
$PowerScribe360Install.WaitForExit()

### PowerScribe360 Check
#$PowerScribe360Check = [System.Windows.MessageBox]::Show("Continue when batch file is all done. It will open in a minimized CMD window.",'PowerScribe360 Check','OK','Error')

### VPN Install
Write-Host "Installing UCH VPN, please wait."
$UCHVPNInstall=Start-Process "X:\RADPROJECT\Installs\VPN\agee64.msi" -ArgumentList "/Quiet /norestart" -passthru
$UCHVPNInstall.WaitForExit()

### Desktop Shortcuts Placed
Copy-Item "X:\RADPROJECT\DesktopShortcuts\MyApps (EPIC).url" -Destination "C:\Users\Default\Desktop" | Out-Null
Copy-Item "X:\RADPROJECT\DesktopShortcuts\Nuance PowerShare.url" -Destination "C:\Users\Default\Desktop" | Out-Null
Copy-Item "X:\RADPROJECT\DesktopShortcuts\RadDecisionSupport.com.url" -Destination "C:\Users\Default\Desktop" | Out-Null
Copy-Item "X:\RADPROJECT\DesktopShortcuts\RADPEER.url" -Destination "C:\Users\Default\Desktop" | Out-Null
Copy-Item "X:\RADPROJECT\DesktopShortcuts\UCD Email.url" -Destination "C:\Users\Default\Desktop" | Out-Null
Copy-Item "X:\RADPROJECT\DesktopShortcuts\UCH VPN.url" -Destination "C:\Users\Default\Desktop" | Out-Null
Copy-Item "X:\\RADPROJECT\DesktopShortcuts\Epic Warp Drive.lnk" -Destination "C:\Users\Default\Desktop" | Out-Null

### Startup Shortcuts
Copy-Item "X:\RADPROJECT\StartupShortcuts\UCH VPN.url" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp" | Out-Null
Copy-Item "X:\RADPROJECT\StartupShortcuts\Citrix Gateway.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp" | Out-Null

### C Drive file Copies
Write-Host "Importing Philips Intellispace PACS files, please wait."
New-Item -Path "c:\itss" -Name "Philips Intellispace PACS" -ItemType "directory"
Copy-Item "X:\RADPROJECT\Installs\Philips intellispace PACS\IntelliSpacePACSRadiologySetup.exe" -Destination "C:\itss\Philips Intellispace PACS" | Out-Null

### Philips Intellispace PACS
Write-Host "Server for Philips Intellispace PACS is uchpacs-central.pvhs.org"
Start-Process "C:\itss\Philips Intellispace PACS\IntelliSpacePACSRadiologySetup.exe"

### Philips Intellispace PACS Check
$PhilipsIntellispacePACSCheck = [System.Windows.MessageBox]::Show("Continue when Philips Intellispace PACS Install is done. Server is uchpacs-central.pvhs.org",'Philips Intellispace PACS Check','OK','Error')

### Copies Philips Intellispace PACS config file
Remove-Item C:\Users\Public\Philips\4.5\MachinePref\iSiteMachinePref_4_5_6.xml
Copy-Item "X:\RADPROJECT\Installs\Philips intellispace PACS\ConfigFile\iSiteMachinePref_4_5_6.xml" -Destination "C:\Users\Public\Philips\4.5\MachinePref" | Out-Null

### Volume Vision Install (Can't figure out how to get silent) Might need to do after the fact
#$VolumeVisionInstall=Start-Process "X:\RADPROJECT\Installs\VolumeVision\VF_IS_Installer.exe" -passthru
#$VolumeVisionInstall.WaitForExit()
#$VolumeVisionCheck = [System.Windows.MessageBox]::Show("Continue when Volume Vision install is done.",'Volume Vision Check','OK','Error')

### Set Intranet for UCH sites
#New-Item -Path 'HKLM:\Software\Microsoft\Windows\Currentversion\Internet Settings\ZoneMap\Domains\myapps.uchealth.org'
#Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\Currentversion\Internet Settings\ZoneMap\Domains\myapps.uchealth.org' -Name http -Value 1 -Type DWord
#Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\Currentversion\Internet Settings\ZoneMap\Domains\myapps.uchealth.org' -Name https -Value 1 -Type DWord
#New-Item -Path 'HKLM:\Software\Microsoft\Windows\Currentversion\Internet Settings\ZoneMap\Domains\myvpn.uchealth.org'
#Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\Currentversion\Internet Settings\ZoneMap\Domains\myvpn.uchealth.org' -Name http -Value 1 -Type DWord
#Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\Currentversion\Internet Settings\ZoneMap\Domains\myvpn.uchealth.org' -Name https -Value 1 -Type DWord
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\P3P\History' -Name myvpn.uchealth.org -Value 1 -Type DWord
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\P3P\History' -Name myapps.uchealth.org -Value 1 -Type DWord
}

### Checks if system is Dell, and installs DCU Silently if it is
$Manufacturer = Get-CimInstance -ClassName Win32_ComputerSystem
IF ($Manufacturer.Manufacturer -Like "*Dell*") {
New-Item -Path "c:\itss" -Name "DCU" -ItemType "directory"
Copy-Item "X:\Dell\DCU\Dell-Command-Update-Windows-Universal-Application_CJ0G9_WIN_4.7.1_A00.EXE" -Destination "C:\itss\DCU" | Out-Null
Write-Host "Installing Dell Command Update, please wait."
Start-Process -Wait "C:\itss\DCU\Dell-Command-Update-Windows-Universal-Application_CJ0G9_WIN_4.7.1_A00.EXE" -ArgumentList "/s"
}

### Imports Start Menu and TaskBar layout
Write-Host "Importing Start Menu and Task Bar layout, please wait."
Import-StartLayout -LayoutPath "X:\Dell\IAScript\StartLayout\Menu.xml" -MountPath C:\ | Out-Null

### Imports Default App Settings
IF ($RADProjectCheck -ne "Yes") {
Write-Host "Importing default app associations, please wait."
New-Item -Path "c:\itss" -Name "DefaultApp" -ItemType "directory"
Copy-Item "X:\Dell\IAScript\DefaultApp\AppAssociations.xml" -Destination "C:\itss\DefaultApp" | Out-Null
dism /online /import-DefaultAppAssociations:"C:\itss\DefaultApp\AppAssociations.xml" | Out-Null
}
IF ($RADProjectCheck -eq "Yes") {
Write-Host "Importing default app associations, please wait."
New-Item -Path "c:\itss" -Name "DefaultApp" -ItemType "directory"
Copy-Item "X:\RADPROJECT\DefaultApps\AppAssociations.xml" -Destination "C:\itss\DefaultApp" | Out-Null
dism /online /import-DefaultAppAssociations:"C:\itss\DefaultApp\AppAssociations.xml" | Out-Null
}

### Copies the Adobe Creative Cloud installer to ITSS hidden folder
###Copy-Item "X:\Adobe\CreativeCloud\Creative_Cloud_Set-Up.exe" -Destination "C:\ITSS" -force

### Installs GlobalProtect if the machine is mobile
IF ($Platform -eq "M") {Write-Host "Installing GlobalProtect, please wait."
    New-Item -Path "c:\itss" -Name "GlobalProtect" -ItemType "directory"
    Copy-Item "X:\GlobalProtect\globalprotect64-6-0-3.msi" -Destination "C:\itss\GlobalProtect" | Out-Null
    $GlobalProtectInstall=Start-Process msiexec.exe -Wait -ArgumentList '/I "C:\ITSS\GlobalProtect\globalprotect64-6-0-3.msi" /quiet PORTAL="amc-vpn.ucdenver.edu" CONNECTMETHOD="on-demand" ENABLEHIDEWELCOMEPAGE="yes"' -PassThru
    $GlobalProtectInstall.WaitForExit()
    }

### Installs Absolute if it was set to install via the checkboxes
IF ($checkedListBox.CheckedItems -Contains "Absolute") {Write-Host "Installing Absolute, please wait."
    $AbsoluteInstall=Start-Process "X:\Absolute\Windows\MSI_Deployment\Computrace.msi" -ArgumentList "/quiet /norestart" -passthru
    $AbsoluteInstall.WaitForExit()
    }

### Installs GlobalProtect if it was set to install via the checkboxes
IF ($checkedListBox.CheckedItems -Contains "GlobalProtect") {Write-Host "Installing GlobalProtect, please wait."
    New-Item -Path "c:\itss" -Name "GlobalProtect" -ItemType "directory"
    Copy-Item "X:\GlobalProtect\globalprotect64-6-0-3.msi" -Destination "C:\itss\GlobalProtect" | Out-Null
    $GlobalProtectInstall=Start-Process msiexec.exe -Wait -ArgumentList '/I "C:\ITSS\GlobalProtect\globalprotect64-6-0-3.msi" /quiet PORTAL="amc-vpn.ucdenver.edu" CONNECTMETHOD="on-demand" ENABLEHIDEWELCOMEPAGE="yes"' -PassThru
    $GlobalProtectInstall.WaitForExit()
    }

### Installs Citrix if it was set to install earlier
IF ($checkedListBox.CheckedItems -Contains "Citrix WorkSpace") {Write-Host "Installing Citrix Workspace, please wait."
    $CitrixInstall=Start-Process "X:\Citrix\Workspace\CitrixWorkspaceApp.exe" -ArgumentList "/silent" -passthru
    $CitrixInstall.WaitForExit()
    }

### Installs Q-Pulse if it was set to install earlier
IF ($checkedListBox.CheckedItems -Contains "Q-Pulse") {Write-Host "Installing Q-Pulse, please wait."
    $QPulseInstall=Start-Process "X:\Q-Pulse\Installers\Q-Pulse Client\Client\q-pulse.msi" -ArgumentList "/qn GQ_APPSERVER=pdermapp443" -passthru
    $QPulseInstall.WaitForExit()
    Copy-Item "X:\Q-Pulse\Configs\Q-Pulse Client\Q-Pulse.exe.config" -Destination "C:\Program Files (x86)\Gael Ltd\Q-Pulse\Q-Pulse.exe.config" -force
    Copy-Item "X:\Q-Pulse\Shortcut\Q-Pulse.lnk" -Destination "C:\Users\Default\Desktop" -force
    }

### Installs EndNote if it was set to install earlier
IF ($checkedListBox.CheckedItems -Contains "EndNote 20") {Write-Host "Installing EndNote 20, please wait."
    $EndNoteInstall=Start-Process "X:\EndNote\EndNote20\EN20Inst.msi" -ArgumentList "/qn" -passthru
    $EndNoteInstall.WaitForExit()
    }
	
### Installs Zoom
	#Write-Host "Installing Zoom, please wait."
    #$ZoomInstall=Start-Process "X:\Zoom\ZoomInstallerFull.msi" -ArgumentList "/qn" -passthru
    #$ZoomInstall.WaitForExit()

### Copies Adobe CC Installer to the desktop if checked earlier
IF ($checkedListBox.CheckedItems -Contains "Adobe Creative Cloud") {
    Copy-Item "X:\Adobe\CreativeCloud\Creative_Cloud_Set-Up.exe" -Destination "C:\users\default\desktop" -force
    }

### Copies TeamViewer to the desktop
	#Copy-Item "X:\TeamViewer\TeamViewerQS15.8.3.exe" -Destination "C:\users\default\desktop" -force

### Installs Adobe Creative Cloud if set to install earlier
###IF ($checkedListBox.CheckedItems -Contains "Adobe Creative Cloud") 
###{Write-Host "Installing Adobe Creative Cloud, please wait."
###$AcrobatProInstall=Start-Process "C:\ITSS\Creative_Cloud_Set-Up.exe" -ArgumentList "--silent" -passthru
###$AcrobatProInstall.WaitForExit()
###Stop-Process -Name "Creative Cloud" -Force -ErrorAction SilentlyContinue | out-null
###}

### Installs VMware if it was set to install earlier
IF ($checkedListBox.CheckedItems -Contains "VMware Horizon Client") {Write-Host "Installing VMware Horizon Client, please wait."
$EndNoteInstall=Start-Process "X:\VMware\VMware-Horizon-Client-2206-8.6.0-20094380.exe" -ArgumentList "/silent /norestart" -passthru
$EndNoteInstall.WaitForExit()
}

### This is supposed to revert automatically once the script process ends but I'm paranoid
Remove-Item env:SEE_MASK_NOZONECHECKS

### Disable local user admin account if previously set
IF ($LocalAdminCheck -eq "Yes") {
Disable-LocalUser -Name "Administrator"
}

### Removes local FirstLogon script
Remove-Item -Path c:\itss\FirstLogon.ps1 -Recurse -Force

### Renames PC and Restarts
Rename-Computer -ComputerName "$ENV:ComputerName" -NewName "$ComputerName" -DomainCredential $Credentials -Force -Restart
