# ============================================================
#  WIN 8.1 ULTRA TUNE - Module 03: Tools
#  Downloads and installs:
#    - Open-Shell  (classic Start menu instead of the Metro screen)
#    - Rainmeter   (desktop widgets: clock, CPU, RAM, disk)
#  Needs internet. Run as Administrator.
# ============================================================

Write-Host ""
Write-Host "=== TOOLS ===" -ForegroundColor Cyan

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Write-Error "Run this script as Administrator (use START.bat)."; exit 1 }

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$tmp = Join-Path $env:TEMP "UltraTune"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

function Get-LatestReleaseAsset($repo, $match) {
    try {
        $rel = Invoke-RestMethod -Uri ("https://api.github.com/repos/" + $repo + "/releases/latest") -UseBasicParsing
        $asset = $rel.assets | Where-Object { $_.name -like $match } | Select-Object -First 1
        return $asset.browser_download_url
    } catch {
        Write-Warning ("Could not query releases for " + $repo + ": " + $_)
        return $null
    }
}

# --- [1/3] Open-Shell ---
Write-Host "[1/3] Open-Shell (Start menu)"
$url = Get-LatestReleaseAsset "Open-Shell/Open-Shell-Menu" "OpenShellSetup_*"
if ($url) {
    $exe = Join-Path $tmp "OpenShellSetup.exe"
    try {
        Invoke-WebRequest -Uri $url -OutFile $exe -UseBasicParsing
        Start-Process $exe -ArgumentList "/passive" -Wait
        Write-Host "   Open-Shell installed." -ForegroundColor Green
    } catch {
        Write-Warning "Open-Shell install failed. Download it manually: https://github.com/Open-Shell/Open-Shell-Menu/releases"
    }
} else {
    Write-Warning "Could not get Open-Shell download URL. Manual: https://github.com/Open-Shell/Open-Shell-Menu/releases"
}

# --- [2/3] Rainmeter ---
Write-Host "[2/3] Rainmeter (desktop widgets)"
$url = Get-LatestReleaseAsset "rainmeter/rainmeter" "Rainmeter-*.exe"
if ($url) {
    $exe = Join-Path $tmp "RainmeterSetup.exe"
    try {
        Invoke-WebRequest -Uri $url -OutFile $exe -UseBasicParsing
        Start-Process $exe -ArgumentList "/S" -Wait
        Write-Host "   Rainmeter installed." -ForegroundColor Green
    } catch {
        Write-Warning "Rainmeter install failed. Download it manually: https://www.rainmeter.net/"
    }
} else {
    Write-Warning "Could not get Rainmeter download URL. Manual: https://www.rainmeter.net/"
}

# --- [3/3] Install widget skins and activate them ---
Write-Host "[3/3] Widget skins"
$skinsSrc = Join-Path (Join-Path $PSScriptRoot "..") "assets\RainmeterSkins"
$skinsDst = Join-Path $env:USERPROFILE "Documents\Rainmeter\Skins"
New-Item -ItemType Directory -Force -Path $skinsDst | Out-Null
Copy-Item (Join-Path $skinsSrc "*") $skinsDst -Recurse -Force

$rmCandidates = @(
    "C:\Program Files\Rainmeter\Rainmeter.exe",
    "C:\Program Files (x86)\Rainmeter\Rainmeter.exe"
)
$rm = $rmCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($rm) {
    Start-Process $rm
    Start-Sleep -Seconds 4
    & $rm "!ActivateConfig" "UltraTune\Clock" "Clock.ini"
    & $rm "!ActivateConfig" "UltraTune\Stats" "Stats.ini"
    & $rm "!Move" "1120" "25" "UltraTune\Clock"
    & $rm "!Move" "1120" "150" "UltraTune\Stats"
    Write-Host "   Widgets activated (clock top-right, CPU/RAM/SSD below)." -ForegroundColor Green
} else {
    Write-Warning "Rainmeter not found. Start it once, then the UltraTune skins will appear in Rainmeter."
}

Write-Host ""
Write-Host "TOOLS DONE." -ForegroundColor Green
Write-Host "Open-Shell: on first launch pick the 'Windows 7 style' start menu."
