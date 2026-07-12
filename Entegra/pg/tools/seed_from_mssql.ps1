# ============================================================
# seed_from_mssql.ps1 — bir tablonun verisini MSSQL'den PG'ye kopyalar
# ------------------------------------------------------------
# "Ayni veri" test durumu kurmak icin: PG tablosunu bosaltir, MSSQL satirlarini
# ayni ID'lerle PG'ye insert eder.
# NOT: MSSQL kolon adi CASE-SENSITIVE (ID<>id) -> gercek adlar kullanilir;
#   Turkce I icin ToLowerInvariant.
#   powershell -File pg\tools\seed_from_mssql.ps1 -Table DEPOLAR
# ============================================================
param(
  [Parameter(Mandatory=$true)][string]$Table,
  [string]$Where = '',                  # opsiyonel MSSQL WHERE filtresi (kolon adlari MSSQL case)
  [switch]$Append,                      # verilirse TRUNCATE etmez (uzerine ekler)
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
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$inv = [System.Globalization.CultureInfo]::InvariantCulture
function LI([string]$s) { return $s.ToLowerInvariant() }
$tblLower = LI $Table

function PgLit([object]$v) {
  if ($null -eq $v -or $v -is [DBNull]) { return 'NULL' }
  if ($v -is [bool])     { if ($v) { return '1' } else { return '0' } }   # bit->smallint (PG'de 0/1)
  if ($v -is [byte[]])   { return "decode('" + ([System.BitConverter]::ToString($v).Replace('-','')) + "','hex')" }  # varbinary->bytea
  if ($v -is [datetime]) { return "'" + $v.ToString('yyyy-MM-dd HH:mm:ss') + "'" }
  if ($v -is [int] -or $v -is [long] -or $v -is [decimal] -or $v -is [double] -or $v -is [single] -or $v -is [byte] -or $v -is [int16]) {
    return ([string]$v).Replace(',', '.')
  }
  return "'" + ([string]$v).Replace("'", "''") + "'"
}

# PG hedef kolonlari (kucuk harf)
$pgColsRaw = docker exec -e "PGPASSWORD=$PgPass" $PgContainer psql -U $PgUser -d $PgDb -tAc `
  "SELECT string_agg(column_name, ',' ORDER BY ordinal_position) FROM information_schema.columns WHERE table_schema='$PgSchema' AND table_name='$tblLower'"
$pgCols = @($pgColsRaw.Trim().Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
if (-not $pgCols) { Write-Host "HATA: PG'de $PgSchema.$tblLower yok." -ForegroundColor Red; return }

# MSSQL gercek kolon adlari
$cn = New-Object System.Data.SqlClient.SqlConnection("Server=$MssqlServer;Database=$MssqlDb;User Id=$MssqlUser;Password=$MssqlPass;TrustServerCertificate=True;")
$cn.Open()
$cmap = @{}; $c = $cn.CreateCommand(); $c.CommandText = "SELECT name FROM sys.columns WHERE object_id=OBJECT_ID('dbo.$Table')"; $r = $c.ExecuteReader()
while ($r.Read()) { $n = $r.GetString(0); $cmap[(LI $n)] = $n }; $r.Close()

# Iki motorda da olan kolonlar (PG sirasi)
$cols = @($pgCols | Where-Object { $cmap.ContainsKey($_) })
$colList = ($cols -join ', ')
$msSelect = ($cols | ForEach-Object { "[$($cmap[$_])]" }) -join ', '

# MSSQL satirlarini oku -> PG literal
$whereClause = if ($Where -ne '') { " WHERE $Where" } else { "" }
$cmd = $cn.CreateCommand(); $cmd.CommandText = "SELECT $msSelect FROM dbo.$Table$whereClause"; $rd = $cmd.ExecuteReader()
$values = @()
while ($rd.Read()) {
  $vals = for ($i=0; $i -lt $rd.FieldCount; $i++) { PgLit $rd.GetValue($i) }
  $values += '(' + ($vals -join ', ') + ')'
}
$rd.Close(); $cn.Close()
if (-not $values) { Write-Host "MSSQL $Table bos." -ForegroundColor Yellow; return }

# PG: bosalt + insert (ayni ID) + sequence resetle
$sql  = if ($Append) { "" } else { "TRUNCATE $PgSchema.$tblLower RESTART IDENTITY CASCADE;`n" }
$sql += "INSERT INTO $PgSchema.$tblLower ($colList) VALUES`n" + ($values -join ",`n") + ";`n"
if ($cols -contains 'id') {
  $sql += "SELECT setval(pg_get_serial_sequence('$PgSchema.$tblLower','id'), COALESCE((SELECT MAX(id) FROM $PgSchema.$tblLower),1));`n"
}
# UTF-8 dosya + docker cp + psql -f  (PowerShell->psql PIPE'i Turkce karakteri bozuyor -> dosya kullan)
$tmp = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tmp, $sql, (New-Object System.Text.UTF8Encoding($false)))
docker cp $tmp "${PgContainer}:/tmp/seed_$tblLower.sql" | Out-Null
docker exec -e "PGPASSWORD=$PgPass" -e "PGCLIENTENCODING=UTF8" $PgContainer psql -U $PgUser -d $PgDb -v ON_ERROR_STOP=1 -f "/tmp/seed_$tblLower.sql" | Out-Null
Remove-Item $tmp -Force
Write-Host ("$Table -> PG: {0} satir yuklendi (UTF-8)." -f $values.Count) -ForegroundColor Green
