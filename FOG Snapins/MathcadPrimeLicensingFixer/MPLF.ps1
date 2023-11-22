# Purpose of this script is to replace C:\Users\All Users\PTC\Mathcad Prime\MathcadPrime.exe.Config
# with a correctly configured version. This script is designed to be ran as part of a FOG snapin pack. 
# That pack includes this script as well as the modified MathcadPrime.exe.Config file.

# Overwrite MathcadPrime.exe.Config for the local PC. By default copy-item overwrites files. The force parameter means it won't ask for user input.
Copy-Item "${PSScriptRoot}\MathcadPrime.exe.Config" -Destination "C:\Users\All Users\PTC\Mathcad Prime" -Force

# Housekeeping. FOG Snapin deletes everything it unzips by default, so no need for remove-item.
exit