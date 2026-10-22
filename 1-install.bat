@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"
echo ==========================================
echo  STEP 1/3 : install dependencies (uv + pnpm)
echo ==========================================
echo.

where uv >nul 2>nul
if errorlevel 1 (
  echo [X] uv not found. Install uv ^(Python package manager^) first:
  echo     powershell -c "irm https://astral.sh/uv/install.ps1 ^| iex"
  echo     ^(or: winget install --id=astral-sh.uv -e^)
  pause
  exit /b 1
)
where pnpm >nul 2>nul
if errorlevel 1 (
  echo [X] pnpm not found. Install Node.js 20 LTS first, then: npm install -g pnpm
  pause
  exit /b 1
)
where powershell >nul 2>nul
if errorlevel 1 (
  echo [X] Windows PowerShell not found.
  pause
  exit /b 1
)

echo [1/3] backend Python environment via uv (incl. torch CPU / ultralytics) ...
pushd backend
uv sync --python 3.12
if errorlevel 1 (
  echo [X] uv sync failed. Check network / mirror and retry.
  popd
  pause
  exit /b 1
)
uv run python -c "import fastapi, torch, ultralytics, cv2; print('backend deps OK: torch', torch.__version__, '| ultralytics', ultralytics.__version__)"
if errorlevel 1 (
  echo [X] backend dependency self-check failed.
  popd
  pause
  exit /b 1
)
if not exist ".env" copy ".env.example" ".env" >nul
popd
echo.

echo [2/3] frontend packages via pnpm ...
pushd frontend
pnpm install --frozen-lockfile
if errorlevel 1 (
  echo [X] pnpm install failed. Check network / mirror and retry.
  popd
  pause
  exit /b 1
)
popd
echo.

echo [3/3] verify model weights (optional but recommended) ...
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\verify-weights.ps1"
if errorlevel 1 (
  echo [!] weight verification reported a problem. If files are missing, restore them and re-run this script.
)

echo.
echo ==========================================
echo  [OK] step 1 done
echo  next: run 2-install-algorithm.bat (already covered by uv sync, optional)
echo  then: run 3-start.bat
echo ==========================================
pause
