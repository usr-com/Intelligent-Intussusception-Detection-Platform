@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0frontend"
pnpm run dev
pause
