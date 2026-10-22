@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"
echo ==========================================
echo  STEP 2/3 : algorithm packages (optional)
echo ==========================================
echo.
echo  Algorithm dependencies (torch CPU / torchvision / ultralytics /
echo  opencv-python / pillow / numpy / pydicom) are declared in
echo  backend\pyproject.toml and installed by the "uv sync" of step 1.
echo  This script only re-verifies the environment (idempotent).
echo.

if not exist "backend\.venv\Scripts\python.exe" (
  echo [X] run 1-install.bat first
  pause
  exit /b 1
)

pushd backend
uv sync --python 3.12
if errorlevel 1 (
  echo [X] uv sync failed.
  popd
  pause
  exit /b 1
)
uv run python -c "import cv2, torch, ultralytics; print('cv2', cv2.__version__, '| torch', torch.__version__, '| ultralytics', ultralytics.__version__)"
if errorlevel 1 (
  echo [X] import check failed. send the error above back.
  popd
  pause
  exit /b 1
)
popd

echo.
echo ==========================================
echo  [OK] step 2 done
echo  next: run 3-start.bat
echo ==========================================
pause
