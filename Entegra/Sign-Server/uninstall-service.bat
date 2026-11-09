@echo off
cd /d "%~dp0"

echo Stopping GenSigner Service...

:: Check if the executable exists
if not exist "sign-server-service.exe" (
    echo Error: sign-server-service.exe not found!
    pause
    exit /b 1
)

:: Stop the service
"sign-server-service.exe" stop

:: Uninstall the service
"sign-server-service.exe" uninstall

echo.
echo Service uninstalled successfully!
pause
