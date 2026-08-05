# depo_adlandirma_duzelt.ps1   —  DEGISIKLIK YAPAR (once depo_adlandirma_kontrol.ps1 calistirin)
#
# DEPO ADLANDIRMA KURALI (05.08.2026): depo veritabani adi  <ANA_DB>_GENDEPO  olmak zorunda.
#
# Bu betik kurala uymayan kurulumlari duzeltir:
#   1) Depo veritabanini yeniden adlandirir  (ALTER DATABASE ... MODIFY NAME)
#   2) GENINI depo opsiyonunu (BOLUM -24120) yeni ada gunceller
#   3) Ana DB'deki depo synonym'lerini yeni depoya cevirir
#
# ONEMLI:
#   * Yeniden adlandirma SINGLE_USER gerektirir -> o veritabanina BAGLI UYGULAMA OLMAMALI.
#     (ROLLBACK IMMEDIATE acik baglantilari duserur.) Once Gentegre'yi kapatin.
#   * Veri kaybi YOK; islem geri alinabilir (ad geri degistirilebilir).
#   * -Onayla verilmeden HICBIR SEY yapilmaz (kuru calisma / dry-run raporu basar).
#
# Kullanim:
#   powershell -ExecutionPolicy Bypass -File depo_adlandirma_duzelt.ps1              # KURU CALISMA
#   powershell -ExecutionPolicy Bypass -File depo_adlandirma_duzelt.ps1 -Onayla      # UYGULA
#   ... -AnaDB SDI      -> yalniz tek veritabani icin

param(
    [string]$Sunucu    = "DESKTOP-HL3J3AS\SQLEXPRESS",
    [string]$Kullanici = "sa",
    [string]$Sifre     = "FETAGEN",
    [switch]$Trusted,
    [string]$AnaDB     = "",     # bos = kurala uymayan TUM veritabanlari
    [switch]$Onayla              # verilmezse yalnizca ne yapilacagini yazar
)

$ErrorActionPreference = "Stop"
$DEPO_OPSIYON = -24120

function Sql($db, $q) {
    $tmp = [System.IO.Path]::GetTempFileName()
    $q | Out-File -Encoding utf8 $tmp
    try {
        $a = @("-S", $Sunucu, "-d", $db, "-C", "-f", "65001", "-h", "-1", "-W", "-i", $tmp)
        if ($Trusted) { $a += "-E" } else { $a += @("-U", $Kullanici, "-P", $Sifre) }
        & sqlcmd @a 2>&1
    } finally { Remove-Item $tmp -ErrorAction SilentlyContinue }
}

# --- Duzeltilecekleri belirle -------------------------------------------------------
$adaylar = if ($AnaDB) { @($AnaDB) } else {
    (Sql "master" "SET NOCOUNT ON; SELECT name FROM sys.databases WHERE database_id > 4 AND state = 0 ORDER BY name") |
    Where-Object { $_ -match '^\w' }
}

$isler = @()
foreach ($db in $adaylar) {
    $var = (Sql $db "SET NOCOUNT ON; SELECT CASE WHEN OBJECT_ID('dbo.GENINI') IS NULL THEN 0 ELSE 1 END") |
           Where-Object { $_ -match '^\d' } | Select-Object -First 1
    if ($var -ne '1') { continue }

    $mevcut = (Sql $db "SET NOCOUNT ON; SELECT ISNULL((SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM=$DEPO_OPSIYON),'')") |
              Where-Object { $_ -match '\S' } | Select-Object -First 1
    if ($null -ne $mevcut) { $mevcut = $mevcut.Trim() }
    $beklenen = "${db}_GENDEPO"
    if ($mevcut -eq $beklenen) { continue }   # zaten uygun

    # Kaynak depo adi: opsiyondaki ad, yoksa eski genel ad
    $eski = if ($mevcut) { $mevcut } else { "GENDEPO" }
    $isler += [pscustomobject]@{ AnaDB = $db; Eski = $eski; Yeni = $beklenen }
}

if ($isler.Count -eq 0) { "Duzeltilecek kurulum yok."; exit 0 }

"=== YAPILACAK ISLEMLER ==="
$isler | Format-Table -AutoSize

if (-not $Onayla) {
    "KURU CALISMA - hicbir degisiklik yapilmadi."
    "Uygulamak icin -Onayla ekleyin. ONCE ilgili veritabanlarina bagli uygulamalari KAPATIN."
    exit 0
}

