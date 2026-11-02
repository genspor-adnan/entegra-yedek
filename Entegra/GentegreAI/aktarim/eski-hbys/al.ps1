# ============================================================================
#  ESKİ HBYS (GEN3000, MSSQL) -> PostgreSQL `eski` şeması  (1. aşama: ham kopya)
#
#  Kaynak tabloları HİÇ YORUMLAMADAN hedef DB'nin `eski` şemasına kopyalar; tablolar MSSQL kolon
#  tiplerinden otomatik kurulur (stg gibi önceden tanımlı şema gerekmez). Eşleme / yorum 2. aşamada
#  (esle.sql) ve bilgi alanında (eski.tanim) durur - böylece ham veri, aktarım kuralı değişse de
#  yeniden çekilmeden tekrar işlenebilir.
#
#  KAPSAM ("bu yılın verisi"): çapa = başvuru (GELISLER) yılı. O yılın başvuruları + bağlı hasta, hizmet
#  satırı, tahsilat, fatura, rapor; tanım tabloları (hizmet, fiyat, kurum, hekim, bölüm) tamamen.
#
#  RAPOR (OLE): RAPORBILGI_ZIP = zlib (78 9C) sıkıştırılmış içerik. KOSUYOLU'da: "BDOC" + 8 bayt başlık +
#  OLE bileşik dosya (D0 CF 11 E0) = OLE "Package" nesnesi; Package akışının İÇİ bir .docx (ZIP). Metin
#  .docx'in word/document.xml'inden doğrudan okunur (Word gerekmez). Paket .docx değilse Word (COM) ile
#  açılır; RTF RichTextBox ile. `rapor_bicim`: docx | doc | rtf | metin. Asıl dosya istenirse rapor_kaynak.
#  Ham ikili (RAPORBILGI, RAPORBILGI_ZIP) ve hasta resmi (KIMLIK.RESIM) KOPYALANMAZ.
#
#  Kullanım:
#    powershell -ExecutionPolicy Bypass -File aktarim\eski-hbys\al.ps1 -MssqlDb KOSUYOLU -PgDb KOSUYOLU -Yil 2026
#    ... -Tablolar OLE            (yalnız bir tablo)
#  Kişisel veri ekrana YAZILMAZ; yalnız sayılar.
#  NOT: Saf ASCII olmayan yorumlar UTF-8 BOM ile; PowerShell 5.1.
# ============================================================================
param(
  [string]$MssqlServer = "DESKTOP-HL3J3AS\SQLEXPRESS",
  [string]$MssqlDb     = "KOSUYOLU",
  [string]$MssqlUser   = "sa",
  [string]$MssqlPass   = "FETAGEN",
  [string]$Kap         = "gentegre-pg18",
  [string]$PgDb        = "KOSUYOLU",
  [string]$PgKul       = "postgres",
  [string]$PgParola    = "FETAGEN",
  [string]$Sema        = "eski",
  [int]$Yil            = 2026,
  [string[]]$Tablolar  = @(),
  # Yalnız bu rapor (OLE.ID) kayıtları - örnek seçmek için; -Devam ile mevcutların yanına eklenir.
  [string[]]$RaporId   = @(),
  # BELLEK (31.10.2026: tek seferde 4.105 rapor makinenin belleğini bitirdi): raporlar parti parti işlenir,
  #   her parti hemen PG'ye yazılır ve Word yeniden açılır.
  [int]$RaporParti     = 250,
  # Asıl Word .doc dosyası da `rapor_kaynak`'a yazılsın mı (varsayılan HAYIR - MSSQL'de duruyor, gerekirse
  #   yeniden çekilir; yazılırsa CSV / bellek ~4 kat büyür).
  [switch]$RaporKaynakSakla,
  # Raporlarda yarıda kalınan yerden devam: tablo silinmez, eski.ole'de olan ID'ler atlanır.
  [switch]$Devam,
  # Örnek: yalnız en yeni N rapor (0 = hepsi).
  [int]$RaporLimit     = 0
)
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Windows.Forms

function Adim($m) { Write-Host ("==> " + $m) -ForegroundColor Cyan }
function Iyi($m)  { Write-Host ("    " + $m) -ForegroundColor Green }

