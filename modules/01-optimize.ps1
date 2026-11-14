# ============================================================
#  WIN 8.1 ULTRA TUNE - Module 01: Optimization
#  Speeds up Windows 8.1 on weak hardware.
#  Run as Administrator.
# ============================================================

Write-Host ""
Write-Host "=== OPTIMIZATION ===" -ForegroundColor Cyan

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Write-Error "Run this script as Administrator (use START.bat)."; exit 1 }

function Set-RegValue($path, $name, $value, $type = "DWord") {
    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    New-ItemProperty -Path $path -Name $name -Value $value -PropertyType $type -Force | Out-Null
}

# --- [1/12] Power plan: High performance ---
Write-Host "[1/12] Power plan: High performance"
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null

# --- [2/12] Visual effects: best performance, keep fonts and thumbnails ---
Write-Host "[2/12] Visual effects"
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" 2
Set-RegValue "HKCU:\Control Panel\Desktop" "FontSmoothing" "2" "String"
Set-RegValue "HKCU:\Control Panel\Desktop\WindowMetrics" "MinAnimate" "0" "String"
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAnimations" 0
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "IconsOnly" 0

# --- [3/12] UI response ---
Write-Host "[3/12] UI response"
Set-RegValue "HKCU:\Control Panel\Desktop" "MenuShowDelay" "0" "String"
Set-RegValue "HKCU:\Control Panel\Desktop" "AutoEndTasks" "1" "String"
Set-RegValue "HKCU:\Control Panel\Desktop" "WaitToKillAppTimeout" "2000" "String"
Set-RegValue "HKCU:\Control Panel\Desktop" "HungAppTimeout" "1000" "String"
Set-RegValue "HKCU:\Control Panel\Mouse" "MouseHoverTime" "10" "String"
# Remove the artificial startup delay for autorun apps
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" "StartupDelayInMSec" 0

# --- [4/12] Telemetry off ---
Write-Host "[4/12] Telemetry"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" "CEIPEnable" 0
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "AITEnable" 0
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableUAR" 1

# --- [5/12] Disable useless / heavy services ---
# NOTE: we only set the startup type and send an async stop command
# (sc.exe stop does not wait). PowerShell Stop-Service can hang
# forever on services like NDU, which refuses to stop cleanly.
Write-Host "[5/12] Services"
$services = @{
    "DiagTrack"        = "Disabled"   # telemetry
    "dmwappushservice" = "Disabled"   # telemetry
    "Fax"              = "Disabled"
    "RemoteRegistry"   = "Disabled"
    "NDU"              = "Disabled"   # known Win 8.1 memory leak
    "WMPNetworkSvc"    = "Disabled"   # media player sharing
    "MapsBroker"       = "Disabled"
    "lfsvc"            = "Disabled"   # geolocation
    "WSearch"          = "Manual"     # indexing; see README to re-enable
}
foreach ($s in $services.Keys) {
    $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
    if ($svc) {
        Set-Service -Name $s -StartupType $services[$s] -ErrorAction SilentlyContinue
        & sc.exe stop $s 2>$null | Out-Null
        Write-Host "   $s -> $($services[$s]) (will fully stop after restart)"
    }
}

# --- [6/12] Disable telemetry scheduled tasks ---
Write-Host "[6/12] Scheduled tasks"
$tasks = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\Autochk\Proxy",
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
)
foreach ($t in $tasks) {
    & schtasks /Change /TN $t /Disable 2>$null | Out-Null
}

# --- [7/12] Remove Metro bloat apps ---
Write-Host "[7/12] Removing built-in bloat apps"
$bloat = @(
    "*Microsoft.BingNews*",
    "*Microsoft.BingFinance*",
    "*Microsoft.BingSports*",
    "*Microsoft.BingTravel*",
    "*Microsoft.BingFoodAndDrink*",
    "*Microsoft.BingHealthAndFitness*",
    "*Microsoft.BingMaps*",
    "*Microsoft.WindowsReadingList*",
    "*Microsoft.WindowsScan*",
    "*Microsoft.WindowsAlarms*",
    "*microsoft.windowscommunicationsapps*",
    "*Microsoft.MicrosoftSolitaireCollection*",
    "*Microsoft.XboxLIVEGames*",
    "*Microsoft.SkypeApp*"
)
foreach ($pattern in $bloat) {
    Get-AppxPackage -Name $pattern -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like $pattern } |
        Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
}

# --- [8/12] Hide OneDrive from Explorer ---
Write-Host "[8/12] OneDrive"
$odPaths = @(
    "HKLM:\SOFTWARE\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
    "HKCU:\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
)
foreach ($p in $odPaths) {
    if (Test-Path $p) {
        New-ItemProperty -Path $p -Name "System.IsPinnedToNameSpaceTree" -Value 0 -PropertyType DWord -Force -ErrorAction SilentlyContinue | Out-Null
    }
}

# --- [9/12] Clean temporary files ---
Write-Host "[9/12] Cleaning temp files"
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service wuauserv -ErrorAction SilentlyContinue

# --- [10/12] Network tweaks ---
Write-Host "[10/12] Network"
netsh int tcp set global autotuninglevel=normal 2>$null | Out-Null
netsh int tcp set global rss=enabled 2>$null | Out-Null

# --- [11/12] Memory tweaks ---
Write-Host "[11/12] Memory"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "ClearPageFileAtShutdown" 0
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "DisablePagingExecutive" 1

# --- [12/12] Restart Explorer ---
Write-Host "[12/12] Restarting Explorer..."
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "OPTIMIZATION COMPLETE. A restart is recommended." -ForegroundColor Green
