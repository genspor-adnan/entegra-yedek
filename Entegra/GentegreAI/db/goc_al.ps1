# ============================================================================
#  Gentegre AI — MSSQL kaynak tablolarini stg semasina AKTARIR (COPY ile)
#
#  Neden ayri betik: pg\tools\seed_from_mssql.ps1 tum satirlari tek dev
#  "INSERT ... VALUES" metnine cevirir. FATURA (500 bin satir), STOKIZLEME
#  (454 bin), KASA (122 bin) icin bu yol hem cok yavas hem yuz megabaytlik
#  SQL dosyasi uretir. Burada satirlar CSV'ye AKITILIR ve PostgreSQL COPY ile
#  yuklenir.
#
#  Kullanim:
#    powershell -ExecutionPolicy Bypass -File .\goc_al.ps1
#    powershell -ExecutionPolicy Bypass -File .\goc_al.ps1 -Tablolar FATURA,KASA
#
#  NOT: Saf ASCII + UTF-8 BOM (Windows PowerShell 5.1 uyumu icin).
# ============================================================================
param(
  [string[]]$Tablolar  = @("REHBER","REHBERBILGI","REHBERILETISIM","KULLANICI","DEPOLAR","DOVIZ","SAYAC","STOKLAR","STOKBARKOD","STOKFIYAT",
                           "STOKDURUM","STOKSERILOT","STOKIZLEME","MASRAFGELIR","FIYATLAR","GENINI",
                           "FATBASLIK","FATURA","KASA",
                           "ROLLER","MODUL","YETKI","YETKIEK","YETKIALANI"),
  [string]$Kap         = "gentegre-pg18",
  [string]$Db          = "gentegre_ai",
  [string]$Sema        = "stg",
  [string]$PgHost      = "",          # dolu ise docker exec YERINE dogrudan baglanir (bulut)
  [int]$PgPort         = 5432,
  [string]$Kul         = "postgres",
  [string]$Parola      = "FETAGEN",
  [string]$MssqlServer = "DESKTOP-HL3J3AS\SQLEXPRESS",
  [string]$MssqlDb     = "BILIM",
  [string]$MssqlUser   = "sa",
  [string]$MssqlPass   = "FETAGEN",
  [int]$Yil            = 2026        # FATBASLIK/FATURA/KASA icin yil filtresi (0 = tumu)
)
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Adim($m) { Write-Host ("==> " + $m) -ForegroundColor Cyan }
function Iyi($m)  { Write-Host ("    " + $m) -ForegroundColor Green }

