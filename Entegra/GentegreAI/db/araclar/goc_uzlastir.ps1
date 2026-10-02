# ============================================================================
#  Gentegre AI — GOC DEFTERI UZLASTIRMA RAPORU  (SALT OKUNUR)
#
#  SORUN (denetim 28.09.2026 #8): `goc_gecmisi` defteri gercek sema gecmisini
#  temsil etmiyor. Diskteki dosyalarin bir kismi defterde yok ama etkileri
#  veritabaninda gorunuyor (elle uygulanmis); bir kismi gercekten hic
#  uygulanmamis olabilir. "Defterde yok = eksik" de, "nesne var = uygulandi"
#  de YANLIS sonuc verir: bir fonksiyonun varligi dosyanin TAMAMININ
#  uygulandigini kanitlamaz (ayni dosyadaki veri duzeltmesi calismamis
#  olabilir).
#
#  NE YAPAR: her NNN_*.sql dosyasinin OLUSTURDUGU nesneleri (tablo, kolon,
#  fonksiyon, view, indeks, tetik, tip, sekans) metinden cikarir, sonradan
#  silinen/yeniden adlandirilanlari ayiklar ve veritabani katalogunda arar.
#  Her dosya bir SINIFA duser:
#
#    DEFTERDE        defterde kayitli. Ozet (sha256) yoksa icerik DOGRULANMAMIS
#                    (tarihsel kayit - bugun hesaplanan ozet gecmisi kanitlamaz).
#    DEFTER_DEGISMIS defterde ozetiyle kayitli ama dosya o gunden beri DEGISMIS.
#    ETKI_VAR        defterde yok; cikarilan nesnelerin HEPSI var. Uygulanmis
#                    OLABILIR - kanit degil, uzlastirma adayi.
#    ETKI_KISMI      defterde yok; nesnelerin bir kismi var. Yarim uygulanmis ya
#                    da sonradan degismis - ELLE incelenmeli.
#    EKSIK           defterde yok; cikarilan nesnelerin HICBIRI yok. Uygulanmamis
#                    oldugu kanitli (en azindan DDL kismi).
#    BELIRSIZ        defterde yok ve metinden nesne cikarilamadi (yalniz veri,
#                    yetki, yorum...). Etkisi katalogdan olculemez.
#
#  VERITABANINA YAZMAZ: oturum `default_transaction_read_only = on` ile acilir.
#  Defteri DOLDURMAZ, dosya CALISTIRMAZ. Paylasilan veritabanina uygulanacak
#  her uzlastirma ayri, gozden gecirilmis ve yedekli bir plandir.
#
#  Kullanim:
#    powershell -ExecutionPolicy Bypass -File db\araclar\goc_uzlastir.ps1 `
#        [-Db gentegre_ai] [-Cikti rapor.md] [-PgHost sunucu]
# ============================================================================
param(
  [string]$Kap    = "gentegre-pg18",
  [string]$Db     = "gentegre_ai",
  [string]$PgHost = "",
  [int]$PgPort    = 5432,
  [string]$Kul    = "postgres",
  [string]$Parola = "FETAGEN",
  [string]$Cikti  = ""
)
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$DbDizin = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Definition)

function Sorgu([string]$Sql) {
  # SALT OKUNUR OTURUM: her komut read-only islemde calisir; yazma denemesi
  #   hata verir (bu betik yazmaz - bu bir emniyet kemeri).
  $ortam = @("-e", ("PGPASSWORD=" + $Parola), "-e", "PGOPTIONS=-c default_transaction_read_only=on")
  if ($PgHost -eq "") {
    $r = ($Sql | & docker exec -i @ortam $Kap psql -U $Kul -d $Db -tA -v ON_ERROR_STOP=1)
  } else {
    $r = ($Sql | & docker run --rm -i @ortam postgres:18 psql -h $PgHost -p $PgPort -U $Kul -d $Db -tA -v ON_ERROR_STOP=1)
  }
  if ($LASTEXITCODE -ne 0) { throw ("sorgu basarisiz: " + $Sql.Substring(0, [Math]::Min(80, $Sql.Length))) }
  return @($r | Where-Object { $_ -ne "" })
}

