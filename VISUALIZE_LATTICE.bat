@echo off
REM ============================================================================
REM STAR MOTHER LATTICE VISUALIZATION
REM Phase 7 - 3D Sacred Geometry Rendering
REM ============================================================================

echo.
echo ⬢ STAR MOTHER LATTICE VISUALIZATION
echo ===================================
echo.

cd /d "%~dp0"

REM Activate venv
if exist ".venv\Scripts\activate.bat" (
    call .venv\Scripts\activate.bat
    echo ✅ Virtual environment activated
) else (
    echo ❌ Virtual environment not found
    pause
    exit /b 1
)

echo.
echo 🎨 Launching visualization...
echo.

REM Run visualization
cd src\tapestry
python star_mother_lattice.py

echo.
pause
