# ============================================================================
#  GentegreAI — tek komutla yayin (yerelde calisir)
#
#  IKI KURULUM, IKI VERITABANI (kullanici karari):
#     genotipai  -> HBYS  : http://46.36.201.170/genotipai/   db gentegre_ai
#     gentegreai -> ERP   : http://46.36.201.170/gentegreai/  db gentegre_erp
#  Ayni kod, ayri veri. Bir hastanenin hasta kayitlariyla bir ticari firmanin
#  stok/fatura kayitlari ayni veritabaninda durmamali; urun modu (genel.urun_modu)
#  da veritabani basina ayarlanir - HBYS 2, ERP 1.
#
#     powershell -File yayin\yayinla.ps1                     # ikisi de
#     powershell -File yayin\yayinla.ps1 -Kurulum hbys       # yalniz HBYS
#     powershell -File yayin\yayinla.ps1 -Kurulum erp        # yalniz ERP
#     powershell -File yayin\yayinla.ps1 -Yalniz web         # sadece arayuz
#     powershell -File yayin\yayinla.ps1 -TemelAl            # gocleri
#                                        # CALISTIRMA, "uygulandi" isaretle
#
#  Ne yapar: web'i kurulumun alt yolu icin derler, api'yi Release yayinlar,
#  sunucu ayarlarini (DB adi dahil) uretir, hepsini tek pakette sunucuya atar
#  ve orada sunucu-guncelle.sh'i calistirir (goc -> web -> api -> saglik
#  kontrolu; kontrol duserse otomatik geri alma).
#
#  nginx'e DOKUNMAZ (sudo istemez). Yollar kurulum basina sabit:
#     web  -> ~/<kok>/web        (nginx alias)
#     api  -> ~/<kok>/api        (docker <konteyner>, kendi portunda)
#     db   -> docker gentegre-pg18 (:5433, yalniz localhost)
#  nginx bloklarini bir kez eklemek icin: yayin\nginx-ikili.conf +
#  yayin\nginx-ikili-uygula.sh (sunucuda sudo ile calistirilir).
# ============================================================================
param(
    [string]$Sunucu  = 'gentegre@46.36.201.170',
    [ValidateSet('hepsi','hbys','erp')] [string]$Kurulum = 'hepsi',
    [ValidateSet('hepsi','web','api')] [string]$Yalniz = 'hepsi',
    [switch]$TemelAl,
    # Sunucudaki DB parolasi appsettings.Production.json'a yazilir. Yerel
    #   gelistirme parolasiyla ayni olmasi KULLANICI KARARIYDI; degistirilirse
    #   hem burada hem PG konteynerinde degismeli.
    [string]$DbParola = 'FETAGEN'
)

$ErrorActionPreference = 'Stop'
$kok = Split-Path -Parent $PSScriptRoot      # ...\GentegreAI

# ---------------------------------------------------------- kurulumlar ------
# Tek dogruluk kaynagi: bir kurulumun URL'i, veritabani, konteyneri ve portu
#   burada durur. Yeni musteri = bu listeye bir satir.
$KURULUMLAR = @(
    [ordered]@{
        Ad = 'hbys';  Etiket = 'GenoTIP AI (HBYS)';
        Yol = '/genotipai/'; Kok = 'gentegre-ai';
        Db = 'gentegre_ai';  Kap = 'gentegre-api';     Port = 5180
    },
    [ordered]@{
        Ad = 'erp';   Etiket = 'Gentegre AI (ERP)';
        Yol = '/gentegreai/'; Kok = 'gentegre-erp';
        Db = 'gentegre_erp'; Kap = 'gentegre-api-erp'; Port = 5181
    }
)
$secilen = if ($Kurulum -eq 'hepsi') { $KURULUMLAR }
           else { $KURULUMLAR | Where-Object { $_.Ad -eq $Kurulum } }

function Adim($m) { Write-Host "`n=== $m" -ForegroundColor Cyan }
function Bilgi($m) { Write-Host "  $m" }

