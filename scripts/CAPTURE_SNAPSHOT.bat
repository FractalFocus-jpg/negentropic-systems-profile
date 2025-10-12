@echo off
REM ============================================================================
REM CAPTURE COHERENCE SNAPSHOT - Quick wrapper for PowerShell script
REM ============================================================================

echo.
echo ⬢ CAPTURING COHERENCE SNAPSHOT...
echo ================================
echo.

cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "fetch_snapshot.ps1"

echo.
pause
