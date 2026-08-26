@echo off
chcp 65001 >nul
echo ===== SUNUCU / VERITABANI KONTROL =====> srv_kontrol_sonuc.txt
echo.>> srv_kontrol_sonuc.txt
sqlcmd -S .\SQLEXPRESS -E -C -Q "SET NOCOUNT ON; SELECT @@SERVERNAME AS ServerName, DB_NAME() AS CurrentDB, @@VERSION AS Ver" -y 0 -w 8000 >> srv_kontrol_sonuc.txt 2>&1
echo.>> srv_kontrol_sonuc.txt
echo ===== BITTI =====>> srv_kontrol_sonuc.txt
echo Sonuc dosyasi: srv_kontrol_sonuc.txt
echo Bitti. Bu pencereyi kapatabilirsiniz.
pause