# ------------------------------------------------------------------ kapsam --
$bas = "'" + $Yil + "0101'"; $son = "'" + ($Yil + 1) + "0101'"
$gelisKosul = "GIRISTARIH >= $bas AND GIRISTARIH < $son"
$gelisIdler = "(SELECT ID FROM dbo.GELISLER WHERE $gelisKosul)"
$KAPSAM = [ordered]@{
  # tanımlar (tamamı)
  "SUBELER"    = ""
  "POLIKLNK"   = ""
  "DOKTOR"     = ""
  "KURUM"      = ""
  "KURUMFIYAT" = ""
  "ISLEMLER"   = ""
  "FIYATLAR"   = ""
  # yılın hareketleri (çapa: başvuru)
  "GELISLER"   = " WHERE $gelisKosul"
  "KIMLIK"     = " WHERE ID IN (SELECT KIMLIKID FROM dbo.GELISLER WHERE $gelisKosul)"
  "DOKTORLAR"  = " WHERE ID IN (SELECT GONDOKTORID FROM dbo.GELISLER WHERE $gelisKosul) OR ID IN (SELECT DOKTORID FROM dbo.GELISLER WHERE $gelisKosul)"
  "PARA"       = " WHERE GELISID IN $gelisIdler"
  "TAHSILAT"   = " WHERE GELISID IN $gelisIdler"
  "FATBASLIK"  = " WHERE GELISID IN $gelisIdler"
  "FATURA"     = " WHERE FATBASID IN (SELECT ID FROM dbo.FATBASLIK WHERE GELISID IN $gelisIdler)"
  "OLE"        = " WHERE GELISID IN $gelisIdler"
  # Rapor şablonları (tamamı): Word belgesi, OLE ile aynı kap (zlib'siz).
  "HAZOLE"     = ""
}
# RAPOR İÇERİKLİ TABLOLAR: Word kabı açılıp metin + biçimli HTML kolonlarına yazılır (ham kopyaya girmez).
#   Sıra önemli: önce zlib'li kolon (ZlibAc), yoksa ham kolon.
$RAPORLU = @{
  "OLE"    = @("RAPORBILGI_ZIP", "RAPORBILGI")
  "HAZOLE" = @("RAPORBILGI")
}
# KOPYALANMAYAN KOLONLAR: ikili (resim, ham rapor) ve SIRLAR - eski sistem şifreleri düz metin tutuyor
#   (SUBELER: Medula / İTS / SN / Claimer / laboratuvar; DOKTOR: e-reçete şifresi, PIN). Ham kopyaya girmez;
#   yeni sistemde hesaplar Ayarlar › Entegrasyon'dan yeniden (şifreli) girilir.
$KOPYALANMAZ = @{
  "KIMLIK"  = @("RESIM")
  "OLE"     = @("RAPORBILGI", "RAPORBILGI_ZIP")
  "HAZOLE"  = @("RAPORBILGI")
  "SUBELER" = @("MEDULASIFRE", "ITSSIFRE", "SN2SIFRE", "SNSIFRE", "DUZENLABSIFRE", "CLAIMERSIFRE", "UTSTOKEN")
  "DOKTOR"  = @("ERECETESIFRE", "PIN")
}
# Kolon adında şifre geçen her kolon da (yukarıdaki listeyi unutmaya karşı) atlanır.
$SIR_DESENI = '(?i)(SIFRE|PAROLA|PASSWORD|TOKEN|^PIN$)'
if ($Tablolar.Count -eq 0) { $Tablolar = @($KAPSAM.Keys) }

