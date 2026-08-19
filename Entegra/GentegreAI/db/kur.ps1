# ============================================================================
#  Gentegre AI — Faz 0 / F0-03a  veritabani kurulumu (yalniz PostgreSQL)
#
#  Ne yapar:
#    1. Docker'daki PG'de "gentegre_ai" veritabanini olusturur (yoksa)
#    2. 001 hedef sema  -> REHBER + REHBERADRES
#    3. 002 stg semasi  -> MSSQL kaynak tablolarinin bos kopyalari
#    4. MSSQL'den (BILIM) stg tablolarini doldurur
#    5. 003 gocu calistirir ve dogrulama sayimlarini basar
#
#  Delphi PG pilotunun veritabanina (gentegre) DOKUNMAZ.
#  Kullanim: powershell -ExecutionPolicy Bypass -File .\kur.ps1
#            .\kur.ps1 -SadeceSema      (MSSQL'den veri cekmeden)
#  NOT: Saf ASCII + UTF-8 BOM (Windows PowerShell 5.1 uyumu icin).
# ============================================================================
param(
  [switch]$SadeceSema,
  [string]$Kap         = "gentegre-pg18",   # PostgreSQL 18 (host portu 5434)
  [string]$Db          = "gentegre_ai",
  [string]$PgHost      = "",          # dolu ise docker exec YERINE dogrudan baglanir (bulut)
  [int]$PgPort         = 5432,
  [string]$Kul         = "postgres",
  [string]$Parola      = "FETAGEN",
  [string]$MssqlServer = "DESKTOP-HL3J3AS\SQLEXPRESS",
  [string]$MssqlDb     = "BILIM",
  [string]$MssqlUser   = "sa",
  [string]$MssqlPass   = "FETAGEN",
  [int]$Yil            = 2026        # belge/hareket gocu icin yil filtresi (0 = tum yillar)
)
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Dizin = Split-Path -Parent $MyInvocation.MyCommand.Definition

function Adim($m) { Write-Host ("==> " + $m) -ForegroundColor Cyan }
function Kotu($m) { Write-Host ("HATA: " + $m) -ForegroundColor Red }

# Baglanti iki modda calisir:
#   PgHost bos  -> yereldeki docker konteynerine "docker exec" (gelistirme)
#   PgHost dolu -> uzak sunucuya baglanan gecici psql konteyneri (bulut)
#     Yerel makinede psql kurulu olmasi gerekmez; postgres:18 imaji kullanilir.
function PsqlDosya([string]$Yol, [string]$Hedef) {
  # DIKKAT: dosyayi PowerShell borusuyla (Get-Content | docker exec) gecirmek
  #   Turkce karakterleri BOZAR - 'Türkiye' -> 'T??rkiye'. Dosya bayt bayt
  #   container'a kopyalanip psql -f ile calistirilir.
  $sql = [System.IO.File]::ReadAllText($Yol).Replace("`r`n", "`n").Replace("`r", "`n")
  $ad  = [System.IO.Path]::GetFileName($Yol)
  $gec = Join-Path ([System.IO.Path]::GetTempPath()) $ad
  [System.IO.File]::WriteAllText($gec, $sql, (New-Object System.Text.UTF8Encoding $false))
  if ($PgHost -eq "") {
    & docker cp $gec ($Kap + ":/tmp/" + $ad) | Out-Null
    if ($LASTEXITCODE -ne 0) { throw ("docker cp basarisiz: " + $Yol) }
    & docker exec -e ("PGPASSWORD=" + $Parola) -e "PGCLIENTENCODING=UTF8" $Kap `
        psql -U $Kul -d $Hedef -v ON_ERROR_STOP=1 -f ("/tmp/" + $ad)
  } else {
    $klasor = Split-Path -Parent $gec
    & docker run --rm -e ("PGPASSWORD=" + $Parola) -e "PGCLIENTENCODING=UTF8" `
        -v ($klasor + ":/sql") postgres:18 `
        psql -h $PgHost -p $PgPort -U $Kul -d $Hedef -v ON_ERROR_STOP=1 -f ("/sql/" + $ad)
  }
  if ($LASTEXITCODE -ne 0) { throw ("psql basarisiz: " + $Yol) }
}

function PsqlKomut([string]$Sql, [string]$Hedef) {
  if ($PgHost -eq "") {
    return ($Sql | & docker exec -i -e ("PGPASSWORD=" + $Parola) $Kap psql -U $Kul -d $Hedef -tA)
  }
  return ($Sql | & docker run --rm -i -e ("PGPASSWORD=" + $Parola) postgres:18 `
                    psql -h $PgHost -p $PgPort -U $Kul -d $Hedef -tA)
}

