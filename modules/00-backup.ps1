# ============================================================
#  WIN 8.1 ULTRA TUNE - Module 00: Backup
#  Creates a system restore point and exports registry branches.
#  Run as Administrator.
# ============================================================

Write-Host ""
Write-Host "=== BACKUP ===" -ForegroundColor Cyan

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Write-Error "Run this script as Administrator (use START.bat)."; exit 1 }

# 1. System restore point
try {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    # Allow creating a restore point even if one was made today
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name SystemRestorePointCreationFrequency -Value 0 -PropertyType DWord -Force | Out-Null
    Write-Host "Creating restore point (may take a minute)..."
    Checkpoint-Computer -Description "Win81UltraTune backup" -RestorePointType MODIFY_SETTINGS
    Write-Host "Restore point created." -ForegroundColor Green
} catch {
    Write-Warning "Could not create restore point: $_"
}

# 2. Export registry branches that the other modules modify
$dir = Join-Path $env:USERPROFILE "Win81UltraTune\backup"
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$branches = @(
    "HKCU\Control Panel",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer",
    "HKCU\Software\Microsoft\Windows\DWM",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell"
)
foreach ($b in $branches) {
    $name = ($b -replace '[\\:]', '_')
    reg export $b (Join-Path $dir ($name + ".reg")) /y | Out-Null
}
Write-Host "Registry backup saved to: $dir" -ForegroundColor Green
