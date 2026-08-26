# ============================================================================
#  Gentegre AI web (v4) - sunucuya yayinla
#  Kullanim: powershell -ExecutionPolicy Bypass -File .\yayinla.ps1
#  NOT: Bu dosya saf ASCII + UTF-8 BOM olarak yazilmistir (PS 5.1 uyumu icin).
#
#  KAPSAM (18.08.2026 - duzeltme): tek sayfalik web uygulamasi + uygulamanin
#    icinde ACTIGI ekran dosyalari birlikte yayinlanir.
#      Ekranlar\gentegre_v4_web.html -> sunucuda index.html
#      Ekranlar\gentegre_data.js     -> gentegre_data.js
#      gentegre_data.js icinde "dosya:'...html'" olarak gecen TUM ekranlar
#      gengrid.js (bazi liste ekranlarinin kullandigi grid betigi)
#    Uygulama alt ekranlari iframe ile acar; ekran dosyalari yayinda olmazsa
#    her sekme bos/ana ekran olarak gorunur - bu yuzden birlikte gonderilir.
#    Belge/sunum HTML'leri (proje ozeti, degerlendirme vb.) KAPSAM DISI.
#    Paket her calistirmada BURADA uretilir - ayrica tar.gz hazirlamaya gerek yok.
# ============================================================================

$Sunucu  = "gentegre@46.36.201.170"
$Dizin   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$Kaynak  = Split-Path -Parent $Dizin            # ...\Ekranlar
$Sayfa   = Join-Path $Kaynak "gentegre_v4_web.html"
$Veri    = Join-Path $Kaynak "gentegre_data.js"
$Grid    = Join-Path $Kaynak "gengrid.js"
$Betik   = Join-Path $Dizin "kur.sh"
$Paket   = Join-Path $Dizin "gentegre-v4.tar.gz"

$ErrorActionPreference = "Continue"

function Adim($m) { Write-Host ("==> " + $m) -ForegroundColor Cyan }
function Kotu($m) { Write-Host ("HATA: " + $m) -ForegroundColor Red }
function Uyar($m) { Write-Host ("!!  " + $m) -ForegroundColor Yellow }

if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
  Kotu "'ssh' bulunamadi."
  Write-Host "Ayarlar > Uygulamalar > Istege bagli ozellikler > 'OpenSSH Client' ekleyin."
  Read-Host "Kapatmak icin Enter"
  exit 1
}
if (-not (Get-Command tar -ErrorAction SilentlyContinue)) {
  Kotu "'tar' bulunamadi (Windows 10 1803+ ile birlikte gelir)."
  Read-Host "Kapatmak icin Enter"
  exit 1
}
if (-not (Test-Path $Sayfa)) { Kotu ("sayfa yok -> " + $Sayfa); Read-Host "Enter"; exit 1 }
if (-not (Test-Path $Veri))  { Kotu ("veri dosyasi yok -> " + $Veri); Read-Host "Enter"; exit 1 }
if (-not (Test-Path $Betik)) { Kotu ("betik yok -> " + $Betik); Read-Host "Enter"; exit 1 }

# ---- 1. paketi uret
Adim "Paket hazirlaniyor (uygulama + ekran dosyalari)"
$Gecici = Join-Path ([System.IO.Path]::GetTempPath()) ("gentegre-v4-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $Gecici -Force | Out-Null
Copy-Item $Sayfa (Join-Path $Gecici "index.html") -Force
Copy-Item $Veri  (Join-Path $Gecici "gentegre_data.js") -Force
if (Test-Path $Grid) { Copy-Item $Grid (Join-Path $Gecici "gengrid.js") -Force }

# gentegre_data.js icinde gecen ekran dosyalarini bul ve kopyala.
# Boylece yalniz uygulamanin gercekten actigi ekranlar yayinlanir.
$VeriMetni = [System.IO.File]::ReadAllText($Veri)
$Ekranlar  = [regex]::Matches($VeriMetni, "[A-Za-z0-9_\-]+\.html") |
             ForEach-Object { $_.Value } | Sort-Object -Unique
$Kopya = 0
$Eksik = @()
foreach ($e in $Ekranlar) {
  if ($e -eq "index.html" -or $e -eq "gentegre_v4_web.html") { continue }
  $Yol = Join-Path $Kaynak $e
  if (Test-Path $Yol) { Copy-Item $Yol (Join-Path $Gecici $e) -Force; $Kopya++ }
  else { $Eksik += $e }
}
Adim ("Ekran dosyasi: " + $Kopya + " adet kopyalandi")
if ($Eksik.Count -gt 0) {
  Uyar ("Bulunamayan ekran dosyalari (" + $Eksik.Count + "): " + ($Eksik -join ", "))
  Uyar "Bu ekranlar uygulamada bos gorunur."
}

if (Test-Path $Paket) { Remove-Item $Paket -Force }
& tar -czf $Paket -C $Gecici .
if ($LASTEXITCODE -ne 0) { Kotu "paket olusturulamadi."; Read-Host "Enter"; exit 1 }
$DosyaSayisi = (Get-ChildItem $Gecici -File).Count
Remove-Item $Gecici -Recurse -Force

$Boyut = "{0:N1} MB" -f ((Get-Item $Paket).Length / 1MB)
Adim ("Paket : " + $Paket + "  (" + $Boyut + ", " + $DosyaSayisi + " dosya)")
Adim ("Sunucu: " + $Sunucu)
Write-Host "    Sunucu parolasi sorulacak (ssh anahtari kuruluysa sorulmaz)." -ForegroundColor DarkGray
Write-Host ""

# kur.sh'i LF satir sonlariyla gecici bir kopyaya yaz. Boylece uzak komutta
# tirnak veya ters bolu kullanmak gerekmez - PowerShell 5.1 ile 7 yerel komut
# argumanlarini farkli isledigi icin en guvenli yol budur.
Adim "kur.sh LF satir sonlarina cevriliyor"
$CR = [string][char]13
$LF = [string][char]10
$Metin  = [System.IO.File]::ReadAllText($Betik)
$Metin  = $Metin.Replace($CR + $LF, $LF).Replace($CR, $LF)
$GeciciBetik = Join-Path ([System.IO.Path]::GetTempPath()) "kur.sh"
[System.IO.File]::WriteAllText($GeciciBetik, $Metin, (New-Object System.Text.UTF8Encoding $false))

Adim "1/2  Dosyalar sunucuya kopyalaniyor..."
& scp $Paket $GeciciBetik ($Sunucu + ":")
if ($LASTEXITCODE -ne 0) { Kotu "kopyalama basarisiz."; Read-Host "Enter"; exit 1 }

Adim "2/2  Sunucuda kurulum calistiriliyor..."
# kur.sh varsayilan paket adi ~/gentegre-v4.tar.gz - ayrica gecmeye gerek yok.
& ssh -t $Sunucu "bash ~/kur.sh"
if ($LASTEXITCODE -ne 0) { Kotu "kurulum basarisiz - yukaridaki ciktiya bakin."; Read-Host "Enter"; exit 1 }

Write-Host ""
Write-Host "Bitti. Tarayicida acin: http://46.36.201.170/" -ForegroundColor Green
Write-Host "  Kullanici: gentegre" -ForegroundColor Green
Write-Host "  Parola   : bEV6uIrKF2A7Gd" -ForegroundColor Green
Write-Host "  (Onceki yayin sunucuda ~/gentegre-yayin-yedek-*.tar.gz olarak saklanir)" -ForegroundColor DarkGray
Write-Host ""
Read-Host "Kapatmak icin Enter"
