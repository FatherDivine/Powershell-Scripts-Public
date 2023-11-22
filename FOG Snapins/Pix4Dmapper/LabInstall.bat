Rem Pix4DMapper installer (as well as task scheduler to activate license)
Rem Created by Aaron S. for CEDC IT Dept. 10-2-23

start /wait msiexec /i Pix4Dmapper-4.8.4.msi /qn /l*v install.log

schtasks.exe /create /F /RU "users" /SC "ONLOGON" /TN "Pix4DMapper" /TR "'C:\Program Files\Pix4Dmapper\pix4dmapper.exe' -c --email julie.gallagher@ucdenver.edu --password P07atoB@dGe"

move /y pix4dmapper.lnk C:\Users\Public\Desktop\pix4dmapper.lnk