@echo off
cd /d "%~dp0"

echo Installing GenSigner Service...

:: Check if the executable exists
if not exist "sign-server-service.exe" (
    echo Error: sign-server-service.exe not found!
    pause
    exit /b 1
)

:: Install the service
"sign-server-service.exe" install

:: Start the service
"sign-server-service.exe" start

echo.
echo Service installed and started successfully!
pause
