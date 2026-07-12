# ============================================================
# schema_port_all.ps1 — TUM MSSQL tablolarini PG'ye portlar (yapi; hata->atla)
# ------------------------------------------------------------
# Tek baglantida tum DDL uretir, tek psql ile uygular (ON_ERROR_STOP YOK -> hatali
# tabloyu atlar, digerine devam). Bir kerelik toplu port.
#   powershell -File pg\tools\schema_port_all.ps1
# ============================================================
param(
  [string]$MssqlServer = 'DESKTOP-HL3J3AS\SQLEXPRESS',
  [string]$MssqlDb   = 'BILIM',
  [string]$MssqlUser = 'sa',
  [string]$MssqlPass = 'FETAGEN',
  [string]$PgContainer = 'gentegre-pg',
  [string]$PgDb = 'gentegre',
  [string]$PgSchema = 'public',
  [string]$PgUser = 'postgres',
  [string]$PgPass = 'FETAGEN',
  [switch]$NoCollation
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
function LI([string]$s) { return $s.ToLowerInvariant() }
$coll = if ($NoCollation) { '' } else { ' COLLATE depo.tr_ci' }

function PgTip($tip,$maxlen,$prec,$scale){
  switch ($tip.ToLowerInvariant()) {
    'bit' {return 'boolean'} 'tinyint' {return 'smallint'} 'smallint' {return 'smallint'}
    'int' {return 'integer'} 'bigint' {return 'bigint'} 'real' {return 'real'}
    'float' {return 'double precision'} 'money' {return 'numeric(19,4)'} 'smallmoney' {return 'numeric(10,4)'}
    {$_ -in @('decimal','numeric')} {return "numeric($prec,$scale)"}
    'date' {return 'date'} 'time' {return "time($scale)"} 'datetime' {return 'timestamp(3)'}
    'smalldatetime' {return 'timestamp(0)'} 'datetime2' {return "timestamp($scale)"} 'datetimeoffset' {return "timestamptz($scale)"}
    'uniqueidentifier' {return 'uuid'} 'xml' {return 'xml'}
    {$_ -in @('char','nchar')} { $n=if($_ -eq 'nchar'){[int]($maxlen/2)}else{[int]$maxlen}; if($n -le 0){return 'text'}else{return "char($n)$coll"} }
    {$_ -in @('varchar','nvarchar')} { if($maxlen -eq -1){return "text$coll"}; $n=if($_ -eq 'nvarchar'){[int]($maxlen/2)}else{[int]$maxlen}; return "varchar($n)$coll" }
    {$_ -in @('text','ntext')} {return "text$coll"}
    {$_ -in @('binary','varbinary','image','timestamp','rowversion')} {return 'bytea'}
    default {return "text$coll"}
  }
}
function PgDefault($def,$pgtip){
  if([string]::IsNullOrWhiteSpace($def)){return ''}
  $d=$def.Trim(); while($d.StartsWith('(') -and $d.EndsWith(')')){$d=$d.Substring(1,$d.Length-2).Trim()}
  $dl=$d.ToLowerInvariant()
  if($dl -in @('getdate()','sysdatetime()','current_timestamp','getutcdate()','sysutcdatetime()')){return 'now()'}
  if($dl -eq 'newid()' -or $dl -eq 'newsequentialid()'){return 'gen_random_uuid()'}
  if($pgtip -eq 'boolean'){ if($d -eq '1'){return 'true'} elseif($d -eq '0'){return 'false'} }
  $n=[decimal]0; if([decimal]::TryParse($d,[System.Globalization.NumberStyles]::Any,[System.Globalization.CultureInfo]::InvariantCulture,[ref]$n)){return $d}
  if($d -match "^[Nn]?'.*'$"){ if($d.Substring(0,1) -in @('N','n')){return $d.Substring(1)}else{return $d} }
  return ''   # cevrilemeyen fonksiyon-default (ident_current/convert...) -> dus
}

$cn = New-Object System.Data.SqlClient.SqlConnection("Server=$MssqlServer;Database=$MssqlDb;User Id=$MssqlUser;Password=$MssqlPass;TrustServerCertificate=True;")
$cn.Open()
$c = $cn.CreateCommand()
$c.CommandText = "SELECT name FROM sys.tables WHERE schema_id=SCHEMA_ID('dbo') ORDER BY name"
$rd = $c.ExecuteReader(); $tables=@(); while($rd.Read()){$tables+=[string]$rd['name']}; $rd.Close()
Write-Host ("Toplam {0} tablo..." -f $tables.Count) -ForegroundColor Cyan

$all = New-Object System.Text.StringBuilder
foreach ($t in $tables) {
  $c.CommandText = @"
SELECT c.name, ty.name AS tip, c.max_length, c.precision, c.scale, c.is_nullable, c.is_identity, dc.definition AS dflt
FROM sys.columns c JOIN sys.types ty ON ty.user_type_id=c.user_type_id
LEFT JOIN sys.default_constraints dc ON dc.object_id=c.default_object_id
WHERE c.object_id=OBJECT_ID('dbo.$t') ORDER BY c.column_id
"@
  $rd=$c.ExecuteReader(); $cols=@()
  while($rd.Read()){ $cols+=[pscustomobject]@{Ad=$rd['name'];Tip=$rd['tip'];MaxLen=[int]$rd['max_length'];Prec=[int]$rd['precision'];Scale=[int]$rd['scale'];Nullable=[bool]$rd['is_nullable'];Identity=[bool]$rd['is_identity'];Dflt=$(if($rd['dflt'] -is [DBNull]){''}else{[string]$rd['dflt']})} }
  $rd.Close()
  if(-not $cols){continue}
  $c.CommandText = "SELECT col.name FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns col ON col.object_id=ic.object_id AND col.column_id=ic.column_id WHERE i.object_id=OBJECT_ID('dbo.$t') AND i.is_primary_key=1 ORDER BY ic.key_ordinal"
  $rd=$c.ExecuteReader(); $pk=@(); while($rd.Read()){$pk+=LI $rd['name']}; $rd.Close()
  $c.CommandText="SELECT name FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.$t') AND is_primary_key=1"
  $pkName=$c.ExecuteScalar(); if($pkName){$pkName=LI $pkName}else{$pkName='pk_'+(LI $t)}

  $tl=LI $t; $lines=@()
  foreach($col in $cols){
    $pgt=PgTip $col.Tip $col.MaxLen $col.Prec $col.Scale
    $ln="  "+('"'+(LI $col.Ad)+'"').PadRight(30)+" "+$pgt
    if($col.Identity){ if($pgt -in @('integer','bigint','smallint')){$ln+=" GENERATED BY DEFAULT AS IDENTITY"} }
    else { $dd=PgDefault $col.Dflt $pgt; if($dd -ne ''){$ln+=" DEFAULT $dd"} }
    if(-not $col.Nullable){$ln+=" NOT NULL"}
    $lines+=$ln
  }
  if($pk.Count -gt 0){$lines+="  CONSTRAINT ""$pkName"" PRIMARY KEY ("+(($pk|ForEach-Object{'"'+$_+'"'}) -join ', ')+")"}
  [void]$all.AppendLine("DROP TABLE IF EXISTS $PgSchema.$tl CASCADE;")
  [void]$all.AppendLine("CREATE TABLE $PgSchema.$tl (")
  [void]$all.AppendLine(($lines -join ",`n"))
  [void]$all.AppendLine(");")
}
$cn.Close()

$tmp=[System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tmp,$all.ToString(),(New-Object System.Text.UTF8Encoding($false)))
docker cp $tmp "${PgContainer}:/tmp/all_ddl.sql" | Out-Null
Write-Host "PG'de olusturuluyor (hatalar atlanir)..." -ForegroundColor Cyan
# ON_ERROR_STOP YOK -> hatali CREATE atlanir. Hatalari yakala:
$res = docker exec -e "PGPASSWORD=$PgPass" -e "PGCLIENTENCODING=UTF8" $PgContainer psql -U $PgUser -d $PgDb -f "/tmp/all_ddl.sql" 2>&1
Remove-Item $tmp -Force
$errs = $res | Select-String -Pattern 'ERROR'
Write-Host ("`n=== BITTI. PG'de tablo sayisi asagida. HATA satiri: {0} ===" -f $errs.Count) -ForegroundColor Green
if($errs){ Write-Host "-- Ilk 20 hata: --" -ForegroundColor Yellow; $errs | Select-Object -First 20 | ForEach-Object { Write-Host ("  "+$_.Line) } }
$cnt = docker exec -e "PGPASSWORD=$PgPass" $PgContainer psql -U $PgUser -d $PgDb -tAc "SELECT count(*) FROM information_schema.tables WHERE table_schema='$PgSchema' AND table_type='BASE TABLE'"
Write-Host ("PG public tablo sayisi: {0}" -f $cnt.Trim())
