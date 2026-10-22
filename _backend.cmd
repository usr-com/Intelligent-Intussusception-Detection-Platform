@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0backend"
uv run uvicorn main:app --host 127.0.0.1 --port 8000
pause
