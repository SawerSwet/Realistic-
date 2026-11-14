# ============================================================
#  WIN 8.1 ULTRA TUNE - Module 05: Win11 look PLUS (free tools)
#  1) Aero Glass for Win8.1 (Big Muscle) - real transparency
#     and blur of window borders, like Win11 acrylic.
#     Free version shows a small watermark in the corner.
#  2) Winstep Nexus dock - a centered bottom panel like the
#     Win11 taskbar (can fully replace it).
#  Needs internet. Installers open in windows - click through them.
#  Run as Administrator.
# ============================================================

Write-Host ""
Write-Host "=== WIN11 LOOK PLUS ===" -ForegroundColor Cyan

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Write-Error "Run this script as Administrator (use START.bat)."; exit 1 }

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$tmp = Join-Path $env:TEMP "UltraTune"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

function Download-File($url, $out) {
    try {
        Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
        return $true
    } catch {
        Write-Warning ("Download failed: " + $url + " (" + $_ + ")")
        return $false
    }
}

# --- [1/2] Aero Glass for Windows 8.1 (v1.4.6, free) ---
Write-Host "[1/2] Aero Glass (real transparent + blurred window borders)"
$agExe = Join-Path $tmp "setup-w8.1-1.4.6.exe"
if (Download-File "https://archive.org/download/full-glass8-archive/glass8.eu/files/setup-w8.1-1.4.6.exe" $agExe) {
    Write-Host "   The installer window will open. Click through it (Next / Install / Finish)."
    try {
        Start-Process $agExe -Wait
        Write-Host "   Aero Glass installed." -ForegroundColor Green
    } catch {
        Write-Warning "Could not start the installer. Run it manually from: $tmp"
    }
} else {
    Write-Warning "Manual download: https://archive.org/download/full-glass8-archive/glass8.eu/files/setup-w8.1-1.4.6.exe"
}

# --- [2/2] Winstep Nexus dock (free) ---
Write-Host "[2/2] Winstep Nexus dock (Win11-style centered panel)"
$nexusZip = Join-Path $tmp "nexus.zip"
if (Download-File "https://www.winstep.net/nexus.zip" $nexusZip) {
    $nexusDir = Join-Path $tmp "nexus"
    Expand-Archive -Path $nexusZip -DestinationPath $nexusDir -Force
    $setup = Get-ChildItem $nexusDir -Recurse -Filter *.exe |
        Where-Object { $_.Name -match 'setup|install' } | Select-Object -First 1
    if (-not $setup) {
        $setup = Get-ChildItem $nexusDir -Recurse -Filter *.exe | Select-Object -First 1
    }
    if ($setup) {
        Write-Host "   The installer window will open. Install with default options."
        try {
            Start-Process $setup.FullName -Wait
            Write-Host "   Nexus installed." -ForegroundColor Green
        } catch {
            Write-Warning "Could not start the installer. Run it manually: $($setup.FullName)"
        }
    } else {
        Write-Warning "No installer found inside the zip. Look in: $nexusDir"
    }
} else {
    Write-Warning "Manual download: https://www.winstep.net/nexus.zip"
}

# --- Final setup instructions ---
Write-Host ""
Write-Host "TO FINISH THE WIN11 LOOK (2 minutes, one time):" -ForegroundColor Yellow
Write-Host " 1. Nexus: right-click the dock -> Preferences -> Position:"
Write-Host "    screen edge = Bottom, alignment = Center."
Write-Host " 2. Right-click the Windows taskbar -> Properties:"
Write-Host "    enable 'Auto-hide the taskbar' (the dock replaces it)."
Write-Host " 3. In Nexus Preferences -> Themes pick a dark flat theme."
Write-Host ""
Write-Host "DONE." -ForegroundColor Green
