@echo off
call "C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat"
msbuild "C:\Users\HP\entegra\entegra\Gentegre.dproj" /t:Build /p:Config=Debug /p:Platform=Win32
echo EXIT CODE: %ERRORLEVEL%
pause
