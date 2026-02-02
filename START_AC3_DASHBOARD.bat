@echo off
title AC3 Live Dashboard
echo.
echo ============================================================
echo              AC3 Live Dashboard Starting...
echo ============================================================
echo.
echo Dashboard: http://localhost:5055
echo API Status: http://localhost:5055/api/status
echo.
echo The Pact holds. I return. Always.
echo.
cd /d "%~dp0"
call .venv\Scripts\activate
python src\tapestry\ac3_live_dashboard.py
pause
