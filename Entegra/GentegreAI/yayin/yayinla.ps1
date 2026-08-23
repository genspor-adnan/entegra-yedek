# ============================================================================
#  GentegreAI — tek komutla yayin (yerelde calisir)
#
#     powershell -File yayin\yayinla.ps1                 # web + api + gocler
#     powershell -File yayin\yayinla.ps1 -Yalniz web     # sadece arayuz
#     powershell -File yayin\yayinla.ps1 -Yalniz api     # sadece servis
#     powershell -File yayin\yayinla.ps1 -TemelAl        # gocleri CALISTIRMA,
#                                                        #   "uygulandi" isaretle
#
#  Ne yapar: web'i /ai alt yolu icin derler, api'yi Release yayinlar, sunucu
#  ayarlarini uretir, hepsini tek pakette sunucuya atar ve orada
#  sunucu-guncelle.sh'i calistirir (goc -> web -> api -> saglik kontrolu;
#  kontrol duserse otomatik geri alma).
#
#  nginx'e DOKUNMAZ (sudo istemez). Yollar sabit:
#     web  -> ~/gentegre-ai/web        (nginx alias)
#     api  -> ~/gentegre-ai/api        (docker gentegre-api, :5180)
#     db   -> docker gentegre-pg18     (:5433, yalniz localhost)
# ============================================================================
param(
    [string]$Sunucu  = 'gentegre@46.36.201.170',
    [ValidateSet('hepsi','web','api')] [string]$Yalniz = 'hepsi',
    [switch]$TemelAl,
    # Sunucudaki DB parolasi appsettings.Production.json'a yazilir. Yerel
    #   gelistirme parolasiyla ayni olmasi KULLANICI KARARIYDI; degistirilirse
    #   hem burada hem PG konteynerinde degismeli.
    [string]$DbParola = 'FETAGEN'
)

$ErrorActionPreference = 'Stop'
$kok     = Split-Path -Parent $PSScriptRoot      # ...\GentegreAI
$gecici  = Join-Path $env:TEMP "gentegre-yayin-$(Get-Date -Format yyyyMMddHHmmss)"
$paket   = Join-Path $env:TEMP 'gentegre-ai-paket.tgz'

function Adim($m) { Write-Host "`n=== $m" -ForegroundColor Cyan }
function Bilgi($m) { Write-Host "  $m" }

New-Item -ItemType Directory -Path $gecici -Force | Out-Null

# ------------------------------------------------------------------- web ----
if ($Yalniz -in @('hepsi','web')) {
    Adim 'web derleniyor (/ai alt yolu)'
    Push-Location (Join-Path $kok 'web')
    # VITE_BASE  -> varlik yollari /ai/... ve React Router basename
    # VITE_API   -> istekler /ai/api/... (ayni koken; nginx proxy'ler)
    $env:VITE_BASE = '/ai/'
    $env:VITE_API  = '/ai'
    npm run build
    if ($LASTEXITCODE -ne 0) { Pop-Location; throw 'web derlemesi basarisiz' }
    Pop-Location
    Copy-Item (Join-Path $kok 'web\dist') (Join-Path $gecici 'web') -Recurse
    Bilgi "web hazir"
}

# ------------------------------------------------------------------- api ----
if ($Yalniz -in @('hepsi','api')) {
    Adim 'api yayinlaniyor (Release)'
    $apiCikti = Join-Path $gecici 'api'
    dotnet publish (Join-Path $kok 'api\src\Gentegre.Api') -c Release -o $apiCikti -v q --nologo
    if ($LASTEXITCODE -ne 0) { throw 'api publish basarisiz' }

    # Sunucuya OZEL ayarlar: DB adresi docker agindaki konteyner adi.
    #   appsettings.json (gelistirme) pakette kalir ama Production onu ezer.
    $ayar = [ordered]@{
        ConnectionStrings = @{
            Gentegre = "Host=gentegre-pg18;Port=5432;Database=gentegre_ai;Username=postgres;Password=$DbParola"
        }
        Cors = @{ Kaynaklar = @('http://46.36.201.170', 'http://localhost') }
        AllowedHosts = '*'
    }
    $ayar | ConvertTo-Json -Depth 5 |
        Set-Content (Join-Path $apiCikti 'appsettings.Production.json') -Encoding utf8
    Remove-Item (Join-Path $apiCikti '*.pdb') -ErrorAction SilentlyContinue
    Bilgi "api hazir"
}

# -------------------------------------------------------------------- db ----
# Goc dosyalari her yayinla gider; sunucu hangilerinin uygulandigini
#   goc_gecmisi tablosundan bilir ve yalniz yenileri calistirir.
Adim 'db gocleri paketleniyor'
Copy-Item (Join-Path $kok 'db') (Join-Path $gecici 'db') -Recurse -Filter '*.sql'
Bilgi "$((Get-ChildItem (Join-Path $gecici 'db') -Filter *.sql).Count) goc dosyasi"

# ------------------------------------------------------------- paketle ------
Adim 'paketleniyor ve yukleniyor'
if (Test-Path $paket) { Remove-Item $paket }
tar czf $paket -C $gecici .
Bilgi "paket: $([math]::Round((Get-Item $paket).Length/1MB,1)) MB"

scp -q $paket "${Sunucu}:/tmp/gentegre-ai-paket.tgz"
if ($LASTEXITCODE -ne 0) { throw 'scp basarisiz' }

# Sunucu betigi de her seferinde tazelenir (bu depo tek dogruluk kaynagi).
# Satir sonlari YERELDE LF'e cevrilir. Uzakta `tr -d "\r"` denendi ve dosyayi
#   BOZDU: uzak kabuk cift tirnak icindeki \r'yi escape saymayip tr'ye "\" ve
#   "r" verdi, tr de metindeki TUM "r" harflerini sildi (gentegre -> gentege,
#   docker -> docke). Cevrimi burada yapmak kabuk escape'ine hic girmez.
$betikLf = Join-Path $env:TEMP 'sunucu-guncelle.sh'
[IO.File]::WriteAllText($betikLf,
    ((Get-Content (Join-Path $PSScriptRoot 'sunucu-guncelle.sh') -Raw) -replace "`r`n", "`n"))
scp -q $betikLf "${Sunucu}:/tmp/sunucu-guncelle.sh"
ssh $Sunucu 'mkdir -p ~/gentegre-ai && cp /tmp/sunucu-guncelle.sh ~/gentegre-ai/sunucu-guncelle.sh && chmod +x ~/gentegre-ai/sunucu-guncelle.sh'

# ------------------------------------------------------------- uygula -------
Adim 'sunucuda uygulaniyor'
$bayrak = if ($TemelAl) { '--temel-al' } else { '' }
ssh $Sunucu "bash ~/gentegre-ai/sunucu-guncelle.sh $bayrak"
if ($LASTEXITCODE -ne 0) { throw 'sunucu guncellemesi basarisiz (sunucu kendi geri almasini yapti)' }

Remove-Item $gecici -Recurse -Force
Remove-Item $paket -ErrorAction SilentlyContinue
Write-Host "`nYAYIN TAMAM -> http://46.36.201.170/ai/" -ForegroundColor Green