# ---------------------------------------------------------------------- PG --
function PgKomut([string]$Sql) {
  $tmp = [System.IO.Path]::GetTempFileName()
  [System.IO.File]::WriteAllText($tmp, $Sql, (New-Object System.Text.UTF8Encoding $false))
  & docker cp $tmp ($Kap + ":/tmp/_eski_komut.sql") | Out-Null
  $cikti = & docker exec -e ("PGPASSWORD=" + $PgParola) -e "PGCLIENTENCODING=UTF8" $Kap `
             psql -U $PgKul -d $PgDb -tA -v ON_ERROR_STOP=1 -f /tmp/_eski_komut.sql
  $kod = $LASTEXITCODE
  Remove-Item $tmp -Force
  if ($kod -ne 0) { throw ("psql hatasi (" + $kod + "): " + $Sql.Substring(0, [Math]::Min(160, $Sql.Length))) }
  return $cikti
}

function PgTip([string]$t, [int]$uzunluk, [int]$hassas, [int]$olcek) {
  switch ($t) {
    { $_ -in "varchar", "nvarchar", "char", "nchar", "text", "ntext", "sysname" } { return "text" }
    { $_ -in "int" }                       { return "integer" }
    { $_ -in "bigint" }                    { return "bigint" }
    { $_ -in "smallint", "tinyint" }       { return "smallint" }
    { $_ -in "bit" }                       { return "smallint" }       # mantik = smallint (proje kuralı)
    { $_ -in "money", "smallmoney" }       { return "numeric(19,4)" }
    { $_ -in "decimal", "numeric" }        { return "numeric($hassas,$olcek)" }
    { $_ -in "float", "real" }             { return "double precision" }
    { $_ -in "datetime", "smalldatetime", "datetime2" } { return "timestamp" }
    { $_ -in "date" }                      { return "date" }
    { $_ -in "uniqueidentifier" }          { return "uuid" }
    { $_ -in "image", "varbinary", "binary" } { return "bytea" }
    default                                { return "text" }
  }
}

function CsvAlan([object]$v) {
  if ($null -eq $v -or $v -is [DBNull]) { return "" }
  if ($v -is [bool])     { if ($v) { return "1" } else { return "0" } }
  if ($v -is [byte[]])   { return '"\x' + ([System.BitConverter]::ToString($v).Replace('-', '')) + '"' }
  if ($v -is [datetime]) {
    # 1899 / 2108 gibi bozuk Delphi tarihleri PG timestamp aralığında; olduğu gibi kalır (eşleme ayıklar).
    return $v.ToString('yyyy-MM-dd HH:mm:ss.fff', [System.Globalization.CultureInfo]::InvariantCulture)
  }
  if ($v -is [decimal] -and [Math]::Abs($v) -ge 922337203685477) { return "" }
  if ($v -is [decimal] -or $v -is [double] -or $v -is [single]) {
    return ([string]::Format([System.Globalization.CultureInfo]::InvariantCulture, "{0}", $v))
  }
  if ($v -is [guid]) { return $v.ToString() }
  if ($v -is [int] -or $v -is [long] -or $v -is [byte] -or $v -is [int16]) { return [string]$v }
  $s = ([string]$v).Replace([string][char]0, '')
  if ($s.Contains('"') -or $s.Contains(',') -or $s.Contains("`n") -or $s.Contains("`r")) {
    return '"' + $s.Replace('"', '""') + '"'
  }
  return $s
}

# ------------------------------------------------------- rapor (zlib + RTF) --
$rtb = New-Object System.Windows.Forms.RichTextBox
$word = $null
$geciciDoc = Join-Path ([System.IO.Path]::GetTempPath()) ("eski_rapor_" + [guid]::NewGuid().ToString("N") + ".doc")
function WordMetin([byte[]]$doc) {
  if ($null -eq $script:word) {
    $script:word = New-Object -ComObject Word.Application
    $script:word.Visible = $false
    $script:word.DisplayAlerts = 0
  }
  [System.IO.File]::WriteAllBytes($script:geciciDoc, $doc)
  $d = $script:word.Documents.Open($script:geciciDoc, $false, $true, $false)   # ConfirmConversions, ReadOnly, AddToRecent
  try { return ([string]$d.Content.Text).Replace("`r`n", "`n").Replace("`r", "`n").Replace([string][char]7, " ").Replace([string][char]11, "`n").Trim() }
  finally { $d.Close(0) }
}
Add-Type -AssemblyName System.IO.Compression
# OLE bileşik dosyasından adı verilen akışı okur (yalnız normal FAT; 4 KB altı mini akış -> $null).
function CfbAkis([byte[]]$d, [string]$ad) {
  $ss = [int][Math]::Pow(2, [BitConverter]::ToUInt16($d, 30))
  $miniSinir = [BitConverter]::ToUInt32($d, 56)
  $nfat = [BitConverter]::ToUInt32($d, 44)
  $fat = New-Object System.Collections.Generic.List[uint32]
  for ($i = 0; $i -lt [Math]::Min($nfat, 109); $i++) {
    $s = [BitConverter]::ToUInt32($d, 76 + 4 * $i); $off = 512 + $s * $ss
    for ($j = 0; $j -lt $ss; $j += 4) { $fat.Add([BitConverter]::ToUInt32($d, $off + $j)) }
  }
  $zincir = { param([uint32]$bas, [int]$boy)
    $ms = New-Object System.IO.MemoryStream; $sec = $bas
    # 0xFFFFFFF0 PS 5.1'de Int32 (-16) okunur: zincir sonu işaretsiz sabitle karşılaştırılır.
    while ($sec -lt [uint32]4294967280 -and $ms.Length -lt $boy) { $ms.Write($d, 512 + $sec * $ss, $ss); $sec = $fat[[int]$sec] }
    $b = $ms.ToArray(); if ($b.Length -gt $boy) { $c = New-Object byte[] $boy; [Array]::Copy($b, $c, $boy); return ,$c } return ,$b }
  $dizin = & $zincir ([BitConverter]::ToUInt32($d, 48)) ([int]::MaxValue)
  for ($k = 0; $k + 128 -le $dizin.Length; $k += 128) {
    $nl = [BitConverter]::ToUInt16($dizin, $k + 64)
    if ($nl -lt 2) { continue }
    $n = [System.Text.Encoding]::Unicode.GetString($dizin, $k, $nl - 2)
    if ($n -eq $ad) {
      $boy = [int][BitConverter]::ToUInt32($dizin, $k + 120)
      if ($boy -lt $miniSinir) { return $null }
      return (& $zincir ([BitConverter]::ToUInt32($dizin, $k + 116)) $boy)
    }
  }
  return $null
}
# .docx (ZIP) -> düz metin: paragraf = satır, tablo hücreleri sekmeyle.
function DocxMetin([byte[]]$zip) {
  $ms = New-Object System.IO.MemoryStream(, $zip)
  $za = New-Object System.IO.Compression.ZipArchive($ms, [System.IO.Compression.ZipArchiveMode]::Read)
  try {
    $g = $za.GetEntry("word/document.xml"); if ($null -eq $g) { return $null }
    $sr = New-Object System.IO.StreamReader($g.Open(), [System.Text.Encoding]::UTF8); $xml = $sr.ReadToEnd(); $sr.Close()
  } finally { $za.Dispose() }
  $x = New-Object System.Xml.XmlDocument; $x.LoadXml($xml)
  $ns = New-Object System.Xml.XmlNamespaceManager($x.NameTable)
  $ns.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
  $satirlar = New-Object System.Collections.Generic.List[string]
  foreach ($p in $x.SelectNodes("//w:body//w:p", $ns)) {
    $sb2 = New-Object System.Text.StringBuilder
    foreach ($r in $p.SelectNodes(".//w:t | .//w:tab | .//w:br", $ns)) {
      switch ($r.LocalName) { "t" { [void]$sb2.Append($r.InnerText) } "tab" { [void]$sb2.Append("`t") } "br" { [void]$sb2.Append("`n") } }
    }
    $satirlar.Add($sb2.ToString().TrimEnd())
  }
  # Ardışık boş satırlar teke iner.
  return ((($satirlar -join "`n") -replace "`n{3,}", "`n`n").Trim())
}
# .docx -> BİÇİMLİ HTML (radyoloji_rapor_bolum.metin_html). Yalnız sunucunun beyaz listesindeki biçim
#   (Servisler/RaporHtml.cs): p, b, i, u, br, table/tr/td (colspan/rowspan), img (yalnız gömülü data:)
#   + style font-size / color / text-align / font-family / width / border / padding / vertical-align.
#   Resimler data URI olarak gömülür; EMF / WMF / BMP / TIFF tarayıcıda açılmadığı için PNG'ye çevrilir.
Add-Type -AssemblyName System.Drawing
$script:DocxResim = @{}
$script:ResimSayac = @{ gomulu = 0; atlanan = 0 }
function DocxAc([byte[]]$zip) {
  # Dönüş: @(document.xml XmlDocument, rId -> data URI)
  $ms = New-Object System.IO.MemoryStream(, $zip)
  $za = New-Object System.IO.Compression.ZipArchive($ms, [System.IO.Compression.ZipArchiveMode]::Read)
  $resim = @{}
  try {
    $g = $za.GetEntry("word/document.xml"); if ($null -eq $g) { return @($null, $resim) }
    $sr = New-Object System.IO.StreamReader($g.Open(), [System.Text.Encoding]::UTF8); $xml = $sr.ReadToEnd(); $sr.Close()
    $rg = $za.GetEntry("word/_rels/document.xml.rels")
    if ($null -ne $rg) {
      $sr = New-Object System.IO.StreamReader($rg.Open(), [System.Text.Encoding]::UTF8); $rx = [xml]$sr.ReadToEnd(); $sr.Close()
      foreach ($rel in $rx.DocumentElement.ChildNodes) {
        if ($rel.GetAttribute("Type") -notlike "*/image") { continue }
        if ($rel.GetAttribute("TargetMode") -eq "External") { continue }
        $hedef = $rel.GetAttribute("Target") -replace '^/', ''
        if ($hedef -notlike "word/*") { $hedef = "word/" + $hedef }
        $e = $za.GetEntry($hedef); if ($null -eq $e) { continue }
        $m2 = New-Object System.IO.MemoryStream; $st = $e.Open(); $st.CopyTo($m2); $st.Close()
        $b = $m2.ToArray()
        $uz = [System.IO.Path]::GetExtension($hedef).ToLowerInvariant()
        $mime = switch ($uz) { ".png" { "png" } ".jpg" { "jpeg" } ".jpeg" { "jpeg" } ".gif" { "gif" } default { $null } }
        if ($null -eq $mime) {
          # EMF / WMF / BMP / TIFF -> PNG
          try {
            $img = [System.Drawing.Image]::FromStream((New-Object System.IO.MemoryStream(, $b)))
            $bmp = New-Object System.Drawing.Bitmap($img.Width, $img.Height)
            $gr = [System.Drawing.Graphics]::FromImage($bmp); $gr.Clear([System.Drawing.Color]::White); $gr.DrawImage($img, 0, 0, $img.Width, $img.Height); $gr.Dispose()
            $m3 = New-Object System.IO.MemoryStream; $bmp.Save($m3, [System.Drawing.Imaging.ImageFormat]::Png)
            $b = $m3.ToArray(); $mime = "png"; $bmp.Dispose(); $img.Dispose()
          } catch { continue }
        }
        $resim[$rel.GetAttribute("Id")] = "data:image/" + $mime + ";base64," + [Convert]::ToBase64String($b)
      }
    }
  } finally { $za.Dispose() }
  $x = New-Object System.Xml.XmlDocument; $x.LoadXml($xml)
  return @($x, $resim)
}
function HtmlKod([string]$t) { return [System.Net.WebUtility]::HtmlEncode($t) }
function ResimHtml($n, $ns) {
  # w:drawing (a:blip r:embed, boyut wp:extent EMU) ya da w:pict / w:object (v:imagedata r:id, boyut v:shape style pt)
  $id = $null; $gen = 0; $yuk = 0
  $blip = $n.SelectSingleNode(".//a:blip", $ns)
  if ($null -ne $blip) {
    $id = $blip.GetAttribute("embed", $ns.LookupNamespace("r"))
    $ext = $n.SelectSingleNode(".//wp:extent", $ns)
    if ($null -ne $ext) { $gen = [int]([long]$ext.GetAttribute("cx") / 9525); $yuk = [int]([long]$ext.GetAttribute("cy") / 9525) }
  } else {
    $im = $n.SelectSingleNode(".//v:imagedata", $ns)
    if ($null -ne $im) {
      $id = $im.GetAttribute("id", $ns.LookupNamespace("r"))
      $sh = $im.ParentNode
      if ($null -ne $sh -and $sh.Attributes["style"]) {
        $st = $sh.GetAttribute("style")
        if ($st -match 'width:\s*([0-9.]+)pt') { $gen = [int]([double]$Matches[1] * 96 / 72) }
        if ($st -match 'height:\s*([0-9.]+)pt') { $yuk = [int]([double]$Matches[1] * 96 / 72) }
      }
    }
  }
  if (-not $id -or -not $script:DocxResim.ContainsKey($id)) { $script:ResimSayac.atlanan++; return "" }
  $script:ResimSayac.gomulu++
  $boy = ""
  if ($gen -gt 0 -and $gen -le 4000) { $boy += ' width="' + $gen + '"' }
  if ($yuk -gt 0 -and $yuk -le 4000) { $boy += ' height="' + $yuk + '"' }
  return '<img src="' + $script:DocxResim[$id] + '"' + $boy + '>'
}
function RunHtml($r, $ns) {
  $sb = New-Object System.Text.StringBuilder
  $resimler = New-Object System.Text.StringBuilder
  foreach ($c in $r.ChildNodes) {
    switch ($c.LocalName) {
      "t"       { [void]$sb.Append((HtmlKod $c.InnerText)) }
      "tab"     { [void]$sb.Append("&emsp;") }
      "br"      { [void]$sb.Append("<br>") }
      "drawing" { [void]$resimler.Append((ResimHtml $c $ns)) }
      "pict"    { [void]$resimler.Append((ResimHtml $c $ns)) }
      "object"  { [void]$resimler.Append((ResimHtml $c $ns)) }
    }
  }
  $ic = $sb.ToString()
  if ($ic -ne "") {
    $pr = $r.SelectSingleNode("w:rPr", $ns)
    if ($null -ne $pr) {
      $stil = New-Object System.Collections.Generic.List[string]
      $sz = $pr.SelectSingleNode("w:sz", $ns)
      if ($null -ne $sz) { $v = 0; if ([int]::TryParse($sz.GetAttribute("val", $ns.LookupNamespace("w")), [ref]$v) -and $v -gt 0) { $stil.Add("font-size: " + ($v / 2) + "pt") } }
      $cl = $pr.SelectSingleNode("w:color", $ns)
      if ($null -ne $cl) { $v = $cl.GetAttribute("val", $ns.LookupNamespace("w")); if ($v -match '^[0-9A-Fa-f]{6}$' -and $v -ne '000000') { $stil.Add("color: #" + $v.ToLowerInvariant()) } }
      $fn = $pr.SelectSingleNode("w:rFonts", $ns)
      if ($null -ne $fn) { $v = $fn.GetAttribute("ascii", $ns.LookupNamespace("w")); if ($v -match "^[A-Za-z0-9 \-]{2,40}$") { $stil.Add("font-family: " + $v) } }
      if ($stil.Count -gt 0) { $ic = '<span style="' + ($stil -join '; ') + '">' + $ic + '</span>' }
      $acik = { param($ad) $n = $pr.SelectSingleNode("w:" + $ad, $ns); if ($null -eq $n) { return $false }
                $v = $n.GetAttribute("val", $ns.LookupNamespace("w")); return -not ($v -in @("0", "false", "none")) }
      if (& $acik "u") { $ic = "<u>" + $ic + "</u>" }
      if (& $acik "i") { $ic = "<i>" + $ic + "</i>" }
      if (& $acik "b") { $ic = "<b>" + $ic + "</b>" }
    }
  }
  return $resimler.ToString() + $ic
}
function ParagrafIc($p, $ns) {
  $sb = New-Object System.Text.StringBuilder
  foreach ($r in $p.SelectNodes("w:r | w:hyperlink/w:r | w:ins/w:r | w:smartTag/w:r", $ns)) { [void]$sb.Append((RunHtml $r $ns)) }
  return $sb.ToString()
}
function ParagrafHiza($p, $ns) {
  $jc = $p.SelectSingleNode("w:pPr/w:jc", $ns)
  if ($null -eq $jc) { return "" }
  switch ($jc.GetAttribute("val", $ns.LookupNamespace("w"))) { "center" { return "center" } "right" { return "right" } "end" { return "right" } "both" { return "justify" } }
  return ""
}
function ParagrafHtml($p, $ns) {
  $ic = ParagrafIc $p $ns
  $hiz = ParagrafHiza $p $ns
  if ($ic -eq "") { $ic = "<br>" }
  if ($hiz) { return '<p style="text-align: ' + $hiz + '">' + $ic + '</p>' } else { return "<p>" + $ic + "</p>" }
}
function KenarliMi($tbl, $ns) {
  $w = $ns.LookupNamespace("w")
  foreach ($k in $tbl.SelectNodes("w:tblPr/w:tblBorders/*", $ns)) { if ($k.GetAttribute("val", $w) -notin @("none", "nil", "")) { return $true } }
  $st = $tbl.SelectSingleNode("w:tblPr/w:tblStyle", $ns)
  return ($null -ne $st -and $st.GetAttribute("val", $w) -match '(?i)grid|klavuz|kılavuz')
}
function TabloHtml($tbl, $ns) {
  $w = $ns.LookupNamespace("w")
  $kenar = KenarliMi $tbl $ns
  # Hücre haritası: satır -> (sütun, tc, yayılım, dikey birleşme)
  $satirlar = @()
  foreach ($tr in $tbl.SelectNodes("w:tr", $ns)) {
    $kol = 0; $hs = @()
    foreach ($tc in $tr.SelectNodes("w:tc", $ns)) {
      $yay = 1; $gs = $tc.SelectSingleNode("w:tcPr/w:gridSpan", $ns)
      if ($null -ne $gs) { [void][int]::TryParse($gs.GetAttribute("val", $w), [ref]$yay); if ($yay -lt 1) { $yay = 1 } }
      $vm = $tc.SelectSingleNode("w:tcPr/w:vMerge", $ns); $dik = ""
      if ($null -ne $vm) { $dik = if ($vm.GetAttribute("val", $w) -eq "restart") { "bas" } else { "devam" } }
      $hs += ,@($kol, $tc, $yay, $dik); $kol += $yay
    }
    $satirlar += ,$hs
  }
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append('<table style="border-collapse: collapse; width: 100%"><tbody>')
  for ($i = 0; $i -lt $satirlar.Count; $i++) {
    [void]$sb.Append("<tr>")
    foreach ($h in $satirlar[$i]) {
      $kol = $h[0]; $tc = $h[1]; $yay = $h[2]; $dik = $h[3]
      if ($dik -eq "devam") { continue }
      $rs = 1
      if ($dik -eq "bas") {
        for ($j = $i + 1; $j -lt $satirlar.Count; $j++) {
          $alt = @($satirlar[$j] | Where-Object { $_[0] -eq $kol })
          if ($alt.Count -gt 0 -and $alt[0][3] -eq "devam") { $rs++ } else { break }
        }
      }
      $ic = New-Object System.Collections.Generic.List[string]; $hiz = ""
      foreach ($el in $tc.ChildNodes) {
        if ($el.LocalName -eq "p") { $ic.Add((ParagrafIc $el $ns)); if (-not $hiz) { $hiz = ParagrafHiza $el $ns } }
        elseif ($el.LocalName -eq "tbl") { $ic.Add((TabloHtml $el $ns)) }
      }
      $stil = New-Object System.Collections.Generic.List[string]
      if ($kenar) { $stil.Add("border: 1px solid #000") }
      $stil.Add("padding: 2px 4px"); $stil.Add("vertical-align: top")
      if ($hiz) { $stil.Add("text-align: " + $hiz) }
      $tw = $tc.SelectSingleNode("w:tcPr/w:tcW", $ns)
      if ($null -ne $tw -and $tw.GetAttribute("type", $w) -eq "dxa") { $v = 0; if ([int]::TryParse($tw.GetAttribute("w", $w), [ref]$v) -and $v -gt 0) { $stil.Add("width: " + [int]($v / 15) + "px") } }
      $oz = ""
      if ($yay -gt 1) { $oz += ' colspan="' + $yay + '"' }
      if ($rs -gt 1) { $oz += ' rowspan="' + $rs + '"' }
      [void]$sb.Append("<td" + $oz + ' style="' + ($stil -join "; ") + '">' + (($ic | Where-Object { $_ -ne "" }) -join "<br>") + "</td>")
    }
    [void]$sb.Append("</tr>")
  }
  [void]$sb.Append("</tbody></table>")
  return $sb.ToString()
}
function DocxHtml([byte[]]$zip) {
  $acilan = DocxAc $zip; $x = $acilan[0]; if ($null -eq $x) { return $null }
  $script:DocxResim = $acilan[1]
  $ns = New-Object System.Xml.XmlNamespaceManager($x.NameTable)
  $ns.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
  $ns.AddNamespace("a", "http://schemas.openxmlformats.org/drawingml/2006/main")
  $ns.AddNamespace("wp", "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing")
  $ns.AddNamespace("r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships")
  $ns.AddNamespace("v", "urn:schemas-microsoft-com:vml")
  $govde = $x.SelectSingleNode("//w:body", $ns)
  $sb = New-Object System.Text.StringBuilder
  foreach ($el in $govde.ChildNodes) {
    if ($el.LocalName -eq "p") { [void]$sb.Append((ParagrafHtml $el $ns)) }
    elseif ($el.LocalName -eq "tbl") { [void]$sb.Append((TabloHtml $el $ns)) }
  }
  $script:DocxResim = @{}
  # Sondaki boş paragraflar atılır.
  return ($sb.ToString() -replace '(<p><br></p>)+$', '')
}
function IcerikCoz([byte[]]$ham) {
  # Dönüş: @(bicim, kaynak_bayt, metin)
  if ($null -eq $ham -or $ham.Length -lt 8) { return @($null, $null, $null) }
  $bas = [System.Text.Encoding]::ASCII.GetString($ham, 0, 4)
  for ($i = 0; $i -lt [Math]::Min(64, $ham.Length - 4); $i++) {
    if ($ham[$i] -eq 0xD0 -and $ham[$i+1] -eq 0xCF -and $ham[$i+2] -eq 0x11 -and $ham[$i+3] -eq 0xE0) {
      $doc = New-Object byte[] ($ham.Length - $i); [Array]::Copy($ham, $i, $doc, 0, $doc.Length)
      # OLE Package içinde .docx mi?
      try {
        $pkg = CfbAkis $doc "Package"
        if ($null -ne $pkg -and $pkg.Length -gt 4 -and $pkg[0] -eq 0x50 -and $pkg[1] -eq 0x4B) {
          $h = $null; try { $h = DocxHtml $pkg } catch { }
          return @("docx", $pkg, (DocxMetin $pkg), $h)
        }
      } catch { }
      try { return @("doc", $doc, (WordMetin $doc)) } catch { return @("doc", $doc, $null) }
    }
  }
  if ($bas -eq "{
t") { $r = RtfMetin $ham; return @("rtf", $ham, $r[1]) }
  return @("metin", $ham, [System.Text.Encoding]::GetEncoding(1254).GetString($ham))
}
function ZlibAc([byte[]]$b) {
  if ($null -eq $b -or $b.Length -lt 3) { return $null }
  $ms = New-Object System.IO.MemoryStream(, $b)
  if ($b[0] -eq 0x78) { [void]$ms.ReadByte(); [void]$ms.ReadByte() }   # zlib başlığı; gerisi ham deflate
  $ds = New-Object System.IO.Compression.DeflateStream($ms, [System.IO.Compression.CompressionMode]::Decompress)
  $cik = New-Object System.IO.MemoryStream
  $ds.CopyTo($cik); $ds.Close()
  return $cik.ToArray()
}
function RtfMetin([byte[]]$ham) {
  # RTF 7-bit ASCII + \'xx kaçışları (cp1254); Latin1 ile birebir dize olarak alınır.
  $rtf = [System.Text.Encoding]::GetEncoding(28591).GetString($ham)
  if (-not $rtf.StartsWith("{\rtf")) { return @($rtf, $rtf) }      # RTF değil: düz metin say
  try { $rtb.Rtf = $rtf; return @($rtf, $rtb.Text) } catch { return @($rtf, "") }
}

# --------------------------------------------------------------------- ana --
$cn = New-Object System.Data.SqlClient.SqlConnection(
        "Server=$MssqlServer;Database=$MssqlDb;User Id=$MssqlUser;Password=$MssqlPass;TrustServerCertificate=True;")
$cn.Open()
PgKomut ("create schema if not exists " + $Sema + ";") | Out-Null

foreach ($t in $Tablolar) {
  if (-not $KAPSAM.Contains($t)) { throw "Bilinmeyen tablo: $t (KAPSAM listesine ekleyin)" }
  $alt = $t.ToLowerInvariant()
  $atla = if ($KOPYALANMAZ.ContainsKey($t)) { $KOPYALANMAZ[$t] } else { @() }

  $kolonlar = New-Object System.Collections.ArrayList
  $c = $cn.CreateCommand()
  $c.CommandText = "SELECT c.name, ty.name, c.max_length, c.precision, c.scale FROM sys.columns c JOIN sys.types ty ON ty.user_type_id = c.user_type_id WHERE c.object_id = OBJECT_ID('dbo.$t') ORDER BY c.column_id"
  $r = $c.ExecuteReader()
  while ($r.Read()) {
    if ($atla -contains $r.GetString(0) -or $r.GetString(0) -match $SIR_DESENI) { continue }
    [void]$kolonlar.Add(@{ Ad = $r.GetString(0); Tip = (PgTip $r.GetString(1) $r.GetInt16(2) $r.GetByte(3) $r.GetByte(4)) })
  }
  $r.Close()
  if ($kolonlar.Count -eq 0) { Write-Host ("ATLANDI (MSSQL'de yok): " + $t) -ForegroundColor Yellow; continue }

  $pgKolon = ($kolonlar | ForEach-Object { '"' + $_.Ad.ToLowerInvariant() + '" ' + $_.Tip }) -join ",`n  "
  $ek = if ($RAPORLU.Contains($t)) { ",`n  rapor_bicim text,`n  rapor_kaynak bytea,`n  rapor_metin text,`n  rapor_html text" } else { "" }
  if ($Devam -and $t -eq "OLE") {
    PgKomut ("create table if not exists " + $Sema + "." + $alt + " (`n  " + $pgKolon + $ek + "`n);") | Out-Null
  } else {
    PgKomut ("drop table if exists " + $Sema + "." + $alt + ";`ncreate table " + $Sema + "." + $alt + " (`n  " + $pgKolon + $ek + "`n);") | Out-Null
  }

  $msSelect = ($kolonlar | ForEach-Object { "[" + $_.Ad + "]" }) -join ", "
  if ($RAPORLU.Contains($t)) { $msSelect += ", " + (($RAPORLU[$t] | ForEach-Object { "[" + $_ + "]" }) -join ", ") }
  Adim ($t + " -> " + $Sema + "." + $alt)

  # PARTİLER: rapor tablosu ID'leriyle bölünür (her parti ayrı okunur / yazılır); diğer tablolar tek parti.
  $partiler = New-Object System.Collections.ArrayList
  if ($t -eq "OLE") {
    $var = @{}
    if ($Devam) { foreach ($x in (PgKomut ("select id from " + $Sema + "." + $alt))) { if ($x) { $var[[string]$x] = 1 } } }
    $ic = $cn.CreateCommand(); $ic.CommandTimeout = 0
    $ic.CommandText = "SELECT ID FROM dbo.$t" + $KAPSAM[$t] + " ORDER BY ID"
    $ir = $ic.ExecuteReader(); $idler = New-Object System.Collections.ArrayList
    while ($ir.Read()) { $id = [string]$ir.GetValue(0); if (-not $var.ContainsKey($id)) { [void]$idler.Add($id) } }
    $ir.Close()
    if ($RaporId.Count -gt 0) {
      $istenen = @{}; foreach ($x in ($RaporId -join ",").Split(",")) { if ($x.Trim()) { $istenen[$x.Trim()] = 1 } }
      $idler = [System.Collections.ArrayList]@($idler | Where-Object { $istenen.ContainsKey($_) })
    }
    if ($RaporLimit -gt 0 -and $idler.Count -gt $RaporLimit) { $idler = $idler.GetRange($idler.Count - $RaporLimit, $RaporLimit) }
    for ($k = 0; $k -lt $idler.Count; $k += $RaporParti) {
      $dilim = $idler.GetRange($k, [Math]::Min($RaporParti, $idler.Count - $k))
      [void]$partiler.Add(" WHERE ID IN (" + ($dilim -join ",") + ")")
    }
    Iyi ("" + $idler.Count + " rapor islenecek" + $(if ($var.Count) { " (" + $var.Count + " zaten var)" } else { "" }) + ", " + $partiler.Count + " parti")
  } else {
    [void]$partiler.Add($KAPSAM[$t])
  }

  $kolonListesi = (($kolonlar | ForEach-Object { '"' + $_.Ad.ToLowerInvariant() + '"' }) -join ", ")
  if ($RAPORLU.Contains($t)) { $kolonListesi += ", rapor_bicim, rapor_kaynak, rapor_metin, rapor_html" }
  $n = 0; $raporHata = 0; $pno = 0
  $kn = $kolonlar.Count
  foreach ($parti in $partiler) {
    $pno++
    $csv = Join-Path ([System.IO.Path]::GetTempPath()) ("eski_" + $alt + ".csv")
    $sw  = New-Object System.IO.StreamWriter($csv, $false, (New-Object System.Text.UTF8Encoding $false))
    $cmd = $cn.CreateCommand()
    $cmd.CommandText = "SELECT $msSelect FROM dbo.$t" + $parti
    $cmd.CommandTimeout = 0
    $rd = $cmd.ExecuteReader()
    $sb = New-Object System.Text.StringBuilder
    while ($rd.Read()) {
      [void]$sb.Clear()
      for ($i = 0; $i -lt $kn; $i++) {
        if ($i -gt 0) { [void]$sb.Append(',') }
        [void]$sb.Append((CsvAlan $rd.GetValue($i)))
      }
      if ($RAPORLU.Contains($t)) {
        $ham = $null
        try {
          for ($j = 0; $j -lt $RAPORLU[$t].Count -and $null -eq $ham; $j++) {
            if ($rd.IsDBNull($kn + $j)) { continue }
            $ham = if ($RAPORLU[$t][$j] -like "*_ZIP") { ZlibAc ([byte[]]$rd.GetValue($kn + $j)) } else { [byte[]]$rd.GetValue($kn + $j) }
          }
        } catch { $raporHata++ }
        $icr = IcerikCoz $ham
        if ($null -ne $ham -and $null -eq $icr[2]) { $raporHata++ }
        $kaynak = if ($RaporKaynakSakla) { $icr[1] } else { $null }
        $html = if ($icr.Count -ge 4) { $icr[3] } else { $null }
        [void]$sb.Append(',').Append((CsvAlan $icr[0])).Append(',').Append((CsvAlan $kaynak)).Append(',').Append((CsvAlan $icr[2])).Append(',').Append((CsvAlan $html))
        $ham = $null; $icr = $null; $kaynak = $null
      }
      $sw.WriteLine($sb.ToString())
      $n++
    }
    $rd.Close(); $sw.Close()
    & docker cp $csv ($Kap + ":/tmp/eski_" + $alt + ".csv") | Out-Null
    PgKomut ("copy " + $Sema + "." + $alt + " (" + $kolonListesi + ") from '/tmp/eski_" + $alt + ".csv' with (format csv, null '');") | Out-Null
    & docker exec $Kap rm -f ("/tmp/eski_" + $alt + ".csv") | Out-Null
    Remove-Item $csv -Force
    if ($RAPORLU.Contains($t)) {
      # Word her partide kapanır (bellek birikmesin), PowerShell çöpü toplanır.
      if ($null -ne $script:word) { $script:word.Quit(); [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($script:word); $script:word = $null }
      [System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers()
      Write-Host ("    parti " + $pno + "/" + $partiler.Count + " - " + $n + " rapor") -ForegroundColor DarkGray
    }
  }
  Iyi ($n.ToString() + " satir" + $(if ($raporHata) { " ($raporHata rapor acilamadi)" } else { "" }))
  if ($RAPORLU.Contains($t) -and ($script:ResimSayac.gomulu + $script:ResimSayac.atlanan) -gt 0) {
    Iyi ("resim: " + $script:ResimSayac.gomulu + " gomuldu, " + $script:ResimSayac.atlanan + " acilamadi")
  }
}
$cn.Close()
if ($null -ne $word) { $word.Quit(); [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) }
Remove-Item $geciciDoc -Force -ErrorAction SilentlyContinue

PgKomut ("comment on schema " + $Sema + " is 'Eski HBYS (GEN3000) ham kopyasi - " + $MssqlDb + " " + $Yil + ", " + (Get-Date -Format 'yyyy-MM-dd HH:mm') + ". Esleme: aktarim/eski-hbys/esle.sql, bilgi: eski.tanim';") | Out-Null
Write-Host ""
Write-Host ("Bitti. " + $PgDb + " / " + $Sema + " dolduruldu.") -ForegroundColor Green
