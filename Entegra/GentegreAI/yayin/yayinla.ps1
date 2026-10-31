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
#  KALITE KAPISI (27.10.2026, kullanici: "canliya cikmadan once duman + testler
#  zorunlu adim olsun"): paket hazirlanmadan ONCE, cagri basina BIR kez:
#     1) web testleri  (vitest)
#     2) api testleri  (dotnet test; DB testleri GENTEGRE_TEST_DB ile - yoksa
#        appsettings.json dizesinden gentegre_ai_test; DB yoksa KIRMIZI, atlanmaz).
#        Test API'si canlidaki gibi SINIRLI uygulama rolüyle baglanir (B07)
#     3) duman testi   (npm run duman; yerel web + API acik olmali;
#        DUMAN_SIFRE zorunlu, DUMAN_URL varsayilan http://localhost:5173,
#        DUMAN_GRUP ile tek grup)
#  Biri kirmiziysa yayin DURUR, sunucuya hicbir sey gitmez.
#     -DumanAtla : yalniz 3. adimi atla (yerel sunucu kapaliysa) - uyari basilir
#     -KapiAtla  : ACIL DURUM, kapinin tamami atlanir - uyari basilir
#
#  Ne yapar: web'i kurulumun alt yolu icin derler, api'yi Release yayinlar,
#  sunucu ayarlarini (DB adi dahil) uretir, hepsini tek pakette sunucuya atar
#  ve orada sunucu-guncelle.sh'i calistirir (goc -> web -> api -> saglik
#  kontrolu; kontrol duserse otomatik geri alma).
#
#  AYNI ANDA TEK YAYIN (13.10.2026): iki yayin birlikte kosunca hem yerelde
#  ayni web/dist'e farkli alt yollarla derleniyor hem sunucuda ayni paket
#  dosyasina yukleniyordu ("tar: A lone zero block", iki kurulum dustu).
#    * yerel kilit  : %TEMP%\gentegre-yayin.kilit (bu makinede ikinci yayin
#                     hemen durur - derleme klasoru ortak)
#    * sunucu kilidi: flock /tmp/gentegre-yayin.kilit (baska makineden gelen
#                     yayin da BEKLER, en fazla 30 dk)
#    * uzak dosyalar kurulum + damga ile benzersiz
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
    # 'profiller' = /genotipai altindaki tum kurum-tipi profilleri (hastane,
    #   tip merkezi, dis, lab, osgb, dal goz, dal ftr - her biri kendi DB'si).
    [ValidateSet('hepsi','hbys','erp','bilim','feta','zone','medx','profiller',
                 'hastane','tipmerkezi','dis','lab','osgb','goz','ftr','goruntuleme','muayene')]
    [string]$Kurulum = 'hepsi',
    [ValidateSet('hepsi','web','api')] [string]$Yalniz = 'hepsi',
    [switch]$TemelAl,
    # KALITE KAPISI atlama anahtarlari (ustteki aciklama).
    [switch]$KapiAtla,
    [switch]$DumanAtla,
    # B07 ACIL DURUM: uygulama rolu adimi atlanir, API postgres (super kullanici) ile baglanir.
    #   Yalniz rolün yetkisi yetmeyen bir hata canlida cikarsa, duzeltme yayinlanana kadar.
    [switch]$SuperRolIleBaglan,
    # YALNIZ -SuperRolIleBaglan ile gerekir: postgres parolasi Production.json'a yazilir. Varsayilan YOK
    #   (kod inceleme 30.10.2026 K11): depodaki betikte duran deger sunucunun super kullanici parolasiydi.
    [string]$DbParola = ''
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
        Db = 'gentegre_erp'; Kap = 'gentegre-api-erp'; Port = 5181; Urun = 'erp'
    },
    # BILIM (24.10.2026, kullanici: "bilim datasi aktardigimiz delphi sunucu adini
    #   bilim diye degistir"): eski DELPHI AKTARIMI PILOTU (14.10.2026; /gentegreai/delphi/,
    #   db gentegre_erp_delphi, konteyner gentegre-api-erp-delphi). Veri Delphi BILIM'den
    #   aktarim ajaniyla geldi (dokuman/19). Yeniden adlandirma bir kez: yayin\bilim-hazirla.sh
    #   (nginx, sudo) - eski /gentegreai/delphi/ web adresi /bilim/'e yonlenir, eski
    #   /gentegreai/delphi/api/ ajan icin ayni porta (5182) gitmeye devam eder.
    #   'hepsi' bu kurulumu da yayinlar.
    [ordered]@{
        Ad = 'bilim'; Etiket = 'BILIM (ERP - Delphi aktarimi)';
        Yol = '/bilim/'; Kok = 'gentegre-bilim';
        Db = 'BILIM'; Kap = 'gentegre-api-bilim'; Port = 5182; Urun = 'erp'
    },
    # FETA (22.10.2026, kullanici: "46.36.201.170/feta ya son erp yi kur ... musteri artik
    #   delphi yerine bu adresten devam edecek, DB adi FETA"): Delphi FETA + FETA_GENDEPO
    #   verisi yerelde aktarilip dogrulandi, sunucuya dump ile gelir (yayin/feta-hazirla.sh).
    #   Gocler veritabaninda uygulanmis - yayin yalniz yeni gocleri calistirir.
    [ordered]@{
        Ad = 'feta'; Etiket = 'FETA (ERP)';
        Yol = '/feta/'; Kok = 'gentegre-feta';
        Db = 'FETA'; Kap = 'gentegre-api-feta'; Port = 5183; Urun = 'erp'
    }
    # ZONE ve MEDX (25.10.2026, kullanici: "mssql'de zone ve medx db'leri var.. onlar icin de sunucuda DB olusturup
    #   migrate yap" - "bunlar 2 ayri musteri", "onlar kullanacak"): FETA ile ayni kalici gecis (dokuman/19 5b);
    #   veri yerelde aktarilip dogrulandi, sunucuya dump ile gelir (yayin/zone-hazirla.sh, medx-hazirla.sh).
    [ordered]@{
        Ad = 'zone'; Etiket = 'ZONE (ERP)';
        Yol = '/zone/'; Kok = 'gentegre-zone';
        Db = 'ZONE'; Kap = 'gentegre-api-zone'; Port = 5184; Urun = 'erp'
    }
    [ordered]@{
        Ad = 'medx'; Etiket = 'MEDX (ERP)';
        Yol = '/medx/'; Kok = 'gentegre-medx';
        Db = 'MEDX'; Kap = 'gentegre-api-medx'; Port = 5185; Urun = 'erp'
    }
)