# ---- 1. veritabani
Adim ("Veritabani kontrol ediliyor: " + $Db)
$var = PsqlKomut ("select 1 from pg_database where datname='" + $Db + "'") "postgres"
if (-not $var) {
  # PG 15+ : Turkce siralama VERITABANI duzeyinde ICU ile verilir.
  #   ("Armut, Cilek, Ihlamur, Incir, Seftali, Uzum, Zeytin" dogru siralanir.)
  #   PG 14'e geri donulurse bu komut hata verir; o durumda kolon bazli
  #   COLLATE "tr-TR-x-icu" gerekir (bkz. 001_sema_rehber.sql yorumu).
  Adim "Olusturuluyor (UTF8 + ICU tr-TR)"
  PsqlKomut ("CREATE DATABASE " + $Db + " TEMPLATE template0 ENCODING 'UTF8'" +
             " LOCALE_PROVIDER icu ICU_LOCALE 'tr-TR' LOCALE 'en_US.utf8'") "postgres" | Out-Null
}

# ---- 2/3. semalar
Adim "001_sema_taraf.sql"
PsqlDosya (Join-Path $Dizin "001_sema_taraf.sql") $Db
Adim "002_stg_kaynak_tablolar.sql"
PsqlDosya (Join-Path $Dizin "002_stg_kaynak_tablolar.sql") $Db

# ---- Faz 1 semasi (veri gocu ayri adimda)
foreach ($f in @("010_sema_ortak.sql", "011_sema_stok.sql", "012_sema_belge.sql", "015_sema_log_ebelge.sql", "016_arama_indeksleri.sql", "017_sema_sube_rol.sql")) {
  Adim $f
  PsqlDosya (Join-Path $Dizin $f) $Db
}

if ($SadeceSema) {
  # Kimlik semasi gocten bagimsiz; sadece-sema kurulumunda da olusur
  # (sube tablosu bos oldugu icin admin kullanicisi subeye baglanmaz).
  Adim "020_sema_kimlik.sql"
  PsqlDosya (Join-Path $Dizin "020_sema_kimlik.sql") $Db
  Adim "SadeceSema verildi - veri cekilmedi, goc calistirilmadi."
  return
}

# ---- 4. MSSQL -> stg  (COPY ile; FATBASLIK/FATURA/KASA icin $Yil filtresi)
Adim "MSSQL kaynak tablolari aktariliyor (goc_al.ps1)"
& powershell -ExecutionPolicy Bypass -File (Join-Path $Dizin "goc_al.ps1") `
    -Kap $Kap -Db $Db -Sema "stg" -Kul $Kul -Parola $Parola `
    -MssqlServer $MssqlServer -MssqlDb $MssqlDb -MssqlUser $MssqlUser -MssqlPass $MssqlPass -Yil $Yil
if ($LASTEXITCODE -ne 0) { throw "kaynak aktarimi basarisiz" }

# ---- 5. goc (SIRA ONEMLI: taraf -> stok/kalem/referans -> belge/hareket)
foreach ($f in @("003_goc_taraf.sql", "013_goc_faz1.sql", "014_goc_belge.sql", "018_goc_sube_rol.sql")) {
  Adim $f
  PsqlDosya (Join-Path $Dizin $f) $Db
}

# 019 goc SONRASI: sube_id degerleri duzeldikten sonra NOT NULL + FK zorlanabilir
Adim "019_sema_cok_sube.sql"
PsqlDosya (Join-Path $Dizin "019_sema_cok_sube.sql") $Db

# Kimlik/yetki: sema 019'dan SONRA (admin kullanicisi varsayilan subeye baglanir),
#   ardindan eski KULLANICI/ROLLER/YETKI gocu.
foreach ($f in @("020_sema_kimlik.sql", "021_goc_kimlik.sql", "022_sema_sube_ebelge.sql",
                 "023_sema_belge_hesap.sql", "024_fn_belge_diptoplam.sql",
                 "025_fn_belge_no.sql", "026_doviz_tutar_kurali.sql")) {
  Adim $f
  PsqlDosya (Join-Path $Dizin $f) $Db
}

Write-Host ""
Write-Host ("Bitti. Veritabani: " + $Db + " (docker: " + $Kap + ")") -ForegroundColor Green
