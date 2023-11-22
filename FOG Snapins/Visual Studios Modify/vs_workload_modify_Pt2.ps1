# Created by John Greene 08/25/2023 for the CEDC IT department
# Simple script to modify an existing visual studios install and add a workload. Script can be modified to suit changes needed, see https://learn.microsoft.com/en-us/visualstudio/install/command-line-parameter-examples?view=vs-2022 for options.
# By default "Microsoft.VisualStudio.Workload.NativeDesktop" only installs the required components. Any recommended or option components to the workload will need to be added as seen below

# Below line will update Visual Studios itself and install 118 packages which seems to be them all. 
# & "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" updateall

& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" modify `
--channelId VisualStudio.17.Release --productId Microsoft.VisualStudio.Product.Enterprise `
    --add Microsoft.VisualStudio.Component.Unity `
    --add Component.UnityEngine.x64 `
    --add Component.Unreal `
    --add Component.Unreal.Ide `
    --add Microsoft.NetCore.Component.Runtime.6.0 `
    --add Microsoft.NetCore.Component.Runtime.7.0 `
    --add Microsoft.NetCore.Component.SDK `
    --add Microsoft.VisualStudio.Component.AppInsights.Tools `
    --add Microsoft.VisualStudio.ComponentGroup.MSIX.Packaging `
    --add Microsoft.ComponentGroup.Blend `
    --add Microsoft.VisualStudio.Component.VC.Modules.x86.x64 `
    --add Microsoft.VisualStudio.Component.VC.Llvm.Clang `
    --add Microsoft.VisualStudio.Component.VC.Tools.ARM64EC `
    --add Microsoft.VisualStudio.Component.UWP.VC.ARM64EC `
    --add Microsoft.VisualStudio.Component.VC.Tools.ARM64 `
    --add Microsoft.VisualStudio.Component.UWP.VC.ARM64 `
    --add Microsoft.Component.NetFX.Native `
    --add Microsoft.VisualStudio.ComponentGroup.UWP.NetCoreAndStandard `
    --add Microsoft.VisualStudio.Component.Graphics `
    --add Microsoft.VisualStudio.ComponentGroup.UWP.Xamarin `
    --add Microsoft.VisualStudio.ComponentGroup.UWP.Support `
    --add Microsoft.VisualStudio.Component.VC.Redist.MSM `
    --add Microsoft.VisualStudio.Component.VC.v141.CLI.Support `
    --add Microsoft.Net.Component.4.8.TargetingPack `
    --add Microsoft.Net.Component.4.6.2.TargetingPack `
    --add Microsoft.Net.Component.4.7.1.TargetingPack `
    --add Microsoft.Net.ComponentGroup.TargetingPacks.Common `
    --add Microsoft.VisualStudio.Component.NuGet.BuildTools `
    --add Microsoft.VisualStudio.HotReload.Components `
    --add Microsoft.VisualStudio.Component.IntelliCode `
    --add Microsoft.VisualStudio.Component.VC.CLI.Support `
    --add Microsoft.VisualStudio.Component.VC.Tools.ARM `
    --add Microsoft.VisualStudio.Component.VC.Tools.ARM `
    --add Microsoft.VisualStudio.Component.VC.Runtimes.ARM.Spectre `
    --add Microsoft.VisualStudio.Component.VC.Runtimes.ARM64EC.Spectre `
    --add Microsoft.VisualStudio.Component.VC.Runtimes.ARM64.Spectre `
    --add Microsoft.VisualStudio.Component.VC.Runtimes.x86.x64.Spectre `
    --add Microsoft.VisualStudio.Component.VSSDK `
    --add Microsoft.VisualStudio.Component.Windows10SDK `
    --add Microsoft.VisualStudio.Component.Windows10SDK.18362 `
    --add Microsoft.VisualStudio.Component.Windows10SDK.19041 `
    --add Microsoft.VisualStudio.Component.Windows10SDK.20348 `
    --add Microsoft.VisualStudio.Component.Windows11SDK.22000 `
    --add Microsoft.VisualStudio.Component.Windows11SDK.22621 `
    --add Microsoft.VisualStudio.Component.Windows11Sdk.WindowsPerformanceToolkit `
    --add Microsoft.Windows.SDK.BuildTools_10.0.22621.756 `
    --add Microsoft.VisualStudio.VC.CppBuildInsights `
--quiet 