# Created by John Greene 08/25/2023 for the CEDC IT department
# Simple script to modify an existing visual studios install and add a workload. Script can be modified to suit changes needed, see https://learn.microsoft.com/en-us/visualstudio/install/command-line-parameter-examples?view=vs-2022 for options.
# By default "Microsoft.VisualStudio.Workload.NativeDesktop" only installs the required components. Any recommended or option components to the workload will need to be added as seen below

& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" `
modify --channelId VisualStudio.17.Release --productId Microsoft.VisualStudio.Product.Enterprise `
    --add Microsoft.VisualStudio.Workload.NativeDesktop `
    --add Component.Microsoft.VisualStudio.LiveShare.2022 `
    --add Microsoft.VisualStudio.Component.CppBuildInsights `
    --add Microsoft.VisualStudio.Component.Debugger.JustInTime `
    --add Microsoft.VisualStudio.Component.Graphics.Tools `
    --add Microsoft.VisualStudio.Component.IntelliCode `
    --add Microsoft.VisualStudio.Component.IntelliTrace.FrontEnd `
    --add Microsoft.VisualStudio.Component.JavaScript.TypeScript `
    --add Microsoft.VisualStudio.Component.NuGet `
    --add Microsoft.VisualStudio.Component.NuGet `
    --add Microsoft.VisualStudio.Component.SecurityIssueAnalysis `
    --add Microsoft.VisualStudio.Component.TypeScript.TSServer `
    --add Microsoft.VisualStudio.Component.VC.ASAN `
    --add Microsoft.VisualStudio.Component.VC.ATL `
    --add Microsoft.VisualStudio.Component.VC.CMake.Project `
    --add Microsoft.VisualStudio.Component.VC.DiagnosticTools `
    --add Microsoft.VisualStudio.Component.VC.TestAdapterForBoostTest `
    --add Microsoft.VisualStudio.Component.VC.TestAdapterForGoogleTest `
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    --add Microsoft.VisualStudio.Component.Vcpkg `
    --add Microsoft.VisualStudio.Component.Windows11SDK.22621 `
    --add Microsoft.VisualStudio.Component.Windows11Sdk.WindowsPerformanceToolkit `
    --add Microsoft.VisualStudio.ComponentGroup.WebToolsExtensions `
    --add Microsoft.VisualStudio.ComponentGroup.WebToolsExtensions.CMake `
--quiet 


