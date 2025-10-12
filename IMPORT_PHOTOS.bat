@echo off
REM ============================================================================
REM TAPESTRY PHONE PHOTO IMPORT — Quick Launcher
REM ============================================================================

cd /d "%~dp0\.."
powershell -NoLogo -ExecutionPolicy Bypass -File "scripts\import_phone_photos.ps1"

pause
