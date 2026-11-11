# MIRTH CONNECT 4.5.2 KONTEYNERİ (kullanıcı 11.11.2026: "teletıp gönderimlerde mirth connect kullanmak istiyorum",
# "mirth 4.5.2 kullanacağız"). Tasarım: Ekranlar/Radyoloji/teletip_mirth.html.
#
#   .\mirth-baslat.ps1            -> nextgenhealthcare/connect:4.5.2, mesaj arşivi gentegre-pg18 içinde "mirthdb"
#   .\mirth-baslat.ps1 -Durdur    -> konteyneri kaldırır (veritabanı ve kanallar kalır)
#
# Sürüm SABİT: 4.5.2 son açık kaynak Mirth (4.6+ NextGen ticari). "latest" kullanılmaz - ticari sürüme sessizce geçer.
#
# Portlar (Gentegre -> Mirth iç ağ; Bakanlık'a çıkış Mirth'in kendi bağlantıları):
#   8443  Mirth Administrator / REST API (https, kendinden imzalı)
#   8080  Mirth web başlangıç sayfası (Administrator indirme)
#   6661  K1 TELETIP_HL7 - Gentegre MLLP ile ORM/ORU gönderir
#   8082  K2 TELETIP_KOS - Gentegre "çalışma hazır" HTTP
#   4104  K3 TELETIP_DOZ - Gentegre RDSR'yi HTTP ile verir (/doz/), Mirth DICOM Sender TLS ile TELETIP_MGA'ya
#
# Pano kullanıcısı gentegre_izleme da açılır (Gentegre API: Mirth__Url, Mirth__Kullanici, Mirth__Parola).
# Parolalar ilk çalıştırmada üretilir ve gizli\mirth.env'e yazılır (depo dışı, .gitignore). Mirth'in varsayılan
# admin/admin parolası ilk açılışta REST ile değiştirilir; yeni parola aynı dosyada.
param([switch]$Durdur, [string]$Ad = 'gentegre-mirth', [string]$PgKonteyner = 'gentegre-pg18', [int]$PgPort = 5434)

$ErrorActionPreference = 'Stop'
$kok = $PSScriptRoot
$gizli = Join-Path $kok 'gizli'
$envDosya = Join-Path $gizli 'mirth.env'

$varolan = docker ps -a --filter "name=^/$Ad$" --format '{{.Names}}'
if ($varolan) { docker rm -f $Ad | Out-Null }
if ($Durdur) { Write-Host "$Ad durduruldu."; exit 0 }

function YeniParola { -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 24 | ForEach-Object { [char]$_ }) }

if (-not (Test-Path $envDosya)) {
    New-Item -ItemType Directory -Force $gizli | Out-Null
    @(
        "MIRTH_DB_PAROLA=$(YeniParola)"
        "MIRTH_ADMIN_PAROLA=$(YeniParola)"
    ) | Set-Content -Encoding ascii $envDosya
    Write-Host "Parolalar üretildi: $envDosya"
}
# Eski kurulumda sonradan eklenen anahtarlar (pano kullanıcısı, 11.11.2026) eksikse tamamlanır.
if (-not (Select-String -Path $envDosya -Pattern '^MIRTH_IZLEME_PAROLA=' -Quiet)) {
    Add-Content -Encoding ascii $envDosya "MIRTH_IZLEME_PAROLA=$(YeniParola)"
}
$deger = @{}
Get-Content $envDosya | ForEach-Object { $k, $v = $_ -split '=', 2; if ($k) { $deger[$k] = $v } }
$dbParola = $deger['MIRTH_DB_PAROLA']

# ---- mesaj arşivi veritabanı (idempotent): rol "mirth", veritabanı "mirthdb"
$rolVar = docker exec $PgKonteyner psql -U postgres -At -c "select 1 from pg_roles where rolname = 'mirth'"
if ($rolVar -ne '1') {
    docker exec $PgKonteyner psql -U postgres -q -c "create role mirth login password '$dbParola'" | Out-Null
} else {
    docker exec $PgKonteyner psql -U postgres -q -c "alter role mirth password '$dbParola'" | Out-Null
}
$dbVar = docker exec $PgKonteyner psql -U postgres -At -c "select 1 from pg_database where datname = 'mirthdb'"
if ($dbVar -ne '1') { docker exec $PgKonteyner psql -U postgres -q -c "create database mirthdb owner mirth" | Out-Null }

