@echo off
setlocal
title Win81 UltraTune
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator rights are required. Requesting elevation...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:menu
cls
echo ==================================================
echo    WIN 8.1 ULTRA TUNE  -  Optimize + Win11 Look
echo ==================================================
echo.
echo   1. FULL SETUP   (backup + optimize + look + tools)
echo   2. Create backup / restore point only
echo   3. Optimize Windows only (speed)
echo   4. Apply Win11 dark look only
echo   5. Install tools only (Start menu + widgets)
echo   6. Win11 look PLUS (glass transparency + centered dock)
echo   7. Exit
echo.
set /p choice=  Type a number and press Enter:

if "%choice%"=="1" goto full
if "%choice%"=="2" goto backup
if "%choice%"=="3" goto opt
if "%choice%"=="4" goto look
if "%choice%"=="5" goto tools
if "%choice%"=="6" goto plus
if "%choice%"=="7" exit /b
goto menu

:full
powershell -NoProfile -ExecutionPolicy Bypass -File "modules\00-backup.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "modules\01-optimize.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "modules\02-customize.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "modules\03-tools.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "modules\05-win11look-plus.ps1"
echo.
echo FULL SETUP FINISHED. A restart is recommended.
pause
goto menu

:backup
powershell -NoProfile -ExecutionPolicy Bypass -File "modules\00-backup.ps1"
pause
goto menu

:opt
powershell -NoProfile -ExecutionPolicy Bypass -File "modules\01-optimize.ps1"
pause
goto menu

:look
powershell -NoProfile -ExecutionPolicy Bypass -File "modules\02-customize.ps1"
pause
goto menu

:tools
powershell -NoProfile -ExecutionPolicy Bypass -File "modules\03-tools.ps1"
pause
goto menu

:plus
powershell -NoProfile -ExecutionPolicy Bypass -File "modules\05-win11look-plus.ps1"
pause
goto menu
