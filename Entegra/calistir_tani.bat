@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo tani_QI.sql calistiriliyor...
sqlcmd -S .\SQLEXPRESS -d BILIM -U sa -P FETAGEN -C -i "%~dp0tani_QI.sql" -o "%~dp0tani_QI_sonuc.txt" -y 0 -w 8000
if errorlevel 1 (
  echo.
  echo Sifreli olmadi, sifresiz deneniyor...
  sqlcmd -S .\SQLEXPRESS -d BILIM -U sa -P FETAGEN -C -N o -i "%~dp0tani_QI.sql" -o "%~dp0tani_QI_sonuc.txt" -y 0 -w 8000
)
if errorlevel 1 (
  echo HALA HATA: sqlcmd surumu/instance adi kontrol et.
) else (
  echo BITTI. Sonuc: %~dp0tani_QI_sonuc.txt
)
echo.
pause