# ---- konteyner
docker run -d --name $Ad --restart unless-stopped `
  -p 8443:8443 -p 8080:8080 -p 6661:6661 -p 8082:8082 -p 4104:4104 `
  --add-host host.docker.internal:host-gateway `
  -e DATABASE=postgres `
  -e "DATABASE_URL=jdbc:postgresql://host.docker.internal:$PgPort/mirthdb" `
  -e DATABASE_USERNAME=mirth `
  -e "DATABASE_PASSWORD=$dbParola" `
  -e "VMOPTIONS=-Xmx768m" `
  -e TZ=Europe/Istanbul `
  -v gentegre-mirth-appdata:/opt/connect/appdata `
  -v "$kok\custom-lib:/opt/connect/custom-lib" `
  nextgenhealthcare/connect:4.5.2 | Out-Null
Write-Host "Mirth başlatıldı ($Ad); açılış bekleniyor..."

# ---- varsayılan admin/admin parolasını değiştir (yalnız ilk kurulumda geçerli; sonra admin/admin 401 döner)
# PowerShell 5.1: kendinden imzalı sertifika için doğrulama bu oturumda kapatılır (yalnız localhost'a gidilir).
Add-Type @"
using System.Net; using System.Security.Cryptography.X509Certificates;
public class MirthSertifika { public static void Kabul() {
  ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
  ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12; } }
"@
[MirthSertifika]::Kabul()
$api = 'https://localhost:8443/api'
$basliklar = @{ 'X-Requested-With' = 'OpenAPI' }
$hazir = $false
for ($i = 0; $i -lt 36 -and -not $hazir; $i++) {
    try { Invoke-WebRequest "$api/server/version" -Headers $basliklar -UseBasicParsing | Out-Null; $hazir = $true }
    catch { if ($_.Exception.Response) { $hazir = $true } else { Start-Sleep 5 } }
}
if (-not $hazir) { throw "Mirth 3 dakikada açılmadı: docker logs $Ad" }
try {
    $oturum = $null
    Invoke-WebRequest "$api/users/_login" -Method Post -Headers $basliklar -UseBasicParsing -SessionVariable oturum `
        -Body @{ username = 'admin'; password = 'admin' } | Out-Null
    Invoke-WebRequest "$api/users/1/password" -Method Put -Headers $basliklar -UseBasicParsing -WebSession $oturum `
        -ContentType 'text/plain' -Body $deger['MIRTH_ADMIN_PAROLA'] | Out-Null
    Write-Host "Mirth admin parolası değiştirildi (gizli\mirth.env: MIRTH_ADMIN_PAROLA)."
} catch {
    Write-Host "Mirth admin parolası zaten değiştirilmiş (admin/admin geçmiyor)."
}

# ---- pano kullanıcısı gentegre_izleme (Gentegre Teletıp panosu kanal durumlarını okur; API ortam değişkeni Mirth__Parola)
#   Mirth 4.5.2 açık sürümünde rol yok - ayrı kullanıcı, parolası admin'den bağımsız değiştirilebilsin / kapatılabilsin.
$oturum = $null
Invoke-WebRequest "$api/users/_login" -Method Post -Headers $basliklar -UseBasicParsing -SessionVariable oturum `
    -Body @{ username = 'admin'; password = $deger['MIRTH_ADMIN_PAROLA'] } | Out-Null
$izlemeVar = $true
try { Invoke-WebRequest "$api/users/gentegre_izleme" -Headers $basliklar -UseBasicParsing -WebSession $oturum | Out-Null }
catch { $izlemeVar = $false }
if (-not $izlemeVar) {
    $xml = '<user><username>gentegre_izleme</username><firstName>Gentegre</firstName><lastName>Izleme</lastName>' +
           '<organization>Gentegre AI - Teletip panosu</organization><email></email><phoneNumber></phoneNumber>' +
           '<description>Yalniz Gentegre Teletip panosu okur (kanal durumlari).</description><industry></industry></user>'
    Invoke-WebRequest "$api/users" -Method Post -Headers $basliklar -UseBasicParsing -WebSession $oturum `
        -ContentType 'application/xml' -Body $xml | Out-Null
}
[xml]$izleme = (Invoke-WebRequest "$api/users/gentegre_izleme" -Headers ($basliklar + @{ Accept = 'application/xml' }) `
    -UseBasicParsing -WebSession $oturum).Content
Invoke-WebRequest "$api/users/$($izleme.user.id)/password" -Method Put -Headers $basliklar -UseBasicParsing -WebSession $oturum `
    -ContentType 'text/plain' -Body $deger['MIRTH_IZLEME_PAROLA'] | Out-Null
Write-Host "Mirth pano kullanıcısı gentegre_izleme hazır (parola gizli\mirth.env: MIRTH_IZLEME_PAROLA)."
Write-Host "Mirth hazır: https://localhost:8443 (Administrator / REST /api), kullanıcı admin, parola gizli\mirth.env"
