#download the client installer to C:\fogtemp\fog.msi
$webclient = New-Object System.Net.WebClient
$webClient.downloadfile("http://10.133.134.10/fog/client/download.php?smartinstaller","C:\temp\SmartInstaller.exe")
#run the installer with msiexec and pass the command line args of /quiet /qn /norestart
Start-Process -FilePath "SmartInstaller.exe" -ArgumentList @('/i','C:\temp\SmartInstaller.exe','/quiet','/qn','/norestart','--server=fog-01','--start') -NoNewWindow -Wait;