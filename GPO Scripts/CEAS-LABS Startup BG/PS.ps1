# From BirkhoffLee edited by Aaron S.
# Note: if scheduling this script, you may need to check 
# that the powershell session is logged in as the user

$path = $args[0]

$setwallpapersrc = @"
using System.Runtime.InteropServices;

public class Wallpaper
{
  public const int SetDesktopWallpaper = 20;
  public const int UpdateIniFile = 0x01;
  public const int SendWinIniChange = 0x02;
  [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
  private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
  public static void SetWallpaper(string path)
  {
    SystemParametersInfo(SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange);
  }
}
"@
Add-Type -TypeDefinition $setwallpapersrc

[Wallpaper]::SetWallpaper($path)


# And call it like so:
# if hostname = specificlab { wallpaper.ps1 D:\wallpapers\wallpaper.jpg ${PSScriptRoot}\BGInfo\CircuitsLabs.jpg}


# MECH3032 = Circuits and Systems Lab class
# ELEC4136 = Control Systems Analysis