function Ozet([string]$Yol) {
  # Satir sonu normalize: ayni icerik Windows'ta CRLF, sunucuda LF durabilir.
  $metin = [System.IO.File]::ReadAllText($Yol).Replace("`r`n", "`n")
  $sha = [System.Security.Cryptography.SHA256]::Create()
  $b = $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($metin))
  return ([BitConverter]::ToString($b) -replace "-", "").ToLowerInvariant()
}

function Temizle([string]$Metin) {
  # Yorumlar nesne sanilmasin: /* */ bloklari ve -- satir sonlari atilir.
  $m = [regex]::Replace($Metin, '/\*[\s\S]*?\*/', ' ')
  $m = [regex]::Replace($m, '--[^\n]*', ' ')
  return $m.ToLowerInvariant()
}

function Nitele([string]$Ad) { if ($Ad.Contains(".")) { return $Ad } else { return "public." + $Ad } }

# ---------------------------------------------------------------- katalog ---
Write-Host ("==> katalog okunuyor: " + $Db) -ForegroundColor Cyan
$ilisk = @{}
foreach ($s in (Sorgu @"
select n.nspname || '.' || c.relname || '|' || c.relkind::text
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
 where n.nspname not in ('pg_catalog', 'information_schema', 'pg_toast')
"@)) { $p = $s.Split("|"); $ilisk[$p[0]] = $p[1] }
$fonk = @{}; foreach ($s in (Sorgu @"
select distinct n.nspname || '.' || p.proname from pg_proc p join pg_namespace n on n.oid = p.pronamespace
 where n.nspname not in ('pg_catalog', 'information_schema')
"@)) { $fonk[$s] = 1 }
$tetik = @{}; foreach ($s in (Sorgu "select distinct tgname from pg_trigger where not tgisinternal")) { $tetik[$s] = 1 }
$kolon = @{}; foreach ($s in (Sorgu @"
select table_schema || '.' || table_name || '.' || column_name from information_schema.columns
 where table_schema not in ('pg_catalog', 'information_schema')
"@)) { $kolon[$s] = 1 }
$tip = @{}; foreach ($s in (Sorgu @"
select n.nspname || '.' || t.typname from pg_type t join pg_namespace n on n.oid = t.typnamespace
 where t.typtype in ('e', 'c', 'd') and n.nspname not in ('pg_catalog', 'information_schema')
"@)) { $tip[$s] = 1 }

$defter = @{}
$defterVar = (Sorgu "select count(*) from information_schema.tables where table_schema = 'public' and table_name = 'goc_gecmisi'")[0] -eq "1"
if ($defterVar) {
  $ozetKolonu = (Sorgu "select count(*) from information_schema.columns where table_name = 'goc_gecmisi' and column_name = 'ozet'")[0] -eq "1"
  $sql = if ($ozetKolonu) { "select dosya || '|' || coalesce(ozet, '') || '|' || coalesce(yontem, '') from public.goc_gecmisi" }
         else { "select dosya || '||' from public.goc_gecmisi" }
  foreach ($s in (Sorgu $sql)) { $p = $s.Split("|"); $defter[$p[0]] = @{ Ozet = $p[1]; Yontem = $p[2] } }
}

# ---------------------------------------------------------------- dosyalar ---
$dosyalar = @(Get-ChildItem $DbDizin -Filter "*.sql" | Where-Object { $_.Name -match '^\d{3}_' } | Sort-Object Name)
$metinler = @{}
foreach ($d in $dosyalar) { $metinler[$d.Name] = Temizle ([System.IO.File]::ReadAllText($d.FullName)) }

$Olustur = @(
  @{ Tur = "tablo";    R = [regex]'create\s+(?:unlogged\s+)?table\s+(?:if\s+not\s+exists\s+)?((?:\w+\.)?\w+)' },
  @{ Tur = "view";     R = [regex]'create\s+(?:or\s+replace\s+)?(?:materialized\s+)?view\s+(?:if\s+not\s+exists\s+)?((?:\w+\.)?\w+)' },
  @{ Tur = "fonk";     R = [regex]'create\s+(?:or\s+replace\s+)?(?:function|procedure)\s+((?:\w+\.)?\w+)' },
  @{ Tur = "indeks";   R = [regex]'create\s+(?:unique\s+)?index\s+(?:concurrently\s+)?(?:if\s+not\s+exists\s+)?(\w+)\s+on' },
  @{ Tur = "tetik";    R = [regex]'create\s+(?:or\s+replace\s+)?(?:constraint\s+)?trigger\s+(\w+)' },
  @{ Tur = "tip";      R = [regex]'create\s+(?:type|domain)\s+((?:\w+\.)?\w+)' },
  @{ Tur = "sekans";   R = [regex]'create\s+sequence\s+(?:if\s+not\s+exists\s+)?((?:\w+\.)?\w+)' }
)
# Tablo adindan sonra BOSLUK sart: dinamik SQL'deki `public.%I` "public" diye
#   okunmasin (format() ile uretilen ALTER'lar metinden cozulemez).
$KolonEkle = [regex]'alter\s+table\s+(?:only\s+)?(?:if\s+exists\s+)?((?:\w+\.)?\w+)(?=\s)([^;]*)'
$AddColumn = [regex]'add\s+column\s+(?:if\s+not\s+exists\s+)?(\w+)'
$Sil = [regex]'drop\s+(table|view|materialized\s+view|function|procedure|index|trigger|type|domain|sequence)\s+(?:if\s+exists\s+)?((?:\w+\.)?\w+)'
$KolonSil = [regex]'alter\s+table\s+(?:only\s+)?(?:if\s+exists\s+)?((?:\w+\.)?\w+)(?=\s)\s+(?:drop\s+column\s+(?:if\s+exists\s+)?(\w+)|rename\s+(?:column\s+)?(\w+)\s+to|rename\s+to)'

# Sonradan silinen / yeniden adlandirilan nesneler: "dosya numarasi" -> kume.
#   Bir nesne, KENDISINDEN SONRAKI bir dosyada silindiyse kanit sayilmaz.
$silinme = @{}   # anahtar -> en yuksek dosya adi
# AYNI dosyada, OLUSTURMADAN SONRA silinen/adlandirilan (or. `x_yeni` kurulup
#   `x` adini alir): dosya -> (anahtar -> son konum). Once-sil-sonra-kur
#   deseni (drop if exists f; create f) bu yuzden ELENMEZ.
$icSilinme = @{}
function SilKaydet([string]$Anahtar, [string]$Dosya, [int]$Konum) {
  if (-not $silinme.ContainsKey($Anahtar) -or $silinme[$Anahtar] -lt $Dosya) { $silinme[$Anahtar] = $Dosya }
  if (-not $icSilinme.ContainsKey($Dosya)) { $icSilinme[$Dosya] = @{} }
  if (-not $icSilinme[$Dosya].ContainsKey($Anahtar) -or $icSilinme[$Dosya][$Anahtar] -lt $Konum) {
    $icSilinme[$Dosya][$Anahtar] = $Konum
  }
}
foreach ($d in $dosyalar) {
  $m = $metinler[$d.Name]
  foreach ($x in $Sil.Matches($m)) {
    $t = $x.Groups[1].Value -replace '\s+', ' '
    $tur = switch -regex ($t) { 'table' { "tablo" } 'view' { "view" } 'function|procedure' { "fonk" }
                                'index' { "indeks" } 'trigger' { "tetik" } 'type|domain' { "tip" } default { "sekans" } }
    $ad = $x.Groups[2].Value
    if ($tur -in @("tablo", "view", "fonk", "tip", "sekans")) { $ad = Nitele $ad }
    SilKaydet ($tur + ":" + $ad) $d.Name $x.Index
  }
  foreach ($x in $KolonSil.Matches($m)) {
    $tablo = Nitele $x.Groups[1].Value
    if ($x.Groups[2].Success) { SilKaydet ("kolon:" + $tablo + "." + $x.Groups[2].Value) $d.Name $x.Index }
    elseif ($x.Groups[3].Success) { SilKaydet ("kolon:" + $tablo + "." + $x.Groups[3].Value) $d.Name $x.Index }
    else { SilKaydet ("tablo:" + $tablo) $d.Name $x.Index }
  }
}

function VarMi([string]$Tur, [string]$Ad) {
  switch ($Tur) {
    "tablo"  { return $ilisk.ContainsKey($Ad) -and "rpf".Contains($ilisk[$Ad]) }
    "view"   { return $ilisk.ContainsKey($Ad) -and "vm".Contains($ilisk[$Ad]) }
    "fonk"   { return $fonk.ContainsKey($Ad) }
    "indeks" { return @($ilisk.Keys | Where-Object { $_.EndsWith("." + $Ad) -and $ilisk[$_] -eq "i" }).Count -gt 0 }
    "tetik"  { return $tetik.ContainsKey($Ad) }
    "tip"    { return $tip.ContainsKey($Ad) }
    "sekans" { return $ilisk.ContainsKey($Ad) -and $ilisk[$Ad] -eq "S" }
    "kolon"  { return $kolon.ContainsKey($Ad) }
  }
  return $false
}

# ---------------------------------------------------------------- siniflama ---
$sonuc = New-Object System.Collections.Generic.List[object]
foreach ($d in $dosyalar) {
  $ad = $d.Name
  $ozet = Ozet $d.FullName
  if ($defter.ContainsKey($ad)) {
    $k = $defter[$ad]
    $sinif = if ($k.Ozet -eq "") { "DEFTERDE" } elseif ($k.Ozet -ne $ozet) { "DEFTER_DEGISMIS" } else { "DEFTERDE" }
    $not = if ($k.Ozet -eq "") { "icerik dogrulanmamis (tarihsel kayit)" } elseif ($sinif -eq "DEFTER_DEGISMIS") { "dosya uygulandiktan SONRA degismis" } else { "ozet eslesiyor (" + $k.Yontem + ")" }
    $sonuc.Add([pscustomobject]@{ Dosya = $ad; Sinif = $sinif; Var = 0; Toplam = 0; Eksikler = ""; Not = $not; Ozet = $ozet })
    continue
  }

  $m = $metinler[$ad]
  $ic = if ($icSilinme.ContainsKey($ad)) { $icSilinme[$ad] } else { @{} }
  $nesneler = New-Object System.Collections.Generic.List[string]
  function Ekle([string]$Anahtar, [int]$Konum) {
    # Ayni dosyada olusturmadan SONRA silindi/adlandirildi: kanit degil.
    if ($ic.ContainsKey($Anahtar) -and $ic[$Anahtar] -gt $Konum) { return }
    $nesneler.Add($Anahtar)
  }
  foreach ($o in $Olustur) {
    foreach ($x in $o.R.Matches($m)) {
      $n = $x.Groups[1].Value
      if ($o.Tur -in @("tablo", "view", "fonk", "tip", "sekans")) { $n = Nitele $n }
      Ekle ($o.Tur + ":" + $n) $x.Index
    }
  }
  foreach ($x in $KolonEkle.Matches($m)) {
    $tablo = Nitele $x.Groups[1].Value
    foreach ($c in $AddColumn.Matches($x.Groups[2].Value)) { Ekle ("kolon:" + $tablo + "." + $c.Groups[1].Value) $x.Index }
  }
  # stg (MSSQL kaynak kopyasi) ve pg_temp nesneleri kanit sayilmaz.
  $kanit = @($nesneler | Select-Object -Unique | Where-Object {
      $_ -notmatch ':(stg|pg_temp)\.' -and
      -not ($silinme.ContainsKey($_) -and $silinme[$_] -gt $ad) })

  if ($kanit.Count -eq 0) {
    $sonuc.Add([pscustomobject]@{ Dosya = $ad; Sinif = "BELIRSIZ"; Var = 0; Toplam = 0; Eksikler = ""; Not = "metinden nesne cikarilamadi"; Ozet = $ozet })
    continue
  }
  $eksik = @($kanit | Where-Object { $p = $_.Split(":", 2); -not (VarMi $p[0] $p[1]) })
  $var = $kanit.Count - $eksik.Count
  $sinif = if ($eksik.Count -eq 0) { "ETKI_VAR" } elseif ($var -eq 0) { "EKSIK" } else { "ETKI_KISMI" }
  $sonuc.Add([pscustomobject]@{ Dosya = $ad; Sinif = $sinif; Var = $var; Toplam = $kanit.Count
      Eksikler = (($eksik | Select-Object -First 6) -join ", ") + $(if ($eksik.Count -gt 6) { " …" } else { "" })
      Not = ""; Ozet = $ozet })
}

$dosyaAdlari = @{}; foreach ($d in $dosyalar) { $dosyaAdlari[$d.Name] = 1 }
# 'tohum' satiri bos kurulum ISARETIDIR (db/kurulum), goc dosyasi degil.
$yetim = @($defter.Keys | Where-Object { -not $dosyaAdlari.ContainsKey($_) -and $defter[$_].Yontem -ne "tohum" } | Sort-Object)

# ---------------------------------------------------------------- rapor ---
$L = New-Object System.Collections.Generic.List[string]
$L.Add("# Goc defteri uzlastirma raporu - $Db")
$L.Add("")
$L.Add("Uretildi: $(Get-Date -Format 'dd.MM.yyyy HH:mm') · ``db/araclar/goc_uzlastir.ps1`` (SALT OKUNUR - veritabanina yazmaz).")
$L.Add("")
$L.Add("Siniflar KANIT DERECESIDIR, uygulama hukmu degildir: ``ETKI_VAR`` dosyanin")
$L.Add("olusturdugu nesnelerin katalogda bulundugunu soyler; dosyadaki veri")
$L.Add("adimlarinin calistigini KANITLAMAZ.")
$L.Add("")
$L.Add("| Sinif | Dosya |")
$L.Add("|---|---:|")
foreach ($g in ($sonuc | Group-Object Sinif | Sort-Object Name)) { $L.Add("| $($g.Name) | $($g.Count) |") }
$L.Add("| **Diskte** | **$($dosyalar.Count)** |")
$L.Add("| Defterde kayit | $($defter.Count) |")
$L.Add("| Defterde olup diskte OLMAYAN | $($yetim.Count) |")
$L.Add("")
foreach ($sinif in @("EKSIK", "ETKI_KISMI", "DEFTER_DEGISMIS", "BELIRSIZ", "ETKI_VAR")) {
  $grup = @($sonuc | Where-Object { $_.Sinif -eq $sinif })
  if ($grup.Count -eq 0) { continue }
  $L.Add("## $sinif ($($grup.Count))")
  $L.Add("")
  $L.Add("| Dosya | Nesne (var/toplam) | Bulunamayan | Not |")
  $L.Add("|---|---:|---|---|")
  foreach ($r in $grup) { $L.Add("| ``$($r.Dosya)`` | $($r.Var)/$($r.Toplam) | $($r.Eksikler) | $($r.Not) |") }
  $L.Add("")
}
if ($yetim.Count -gt 0) {
  $L.Add("## Defterde olup diskte olmayan ($($yetim.Count))")
  $L.Add("")
  foreach ($y in $yetim) { $L.Add("- ``$y``") }
  $L.Add("")
}

$metin = $L -join "`n"
if ($Cikti -ne "") {
  [System.IO.File]::WriteAllText($Cikti, $metin, (New-Object System.Text.UTF8Encoding $false))
  Write-Host ("rapor: " + $Cikti) -ForegroundColor Green
} else { $metin }

Write-Host ""
foreach ($g in ($sonuc | Group-Object Sinif | Sort-Object Name)) { Write-Host ("  {0,-16} {1,4}" -f $g.Name, $g.Count) }
Write-Host ("  diskte {0} · defterde {1} · yetim defter kaydi {2}" -f $dosyalar.Count, $defter.Count, $yetim.Count)
