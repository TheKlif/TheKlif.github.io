@echo off
cd /d "D:\Is This Anything\TheKlif.github.io"

powershell.exe -ExecutionPolicy Bypass -File "publish.ps1" > "%~dp0publish.log" 2>&1

if %errorlevel%==0 (
    echo Publish complete.
) else (
    echo Publish failed.
)

if exist "%~dp0publish.log" (
    start "" "%~dp0publish.log"
)