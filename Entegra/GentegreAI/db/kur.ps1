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
#            .\kur.ps1 -SadeceSema      (MSSQL'den veri cekmeden - GUNCEL semanin
#                                        tamami, bos kurulum tohumuyla)
#
#  GOC UYGULAMA KURALLARI db\araclar\goc_uygula.ps1'dedir (denetim 28.09.2026
#  #9/#10): dosya + defter tek islem, eszamanli kuruluma karsi kilit, bos
#  kurulumda tohum ve MSSQL aktarim adimlari (db\kurulum). Cikis kodu:
#  0 tamam · 1 hata · 2 dis veri on kosulu (SKRS) bekleniyor.
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

# ---- GOC UYGULAYICI ---------------------------------------------------------
# Uygulama, defter ve kilit kurallari TEK yerde: araclar\goc_uygula.ps1
#   (sunucu esi: yayin\goc_uygula.sh). Bu betik yalniz SIRAYI ve MSSQL
#   aktarimini yonetir.
$Uygulayici = Join-Path $Dizin "araclar\goc_uygula.ps1"
function Goc([string[]]$Liste, [switch]$Bos) {
  # Liste DOSYAYLA verilir: 900 dosya adi komut satiri sinirini (32K) asar.
  $listeYolu = [System.IO.Path]::GetTempFileName()
  [System.IO.File]::WriteAllLines($listeYolu, $Liste)
  $a = @("-ExecutionPolicy", "Bypass", "-File", $Uygulayici, "-Kap", $Kap, "-Db", $Db,
         "-Kul", $Kul, "-Parola", $Parola, "-Dizin", $Dizin, "-ListeDosyasi", $listeYolu)
  if ($PgHost -ne "") { $a += @("-PgHost", $PgHost, "-PgPort", $PgPort) }
  if ($Bos) { $a += "-BosKurulum" }
  & powershell @a
  $kod = $LASTEXITCODE
  Remove-Item $listeYolu -ErrorAction SilentlyContinue
  if ($kod -eq 2) {
    Write-Host "Kurulum DIS VERI bekliyor (yukarida). On kosul saglaninca ayni komutu yeniden calistirin." -ForegroundColor Yellow
    exit 2
  }
  if ($kod -ne 0) { Kotu "goc basarisiz"; exit 1 }
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

# ---- SIRA (tek kaynak): sema -> [MSSQL aktarimi] -> goc -> kimlik -> kalan
$Sema1   = @("001_sema_taraf.sql", "002_stg_kaynak_tablolar.sql",
             "010_sema_ortak.sql", "011_sema_stok.sql", "012_sema_belge.sql",
             "015_sema_log_ebelge.sql", "016_arama_indeksleri.sql", "017_sema_sube_rol.sql")
# SIRA ONEMLI: taraf -> stok/kalem/referans -> belge/hareket; 019 goc SONRASI
#   (sube_id degerleri duzeldikten sonra NOT NULL + FK zorlanabilir).
$Goc     = @("003_goc_taraf.sql", "013_goc_faz1.sql", "014_goc_belge.sql", "018_goc_sube_rol.sql",
             "019_sema_cok_sube.sql")
# Kimlik/yetki: sema 019'dan SONRA (admin kullanicisi varsayilan subeye baglanir).
$Kimlik  = @("020_sema_kimlik.sql", "021_goc_kimlik.sql", "022_sema_sube_ebelge.sql",
             "023_sema_belge_hesap.sql", "024_fn_belge_diptoplam.sql",
             "025_fn_belge_no.sql", "026_doviz_tutar_kurali.sql")
# 027 ve sonrasi: dosya sirasi.
$Kalan   = @(Get-ChildItem $Dizin -Filter "*.sql" |
             Where-Object { $_.Name -match '^(\d{3})_' -and [int]$Matches[1] -ge 27 } |
             Sort-Object Name | ForEach-Object { $_.Name })

if ($TemelAl) {
  # DIKKAT: SQL CALISTIRMAZ, butun dosyalari "uygulandi" isaretler. Yalniz
  #   semasi baska yoldan (dump) gelmis veritabani icindir; defteri toptan
  #   doldurmak gercek gecmisi gizler (denetim #8) - kayitlar 'temel_al'
  #   yontemiyle ayrilir.
  Adim "Temel alma: goc defterine 'temel_al' ile isaretleniyor (SQL calistirilmaz)"
  PsqlKomut @"
create table if not exists public.goc_gecmisi (dosya varchar(200) primary key,
    uygulama timestamp not null default now()::timestamp);
alter table public.goc_gecmisi add column if not exists ozet varchar(64);
alter table public.goc_gecmisi add column if not exists yontem varchar(20);
"@ $Db | Out-Null
  foreach ($g in ($Sema1 + $Goc + $Kimlik + $Kalan)) {
    PsqlKomut ("insert into public.goc_gecmisi(dosya, yontem) values ('" + $g +
               "', 'temel_al') on conflict (dosya) do nothing") $Db | Out-Null
  }
  Adim ("Defterde " + (PsqlKomut "select count(*) from public.goc_gecmisi" $Db) + " dosya kayitli.")
  return
}

if ($SadeceSema) {
  # MSSQL KAYNAGI YOK: tum zincir tek siraya, bos kurulum kipinde. Aktarim
  #   adimlari (db\kurulum\aktarim_adimlari.txt) calistirilmaz ve deftere
  #   'aktarim_yok' yazilir; her bekleyen dosyadan once tohum
  #   (db\kurulum\000_bos_kurulum.sql) eksik sube/depo/kod listesini tamamlar.
  #   Onceden bu secenek 020'de duruyordu - 027 ve sonrasi HIC kurulmuyordu.
  Adim "SadeceSema: guncel sema, MSSQL aktarimi olmadan"
  Goc ($Sema1 + $Goc + $Kimlik + $Kalan) -Bos
  Adim ("Goc defteri: " + (PsqlKomut "select count(*) from public.goc_gecmisi" $Db) + " dosya kayitli")
  Write-Host ""
  Write-Host ("Bitti. Veritabani: " + $Db + " (sema, bos kurulum)") -ForegroundColor Green
  return
}

Goc $Sema1

# ---- MSSQL -> stg  (COPY ile; FATBASLIK/FATURA/KASA icin $Yil filtresi)
Adim "MSSQL kaynak tablolari aktariliyor (goc_al.ps1)"
& powershell -ExecutionPolicy Bypass -File (Join-Path $Dizin "goc_al.ps1") `
    -Kap $Kap -Db $Db -Sema "stg" -Kul $Kul -Parola $Parola `
    -MssqlServer $MssqlServer -MssqlDb $MssqlDb -MssqlUser $MssqlUser -MssqlPass $MssqlPass -Yil $Yil
if ($LASTEXITCODE -ne 0) { throw "kaynak aktarimi basarisiz" }

Goc ($Goc + $Kimlik + $Kalan)
Adim ("Goc defteri: " + (PsqlKomut "select count(*) from public.goc_gecmisi" $Db) + " dosya kayitli")

Write-Host ""
Write-Host ("Bitti. Veritabani: " + $Db + " (docker: " + $Kap + ")") -ForegroundColor Green
