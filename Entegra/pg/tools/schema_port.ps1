# ============================================================
# schema_port.ps1 — MSSQL tablo tanimini PostgreSQL CREATE TABLE'a cevirir
# ------------------------------------------------------------
# Tip eslemesi: int IDENTITY->identity, tinyint->smallint, bit->boolean,
#   varbinary/binary->bytea, nvarchar->varchar (byte/2), (n)varchar(max)->text,
#   datetime->timestamp, getdate()/newid() defaults->now()/gen_random_uuid(),
#   uniqueidentifier->uuid. String kolonlara Turkce CI collation (depo.tr_ci) — MSSQL
#   CI davranis paritesi. Kolon/tablo adlari KUCUK HARF (PG folds; app'in UPPERCASE
#   sorgulari otomatik eslesir). PK dahil.
# Kullanim:
#   powershell -File pg\tools\schema_port.ps1 -Table GENINI            # ekrana yaz
#   powershell -File pg\tools\schema_port.ps1 -Table GENINI -Apply     # PG'de olustur
# ============================================================
param(
  [Parameter(Mandatory=$true)][string]$Table,
  [switch]$Apply,                                  # verilirse PG'de CREATE eder
  [switch]$NoCollation,                            # verilirse tr_ci uygulamaz
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
$coll = if ($NoCollation) { '' } else { ' COLLATE depo.tr_ci' }

# MSSQL tipi -> PG tipi
function PgTip($tip, $maxlen, $prec, $scale) {
  $t = $tip.ToLowerInvariant()
  switch ($t) {
    'bit'              { return 'boolean' }
    'tinyint'          { return 'smallint' }
    'smallint'         { return 'smallint' }
    'int'              { return 'integer' }
    'bigint'           { return 'bigint' }
    'real'             { return 'real' }
    'float'            { return 'double precision' }
    'money'            { return 'numeric(19,4)' }
    'smallmoney'       { return 'numeric(10,4)' }
    { $_ -in @('decimal','numeric') } { return "numeric($prec,$scale)" }
    'date'             { return 'date' }
    'time'             { return "time($scale)" }
    'datetime'         { return 'timestamp(3)' }
    'smalldatetime'    { return 'timestamp(0)' }
    'datetime2'        { return "timestamp($scale)" }
    'datetimeoffset'   { return "timestamptz($scale)" }
    'uniqueidentifier' { return 'uuid' }
    'xml'              { return 'xml' }
    { $_ -in @('char','nchar') } {
      $n = if ($t -eq 'nchar') { [int]($maxlen/2) } else { [int]$maxlen }
      if ($n -le 0) { return 'text' } else { return "char($n)$coll" } }
    { $_ -in @('varchar','nvarchar') } {
      if ($maxlen -eq -1) { return "text$coll" }
      $n = if ($t -eq 'nvarchar') { [int]($maxlen/2) } else { [int]$maxlen }
      return "varchar($n)$coll" }
    { $_ -in @('text','ntext') } { return "text$coll" }
    { $_ -in @('binary','varbinary','image','timestamp','rowversion') } { return 'bytea' }
    default { return 'text' + $coll }   # bilinmeyen -> text (elle gozden gecir)
  }
}

# MSSQL default -> PG default
function PgDefault($def, $pgtip) {
  if ([string]::IsNullOrWhiteSpace($def)) { return '' }
  $d = $def.Trim()
  # dis parantezleri soy: ((1)) -> 1
  while ($d.StartsWith('(') -and $d.EndsWith(')')) { $d = $d.Substring(1, $d.Length-2).Trim() }
  $dl = $d.ToLowerInvariant()
  if ($dl -in @('getdate()','sysdatetime()','current_timestamp','getutcdate()','sysutcdatetime()')) { return 'now()' }
  if ($dl -eq 'newid()' -or $dl -eq 'newsequentialid()') { return 'gen_random_uuid()' }
  if ($pgtip -eq 'boolean') { if ($d -eq '1') { return 'true' } elseif ($d -eq '0') { return 'false' } }
  # sayi literali -> tut
  $n = [decimal]0
  if ([decimal]::TryParse($d, [System.Globalization.NumberStyles]::Any, $inv, [ref]$n)) { return $d }
  # tirnakli string literali ('xxx' veya N'xxx') -> tut (N soy)
  if ($d -match "^[Nn]?'.*'$") { if ($d.Substring(0,1) -in @('N','n')) { return $d.Substring(1) } else { return $d } }
  # baska her sey (ident_current, host_name, convert, user_name...) -> DUS
  #   (PG'de yok/uyumsuz; app degeri kodda yazar). Elle gerekirse sonra eklenir.
  return ''
}

# --- MSSQL kolonlari ---
$cn = New-Object System.Data.SqlClient.SqlConnection("Server=$MssqlServer;Database=$MssqlDb;User Id=$MssqlUser;Password=$MssqlPass;TrustServerCertificate=True;")
$cn.Open()
$q = @"
SELECT c.column_id, c.name, t.name AS tip, c.max_length, c.precision, c.scale,
       c.is_nullable, c.is_identity, dc.definition AS dflt
FROM sys.columns c
JOIN sys.types t ON t.user_type_id = c.user_type_id
LEFT JOIN sys.default_constraints dc ON dc.object_id = c.default_object_id
WHERE c.object_id = OBJECT_ID('dbo.$Table') ORDER BY c.column_id
"@
$cmd = $cn.CreateCommand(); $cmd.CommandText = $q; $rd = $cmd.ExecuteReader()
$cols = @()
while ($rd.Read()) {
  $cols += [pscustomobject]@{
    Ad=$rd['name']; Tip=$rd['tip']; MaxLen=[int]$rd['max_length']; Prec=[int]$rd['precision'];
    Scale=[int]$rd['scale']; Nullable=[bool]$rd['is_nullable']; Identity=[bool]$rd['is_identity'];
    Dflt=$(if ($rd['dflt'] -is [DBNull]) { '' } else { [string]$rd['dflt'] }) }
}
$rd.Close()
if (-not $cols) { Write-Host "HATA: MSSQL'de dbo.$Table yok." -ForegroundColor Red; $cn.Close(); return }

# --- PK ---
$cmd.CommandText = @"
SELECT col.name FROM sys.indexes i
JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id
JOIN sys.columns col ON col.object_id=ic.object_id AND col.column_id=ic.column_id
WHERE i.object_id=OBJECT_ID('dbo.$Table') AND i.is_primary_key=1 ORDER BY ic.key_ordinal
"@
$rd = $cmd.ExecuteReader(); $pk = @(); while ($rd.Read()) { $pk += LI $rd['name'] }; $rd.Close()
$cn.Close()

# --- PG DDL uret ---
$tl = LI $Table
$lines = @()
foreach ($c in $cols) {
  $pgt = PgTip $c.Tip $c.MaxLen $c.Prec $c.Scale
  # Kolon adi cift-tirnakli (kucuk harf) -> PG rezerve kelime (left/limit/order...) sorun olmaz;
  #   app'in tirnaksiz UPPERCASE sorgulari PG folding ile ayni kucuk-harf ada eslesir.
  $line = "  " + ('"' + (LI $c.Ad) + '"').PadRight(30) + " " + $pgt
  if ($c.Identity) {
    if ($pgt -eq 'integer' -or $pgt -eq 'bigint' -or $pgt -eq 'smallint') { $line += " GENERATED BY DEFAULT AS IDENTITY" }
  } else {
    $dd = PgDefault $c.Dflt $pgt
    if ($dd -ne '') { $line += " DEFAULT $dd" }
  }
  if (-not $c.Nullable) { $line += " NOT NULL" }
  $lines += $line
}
if ($pk.Count -gt 0) { $lines += "  CONSTRAINT pk_$tl PRIMARY KEY (" + (($pk | ForEach-Object { '"' + $_ + '"' }) -join ', ') + ")" }

$ddl = "-- $MssqlDb.dbo.$Table -> $PgSchema.$tl`n"
$ddl += "DROP TABLE IF EXISTS $PgSchema.$tl CASCADE;`n"
$ddl += "CREATE TABLE $PgSchema.$tl (`n" + ($lines -join ",`n") + "`n);`n"

Write-Host $ddl -ForegroundColor Gray

if ($Apply) {
  $tmp = [System.IO.Path]::GetTempFileName()
  [System.IO.File]::WriteAllText($tmp, $ddl, (New-Object System.Text.UTF8Encoding($false)))
  docker cp $tmp "${PgContainer}:/tmp/ddl_$tl.sql" | Out-Null
  docker exec -e "PGPASSWORD=$PgPass" -e "PGCLIENTENCODING=UTF8" $PgContainer psql -U $PgUser -d $PgDb -v ON_ERROR_STOP=1 -f "/tmp/ddl_$tl.sql"
  Remove-Item $tmp -Force
  Write-Host "-> $PgSchema.$tl PG'de olusturuldu." -ForegroundColor Green
}
