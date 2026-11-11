# OHIF VIEWER KONTEYNERİ (kullanıcı 11.11.2026: ClearCanvas ImageServer + OHIF).
#
#   .\ohif-baslat.ps1            -> ohif/app:latest (nginx) 3001 portunda, app-config.js bu klasörden bağlı
#   .\ohif-baslat.ps1 -Durdur    -> konteyneri kaldırır
#   .\ohif-baslat.ps1 -Port 3001 -> başka port (API appsettings Dicom:GoruntuleyiciUrl ve Cors:Kaynaklar aynı olmalı)
#
# OHIF derlenmiş paket ~117 MB ve varlıkları kök yoldan ("/assets/…") ister; bu yüzden web/ altına değil kendi
# nginx konteynerine konur. Gentegre "🖼 Görüntüle" düğmesi {OHIF}/viewer/dicomjson?url={API manifesti} açar.
# Sunucuda aynı imaj; Cloudflare / nginx arkasında /ohif/ altına konacaksa PUBLIC_URL=/ohif/ ile imaj yeniden
# derlenmeli (hazır imaj kök yola gömülü) - o zaman ayrı alt alan adı (ohif.alan.com) daha kolay.
param([switch]$Durdur, [int]$Port = 3001, [string]$Ad = 'gentegre-ohif')

$ErrorActionPreference = 'Stop'
$kok = $PSScriptRoot
# PowerShell 5.1: native stderr ErrorRecord olur - var mı diye sorup öyle kaldır.
$varolan = docker ps -a --filter "name=^/$Ad$" --format '{{.Names}}'
if ($varolan) { docker rm -f $Ad | Out-Null }
if ($Durdur) { Write-Host "$Ad durduruldu."; exit 0 }

docker run -d --name $Ad --restart unless-stopped -p "$Port`:80" `
  -v "$kok\app-config.js:/usr/share/nginx/html/app-config.js:ro" `
  ohif/app:latest | Out-Null
Write-Host "OHIF: http://localhost:$Port  (yapılandırma $kok\app-config.js)"
