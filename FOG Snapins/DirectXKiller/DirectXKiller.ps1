# Delete remnants of a bad install prior
#If(Test-Path "C:\Program Files (x86)\FOG\tmp\Microsoft DirectX Silent Installer\DirectX") {
taskkill /IM DXSETUP.exe /F
Stop-Process -Name "DXSETUP.exe" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Program Files (x86)\FOG\tmp\Microsoft DirectX Silent Installer" -Recurse -Force -ErrorAction SilentlyContinue
#}