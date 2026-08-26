@echo off
chcp 65001 >nul
title Gentegre Mockup - Mobil Sunucu
cd /d "%~dp0"
set PORT=8080

echo.
echo   ============================================================
echo    GENTEGRE MOCKUP - TELEFONDAN ERISIM
echo   ============================================================
echo.

rem --- yerel IP adresini bul ---
set IP=
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
  for /f "tokens=1" %%b in ("%%a") do if not defined IP set IP=%%b
)
if not defined IP set IP=127.0.0.1

echo    Telefonun ayni Wi-Fi agina bagli olmali.
echo    Telefonun tarayicisinda su adresi ac:
echo.
echo        http://%IP%:%PORT%/gentegre_v5_fluent.html
echo.
echo    Diger kabuklar:
echo        http://%IP%:%PORT%/gentegre.html              (mevcut)
echo        http://%IP%:%PORT%/gentegre_v2_komut.html     (komut paleti)
echo        http://%IP%:%PORT%/gentegre_v3_ribbon.html    (ribbon)
echo        http://%IP%:%PORT%/gentegre_v4_web.html       (modern web)
echo        http://%IP%:%PORT%/gentegre_konseptler.html   (karsilastirma)
echo.
echo    Kapatmak icin bu pencereyi kapat ya da Ctrl+C.
echo   ------------------------------------------------------------
echo.

rem --- Python varsa onu kullan (en saglikli yol) ---
where python >nul 2>nul
if %errorlevel%==0 (
  python -m http.server %PORT%
  goto :son
)
where py >nul 2>nul
if %errorlevel%==0 (
  py -m http.server %PORT%
  goto :son
)

rem --- Python yoksa PowerShell yedegi (Yonetici olarak calistirmak gerekebilir) ---
echo    Python bulunamadi, PowerShell sunucusu deneniyor...
echo    (Hata verirse bu dosyayi "Yonetici olarak calistir" ile ac)
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0mobil_sunucu.ps1" -Port %PORT%

:son
echo.
echo    Sunucu durdu.
pause