foreach ($k in $secilen) {
    Write-Host "`n################ $($k.Etiket) -> $($k.Yol)" -ForegroundColor Yellow

    $gecici = Join-Path $env:TEMP "gentegre-yayin-$($k.Ad)-$(Get-Date -Format yyyyMMddHHmmss)"
    $paket  = Join-Path $env:TEMP "gentegre-ai-paket-$($k.Ad).tgz"
    New-Item -ItemType Directory -Path $gecici -Force | Out-Null

    # --------------------------------------------------------------- web ----
    if ($Yalniz -in @('hepsi','web')) {
        Adim "web derleniyor ($($k.Yol) alt yolu)"
        Push-Location (Join-Path $kok 'web')
        # VITE_BASE  -> varlik yollari <yol>... ve React Router basename
        # VITE_API   -> istekler <yol>api/... (ayni koken; nginx proxy'ler)
        $env:VITE_BASE = $k.Yol
        $env:VITE_API  = $k.Yol.TrimEnd('/')
        npm run build
        if ($LASTEXITCODE -ne 0) { Pop-Location; throw 'web derlemesi basarisiz' }
        Pop-Location
        Copy-Item (Join-Path $kok 'web\dist') (Join-Path $gecici 'web') -Recurse
        Bilgi "web hazir"
    }

    # --------------------------------------------------------------- api ----
    if ($Yalniz -in @('hepsi','api')) {
        Adim 'api yayinlaniyor (Release)'
        $apiCikti = Join-Path $gecici 'api'
        dotnet publish (Join-Path $kok 'api\src\Gentegre.Api') -c Release -o $apiCikti -v q --nologo
        if ($LASTEXITCODE -ne 0) { throw 'api publish basarisiz' }

        # Sunucuya OZEL ayarlar: DB adresi docker agindaki konteyner adi,
        #   VERITABANI ADI kuruluma gore degisir - iki kurulumun verisi ayri.
        $ayar = [ordered]@{
            ConnectionStrings = @{
                Gentegre = "Host=gentegre-pg18;Port=5432;Database=$($k.Db);Username=postgres;Password=$DbParola"
            }
            Cors = @{ Kaynaklar = @('http://46.36.201.170', 'http://localhost') }
            AllowedHosts = '*'
        }
        $ayar | ConvertTo-Json -Depth 5 |
            Set-Content (Join-Path $apiCikti 'appsettings.Production.json') -Encoding utf8
        Remove-Item (Join-Path $apiCikti '*.pdb') -ErrorAction SilentlyContinue
        Bilgi "api hazir (db: $($k.Db))"
    }

    # ---------------------------------------------------------------- db ----
    # Goc dosyalari her yayinla gider; sunucu hangilerinin uygulandigini
    #   goc_gecmisi tablosundan bilir ve yalniz yenileri calistirir.
    # YALNIZ NNN_*.sql kopyalanir: db/ klasorundeki dev dump'lari (or.
    #   gentegre_ai_pg14_*.sql, yuzlerce MB) paketlenip TEMP'i dolduruyordu.
    Adim 'db gocleri paketleniyor'
    $dbHedef = Join-Path $gecici 'db'
    New-Item -ItemType Directory -Path $dbHedef -Force | Out-Null
    Get-ChildItem (Join-Path $kok 'db') -Filter '*.sql' |
        Where-Object { $_.Name -match '^\d{3}_' } |
        Copy-Item -Destination $dbHedef
    # SIFIRDAN kurulan veritabani icin baslangic tohumu (sube + depo):
    #   numarali goclerin ilk halkalari bunlari MSSQL'den getiriyor, MSSQL'i
    #   olmayan yeni kurulumda o adim atlaniyor ve 020 dayanacagi kaydi
    #   bulamiyor. Idempotent - dolu veritabaninda hicbir sey yapmaz.
    $tohum = Join-Path $kok 'db\kurulum\000_bos_kurulum.sql'
    if (Test-Path $tohum) { Copy-Item $tohum (Join-Path $gecici 'bos_kurulum.sql') }
    Bilgi "$((Get-ChildItem $dbHedef -Filter *.sql).Count) goc dosyasi"

    # ----------------------------------------------------------- paketle ----
    Adim 'paketleniyor ve yukleniyor'
    if (Test-Path $paket) { Remove-Item $paket }
    # TAR SECIMI: PATH'te Git/MSYS'in GNU tar'i one gecerse "C:\..." yolunu UZAK
    #   SUNUCU sanir ("Cannot connect to C: resolve failed") ve paket hic
    #   olusmaz. GNU tar'da --force-local bunu keser; Windows'un kendi
    #   bsdtar'inda boyle bir anahtar yok, oraya verilirse patlar.
    $tarSurum = (tar --version 2>&1) -join ' '
    $yerelBayrak = if ($tarSurum -match 'GNU tar') { @('--force-local') } else { @() }
    tar $yerelBayrak -czf $paket -C $gecici .
    if ($LASTEXITCODE -ne 0) { throw 'tar basarisiz' }
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
    ssh $Sunucu "mkdir -p ~/$($k.Kok) && cp /tmp/sunucu-guncelle.sh ~/$($k.Kok)/sunucu-guncelle.sh && chmod +x ~/$($k.Kok)/sunucu-guncelle.sh"

    # ------------------------------------------------------------ uygula ----
    Adim 'sunucuda uygulaniyor'
    $bayrak = if ($TemelAl) { '--temel-al' } else { '' }
    # Kurulum bilgisi ORTAM DEGISKENIYLE gecer: betik tek, kurulum coktur.
    $ortam = "KOK=`$HOME/$($k.Kok) DB=$($k.Db) KAP=$($k.Kap) PORT=$($k.Port) YOL=$($k.Yol)"
    ssh $Sunucu "$ortam bash ~/$($k.Kok)/sunucu-guncelle.sh $bayrak"
    if ($LASTEXITCODE -ne 0) { throw 'sunucu guncellemesi basarisiz (sunucu kendi geri almasini yapti)' }

    Remove-Item $gecici -Recurse -Force
    Remove-Item $paket -ErrorAction SilentlyContinue
    Write-Host "YAYIN TAMAM -> http://46.36.201.170$($k.Yol)" -ForegroundColor Green
}
