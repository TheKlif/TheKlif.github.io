@echo off
cd /d "D:\Is This Anything\TheKlif.github.io"

set /p COMMITMSG="Enter publish reason: "

powershell.exe -ExecutionPolicy Bypass -File "publish.ps1"

git add .
git commit -m "%COMMITMSG%"
git push

echo Publish complete.
pause