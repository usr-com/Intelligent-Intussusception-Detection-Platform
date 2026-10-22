@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"
echo ==========================================
echo  build frontend (Vite production bundle)
echo ==========================================
pushd frontend
call pnpm install --frozen-lockfile
if errorlevel 1 (
  echo [X] pnpm install failed.
  popd
  pause
  exit /b 1
)
call pnpm run build
if errorlevel 1 (
  echo [X] pnpm run build failed.
  popd
  pause
  exit /b 1
)
popd
echo.
echo [OK] built to frontend\dist
pause
