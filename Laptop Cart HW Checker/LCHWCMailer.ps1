#Version 1.5.5
Param($serial, $datestr)

function sendMail{

Write-Host "Sending Email to CEDC..."

####Define Variables
$attachment = "C:\Users\cladmin\Desktop\LCHWC\$datestr-$serial.txt"
$laptop = $env:COMPUTERNAME
#The below strips CEDC-CART- from the hostname and just leaves the laptop #
# test line for local laptop: $laptopnumber = $laptop.TrimStart(" ", "C","E","D","C","-","N","C","2","6","1","2","A","-") 
$laptopnumber = $laptop.TrimStart(" ", "C","E","D","C","-","C","A","R","T","-")

#SMTP server name
$smtpServer = "mail.ucdenver.pvt"

#Creating a Mail object
$msg = new-object System.Net.Mail.MailMessage

#Creating SMTP server object
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

#Email structure
$msg.From = "LaptopHardwareChecker@ucdenver.edu"
$msg.ReplyTo = "cedchelp@ucdenver.edu"
$msg.To.Add("support+idow6rmo-wwmz@cedchelp.zendesk.com")
$msg.subject = "LCHWC Results for $laptopnumber"
$attach = new-object Net.Mail.Attachment($attachment)

$msg.Attachments.Add($attach)
$msg.body = "Attached are the Laptop Hardware Checker results for $laptop (Service Tag #$serial) highlighting any detected changes in hardware. `n `n This is the result of comparing PreHardware.txt with PostHardware.txt & recording only the differences. If LocalDateTime & Technician Notes are the only lines found in the text file, there were no detected changes in hardware. `n `n The hardware being checked (via serial numbers): `n Service Tag `n Hard Drive `n Memory Chips/RAM `n Display `n Motherboard `n `n Collected on $datestr.`n `n"
#Sending email
$smtp.Send($msg)
}

#Calling function
sendMail