# ---- /genotipai altindaki KURUM-TIPI PROFILLERI (izole ayri-DB, ayri konteyner)
#   Her profil: kendi DB (gentegre_ai_<ad>), kendi konteyner + port, /genotipai/<ad>/.
#   DB'ler ayrica kuruldu (dev tohumundan restore + kurum_tipi ayarli); goc_gecmisi
#   dolu oldugu icin deploy'daki DB gocu adimi hicbir sey calistirmaz.
$PROFILLER = @(
    @{ Ad='hastane';    Etiket='Profil: Hastane';      Tip='hastane' }
    @{ Ad='tipmerkezi'; Etiket='Profil: Tip Merkezi';  Tip='tip_merkezi' }
    @{ Ad='dis';        Etiket='Profil: Agiz-Dis';     Tip='dis' }
    @{ Ad='lab';        Etiket='Profil: Laboratuvar';  Tip='lab' }
    @{ Ad='osgb';       Etiket='Profil: OSGB';         Tip='osgb' }
    @{ Ad='goz';        Etiket='Profil: Goz (dal)';    Tip='dal_goz' }
    @{ Ad='ftr';        Etiket='Profil: FTR (dal)';    Tip='dal_ftr' }
    @{ Ad='goruntuleme'; Etiket='Profil: Goruntuleme Mrk'; Tip='goruntuleme' }
    # MUAYENE (kullanici 07.10.2026: "46.36.201.170/genotipai/muayene yayinla"):
    #   muayene akisi odakli kurulum; DB'si HASTANE profilinden kopyalandi, o
    #   yuzden kurum tipi de hastane - muayene/istem/recete zinciri tam acik
    #   olsun. Listenin SONUNA eklenir: port sirayla atandigi icin ortaya
    #   eklemek butun profillerin portunu kaydirir ve nginx bloklariyla
    #   ayrismasina yol acar (muayene = 5198).
    @{ Ad='muayene';    Etiket='Profil: Muayene';       Tip='hastane' }
)
$port = 5190
foreach ($p in $PROFILLER) {
    $KURULUMLAR += [ordered]@{
        Ad = $p.Ad; Etiket = $p.Etiket;
        Yol = "/genotipai/$($p.Ad)/"; Kok = "gentegre-ai-$($p.Ad)";
        Db = "gentegre_ai_$($p.Ad)"; Kap = "gentegre-api-$($p.Ad)"; Port = $port
    }
    $port++
}
$profilAdlari = $PROFILLER.Ad

