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
  # Mevcut (elle kurulmus) veritabanini goc defterine "uygulanmis" olarak
  #   isaretler; hicbir SQL CALISTIRMAZ. Bir kez calistirilir, sonra normal
  #   kullanimda yalniz YENI gocler uygulanir.
  [switch]$TemelAl,
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

# ---- GOC DEFTERI ------------------------------------------------------------
# Hangi goc dosyasinin bu veritabaninda calistigi DB'de tutulur. Gocler
#   idempotent yazilsa da (create if not exists / on conflict) kayit tutmak
#   "bu veritabani hangi surumde" sorusunun tek cevabidir. Ayni tablo sunucu
#   tarafinda da kullaniliyor (yayin/sunucu-guncelle.sh) - iki taraf ayni.
function GocDefteriKur() {
  PsqlKomut @"
create table if not exists public.goc_gecmisi (
    dosya      varchar(200) primary key,
    uygulama   timestamp not null default now()::timestamp
);
comment on table public.goc_gecmisi is
  'Bu veritabaninda calistirilmis db/NNN_*.sql goc dosyalari (kur.ps1 / yayinla.ps1).';
"@ $Db | Out-Null
}

function GocUygulandiMi([string]$Ad) {
  return [bool](PsqlKomut ("select 1 from public.goc_gecmisi where dosya = '" + $Ad + "'") $Db)
}

function GocIsaretle([string]$Ad) {
  PsqlKomut ("insert into public.goc_gecmisi(dosya) values ('" + $Ad +
             "') on conflict (dosya) do nothing") $Db | Out-Null
}

# Defterde varsa ATLA - "sadece sema" gibi kismi calistirmalar zaten uygulanmis
#   dosyalari yeniden calistirmasin (idempotent olsalar da gereksiz ve yavas).
function GocCalistir([string]$Ad) {
  if (GocUygulandiMi $Ad) { Adim ($Ad + " (zaten uygulanmis, atlandi)"); return }
  Adim $Ad
  PsqlDosya (Join-Path $Dizin $Ad) $Db
  GocIsaretle $Ad
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

GocDefteriKur

if ($TemelAl) {
  Adim "Temel alma: mevcut veritabani goc defterine isaretleniyor (SQL calistirilmaz)"
  $hepsi = Get-ChildItem $Dizin -Filter "*.sql" | Where-Object { $_.Name -match '^\d{3}_' } | Sort-Object Name
  foreach ($g in $hepsi) { GocIsaretle $g.Name }
  Adim ("Defterde " + (PsqlKomut "select count(*) from public.goc_gecmisi" $Db) + " dosya kayitli.")
  return
}

# ---- 2/3. semalar
GocCalistir "001_sema_taraf.sql"
GocCalistir "002_stg_kaynak_tablolar.sql"

# ---- Faz 1 semasi (veri gocu ayri adimda)
foreach ($f in @("010_sema_ortak.sql", "011_sema_stok.sql", "012_sema_belge.sql", "015_sema_log_ebelge.sql", "016_arama_indeksleri.sql", "017_sema_sube_rol.sql")) {
  GocCalistir $f
}

if ($SadeceSema) {
  # Kimlik semasi gocten bagimsiz; sadece-sema kurulumunda da olusur
  # (sube tablosu bos oldugu icin admin kullanicisi subeye baglanmaz).
  GocCalistir "020_sema_kimlik.sql"
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
  GocCalistir $f
}

# 019 goc SONRASI: sube_id degerleri duzeldikten sonra NOT NULL + FK zorlanabilir
GocCalistir "019_sema_cok_sube.sql"

# Kimlik/yetki: sema 019'dan SONRA (admin kullanicisi varsayilan subeye baglanir),
#   ardindan eski KULLANICI/ROLLER/YETKI gocu.
foreach ($f in @("020_sema_kimlik.sql", "021_goc_kimlik.sql", "022_sema_sube_ebelge.sql",
                 "023_sema_belge_hesap.sql", "024_fn_belge_diptoplam.sql",
                 "025_fn_belge_no.sql", "026_doviz_tutar_kurali.sql")) {
  GocCalistir $f
}

# ---- 6. KALAN TUM GOCLER (027...)
#
# BU ADIM EKSIKTI: betik 026'da bitiyordu, oysa klasorde 190'in uzerinde goc
# dosyasi var. Yani "sifirdan kurulum" aslinda calismiyordu - gelistirme
# veritabani elle uygulanan goclerle ayakta duruyordu ve hangi dosyanin
# uygulandigi hicbir yerde yazmiyordu.
#
# Ayni defter (goc_gecmisi) SUNUCUDA zaten vardi (yayin/sunucu-guncelle.sh);
# yerelde yoktu. Artik iki taraf ayni mekanizmayi kullaniyor: dosya adina gore
# bir kez uygulanir, tekrar calistirmak zararsizdir.
Adim "Kalan gocler (027+)"
$kalan = Get-ChildItem $Dizin -Filter "*.sql" |
         Where-Object { $_.Name -match '^(\d{3})_' -and [int]$Matches[1] -ge 27 } |
         Sort-Object Name
foreach ($g in $kalan) {
  if (GocUygulandiMi $g.Name) { continue }
  GocCalistir $g.Name
}
Adim ("Goc defteri: " + (PsqlKomut "select count(*) from public.goc_gecmisi" $Db) + " dosya kayitli")

Write-Host ""
Write-Host ("Bitti. Veritabani: " + $Db + " (docker: " + $Kap + ")") -ForegroundColor Green
