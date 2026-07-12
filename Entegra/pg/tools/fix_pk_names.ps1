# ============================================================
# fix_pk_names.ps1 — PG PK constraint/index adlarini MSSQL PK adlarina esitler
# ------------------------------------------------------------
# Sorun: schema_port PK'lari 'pk_<tablo>' diye adlandirdi; ama app'in TFDTable'lari
#   IndexName='PK_BANKALAR_1' (MSSQL PK adi) bekliyor -> FireDAC PG'de bulamiyor.
# PG'de PK constraint adi = alttaki index adi -> RENAME CONSTRAINT ikisini de degistirir.
# Adlar KUCUK HARF (FireDAC PG'de index adini kuculterek arar). Veri KORUNUR (sadece rename).
#   powershell -File pg\tools\fix_pk_names.ps1
# ============================================================
param(
  [string]$MssqlServer = 'DESKTOP-HL3J3AS\SQLEXPRESS',
  [string]$MssqlDb = 'BILIM',
  [string]$MssqlUser = 'sa',
  [string]$MssqlPass = 'FETAGEN',
  [string]$PgContainer = 'gentegre-pg',
  [string]$PgDb = 'gentegre',
  [string]$PgSchema = 'public',
  [string]$PgUser = 'postgres',
  [string]$PgPass = 'FETAGEN'
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
function LI([string]$s){ return $s.ToLowerInvariant() }

# MSSQL: tablo -> PK adi
$cn = New-Object System.Data.SqlClient.SqlConnection("Server=$MssqlServer;Database=$MssqlDb;User Id=$MssqlUser;Password=$MssqlPass;TrustServerCertificate=True;")
$cn.Open(); $c=$cn.CreateCommand()
$c.CommandText = "SELECT t.name AS tbl, i.name AS pk FROM sys.tables t JOIN sys.indexes i ON i.object_id=t.object_id WHERE t.schema_id=SCHEMA_ID('dbo') AND i.is_primary_key=1"
$rd=$c.ExecuteReader(); $pairs=@()
while($rd.Read()){ $pairs += [pscustomobject]@{ Tbl=LI $rd['tbl']; Pk=LI $rd['pk'] } }
$rd.Close(); $cn.Close()

$sb = New-Object System.Text.StringBuilder
foreach($p in $pairs){
  $eski = "pk_$($p.Tbl)"          # schema_port'un koydugu
  $yeni = $p.Pk                    # MSSQL PK adi (kucuk)
  if($eski -eq $yeni){ continue }
  # Constraint varsa ismini degistir (yoksa hata -> DO block ile yut)
  [void]$sb.AppendLine("DO `$`$ BEGIN IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname='$eski' AND conrelid='$PgSchema.`"$($p.Tbl)`"'::regclass) THEN ALTER TABLE $PgSchema.`"$($p.Tbl)`" RENAME CONSTRAINT `"$eski`" TO `"$yeni`"; END IF; EXCEPTION WHEN others THEN RAISE NOTICE '% : %', '$($p.Tbl)', SQLERRM; END `$`$;")
}
$tmp=[System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tmp,$sb.ToString(),(New-Object System.Text.UTF8Encoding($false)))
docker cp $tmp "${PgContainer}:/tmp/fix_pk.sql" | Out-Null
$res = docker exec -e "PGPASSWORD=$PgPass" $PgContainer psql -U $PgUser -d $PgDb -f "/tmp/fix_pk.sql" 2>&1
Remove-Item $tmp -Force
Write-Host ("Islenen tablo: {0}" -f $pairs.Count) -ForegroundColor Green
$errs = $res | Select-String -Pattern 'ERROR|NOTICE.*:'
if($errs){ Write-Host "-- notlar/hatalar (ilk 15): --" -ForegroundColor Yellow; $errs | Select-Object -First 15 | ForEach-Object { Write-Host ("  "+$_.Line) } }