$secilen =
    if ($Kurulum -eq 'hepsi')     { $KURULUMLAR }
    elseif ($Kurulum -eq 'profiller') { $KURULUMLAR | Where-Object { $profilAdlari -contains $_.Ad } }
    else { $KURULUMLAR | Where-Object { $_.Ad -eq $Kurulum } }

function Adim($m) { Write-Host "`n=== $m" -ForegroundColor Cyan }
function Bilgi($m) { Write-Host "  $m" }

# ------------------------------------------------------ kalite kapisi -------
function KaliteKapisi {
    if ($KapiAtla) {
        Write-Warning 'KALITE KAPISI ATLANDI (-KapiAtla) - testler kosulmadan yayinlaniyor.'
        return
    }

    Adim 'kalite kapisi 1/3: web testleri (vitest)'
    Push-Location (Join-Path $kok 'web')
    try {
        npx vitest run --reporter=dot
        if ($LASTEXITCODE -ne 0) { throw 'KALITE KAPISI: web testleri kirmizi - yayin durdu, sunucuya bir sey gitmedi.' }
    } finally { Pop-Location }

    Adim 'kalite kapisi 2/3: api testleri (dotnet test)'
    # DB testleri yalniz GENTEGRE_TEST_DB ile kosar (adi 'test' icermeli); yoksa yerel
    #   appsettings.json dizesinin veritabani gentegre_ai_test yapilir. ZORUNLU=1:
    #   DB'ye ulasilamazsa testler ATLANMAZ, kirmizi olur - sessiz "gecti" olmasin.
    $testDb = $env:GENTEGRE_TEST_DB
    if (-not $testDb) {
        $ayar = Get-Content (Join-Path $kok 'api\src\Gentegre.Api\appsettings.json') -Raw -Encoding UTF8 | ConvertFrom-Json
        $testDb = $ayar.ConnectionStrings.Gentegre -replace '(?i)Database=[^;]*', 'Database=gentegre_ai_test'
    }
    # UYGULAMA ROLU (B07): test API'si canlidaki gibi SINIRLI rolle baglanir - rolün yetkisi yetmeyen
    #   bir uc yayindan ONCE burada kirmizi olur. Rol yerel test DB'sinde ayni SQL ile kurulur; parola
    #   her calismada yenilenir, dosyaya yazilmaz.
    $testDbAdi = if ($testDb -match '(?i)Database=([^;]+)') { $Matches[1] } else { throw 'KALITE KAPISI: test DB adi okunamadi.' }
    $testRol = ($testDbAdi.ToLowerInvariant()) + '_uyg'
    $testParola = -join ((1..40) | ForEach-Object { [char[]]'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789' | Get-Random })
    $rolSql = "\set parola '$testParola'`n" + (Get-Content (Join-Path $PSScriptRoot 'uygulama-rolu.sql') -Raw -Encoding UTF8)
    $rolSql | docker exec -i gentegre-pg18 psql -U postgres -d $testDbAdi -v db=$testDbAdi -v rol=$testRol -q | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "KALITE KAPISI: test DB'sinde uygulama rolu kurulamadi ($testRol)." }
    $testApiDb = ($testDb -replace '(?i)(Username|User Id)=[^;]*', "Username=$testRol") -replace '(?i)Password=[^;]*', "Password=$testParola"
    $eskiDb = $env:GENTEGRE_TEST_DB; $eskiZorunlu = $env:GENTEGRE_TEST_ZORUNLU; $eskiApiDb = $env:GENTEGRE_TEST_API_DB
    $env:GENTEGRE_TEST_DB = $testDb; $env:GENTEGRE_TEST_ZORUNLU = '1'; $env:GENTEGRE_TEST_API_DB = $testApiDb
    try {
        # Cikti depo ICINDE (bin altinda, git disi): testler depo kokunu derleme klasorunden yukari
        #   yururek bulur. Ayri klasor = calisan gelistirme API'sinin (5180) kilitledigi bin'e dokunmaz.
        dotnet test (Join-Path $kok 'api\tests\Gentegre.Testler') -o (Join-Path $kok 'api\tests\Gentegre.Testler\bin\yayin-kapisi') --nologo -v q
        if ($LASTEXITCODE -ne 0) { throw 'KALITE KAPISI: api testleri kirmizi - yayin durdu, sunucuya bir sey gitmedi.' }
    } finally { $env:GENTEGRE_TEST_DB = $eskiDb; $env:GENTEGRE_TEST_ZORUNLU = $eskiZorunlu; $env:GENTEGRE_TEST_API_DB = $eskiApiDb }

    Adim 'kalite kapisi 3/3: duman testi (menu ekranlari)'
    if ($DumanAtla) {
        Write-Warning 'DUMAN TESTI ATLANDI (-DumanAtla).'
        return
    }
    $dumanUrl = if ($env:DUMAN_URL) { $env:DUMAN_URL } else { 'http://localhost:5173' }
    if (-not $env:DUMAN_SIFRE) {
        throw "KALITE KAPISI: DUMAN_SIFRE yok - $dumanUrl girisinin admin parolasini ortam degiskenine verin (ya da -DumanAtla)."
    }
    try { Invoke-WebRequest $dumanUrl -UseBasicParsing -TimeoutSec 5 | Out-Null }
    catch { throw "KALITE KAPISI: duman adresi $dumanUrl acik degil - yerel web + API'yi baslatin (ya da -DumanAtla)." }
    $env:DUMAN_URL = $dumanUrl
    Push-Location (Join-Path $kok 'web')
    try {
        npm run duman
        if ($LASTEXITCODE -ne 0) { throw 'KALITE KAPISI: duman testinde hatali ekran var (rapor web/duman/sonuc/) - yayin durdu.' }
    } finally { Pop-Location }
    Bilgi 'kalite kapisi GECTI'
}