# PgHost bos -> yerel docker konteyneri (gelistirme); dolu -> uzak sunucu (bulut).
function PgKomut([string]$Sql) {
  $tmp = [System.IO.Path]::GetTempFileName()
  [System.IO.File]::WriteAllText($tmp, $Sql, (New-Object System.Text.UTF8Encoding $false))
  if ($PgHost -eq "") {
    & docker cp $tmp ($Kap + ":/tmp/_komut.sql") | Out-Null
    $cikti = & docker exec -e ("PGPASSWORD=" + $Parola) -e "PGCLIENTENCODING=UTF8" $Kap `
               psql -U $Kul -d $Db -tA -v ON_ERROR_STOP=1 -f /tmp/_komut.sql
  } else {
    $klasor = Split-Path -Parent $tmp
    $ad     = Split-Path -Leaf $tmp
    $cikti = & docker run --rm -e ("PGPASSWORD=" + $Parola) -e "PGCLIENTENCODING=UTF8" `
                 -v ($klasor + ":/sql") postgres:18 `
                 psql -h $PgHost -p $PgPort -U $Kul -d $Db -tA -v ON_ERROR_STOP=1 -f ("/sql/" + $ad)
  }
  Remove-Item $tmp -Force
  return $cikti
}

# CSV alani: RFC4180 tirnaklama; NULL icin bos birakip COPY'ye "" (bos) yerine
#   \N benzeri isaret vermek yerine, CSV'de tirnaksiz BOS alan = NULL kabul edilir
#   (COPY ... WITH (format csv, null '')).
function CsvAlan([object]$v) {
  if ($null -eq $v -or $v -is [DBNull]) { return "" }
  if ($v -is [bool])     { if ($v) { return "1" } else { return "0" } }      # bit -> smallint
  if ($v -is [byte[]])   { return '"\x' + ([System.BitConverter]::ToString($v).Replace('-','')) + '"' }  # bytea hex
  if ($v -is [datetime]) { return $v.ToString('yyyy-MM-dd HH:mm:ss') }
  if ($v -is [decimal] -or $v -is [double] -or $v -is [single]) {
    return ([string]$v).Replace(',', '.')
  }
  if ($v -is [int] -or $v -is [long] -or $v -is [byte] -or $v -is [int16]) { return [string]$v }
  $s = [string]$v
  if ($s.Contains('"') -or $s.Contains(',') -or $s.Contains("`n") -or $s.Contains("`r")) {
    return '"' + $s.Replace('"', '""') + '"'
  }
  return $s
}

$cn = New-Object System.Data.SqlClient.SqlConnection(
        "Server=$MssqlServer;Database=$MssqlDb;User Id=$MssqlUser;Password=$MssqlPass;TrustServerCertificate=True;")
$cn.Open()

foreach ($t in $Tablolar) {
  $alt = $t.ToLowerInvariant()

  # PG'deki kolon sirasi belirleyici (stg tablolari MSSQL semasindan uretildi)
  $pgCols = (PgKomut ("select string_agg(column_name, ',' order by ordinal_position) from information_schema.columns where table_schema='" + $Sema + "' and table_name='" + $alt + "'"))
  if (-not $pgCols) { Write-Host ("ATLANDI (PG'de yok): " + $Sema + "." + $alt) -ForegroundColor Yellow; continue }
  $cols = $pgCols -split ','

  # MSSQL gercek kolon adlari (buyuk/kucuk harf duyarli)
  $cmap = @{}
  $c = $cn.CreateCommand()
  $c.CommandText = "SELECT name FROM sys.columns WHERE object_id=OBJECT_ID('dbo.$t')"
  $r = $c.ExecuteReader()
  while ($r.Read()) { $n = $r.GetString(0); $cmap[$n.ToLowerInvariant()] = $n }
  $r.Close()

  $kullan   = @($cols | Where-Object { $cmap.ContainsKey($_) })
  $msSelect = ($kullan | ForEach-Object { "[" + $cmap[$_] + "]" }) -join ', '

  Adim ($t + " -> " + $Sema + "." + $alt)

  $csv = Join-Path ([System.IO.Path]::GetTempPath()) ("goc_" + $alt + ".csv")
  $sw  = New-Object System.IO.StreamWriter($csv, $false, (New-Object System.Text.UTF8Encoding $false))
  # Yil filtresi: belge hacmi buyuk (FATURA 500 bin satir). Faz 1 dogrulamasi
  #   icin tek yil yeterli; belge disi tablolar filtresiz aktarilir.
  $nerede = ""
  if ($Yil -gt 0) {
    switch ($t) {
      "FATBASLIK" { $nerede = " WHERE YEAR(FATURATARIH) = $Yil" }
      "FATURA"    { $nerede = " WHERE FATBASID IN (SELECT ID FROM dbo.FATBASLIK WHERE YEAR(FATURATARIH) = $Yil)" }
      "KASA"      { $nerede = " WHERE YEAR(ISLEMTARIHI) = $Yil" }
    }
  }
  $cmd = $cn.CreateCommand()
  $cmd.CommandText = "SELECT $msSelect FROM dbo.$t$nerede"
  $cmd.CommandTimeout = 0
  $rd = $cmd.ExecuteReader()
  $n = 0
  $sb = New-Object System.Text.StringBuilder
  while ($rd.Read()) {
    [void]$sb.Clear()
    for ($i = 0; $i -lt $rd.FieldCount; $i++) {
      if ($i -gt 0) { [void]$sb.Append(',') }
      [void]$sb.Append((CsvAlan $rd.GetValue($i)))
    }
    $sw.WriteLine($sb.ToString())
    $n++
  }
  $rd.Close(); $sw.Close()

  $kolonListesi = ($kullan -join ', ')
  if ($PgHost -eq "") {
    & docker cp $csv ($Kap + ":/tmp/" + $alt + ".csv") | Out-Null
    PgKomut ("truncate " + $Sema + "." + $alt + ";
copy " + $Sema + "." + $alt + " (" + $kolonListesi + ") from '/tmp/" + $alt + ".csv' with (format csv, null '');") | Out-Null
  } else {
    # Uzak sunucuda dosya yok -> istemci tarafli \copy (stdin uzerinden akitilir)
    $klasor = Split-Path -Parent $csv
    $ad     = Split-Path -Leaf $csv
    & docker run --rm -e ("PGPASSWORD=" + $Parola) -e "PGCLIENTENCODING=UTF8" `
        -v ($klasor + ":/veri") postgres:18 `
        psql -h $PgHost -p $PgPort -U $Kul -d $Db -v ON_ERROR_STOP=1 `
        -c ("truncate " + $Sema + "." + $alt + ";") `
        -c ("\copy " + $Sema + "." + $alt + " (" + $kolonListesi + ") from '/veri/" + $ad + "' with (format csv, null '')") | Out-Null
  }
  Remove-Item $csv -Force
  Iyi ($n.ToString() + " satir")
}

$cn.Close()
Write-Host ""
Write-Host ("Bitti. " + $Db + " / " + $Sema + " dolduruldu.") -ForegroundColor Green
