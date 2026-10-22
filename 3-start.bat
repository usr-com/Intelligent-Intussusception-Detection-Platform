@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

if not exist "backend\.venv\Scripts\python.exe" (
  echo [X] run 1-install.bat first
  pause
  exit /b 1
)
if not exist "frontend\node_modules" (
  echo [X] frontend dependencies missing. run 1-install.bat first.
  pause
  exit /b 1
)

echo starting backend  on http://127.0.0.1:8000 ...
start "backend :8000" cmd /k "%~dp0_backend.cmd"
timeout /t 4 >nul

echo starting frontend on http://localhost:5173 ...
start "frontend :5173" cmd /k "%~dp0_frontend.cmd"
timeout /t 8 >nul

start "" http://localhost:5173

echo.
echo ==========================================
echo  keep both windows open (closing = stop service)
echo  first detection waits 60-90 s for model warmup
echo  login: admin / admin123    doctor / doctor123
echo ==========================================
pause
