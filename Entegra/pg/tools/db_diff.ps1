# ============================================================
# db_diff.ps1  —  MSSQL <-> PostgreSQL tablo karsilastirma (diferansiyel test)
# ------------------------------------------------------------
# Ayni is verisini iki Gentegre.exe'ye (biri MSSQL, biri PG) girersin; bu arac
# ilgili tabloyu iki motordan cekip karsilastirir.
#   - Meshru farklari YOK SAYAR (ID, zaman damgalari -> -Ignore)
#   - Satirlari IS ANAHTARIYLA eslestirir (-Keys)
#   - bool/sayi NORMALIZE eder; kolon adlarini iki motor arasinda eslestirir
# NOT: MSSQL burada kolon adinda buyuk/kucuk harfe DUYARLI (ID<>id) + Turkce I
#   tuzagi -> ToLowerInvariant ve MSSQL gercek kolon adlari kullanilir.
# Kullanim: powershell -File pg\tools\db_diff.ps1 -Table DEPOLAR -Keys DEPOADI
# ============================================================
param(
  [Parameter(Mandatory=$true)][string]$Table,
  [string]$Keys   = 'DEPOADI',
  [string]$Ignore = 'ID,EKLEYEN,EKLEMETARIHI,DEGISTIREN,DEGISTIRMETARIHI,SONSAYIMTARIHI',
  [string]$MssqlServer = 'DESKTOP-HL3J3AS\SQLEXPRESS',
  [string]$MssqlDb   = 'BILIM',
  [string]$MssqlUser = 'sa',
  [string]$MssqlPass = 'FETAGEN',
  [string]$PgContainer = 'gentegre-pg',
  [string]$PgDb     = 'gentegre',
  [string]$PgSchema = 'public',
  [string]$PgUser   = 'postgres',
  [string]$PgPass   = 'FETAGEN'
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8        # docker/psql UTF-8 ciktisini dogru oku
$inv = [System.Globalization.CultureInfo]::InvariantCulture
function LI([string]$s) { return $s.ToLowerInvariant() }        # Turkce I tuzagina karsi
function Norm([object]$v) {
  if ($null -eq $v -or $v -is [DBNull]) { return '' }
  $s = ([string]$v).Trim(); if ($s -eq '') { return '' }
  switch -Regex ($s) { '^(True|t)$' { return '1' }  '^(False|f)$' { return '0' } }
  $d = [decimal]0
  if ([decimal]::TryParse($s, [System.Globalization.NumberStyles]::Any, $inv, [ref]$d)) { return $d.ToString($inv) }
  return $s
}
$ignoreSet = @{}; ($Ignore.Split(',') | ForEach-Object { LI $_.Trim() }) | ForEach-Object { $ignoreSet[$_] = $true }
$keyLower  = @($Keys.Split(',') | ForEach-Object { LI $_.Trim() })
$tblLower  = LI $Table

# MSSQL gercek kolon adlari (lowerInvariant -> gercek ad)
$cn = New-Object System.Data.SqlClient.SqlConnection("Server=$MssqlServer;Database=$MssqlDb;User Id=$MssqlUser;Password=$MssqlPass;TrustServerCertificate=True;")
$cn.Open()
$cmap = @{}; $c = $cn.CreateCommand(); $c.CommandText = "SELECT name FROM sys.columns WHERE object_id=OBJECT_ID('dbo.$Table')"; $r = $c.ExecuteReader()
while ($r.Read()) { $n = $r.GetString(0); $cmap[(LI $n)] = $n }; $r.Close()
if ($cmap.Count -eq 0) { Write-Host "HATA: MSSQL'de dbo.$Table yok." -ForegroundColor Red; $cn.Close(); return }

# PG kolonlari (kucuk harf)
$pgColsRaw = docker exec -e "PGPASSWORD=$PgPass" $PgContainer psql -U $PgUser -d $PgDb -tAc `
  "SELECT string_agg(column_name, ',' ORDER BY ordinal_position) FROM information_schema.columns WHERE table_schema='$PgSchema' AND table_name='$tblLower'"
$pgCols = @($pgColsRaw.Trim().Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
if (-not $pgCols) { Write-Host "HATA: PG'de $PgSchema.$tblLower yok." -ForegroundColor Red; $cn.Close(); return }

# Karsilastirma kolonlari = iki motorda da olan, ignore/anahtar disi
$compareCols = @($pgCols | Where-Object { -not $ignoreSet.ContainsKey($_) -and ($keyLower -notcontains $_) -and $cmap.ContainsKey($_) })
$selLower = @($keyLower + $compareCols)

Write-Host "== Karsilastirma: $Table ==" -ForegroundColor Cyan
Write-Host ("Anahtar: {0}   Karsilastirilan: {1}" -f ($keyLower -join ','), ($compareCols -join ','))
Write-Host ("Yok sayilan: {0}`n" -f $Ignore)

# MSSQL veriyi cek (gercek adlar, kucuk harf alias -> reader tutarli)
$msSelect = ($selLower | ForEach-Object { "[$($cmap[$_])] AS [$_]" }) -join ', '
$cmd = $cn.CreateCommand(); $cmd.CommandText = "SELECT $msSelect FROM dbo.$Table"; $rd = $cmd.ExecuteReader()
$ms = @{}
while ($rd.Read()) {
  $row = @{}; for ($i=0; $i -lt $rd.FieldCount; $i++) { $row[(LI $rd.GetName($i))] = Norm $rd.GetValue($i) }
  $k = LI (($keyLower | ForEach-Object { $row[$_] }) -join '|'); $ms[$k] = $row
}
$rd.Close(); $cn.Close()

# PG veriyi cek (CSV)
$pgSelect = ($selLower -join ', ')
$pgCsv = docker exec -e "PGPASSWORD=$PgPass" $PgContainer psql -U $PgUser -d $PgDb -c "\copy (SELECT $pgSelect FROM $PgSchema.$tblLower) TO STDOUT WITH CSV HEADER"
$pg = @{}
foreach ($rr in ($pgCsv | ConvertFrom-Csv)) {
  $row = @{}; foreach ($col in $selLower) { $row[$col] = Norm $rr.$col }
  $k = LI (($keyLower | ForEach-Object { $row[$_] }) -join '|'); $pg[$k] = $row
}

# Karsilastir
$onlyMs = @(); $onlyPg = @(); $diffs = @()
foreach ($k in $ms.Keys) {
  if (-not $pg.ContainsKey($k)) { $onlyMs += $k; continue }
  foreach ($col in $compareCols) { if ($ms[$k][$col] -ne $pg[$k][$col]) { $diffs += [pscustomobject]@{ Anahtar=$k; Kolon=$col; MSSQL=$ms[$k][$col]; PG=$pg[$k][$col] } } }
}
foreach ($k in $pg.Keys) { if (-not $ms.ContainsKey($k)) { $onlyPg += $k } }

Write-Host ("MSSQL satir: {0}   PG satir: {1}" -f $ms.Count, $pg.Count)
Write-Host ("Sadece MSSQL'de: {0}   Sadece PG'de: {1}   Deger farki: {2}`n" -f $onlyMs.Count, $onlyPg.Count, $diffs.Count)
if ($onlyMs) { Write-Host "-- Sadece MSSQL'de:" -ForegroundColor Yellow; $onlyMs | ForEach-Object { Write-Host "   $_" } }
if ($onlyPg) { Write-Host "-- Sadece PG'de:"    -ForegroundColor Yellow; $onlyPg | ForEach-Object { Write-Host "   $_" } }
if ($diffs)  { Write-Host "-- Deger farklari:"  -ForegroundColor Red;    ($diffs | Format-Table -AutoSize | Out-String) | Write-Host }
if (-not $onlyMs -and -not $onlyPg -and -not $diffs) { Write-Host "SONUC: ESLESTI (fark yok)" -ForegroundColor Green }
else { Write-Host "SONUC: FARK VAR" -ForegroundColor Red }
