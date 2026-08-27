# ============================================================================
#  Gentegre AI — YURURLUKTEKI TANIM INDEKSI  (db/GUNCEL.md uretir)
#
#  SORUN: gocler tarihtir, silinmez ve DUZENLENMEZ. Ama bir fonksiyon zaman
#  icinde defalarca `create or replace` ile yeniden yazilinca "su an calisan
#  hali hangi dosyada" sorusunun cevabi grep'e kaliyor. Olculdu: 103 fonksiyon
#  adi 140 kez, 45 view adi 65 kez tanimlanmis; 27 fonksiyon ve 18 view birden
#  cok dosyada. `fn_kasa_islem_bacak_uret` DORT ayri dosyada var.
#
#  COZUM: gocleri degistirmeden, hangi dosyanin SON tanimi tasidigini gosteren
#  bir indeks uretmek. En yuksek numarali dosya yururluktekidir (gocler sirayla
#  uygulanir). Uretilen dosya elle duzenlenmez - bu betik yeniden uretir.
#
#  Kullanim: powershell -ExecutionPolicy Bypass -File .\araclar\guncel_indeks.ps1
# ============================================================================
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$Dizin = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Definition)
$Cikti = Join-Path $Dizin "GUNCEL.md"

# create [or replace] function|view [public.]<ad>
#
# METIN KUCUK HARFE INDIRILIP eslestirilir: dosyalarin bir kismi SQL'i BUYUK
#   harfle yaziyor (pg_get_functiondef ciktisi oldugu gibi yapistirilmis) ve
#   PowerShell 5.1'de bu kalibin buyuk-kucuk harf duyarsiz bicimi guvenilir
#   calismadi - fn_kasa_islem_iptal / _kesinlestir'in 152'deki SON tanimlari
#   sessizce atlaniyordu. Kucuk harfe indirmek karakter KONUMLARINI degistirmez,
#   ad zaten kucuk harfle yaziliyor.
$Kalip = [regex]'(?m)^\s*create\s+(?:or\s+replace\s+)?(function|view)\s+(?:public\.)?([a-z_][a-z0-9_]*)'

$bulgular = @{}     # "tur|ad" -> dosya listesi
foreach ($d in (Get-ChildItem $Dizin -Filter "*.sql" | Sort-Object Name)) {
    $metin = [System.IO.File]::ReadAllText($d.FullName).ToLowerInvariant()
    foreach ($m in $Kalip.Matches($metin)) {
        $tur = $m.Groups[1].Value.ToLower()
        $ad  = $m.Groups[2].Value.ToLower()
        if ($ad -eq "pg_temp") { continue }          # gecici sema, nesne degil
        $anahtar = "$tur|$ad"
        if (-not $bulgular.ContainsKey($anahtar)) { $bulgular[$anahtar] = @() }
        if ($bulgular[$anahtar] -notcontains $d.Name) { $bulgular[$anahtar] += $d.Name }
    }
}

$satirlar = New-Object System.Collections.Generic.List[string]
$satirlar.Add("# Yururlukteki tanimlar (uretilmis dosya - ELLE DUZENLEMEYIN)")
$satirlar.Add("")
$satirlar.Add("``araclar/guncel_indeks.ps1`` uretir. Gocler tarihtir ve duzenlenmez;")
$satirlar.Add("bir nesne birden cok dosyada tanimlanmissa **en yuksek numarali dosya**")
$satirlar.Add("yururluktedir - degistirmeniz gereken yer odur.")
$satirlar.Add("")

foreach ($tur in @("function", "view")) {
    $liste = $bulgular.Keys | Where-Object { $_ -like "$tur|*" } | Sort-Object
    $cok = @($liste | Where-Object { $bulgular[$_].Count -gt 1 })
    $satirlar.Add("## " + $(if ($tur -eq "function") { "Fonksiyonlar" } else { "Gorunumler" }) +
                  " (" + @($liste).Count + " ad, " + $cok.Count + " tanesi birden cok dosyada)")
    $satirlar.Add("")
    $satirlar.Add("| Nesne | Yururlukteki dosya | Onceki tanimlar |")
    $satirlar.Add("|---|---|---|")
    foreach ($k in $liste) {
        $ad = $k.Split("|")[1]
        $dosyalar = @($bulgular[$k] | Sort-Object)
        $son = $dosyalar[-1]
        $onceki = if ($dosyalar.Count -gt 1) { ($dosyalar[0..($dosyalar.Count - 2)] -join ", ") } else { "—" }
        $satirlar.Add("| ``$ad`` | ``$son`` | $onceki |")
    }
    $satirlar.Add("")
}

[System.IO.File]::WriteAllLines($Cikti, $satirlar, (New-Object System.Text.UTF8Encoding $false))
Write-Host ("GUNCEL.md yazildi: " + $Cikti) -ForegroundColor Green
Write-Host ("  " + $bulgular.Count + " nesne indekslendi.")