# YEREL KILIT: dosya paylasimsiz acik tutulur; surec bitince (hata dahil)
#   isletim sistemi birakir - eski kilit dosyasi kalsa bile engellemez.
$kilitYolu = Join-Path $env:TEMP 'gentegre-yayin.kilit'
try {
    $kilit = [System.IO.File]::Open($kilitYolu, 'OpenOrCreate', 'ReadWrite', 'None')
} catch [System.IO.IOException] {
    throw "Bu makinede baska bir yayin suruyor ($kilitYolu). Bitmesini bekleyin; iki yayin ayni web/dist klasorunu ve sunucu adimini paylasir."
}

try {
KaliteKapisi
foreach ($k in $secilen) {
    Write-Host "`n################ $($k.Etiket) -> $($k.Yol)" -ForegroundColor Yellow
    # Uzak dosyalar benzersiz: ayni sabit /tmp yoluna iki yayin yuklemesin.
    $damga     = "$($k.Ad)-$(Get-Date -Format yyyyMMddHHmmss)"
    $uzakPaket = "/tmp/gentegre-ai-paket-$damga.tgz"
    $uzakBetik = "/tmp/sunucu-guncelle-$damga.sh"

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

        # Sunucuya OZEL ayarlar. BAGLANTI DIZESI (B07) artik sunucuda uretilir: sunucu-guncelle.sh
        #   kuruluma ozel uygulama rolünü kurar ve dizeyi appsettings.Gizli.json'a yazar - postgres
        #   (super kullanici) parolasi API klasorune hic girmez. Yalniz -SuperRolIleBaglan (acil durum)
        #   eski usul postgres dizesini buraya yazar.
        # GUVENILEN AGLAR (K08): API docker koprusunde, nginx host'ta - X-Forwarded-For ag gecidinden gelir.
        #   172.16.0.0/12 docker'in varsayilan kopru araligi. CORS'ta localhost yok (K87).
        $ayar = [ordered]@{
            Cors = @{ Kaynaklar = @('http://46.36.201.170', 'https://46.36.201.170') }
            AllowedHosts = '*'
            Guvenlik = @{ GuvenilenAglar = @('172.16.0.0/12') }
        }
        # YEREL BAGLANTI DIZESI YAYINA GITMEZ (K11): appsettings.json'daki gelistirme parolasi pakette durmasin.
        $temelAyarYolu = Join-Path $apiCikti 'appsettings.json'
        $temelAyar = Get-Content $temelAyarYolu -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($temelAyar.PSObject.Properties['ConnectionStrings']) { $temelAyar.PSObject.Properties.Remove('ConnectionStrings') }
        $temelAyar | ConvertTo-Json -Depth 10 | Set-Content $temelAyarYolu -Encoding utf8
        Remove-Item (Join-Path $apiCikti 'appsettings.Development.json') -ErrorAction SilentlyContinue
        if ($SuperRolIleBaglan) {
            if (-not $DbParola) { throw '-SuperRolIleBaglan icin -DbParola verin (postgres parolasi).' }
            Write-Warning "ACIL DURUM (-SuperRolIleBaglan): $($k.Db) API'si postgres ile baglanacak."
            $ayar.ConnectionStrings = @{
                Gentegre = "Host=gentegre-pg18;Port=5432;Database=$($k.Db);Username=postgres;Password=$DbParola"
            }
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
        # En az uc hane: 1000 ve sonrasi da goc (eski '^\d{3}_' onlari atliyordu).
        Where-Object { $_.Name -match '^\d{3,}_' } |
        Copy-Item -Destination $dbHedef
    # KURULUM DOSYALARI (tek kaynak, db/kurulum): bos kurulum tohumu, MSSQL
    #   aktarim adimlari listesi, dis veri on kosullari. Sunucudaki goc
    #   uygulayici (goc_uygula.sh) bunlari paketten okur.
    Copy-Item (Join-Path $kok 'db\kurulum') (Join-Path $gecici 'kurulum') -Recurse
    # Goc uygulayici: satir sonu LF (sunucu-guncelle.sh ile ayni sebep, asagida).
    [System.IO.File]::WriteAllText((Join-Path $gecici 'goc_uygula.sh'),
        ((Get-Content (Join-Path $PSScriptRoot 'goc_uygula.sh') -Raw) -replace "`r`n", "`n"))
    # Uygulama rolü (B07): sunucu-guncelle.sh goclerden sonra calistirir.
    [System.IO.File]::WriteAllText((Join-Path $gecici 'uygulama-rolu.sql'),
        ((Get-Content (Join-Path $PSScriptRoot 'uygulama-rolu.sql') -Raw -Encoding UTF8) -replace "`r`n", "`n"))
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

    scp -q $paket "${Sunucu}:$uzakPaket"
    if ($LASTEXITCODE -ne 0) { throw 'scp basarisiz' }

    # Sunucu betigi de her seferinde tazelenir (bu depo tek dogruluk kaynagi).
    # Satir sonlari YERELDE LF'e cevrilir. Uzakta `tr -d "\r"` denendi ve dosyayi
    #   BOZDU: uzak kabuk cift tirnak icindeki \r'yi escape saymayip tr'ye "\" ve
    #   "r" verdi, tr de metindeki TUM "r" harflerini sildi (gentegre -> gentege,
    #   docker -> docke). Cevrimi burada yapmak kabuk escape'ine hic girmez.
    $betikLf = Join-Path $env:TEMP 'sunucu-guncelle.sh'
    [IO.File]::WriteAllText($betikLf,
        ((Get-Content (Join-Path $PSScriptRoot 'sunucu-guncelle.sh') -Raw) -replace "`r`n", "`n"))
    scp -q $betikLf "${Sunucu}:$uzakBetik"
    if ($LASTEXITCODE -ne 0) { throw 'betik scp basarisiz' }
    ssh $Sunucu "mkdir -p ~/$($k.Kok) && mv $uzakBetik ~/$($k.Kok)/sunucu-guncelle.sh && chmod +x ~/$($k.Kok)/sunucu-guncelle.sh"
    # Betik kopyasi dogrulanmadan paket calistirilmaz (K88): eski betik + yeni paket uyumsuz olabilir.
    if ($LASTEXITCODE -ne 0) { throw 'sunucu-guncelle.sh sunucuya yerlestirilemedi' }

    # ------------------------------------------------------------ uygula ----
    Adim 'sunucuda uygulaniyor'
    $bayrak = if ($TemelAl) { '--temel-al' } else { '' }
    # Kurulum bilgisi ORTAM DEGISKENIYLE gecer: betik tek, kurulum coktur.
    # URUN: bos kurulumda urune ozgu duzeltmeler (db/kurulum/bos/erp) - goc_uygula.sh.
    $ortam = "KOK=`$HOME/$($k.Kok) DB=$($k.Db) KAP=$($k.Kap) PORT=$($k.Port) YOL=$($k.Yol) URUN=$($k.Urun) UYGULAMA_ROLU=$(if ($SuperRolIleBaglan) { 0 } else { 1 })"
    # SUNUCU KILIDI: baska bir yayin (baska makineden de) sunucu adimindaysa
    #   BEKLER (en fazla 30 dk); sure dolarsa 75 ile cikar, hicbir sey yapilmaz.
    ssh $Sunucu "flock -w 1800 -E 75 /tmp/gentegre-yayin.kilit env $ortam PAKET=$uzakPaket bash ~/$($k.Kok)/sunucu-guncelle.sh $bayrak"
    if ($LASTEXITCODE -eq 75) { throw 'sunucuda baska bir yayin 30 dakikadir suruyor - bu kurulum ATLANDI, hicbir sey degismedi' }
    if ($LASTEXITCODE -ne 0) { throw 'sunucu guncellemesi basarisiz (sunucu kendi geri almasini yapti)' }

    Remove-Item $gecici -Recurse -Force
    Remove-Item $paket -ErrorAction SilentlyContinue
    Write-Host "YAYIN TAMAM -> http://46.36.201.170$($k.Yol)" -ForegroundColor Green
}
} finally {
    $kilit.Dispose()
}
