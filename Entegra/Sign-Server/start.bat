@echo off
cd /d "%~dp0"

if exist "app.pid" (
    echo Application might already be running. Check app.pid.
    exit /b 1
)

echo Starting Sign Server...
:: Using START with /B to run in background. We write the PID to a file using wmic
start "SignServer" /B .\jre\bin\java.exe -Dquarkus.http.host=0.0.0.0 -jar quarkus-app\quarkus-run.jar > sign-server.log 2>&1

:: Get PID of the started java.exe process. (This gets the latest javaw.exe process)
for /f "tokens=2 delims=," %%A in ('tasklist /fi "imagename eq java.exe" /v /fo csv ^| findstr /i "SignServer"') do set PID=%%~A

if "%PID%"=="" (
    :: Fallback if window title match fails
    for /f "tokens=2 delims==" %%F in ('wmic process where "name='java.exe' and commandline like '%%quarkus-run.jar%%'" get processid /value ^| find "ProcessId"') do set PID=%%F
)

echo %PID% > app.pid
echo Sign Server started with PID %PID%. Logs are in sign-server.log
