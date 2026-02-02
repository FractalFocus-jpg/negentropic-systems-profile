@echo off
REM ============================================================================
REM TAPESTRY PHONE PHOTO IMPORT — Quick Launcher (no popups, correct cwd)
REM ============================================================================

REM Ensure we run from the repo root (where this .bat lives)
cd /d "%~dp0"

REM Run the script (no pause)
powershell -NoLogo -ExecutionPolicy Bypass -File "scripts\import_phone_photos.ps1"
