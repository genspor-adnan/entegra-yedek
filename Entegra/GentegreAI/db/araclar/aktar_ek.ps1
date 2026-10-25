# ============================================================================
#  Gentegre AI - Delphi EK MODULLERININ bir kerelik aktarimi (1143..1149)
#
#  Cekirdek ERP (cari/stok/belge/kasa) ajanla surekli aktarilir. Bu betik Delphi
#  KAPANIRKEN bir kez calisir ve geri kalanlari tasir: kullanicilar + personel +
#  ilgili kisiler, gorevler + aktiviteler + yorumlar, dokumanlar + ekler (IMAJ) +
#  e-Belge gecmisi (GENDEPO), cek/senet, teklif, hesap plani, demirbas,
#  stok kategorileri (KATEGORI, 1171 - ayni kimlikle; kurulum tohumu silinir), GENINI kod
#  listeleri (1180 - fn_aktar_kod_listesi; eklemeli), cari kisi bolum / gorev listeleri (1182).
#
#  1) goc_al.ps1 ile MSSQL -> stg (Delphi DB ve depo DB'si)
#  2) IMAJ icerigi: BELGE ZLib ise acilir (Delphi KutugeYaz); ICDIS=1 ise dosya
#     <DokumanKlasoru>\yyyy-mm\<000ID>.OBJ'den okunur (sp_Imaj_Okuma ile ayni yol).
#     Bulunamayan icerik stg.imaj.kaynak_yok = 1 (rapor edilir, dokuman kartsiz kalmaz).
#  3) public.fn_aktar_ek() - sirali, idempotent; sonuc JSON ekrana.
#
#  Kullanim (cekirdek aktarim bittikten SONRA):
#    powershell -ExecutionPolicy Bypass -File db\araclar\aktar_ek.ps1 -Db FETA `
#        -MssqlDb FETA -DepoDb FETA_GENDEPO -DokumanKlasoru D:\GenDokuman\
#
#  NOT: Saf ASCII + UTF-8 BOM (Windows PowerShell 5.1).
# ============================================================================
param(
  [string]$Db             = "",              # hedef PG veritabani (zorunlu)
  [string]$MssqlDb        = "",              # Delphi MSSQL veritabani (zorunlu)
  [string]$DepoDb        = "",              # bos = <MssqlDb>_GENDEPO
  [string]$DokumanKlasoru = "",             # bos = Delphi GENINI -10006
  [string]$Kap           = "gentegre-pg18",
  [string]$Kul           = "postgres",
  [string]$Parola        = "FETAGEN",
  [string]$MssqlServer   = "DESKTOP-HL3J3AS\SQLEXPRESS",
  [string]$MssqlUser     = "sa",
  [string]$MssqlPass     = "FETAGEN",
  [switch]$IcerikAtla                       # IMAJ icerigini okuma (yalniz kartlar)
)
$ErrorActionPreference = "Stop"
if ($Db -eq "" -or $MssqlDb -eq "") { throw "-Db ve -MssqlDb zorunlu" }
$dbDizin = Split-Path -Parent $PSScriptRoot
if ($DepoDb -eq "") { $DepoDb = $MssqlDb + "_GENDEPO" }

