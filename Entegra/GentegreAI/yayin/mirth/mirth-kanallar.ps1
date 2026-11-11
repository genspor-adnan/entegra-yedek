# MIRTH KANALLARI (K1 TELETIP_HL7 + dev için TELETIP_SIMULATOR) - üret, yükle, deploy et.
#
#   .\mirth-kanallar.ps1                                  -> dev: K1 hedefi benzetim (127.0.0.1:6671), benzetim kanalı da yüklenir
#   .\mirth-kanallar.ps1 -TeletipHost 1.2.3.4 -TeletipPort 5555 -TeletipXdsUrl https://.../xds/ -BenzetimYok
#                                                         -> gerçek Bakanlık HL7 alıcısı + XDS deposu (K1 + K2)
#   .\mirth-kanallar.ps1 ... -MgaHost dicom.teletip.saglik.gov.tr -MgaPort 443 -DozTls aes -DozGuvenDeposu /opt/java/openjdk/lib/security/cacerts
#                                                         -> K3 doz (RDSR) gerçek MGA'ya TLS ile (dev: TELETIP_MGA_SIMULATOR 127.0.0.1:11112, TLS yok)
#   .\mirth-kanallar.ps1 -Uretmeden                       -> kanallar\*.xml olduğu gibi yüklenir (konteynerde üretilmez)
#
# Kanal XML'i elle yazılmaz: kanal-uret.js Mirth'in kendi model sınıflarıyla konteyner içinde üretir (Rhino), çıktı
# kanallar\ altına alınır ve depoda durur. Kanal kimlikleri sabit: tekrar çalıştırma aynı kanalı günceller.
# Teletıp adresi kanalda değil Mirth "configuration map"te (teletip_hl7_host / teletip_hl7_port) - kurum başına değişir.
param([string]$TeletipHost = '127.0.0.1', [string]$TeletipPort = '6671',
      [string]$TeletipXdsUrl = 'http://127.0.0.1:8083/xds/', [switch]$BenzetimYok, [switch]$Uretmeden,
      [string]$MgaHost = '127.0.0.1', [string]$MgaPort = '11112', [string]$MgaAe = 'TELETIP_MGA', [string]$BizimAe = 'GENTEGRE',
      [ValidateSet('notls', 'aes', '3des', 'without')][string]$DozTls = 'notls', [string]$DozGuvenDeposu = '', [string]$DozGuvenParola = 'changeit',
      [string]$Ad = 'gentegre-mirth', [string]$Api = 'https://localhost:8443/api')

$ErrorActionPreference = 'Stop'
$kok = $PSScriptRoot
$kanalKlasoru = Join-Path $kok 'kanallar'

# ---- 1) üret (konteyner içinde, Mirth sınıflarıyla)
if (-not $Uretmeden) {
    docker cp (Join-Path $kok 'kanal-uret.js') "${Ad}:/tmp/kanal-uret.js" | Out-Null
    $klasorler = (docker exec $Ad sh -c 'cd /opt/connect; ls -d server-lib/*/ extensions/*/') -split "`n" |
                 Where-Object { $_.Trim() } | ForEach-Object { $_.Trim() + '*' }
    $cp = (@('server-lib/*') + $klasorler) -join ':'
    docker exec $Ad sh -c "rm -rf /tmp/kanallar; cd /opt/connect; java -Ddoz.tls=$DozTls '-Ddoz.guven=$DozGuvenDeposu' '-Ddoz.guvenParola=$DozGuvenParola' -cp '$cp' org.mozilla.javascript.tools.shell.Main /tmp/kanal-uret.js"
    if ($LASTEXITCODE -ne 0) { throw 'Kanal üretimi başarısız (kanal-uret.js).' }
    New-Item -ItemType Directory -Force $kanalKlasoru | Out-Null
    docker cp "${Ad}:/tmp/kanallar/." $kanalKlasoru | Out-Null
}

# ---- 2) oturum (parola gizli\mirth.env)
Add-Type @"
using System.Net; using System.Security.Cryptography.X509Certificates;
public class MirthSertifika2 { public static void Kabul() {
  ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
  ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12; } }
