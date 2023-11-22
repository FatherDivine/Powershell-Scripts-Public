#Version 1.5.5
Param($serial, $datestr)

function sendMail{

Write-Host "Sending Email to CEDC..."

####Define Variables
##$attachment = "C:\Users\cladmin\Desktop\LCHWC\Results.txt"
$attachment = "C:\Users\cladmin\Desktop\LCHWC\$datestr-$serial.txt"
#SMTP server name
$smtpServer = "mail.ucdenver.pvt"

#Creating a Mail object
$msg = new-object System.Net.Mail.MailMessage
#old = $msg = new-object Net.Mail.MailMessage

#Creating SMTP server object
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

#Email structure
$msg.From = "LaptopHWChecker@ucdenver.edu"
$msg.ReplyTo = "cedchelp@ucdenver.edu"
$msg.To.Add("aaron.staten@ucdenver.edu")
$msg.subject = "Laptop Hardware Checker Results"
$attach = new-object Net.Mail.Attachment($attachment)


$msg.Attachments.Add($attach)
$msg.body = "Here are the results of the Laptop Checker"
# doesn't work, only shows first line --> $msg.body = Get-Content -Path C:\Users\cladmin\Desktop\LCHWC\Results.txt -RAW
#Sending email
$smtp.Send($msg)

}

#Calling function
sendMail