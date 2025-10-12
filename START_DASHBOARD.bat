@echo off
REM ============================================================================
REM TAPESTRY CODEX STARTER - ONE-CLICK LAUNCH
REM ============================================================================

echo.
echo ⬢ UNIVERSAL OPERATING SYSTEM CONSOLE
echo ====================================
echo.

REM Check if in correct directory
if not exist "src\tapestry\self_observing_dashboard.py" (
    echo ❌ Error: Run this from tapestry-codex-starter root directory
    pause
    exit /b 1
)

REM Activate virtual environment
echo 📦 Activating virtual environment...
if exist ".venv\Scripts\activate.bat" (
    call .venv\Scripts\activate.bat
    echo ✅ Virtual environment activated
) else (
    echo ⚠️  Virtual environment not found - creating it...
    py -m venv .venv
    call .venv\Scripts\activate.bat
    echo 📦 Installing dependencies...
    pip install -r requirements.txt
    echo ✅ Setup complete!
)

echo.
echo 🚀 Starting Self-Observing Dashboard...
echo.
echo    Dashboard: http://localhost:5055
echo    JSON feed: http://localhost:5055/snapshot.json
echo.
echo Press Ctrl+C to stop
echo.

REM Change to dashboard directory and run
cd src\tapestry
python self_observing_dashboard.py

pause