# --- Uygula --------------------------------------------------------------------------
foreach ($i in $isler) {
    "--- $($i.AnaDB): '$($i.Eski)' -> '$($i.Yeni)'"

    $eskiVar = (Sql "master" "SET NOCOUNT ON; SELECT CASE WHEN DB_ID('$($i.Eski)') IS NULL THEN 0 ELSE 1 END") |
               Where-Object { $_ -match '^\d' } | Select-Object -First 1
    $yeniVar = (Sql "master" "SET NOCOUNT ON; SELECT CASE WHEN DB_ID('$($i.Yeni)') IS NULL THEN 0 ELSE 1 END") |
               Where-Object { $_ -match '^\d' } | Select-Object -First 1

    if ($yeniVar -eq '1') {
        "    Hedef ad zaten var -> yalniz opsiyon + synonym guncellenecek."
    }
    elseif ($eskiVar -eq '1') {
        $q = @"
ALTER DATABASE [$($i.Eski)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE [$($i.Eski)] MODIFY NAME = [$($i.Yeni)];
ALTER DATABASE [$($i.Yeni)] SET MULTI_USER;
SELECT 'rename tamam';
"@
        $s = Sql "master" $q
        if ($s -match 'Msg') { "    HATA(rename): " + (($s | Select-String 'Msg') -join ' '); continue }
        "    veritabani yeniden adlandirildi"
    }
    else {
        "    UYARI: '$($i.Eski)' bulunamadi -> depo KURULMALI (GenDepoKur1..9). Opsiyon yine de yazilacak."
    }

    # GENINI opsiyonu (upsert)
    $q2 = @"
IF EXISTS (SELECT 1 FROM GENINI WHERE BOLUM=$DEPO_OPSIYON)
    UPDATE GENINI SET ANAHTAR='$($i.Yeni)' WHERE BOLUM=$DEPO_OPSIYON;
ELSE
    INSERT INTO GENINI (BOLUM, ANAHTAR, DEGER, DIL) VALUES ($DEPO_OPSIYON, '$($i.Yeni)', '', -1);
SELECT 'opsiyon tamam';
"@
    $s2 = Sql $i.AnaDB $q2
    if ($s2 -match 'Msg') { "    HATA(opsiyon): " + (($s2 | Select-String 'Msg') -join ' ') }
    else { "    opsiyon guncellendi" }

    # Depo synonym'lerini yeni ada cevir (uygulama acilista da duzeltir; burada pesin)
    $q3 = @"
DECLARE @s SYSNAME, @t SYSNAME, @sql NVARCHAR(MAX);
DECLARE c CURSOR FOR
    SELECT name, PARSENAME(base_object_name,1) FROM sys.synonyms
     WHERE PARSENAME(base_object_name,3) IS NOT NULL;
OPEN c; FETCH NEXT FROM c INTO @s, @t;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'DROP SYNONYM [' + @s + N']; CREATE SYNONYM [' + @s + N'] FOR [$($i.Yeni)].dbo.[' + @t + N'];';
    EXEC sp_executesql @sql;
    FETCH NEXT FROM c INTO @s, @t;
END
CLOSE c; DEALLOCATE c;
SELECT 'synonym tamam';
"@
    $s3 = Sql $i.AnaDB $q3
    if ($s3 -match 'Msg') { "    HATA(synonym): " + (($s3 | Select-String 'Msg') -join ' ') }
    else { "    synonym'ler cevrildi" }
}

""
"Bitti. Dogrulama:  powershell -ExecutionPolicy Bypass -File depo_adlandirma_kontrol.ps1"


# --- Yardimci: GenDepoKur/Update betiklerini KURAL ADIYLA calistirma ------------------
# GenDepoKur*.sql / GenDepoUpdate*.sql dosyalari tarihsel olarak sabit 'GENDEPO' adini yazar.
#   Bu dosyalari tek tek degistirmek yerine, calistirmadan once metindeki depo adini
#   <ANA_DB>_GENDEPO ile degistiriyoruz. Boylece YENI kurulum da kurala uyar.
#
# Ornek:
#   . .\depo_adlandirma_duzelt.ps1            # fonksiyonu yukle (islem yapmaz, -Onayla yok)
#   Invoke-DepoBetigi -Betik "GenUpdate\GenDepoKur1.sql" -AnaDB SDI
function Invoke-DepoBetigi {
    param(
        [Parameter(Mandatory=$true)][string]$Betik,
        [Parameter(Mandatory=$true)][string]$AnaDB
    )
    if (-not (Test-Path $Betik)) { throw "Betik bulunamadi: $Betik" }
    $hedef = "${AnaDB}_GENDEPO"
    $metin = Get-Content $Betik -Raw -Encoding UTF8

    # Kelime sinirli degisim: zaten dogru adi tasiyanlar (or. SDI_GENDEPO) BOZULMASIN.
    $yeni = [regex]::Replace($metin, '(?<![A-Za-z0-9_])GENDEPO(?![A-Za-z0-9_])', $hedef)

    $tmp = [System.IO.Path]::GetTempFileName() + ".sql"
    try {
        $yeni | Out-File -Encoding utf8 $tmp
        $a = @("-S", $Sunucu, "-d", $AnaDB, "-C", "-b", "-f", "65001", "-i", $tmp)
        if ($Trusted) { $a += "-E" } else { $a += @("-U", $Kullanici, "-P", $Sifre) }
        $cikti = & sqlcmd @a 2>&1
        [pscustomobject]@{ Betik = (Split-Path $Betik -Leaf); Depo = $hedef
                           Basarili = ($LASTEXITCODE -eq 0); Cikti = ($cikti -join "`n") }
    } finally { Remove-Item $tmp -ErrorAction SilentlyContinue }
}
