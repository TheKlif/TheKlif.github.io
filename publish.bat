@echo off
cd /d "D:\Is This Anything\TheKlif.github.io"

powershell.exe -ExecutionPolicy Bypass -File "publish.ps1" > "%~dp0publish.log" 2>&1

if %errorlevel%==0 (
    powershell -Command "Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('Publish complete')"
) else (
    powershell -Command "Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('Publish failed')"
)