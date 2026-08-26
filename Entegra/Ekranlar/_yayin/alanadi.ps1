# ============================================================================
#  Gentegre AI mockup - alan adi + HTTPS kurulumu (gentegreai.com)
#  Kullanim: powershell -ExecutionPolicy Bypass -File .\alanadi.ps1
#  NOT: Bu dosya saf ASCII + UTF-8 BOM olarak yazilmistir (PS 5.1 uyumu icin).
#
#  ONCE YAPILACAK: alan adi panelinde (nereden aldiysaniz) su kayitlar:
#      Tur  Ad    Deger              TTL
#      A    @     46.36.201.170      3600
#      A    www   46.36.201.170      3600
#  DNS yayildiktan sonra bu betigi calistirin.
# ============================================================================

$Sunucu = "gentegre@46.36.201.170"
$Alan   = "gentegreai.com"
$Dizin  = Split-Path -Parent $MyInvocation.MyCommand.Definition
$Betik  = Join-Path $Dizin "alanadi.sh"

$ErrorActionPreference = "Continue"

function Adim($m) { Write-Host ("==> " + $m) -ForegroundColor Cyan }
function Kotu($m) { Write-Host ("HATA: " + $m) -ForegroundColor Red }

if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
  Kotu "'ssh' bulunamadi."
  Write-Host "Ayarlar > Uygulamalar > Istege bagli ozellikler > 'OpenSSH Client' ekleyin."
  Read-Host "Kapatmak icin Enter"
  exit 1
}
if (-not (Test-Path $Betik)) { Kotu ("betik yok -> " + $Betik); Read-Host "Enter"; exit 1 }

# ---- DNS on kontrolu (Windows tarafinda) ----
Adim "DNS kontrol ediliyor..."
$Bekleniyor = "46.36.201.170"
$Bulunan = $null
try {
  $Bulunan = (Resolve-DnsName -Name $Alan -Type A -ErrorAction Stop |
              Where-Object { $_.IPAddress } | Select-Object -First 1).IPAddress
} catch {
  try { $Bulunan = ([System.Net.Dns]::GetHostAddresses($Alan) | Select-Object -First 1).IPAddressToString }
  catch { $Bulunan = $null }
}

if ($Bulunan -ne $Bekleniyor) {
  Write-Host ""
  Kotu ($Alan + " henuz sunucuya bakmiyor.  Bulunan: " + $(if ($Bulunan) { $Bulunan } else { "(kayit yok)" }))
  Write-Host ""
  Write-Host "Alan adi panelinde su kayitlari ekleyin:" -ForegroundColor Yellow
  Write-Host "    Tur  Ad    Deger              TTL"
  Write-Host ("    A    @     " + $Bekleniyor + "      3600")
  Write-Host ("    A    www   " + $Bekleniyor + "      3600")
  Write-Host ""
  Write-Host "Kayitlari ekledikten sonra 5 dk - 24 saat icinde yayilir." -ForegroundColor Yellow
  Write-Host "Sonra bu betigi tekrar calistirin."
  Read-Host "Kapatmak icin Enter"
  exit 1
}
Adim ($Alan + " -> " + $Bulunan + "   (dogru)")

# alanadi.sh'i LF satir sonlariyla gecici bir kopyaya yaz
Adim "alanadi.sh LF satir sonlarina cevriliyor"
$CR = [string][char]13
$LF = [string][char]10
$Metin  = [System.IO.File]::ReadAllText($Betik)
$Metin  = $Metin.Replace($CR + $LF, $LF).Replace($CR, $LF)
$Gecici = Join-Path ([System.IO.Path]::GetTempPath()) "alanadi.sh"
[System.IO.File]::WriteAllText($Gecici, $Metin, (New-Object System.Text.UTF8Encoding $false))

Adim "1/2  Betik sunucuya kopyalaniyor..."
& scp $Gecici ($Sunucu + ":")
if ($LASTEXITCODE -ne 0) { Kotu "kopyalama basarisiz."; Read-Host "Enter"; exit 1 }

Adim "2/2  Sunucuda alan adi + sertifika kuruluyor..."
Write-Host "    Sunucu parolasi sorulabilir." -ForegroundColor DarkGray
& ssh -t $Sunucu "bash ~/alanadi.sh"
if ($LASTEXITCODE -ne 0) { Kotu "kurulum basarisiz - yukaridaki ciktiya bakin."; Read-Host "Enter"; exit 1 }

Write-Host ""
Write-Host ("Bitti. Tarayicida acin: https://" + $Alan + "/") -ForegroundColor Green
Write-Host "  Kullanici: gentegre" -ForegroundColor Green
Write-Host "  Parola   : bEV6uIrKF2A7Gd" -ForegroundColor Green
Write-Host ""
Read-Host "Kapatmak icin Enter"
