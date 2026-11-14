# ============================================================
#  WIN 8.1 ULTRA TUNE - Module 02: Win11-style dark look
#  Dark color scheme, purple accent, generated wallpaper,
#  small taskbar icons, no charms / hot corners.
#  Run as Administrator.
# ============================================================

Write-Host ""
Write-Host "=== WIN11 DARK LOOK ===" -ForegroundColor Cyan

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Write-Error "Run this script as Administrator (use START.bat)."; exit 1 }

function Set-RegValue($path, $name, $value, $type = "DWord") {
    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    New-ItemProperty -Path $path -Name $name -Value $value -PropertyType $type -Force | Out-Null
}

$themeDir = Join-Path $env:USERPROFILE "Win81UltraTune"
New-Item -ItemType Directory -Force -Path $themeDir | Out-Null

try {
    Add-Type -TypeDefinition @"
using System.Runtime.InteropServices;
public class UltraWin32 {
    [DllImport("user32.dll")]
    public static extern bool SetSysColors(int count, int[] elements, uint[] colors);
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int action, int param, string lpvParam, int flags);
}
"@ -ErrorAction SilentlyContinue
} catch { }

# --- [1/8] Generate and apply dark wallpaper ---
Write-Host "[1/8] Wallpaper"
& (Join-Path $PSScriptRoot "04-wallpaper.ps1")
$wall = Join-Path $themeDir "wallpaper.png"
if (Test-Path $wall) {
    Set-RegValue "HKCU:\Control Panel\Desktop" "Wallpaper" $wall "String"
    Set-RegValue "HKCU:\Control Panel\Desktop" "WallpaperStyle" "2" "String"
    Set-RegValue "HKCU:\Control Panel\Desktop" "TileWallpaper" "0" "String"
    [UltraWin32]::SystemParametersInfo(20, 0, $wall, 3) | Out-Null
}

# --- [2/8] Dark color scheme (like Win11 dark mode) ---
Write-Host "[2/8] Dark color scheme"
$colors = @{
    "Scrollbar"       = "55 55 70"
    "ActiveTitle"     = "25 20 45"
    "InactiveTitle"   = "35 30 55"
    "Menu"            = "38 38 48"
    "Window"          = "32 32 40"
    "WindowFrame"     = "70 70 90"
    "MenuText"        = "235 235 245"
    "WindowText"      = "235 235 245"
    "TitleText"       = "240 240 255"
    "ActiveBorder"    = "60 50 100"
    "InactiveBorder"  = "50 45 75"
    "AppWorkSpace"    = "28 28 36"
    "Hilight"         = "124 92 255"
    "HilightText"     = "255 255 255"
    "ButtonFace"      = "45 45 55"
    "ButtonShadow"    = "90 90 110"
    "GrayText"        = "130 130 150"
    "ButtonText"      = "235 235 245"
    "InactiveTitleText" = "160 160 180"
    "ButtonHilight"   = "70 70 90"
    "InfoText"        = "235 235 245"
    "InfoWindow"      = "38 38 48"
    "HotTrackingColor" = "150 130 255"
    "GradientActiveTitle" = "60 40 110"
    "GradientInactiveTitle" = "45 35 70"
}
foreach ($c in $colors.Keys) {
    Set-RegValue "HKCU:\Control Panel\Colors" $c $colors[$c] "String"
}

# Apply colors immediately
$sysMap = @{
    0 = "Scrollbar"; 2 = "ActiveTitle"; 3 = "InactiveTitle"; 4 = "Menu"; 5 = "Window";
    6 = "WindowFrame"; 7 = "MenuText"; 8 = "WindowText"; 9 = "TitleText";
    10 = "ActiveBorder"; 11 = "InactiveBorder"; 12 = "AppWorkSpace"; 13 = "Hilight";
    14 = "HilightText"; 15 = "ButtonFace"; 16 = "ButtonShadow"; 17 = "GrayText";
    18 = "ButtonText"; 19 = "InactiveTitleText"; 20 = "ButtonHilight"; 23 = "InfoText";
    24 = "InfoWindow"; 26 = "HotTrackingColor"; 27 = "GradientActiveTitle"; 28 = "GradientInactiveTitle"
}
$elements = New-Object System.Collections.ArrayList
$colorRefs = New-Object System.Collections.ArrayList
foreach ($k in $sysMap.Keys) {
    $v = $colors[$sysMap[$k]] -split ' '
    [void]$elements.Add([int]$k)
    [void]$colorRefs.Add([uint32]([int]$v[0] + [int]$v[1] * 256 + [int]$v[2] * 65536))
}
[UltraWin32]::SetSysColors($elements.Count, $elements.ToArray(), $colorRefs.ToArray()) | Out-Null

# --- [3/8] DWM glass color: dark purple ---
Write-Host "[3/8] Window accent color"
Set-RegValue "HKCU:\Software\Microsoft\Windows\DWM" "ColorizationColor" 0xFF9E2C4E
Set-RegValue "HKCU:\Software\Microsoft\Windows\DWM" "ColorizationColorBalance" 0x00000046
Set-RegValue "HKCU:\Software\Microsoft\Windows\DWM" "EnableAeroPeek" 1

# --- [4/8] Taskbar: small icons (Win11 style) ---
Write-Host "[4/8] Taskbar"
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarSmallIcons" 1

# --- [5/8] Kill Metro behavior: hot corners, charms, boot to desktop ---
Write-Host "[5/8] Disabling charms and hot corners"
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell\EdgeUI" "DisabledHotCorners" 1
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell\EdgeUI" "DisableCharmsHint" 1
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell\EdgeUI" "DisableTLcorner" 1
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage" "OpenAtLogon" 0

# --- [6/8] Desktop icons: This PC ---
Write-Host "[6/8] Desktop icons"
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" 0

# --- [7/8] Explorer: show file extensions ---
Write-Host "[7/8] Explorer"
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0

# --- [8/8] Restart Explorer to apply ---
Write-Host "[8/8] Restarting Explorer..."
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "DARK LOOK APPLIED. Run module 03 (START.bat, option 5) for the start menu and widgets." -ForegroundColor Green