"@
[MirthSertifika2]::Kabul()
$deger = @{}
Get-Content (Join-Path $kok 'gizli\mirth.env') | ForEach-Object { $k, $v = $_ -split '=', 2; if ($k) { $deger[$k] = $v } }
$b = @{ 'X-Requested-With' = 'OpenAPI' }
$oturum = $null
Invoke-WebRequest "$Api/users/_login" -Method Post -Headers $b -UseBasicParsing -SessionVariable oturum `
    -Body @{ username = 'admin'; password = $deger['MIRTH_ADMIN_PAROLA'] } | Out-Null
function Cagir($yol, $yontem = 'Get', $govde = $null, $tur = 'application/xml') {
    $p = @{ Uri = "$Api$yol"; Method = $yontem; Headers = $b; WebSession = $oturum; UseBasicParsing = $true }
    if ($null -ne $govde) { $p.Body = [Text.Encoding]::UTF8.GetBytes($govde); $p.ContentType = "$tur; charset=utf-8" }
    elseif ($yontem -ne 'Get' -and $yontem -ne 'Delete') { $p.ContentType = 'application/json' }  # gövdesiz POST: form türü 415 alır
    Invoke-WebRequest @p
}

# ---- 3) configuration map: Teletıp HL7 adresi (diğer anahtarlar korunur)
[xml]$harita = (Cagir '/server/configurationMap').Content
function Anahtar($ad, $deg, $not) {
    $giris = $harita.map.entry | Where-Object { $_.string -eq $ad }
    if (-not $giris) {
        $giris = $harita.CreateElement('entry')
        $s = $harita.CreateElement('string'); $s.InnerText = $ad; $giris.AppendChild($s) | Out-Null
        $o = $harita.CreateElement('com.mirth.connect.util.ConfigurationProperty')
        $o.AppendChild($harita.CreateElement('value')) | Out-Null; $o.AppendChild($harita.CreateElement('comment')) | Out-Null
        $giris.AppendChild($o) | Out-Null
        $harita.DocumentElement.AppendChild($giris) | Out-Null
    }
    $o = $giris.'com.mirth.connect.util.ConfigurationProperty'
    $o.value = $deg; $o.comment = $not
}
if (-not $harita.DocumentElement) { $harita.LoadXml('<map/>') }
Anahtar 'teletip_hl7_host' $TeletipHost 'K1 hedefi: Teletip HL7 alicisi (dev: TELETIP_SIMULATOR 127.0.0.1)'
Anahtar 'teletip_hl7_port' $TeletipPort 'K1 hedefi portu (dev: 6671)'
Anahtar 'teletip_xds_url' $TeletipXdsUrl 'K2 hedefi: Teletip XDS deposu RAD-68 (dev: TELETIP_XDS_SIMULATOR http://127.0.0.1:8083/xds/ - sondaki / şart, Jetty /xds -> /xds/ 302 verir, POST gövdesi kaybolur)'
Anahtar 'teletip_mga_host' $MgaHost 'K3 hedefi: Teletip MGA doz alicisi (Bakanlik dicom.teletip.saglik.gov.tr, TLS; dev: TELETIP_MGA_SIMULATOR 127.0.0.1)'
Anahtar 'teletip_mga_port' $MgaPort 'K3 hedefi portu (Bakanlik 443; dev 11112)'
Anahtar 'teletip_mga_ae' $MgaAe 'K3 Called AE (Bakanlik TELETIP_MGA)'
Anahtar 'teletip_mga_bizim_ae' $BizimAe 'K3 Calling AE (kurumun AE basligi)'
Cagir '/server/configurationMap' 'Put' $harita.OuterXml | Out-Null
Write-Host "Configuration map: teletip_hl7 = ${TeletipHost}:${TeletipPort}, teletip_xds_url = $TeletipXdsUrl, teletip_mga = ${MgaHost}:${MgaPort} $MgaAe (TLS $DozTls)"

# ---- 4) kanalları yükle (sabit kimlik: varsa güncelle) ve deploy et
$dosyalar = @('TELETIP_HL7.xml', 'TELETIP_KOS.xml', 'TELETIP_DOZ.xml')
if (-not $BenzetimYok) { $dosyalar = @('TELETIP_SIMULATOR.xml', 'TELETIP_XDS_SIMULATOR.xml', 'TELETIP_MGA_SIMULATOR.xml') + $dosyalar }
foreach ($d in $dosyalar) {
    $xml = [IO.File]::ReadAllText((Join-Path $kanalKlasoru $d), [Text.Encoding]::UTF8)
    $id = ([xml]$xml).channel.id
    $var = $true
    try { Cagir "/channels/$id" | Out-Null } catch { $var = $false }
    if ($var) { Cagir "/channels/${id}?override=true" 'Put' $xml | Out-Null }
    else      { Cagir '/channels' 'Post' $xml | Out-Null }
    Cagir "/channels/$id/enabled/true" 'Post' | Out-Null
    Cagir "/channels/$id/_deploy?returnErrors=true" 'Post' | Out-Null
    Write-Host ("{0,-20} {1} ve deploy edildi ({2})" -f ([xml]$xml).channel.name, $(if ($var) { 'güncellendi' } else { 'yüklendi' }), $id)
}
if ($BenzetimYok) {
    foreach ($simId in @('6d1f0c2a-7e43-4c55-9a0e-1b7c5e2f6699', '6d1f0c2a-7e43-4c55-9a0e-1b7c5e2f6698', '6d1f0c2a-7e43-4c55-9a0e-1b7c5e2f6697')) {
        try { Cagir "/channels/$simId/_undeploy" 'Post' | Out-Null; Cagir "/channels/$simId" 'Delete' | Out-Null; Write-Host "Benzetim kanalı kaldırıldı ($simId)." } catch { }
    }
}
Start-Sleep 3
[xml]$durum = (Cagir '/channels/statuses').Content
$durum.list.dashboardStatus | ForEach-Object { Write-Host ("  {0,-20} {1}" -f $_.name, $_.state) }
