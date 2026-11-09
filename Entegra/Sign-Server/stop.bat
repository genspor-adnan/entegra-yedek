@echo off
cd /d "%~dp0"

if not exist "app.pid" (
    echo Sign Server does not appear to be running (no app.pid found).
    exit /b 1
)

set /p PID=<app.pid
echo Stopping Sign Server (PID: %PID%)...
taskkill /F /PID %PID%
del app.pid
echo Stopped.
