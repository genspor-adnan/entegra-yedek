# ============================================================================
#  Gentegre - Konsolide 66-169 PG portunu Docker'daki PostgreSQL'e uygular
#  Kullanim: powershell -ExecutionPolicy Bypass -File .\uygula_pg.ps1
#  NOT: Saf ASCII + UTF-8 BOM (Windows PowerShell 5.1 uyumu icin).
# ============================================================================

# ---- ayarlar ----
$Kap  = "gentegre-pg"      # docker container adi
$Db   = "gentegre"
$Kul  = "postgres"
# -----------------

$Dizin = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ErrorActionPreference = "Continue"

function Adim($m) { Write-Host ("==> " + $m) -ForegroundColor Cyan }
function Iyi($m)  { Write-Host ("    " + $m) -ForegroundColor Green }
function Kotu($m) { Write-Host ("HATA: " + $m) -ForegroundColor Red }

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Kotu "'docker' bulunamadi. Docker Desktop calisiyor mu?"
  Read-Host "Enter"; exit 1
}

$Durum = (& docker inspect -f "{{.State.Running}}" $Kap 2>$null)
if ($LASTEXITCODE -ne 0) { Kotu ("container yok: " + $Kap); Read-Host "Enter"; exit 1 }
if ($Durum -ne "true")   { Kotu ("container calismiyor: " + $Kap + "  ->  docker start " + $Kap); Read-Host "Enter"; exit 1 }
Adim ("Container calisiyor: " + $Kap)

# ---- calistirma sirasi ----
# 01 : eksik _USER tablolari (09'daki trigger URETIMEMRI_USER'i bekler)
# 00 : sema + seed
# 09 : once calismali - 08 icindeki log fonksiyonlari fn_api_depodbadi()'ni cagirir
# 08 : log/audit
# 02 : donusum (app'in exec ile cagirdigi imzalar)
# 04 : silme engelleri + silme matrisi (08'deki fn_api_log_yaz_ic'e bagli)
$Sira = @("01_Eksik_User_Tablolari_PG.sql",
          "00_Kurulum_Sema_PG.sql",
          "09_Diger_PG.sql",
          "08_Log_Audit_PG.sql",
          "02_Belge_Donusum_PG.sql",
          "04_Silme_API_PG.sql")

foreach ($Ad in $Sira) {
  $Yol = Join-Path $Dizin $Ad
  if (-not (Test-Path $Yol)) { Kotu ("dosya yok -> " + $Yol); Read-Host "Enter"; exit 1 }

  Adim ("Uygulaniyor: " + $Ad)
  # LF'e cevirip container'in stdin'ine ver (dosyayi kopyalamaya gerek yok)
  $CR = [string][char]13
  $LF = [string][char]10
  $Sql = [System.IO.File]::ReadAllText($Yol)
  $Sql = $Sql.Replace($CR + $LF, $LF).Replace($CR, $LF)
  $Gecici = Join-Path ([System.IO.Path]::GetTempPath()) $Ad
  [System.IO.File]::WriteAllText($Gecici, $Sql, (New-Object System.Text.UTF8Encoding $false))

  Get-Content -Raw $Gecici | & docker exec -i $Kap psql -U $Kul -d $Db -v ON_ERROR_STOP=1 -q
  if ($LASTEXITCODE -ne 0) {
    Kotu ($Ad + " basarisiz - yukaridaki psql hatasina bakin. Sonraki dosya CALISTIRILMADI.")
    Read-Host "Enter"; exit 1
  }
  Iyi ($Ad + " tamam")
}

Adim "Olusan nesneler kontrol ediliyor"
$Sorgu = @"
select 'fonksiyon: '||p.proname from pg_proc p join pg_namespace n on n.oid=p.pronamespace
 where n.nspname='public' and p.proname in ('fn_api_depodbadi','fn_api_log_yiltablosu','fn_api_log_yaz_ic',
       'fn_api_log_kaynak_isaretle','fn_api_log_detaysil_json','fn_api_log_kayitsil_json',
       'trg_uretimemriuser_skt_guncelle','fn_prog_donusum_hedefbelge','fn_prog_donusum_kaynakbelge',
       'fn_prog_donusum_satiradetkontrol')
union all select 'tablo: BELGEDONUSUMISLEM' from information_schema.tables
 where table_schema='public' and table_name='belgedonusumislem'
union all select 'kolon: depo.SNAPSHOT.'||column_name from information_schema.columns
 where table_schema='depo' and table_name='snapshot' and column_name in ('silsira','tamsil')
union all select 'silme matrisi satir: '||(select count(*)::text from public.fn_prog_silme_detay())
order by 1;
"@
# Sorguyu -c yerine stdin ile ver: tirnak iceren argumanlarda PS 5.1/7 farki olmaz
$Sorgu | & docker exec -i $Kap psql -U $Kul -d $Db -tA

Write-Host ""
Write-Host "Bitti. Yukaridaki kontrol listesinde eksik satir olmamali." -ForegroundColor Green
Write-Host "UYARI: 08_09_dogrulama_PG.sql TEST verisi ekler - canli veritabaninda CALISTIRMAYIN." -ForegroundColor Yellow
Write-Host ""
Read-Host "Kapatmak icin Enter"
