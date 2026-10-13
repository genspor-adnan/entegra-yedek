# =============================================================================
#  GENTEGRE AKTARIM AJANI - WINDOWS SERVISI (müşteri sunucusunda, YÖNETİCİ olarak)
#
#  powershell -ExecutionPolicy Bypass -File servis_kur.ps1 [-Klasor C:\GentegreAktarim] [-Kaldir]
#
#  Klasörde GentegreAktarimAjani.exe + ajan.json olmalı (ajan.ornek.json'dan).
#  Sırayla: ayar dosyası var mı -> sırlar şifreli mi (değilse --sifrele) -> bir
#  deneme turu (--tek-tur: bağlantı, anahtar, CT) -> servis (otomatik başlar,
#  çökerse 1 dk sonra yeniden) -> başlat. Deneme turu başarısızsa servis KURULMAZ.
#  Not: --sifrele DPAPI'yi MAKİNE kapsamında kullanır; servis hangi hesapla
#  çalışırsa çalışsın aynı makinede çözer, başka makineye kopyalanan ayar çözülmez.
# =============================================================================
param(
  [string]$Klasor = "C:\GentegreAktarim",
  [switch]$Kaldir
)
$ErrorActionPreference = "Stop"
$Ad = "GentegreAktarim"
$Exe = Join-Path $Klasor "GentegreAktarimAjani.exe"
$Ayar = Join-Path $Klasor "ajan.json"

$yonetici = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
  [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $yonetici) { Write-Host "HATA: PowerShell'i yönetici olarak açın." -ForegroundColor Red; exit 1 }

if ($Kaldir) {
  if (Get-Service $Ad -ErrorAction SilentlyContinue) {
    Stop-Service $Ad -ErrorAction SilentlyContinue
    & sc.exe delete $Ad | Out-Null
    Write-Host "Servis kaldırıldı ($Ad). Klasör ve günlükler duruyor: $Klasor"
  } else { Write-Host "Servis zaten yok." }
  exit 0
}

if (-not (Test-Path $Exe))  { Write-Host "HATA: $Exe yok." -ForegroundColor Red; exit 1 }
if (-not (Test-Path $Ayar)) { Write-Host "HATA: $Ayar yok - ajan.ornek.json'u kopyalayıp doldurun." -ForegroundColor Red; exit 1 }

$a = Get-Content $Ayar -Raw | ConvertFrom-Json
if ($a.Anahtar -or $a.MssqlBaglanti) {
  Write-Host "Sırlar düz yazılmış -> şifreleniyor (DPAPI)..."
  & $Exe --sifrele --ayar $Ayar
}

Write-Host "Deneme turu (bağlantı, anahtar, Change Tracking)..."
& $Exe --tek-tur --ayar $Ayar
if ($LASTEXITCODE -ne 0) {
  Write-Host "HATA: deneme turu başarısız (çıkış $LASTEXITCODE) - $Klasor\gunluk altındaki günlüğe bakın. Servis kurulmadı." -ForegroundColor Red
  exit 1
}

if (Get-Service $Ad -ErrorAction SilentlyContinue) {
  Write-Host "Servis var, yeniden başlatılıyor..."
  Restart-Service $Ad
} else {
  & sc.exe create $Ad binPath= "`"$Exe`" --ayar `"$Ayar`"" start= delayed-auto DisplayName= "Gentegre Aktarım Ajanı" | Out-Null
  & sc.exe description $Ad "Delphi ERP (MSSQL) -> Gentegre AI tek yön aktarım. Yalnız dışarı HTTPS; MSSQL salt okur." | Out-Null
  & sc.exe failure $Ad reset= 86400 actions= restart/60000/restart/60000/restart/300000 | Out-Null
  Start-Service $Ad
}
Get-Service $Ad | Format-Table Name, Status, StartType -AutoSize
Write-Host "Tamam. Durum: web'de Yönetim > Platform > Aktarım Durumu; günlük: $Klasor\gunluk" -ForegroundColor Green
