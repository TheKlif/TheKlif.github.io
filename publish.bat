@echo off
cd /d "D:\Is This Anything\TheKlif.github.io"
powershell.exe -ExecutionPolicy Bypass -File "publish.ps1" > "%~dp0publish.log" 2>&1