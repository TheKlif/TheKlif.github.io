@echo off
cd /d "D:\Is This Anything\TheKlif.github.io"

powershell.exe -ExecutionPolicy Bypass -File "publish.ps1"

echo.
echo Publish complete (or check output above).
pause