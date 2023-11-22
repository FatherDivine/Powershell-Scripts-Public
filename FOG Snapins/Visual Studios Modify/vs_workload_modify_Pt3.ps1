# Originally created by John Greene 08/25/2023 for the CEDC IT department
# This fork was made by Aaron S. 9-14-23 to satisfy new requests by Prof. Min Choi
# Simple script to modify an existing visual studios install and add a workload. Script can be modified to suit changes needed, see https://learn.microsoft.com/en-us/visualstudio/install/command-line-parameter-examples?view=vs-2022 for options.
# By default "Microsoft.VisualStudio.Workload.NativeDesktop" only installs the required components. Any recommended or option components to the workload will need to be added as seen below

# Below line will update Visual Studios itself and install 118 packages which seems to be them all. 
# & "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" updateall

& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" modify `
--channelId VisualStudio.17.Release --productId Microsoft.VisualStudio.Product.Enterprise `
    --add Microsoft.VisualStudio.Workload.ManagedDesktop `
    --add Microsoft.VisualStudio.Workload.NativeGame `
--quiet 
exit