function Adim([string]$m) { Write-Host ""; Write-Host ("=== " + $m) -ForegroundColor Cyan }
function GocAl([string]$mdb, [string[]]$tablolar) {
  # -File ile dizi parametresi tek dize gider: tablo basina bir cagri.
  foreach ($tb in $tablolar) {
    & powershell -ExecutionPolicy Bypass -File (Join-Path $dbDizin "goc_al.ps1") `
        -Kap $Kap -Db $Db -Sema "stg" -Kul $Kul -Parola $Parola `
        -MssqlServer $MssqlServer -MssqlDb $mdb -MssqlUser $MssqlUser -MssqlPass $MssqlPass `
        -Tablolar $tb | Where-Object { $_ -match 'satir|ATLANDI|HATA' }
    if ($LASTEXITCODE -ne 0) { throw ("goc_al basarisiz: " + $mdb + "." + $tb) }
  }
}
function Psql([string]$sql) {
  $o = & docker exec $Kap psql -U $Kul -d $Db -v ON_ERROR_STOP=1 -Atc $sql
  if ($LASTEXITCODE -ne 0) { throw ("psql: " + $sql) }
  return $o
}

Adim ("Delphi tablolari: " + $MssqlDb)
GocAl $MssqlDb @("KATEGORI","KULLANICI","ROLLER","REHBERPERSONEL","PERSONELIZIN","PERS_HAREKET",
                 "GOREVLER","GOREVKULLANICI","GOREVYORUM","AKTIVITELER","AKTIVITENOTLAR","ANIMSAT",
                 "DOKUMAN","DOKUMANKLASOR","CEKLER","CEKHAREKET","TEKLIF","TEKLIFDETAY",
                 "HESAPPLANI","DEMIRBAS","GENINI")

Adim ("Depo tablolari: " + $DepoDb)
GocAl $DepoDb @("EBELGE","EBELGEMESAJ")

# ------------------------------------------------------------------ IMAJ ----
Adim "IMAJ (ekler) + icerik"
$cn = New-Object System.Data.SqlClient.SqlConnection(
  "Server=$MssqlServer;Database=$MssqlDb;User Id=$MssqlUser;Password=$MssqlPass;TrustServerCertificate=True")
$cn.Open()
if ($DokumanKlasoru -eq "") {
  $c = $cn.CreateCommand(); $c.CommandText = "SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM = -10006"
  $DokumanKlasoru = [string]$c.ExecuteScalar()
}
Write-Host ("  dokuman klasoru: " + $DokumanKlasoru)

function Hex([byte[]]$b) { if ($null -eq $b) { return "" } return '"\x' + ([System.BitConverter]::ToString($b).Replace('-', '')) + '"' }
function Metin([object]$v) {
  if ($null -eq $v -or $v -is [DBNull]) { return "" }
  if ($v -is [bool]) { if ($v) { return "1" } else { return "0" } }
  if ($v -is [datetime]) { return $v.ToString('yyyy-MM-dd HH:mm:ss') }
  if ($v -is [decimal]) { return ([string]$v).Replace(',', '.') }
  $s = [string]$v
  if ($s.Contains('"') -or $s.Contains(',') -or $s.Contains("`n") -or $s.Contains("`r")) { return '"' + $s.Replace('"', '""') + '"' }
  return $s
}
# Delphi KutugeYaz: zlib (78 xx, (b0*256+b1) % 31 = 0). Resimler ham.
function ZlibAc([byte[]]$b) {
  if ($null -eq $b -or $b.Length -lt 3) { return ,$b }
  if ($b[0] -ne 0x78 -or ((([int]$b[0]) * 256 + [int]$b[1]) % 31) -ne 0) { return ,$b }
  try {
    $uzunluk = $b.Length - 2
    $giris = [System.IO.MemoryStream]::new($b, 2, $uzunluk)
    $ds = New-Object System.IO.Compression.DeflateStream($giris, [System.IO.Compression.CompressionMode]::Decompress)
    $cikis = New-Object System.IO.MemoryStream
    $ds.CopyTo($cikis); $ds.Close()
    return ,$cikis.ToArray()
  } catch { return ,$b }
}

$cmd = $cn.CreateCommand()
$cmd.CommandText = @"
SELECT ID, VARSAYILAN, REHBERID, ICDIS, YERI, YER_ID, DURUM, BELGENO, SURUM, TUR, BELGEADI, ACIKLAMA,
       EKLEYEN, EKLEMETARIHI, SUBEID, BELGETURU, BOYUT, $(if ($IcerikAtla) { 'NULL' } else { 'BELGE' }) AS BELGE
  FROM dbo.IMAJ
"@
$cmd.CommandTimeout = 0
$csv = Join-Path ([System.IO.Path]::GetTempPath()) "goc_imaj.csv"
$sw = New-Object System.IO.StreamWriter($csv, $false, (New-Object System.Text.UTF8Encoding $false))
$rd = $cmd.ExecuteReader()
$n = 0; $disk = 0; $yok = 0; $acilan = 0
while ($rd.Read()) {
  $alan = @()
  for ($i = 0; $i -lt 17; $i++) { $alan += (Metin $rd.GetValue($i)) }
  $icerik = $null
  if (-not $IcerikAtla) {
    if (-not $rd.IsDBNull(17)) { $icerik = [byte[]]$rd.GetValue(17) }
    $icdis = (-not $rd.IsDBNull(3)) -and [bool]$rd.GetValue(3)
    if ($null -eq $icerik -and $icdis -and -not $rd.IsDBNull(13)) {
      $t = [datetime]$rd.GetValue(13)
      $yol = Join-Path (Join-Path $DokumanKlasoru $t.ToString('yyyy-MM')) (('{0:D6}' -f [int]$rd.GetValue(0)) + '.OBJ')
      if (Test-Path -LiteralPath $yol) { $icerik = [System.IO.File]::ReadAllBytes($yol); $disk++ }
    }
    if ($null -ne $icerik) {
      $acik = ZlibAc $icerik
      if ($acik.Length -ne $icerik.Length) { $acilan++ }
      $icerik = $acik
    }
  }
  $kaynakYok = "0"
  if ($null -eq $icerik) { $kaynakYok = "1"; $yok++ }
  $sw.WriteLine((($alan + @((Hex $icerik), $kaynakYok)) -join ','))
  $n++
}
$rd.Close(); $sw.Close(); $cn.Close()
& docker cp $csv ($Kap + ":/tmp/goc_imaj.csv") | Out-Null
Psql ("truncate stg.imaj; copy stg.imaj (id, varsayilan, rehberid, icdis, yeri, yer_id, durum, belgeno, surum, tur, " +
      "belgeadi, aciklama, ekleyen, eklemetarihi, subeid, belgeturu, boyut, icerik, kaynak_yok) " +
      "from '/tmp/goc_imaj.csv' with (format csv, null '');") | Out-Null
Remove-Item $csv -Force
Write-Host ("  " + $n + " ek; diskten " + $disk + ", zlib acilan " + $acilan + ", icerigi BULUNAMAYAN " + $yok) -ForegroundColor $(if ($yok -gt 0) { 'Yellow' } else { 'Green' })

Adim "public.fn_aktar_ek()"
$sonuc = Psql "select jsonb_pretty(public.fn_aktar_ek())"
$sonuc | ForEach-Object { Write-Host $_ }

# KOD LISTELERI (1180): GENINI cok satirli bolumleri -> kod_liste / kod_deger (cari kategori / sektor /
#   sinif / bolge / ilk temas, stok marka / grup ...). Eklemeli: var olan liste ve degerlere dokunmaz.
Adim "public.fn_aktar_kod_listesi()"
Psql "select public.fn_aktar_kod_listesi()" | ForEach-Object { Write-Host $_ }
# KISI BOLUM / GOREV (1182): GENINI -2206/-2251 -> departman, -2205 -> personel_gorev (ada gore eklemeli).
Adim "public.fn_aktar_kisi_listeleri()"
Psql "select public.fn_aktar_kisi_listeleri()" | ForEach-Object { Write-Host $_ }
Write-Host ""
Write-Host "Bitti." -ForegroundColor Green
