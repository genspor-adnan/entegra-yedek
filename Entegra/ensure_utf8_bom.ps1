# Tum .pas dosyalarinin UTF-8 BOM ile baslamasini garanti eder.
# Algoritma:
#   1. BOM zaten varsa atla.
#   2. Dosya saf ASCII ise sadece BOM ekle.
#   3. Dosya gecerli UTF-8 ise (high byte'lar valid sequence olusturuyor) -> sadece BOM ekle.
#   4. Aksi halde cp1254 varsay, decode edip UTF-8 BOM'a yaz.
# Bu sayede zaten UTF-8 olan dosyalari (em dash, smart quote vb. ozel chars iceren)
# yanlislikla mojibake'lemez.

param(
    [string]$Root = $PSScriptRoot
)

$enc1254     = [System.Text.Encoding]::GetEncoding(1254)
$utf8strict  = New-Object System.Text.UTF8Encoding($false, $true)  # throws on invalid
$utf8bom     = New-Object System.Text.UTF8Encoding($true)
$donusturulen = 0
$utf8bomEklendi = 0
$asciiBomEklendi = 0
$atlanan = 0

Get-ChildItem -Path $Root -Filter *.pas -Recurse -File | ForEach-Object {
    $path = $_.FullName

    # 3dparty ve Archive dizinlerini atla
    if ($path -like '*\3dparty\*' -or $path -like '*\Archive\*') {
        return
    }

    $bytes = [System.IO.File]::ReadAllBytes($path)
    if ($bytes.Length -eq 0) { return }

    # 1. Zaten UTF-8 BOM ise atla.
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $atlanan++
        return
    }

    # 2. Saf ASCII ise sadece BOM ekle.
    $hasHi = $false
    foreach ($b in $bytes) {
        if ($b -ge 0x80) { $hasHi = $true; break }
    }
    if (-not $hasHi) {
        $newBytes = [byte[]]@(0xEF, 0xBB, 0xBF) + $bytes
        [System.IO.File]::WriteAllBytes($path, $newBytes)
        $asciiBomEklendi++
        return
    }

    # 3. Gecerli UTF-8 mi? Strict decode dene; basarili ise BOM eklemek yeterli.
    $isUtf8 = $true
    try {
        [void]$utf8strict.GetString($bytes)
    } catch {
        $isUtf8 = $false
    }
    if ($isUtf8) {
        $newBytes = [byte[]]@(0xEF, 0xBB, 0xBF) + $bytes
        [System.IO.File]::WriteAllBytes($path, $newBytes)
        $utf8bomEklendi++
        return
    }

    # 4. cp1254 olarak yorumla ve UTF-8 BOM'a yaz. Mevcut FFFD byte sequence'leri
    #    tek FFFD karakter olarak korunur.
    $sb = New-Object System.Text.StringBuilder
    $i = 0
    while ($i -lt $bytes.Length) {
        if ($i + 2 -lt $bytes.Length -and $bytes[$i] -eq 0xEF -and $bytes[$i+1] -eq 0xBF -and $bytes[$i+2] -eq 0xBD) {
            [void]$sb.Append([char]0xFFFD); $i += 3
        } elseif ($bytes[$i] -lt 0x80) {
            [void]$sb.Append([char]$bytes[$i]); $i++
        } else {
            $ch = $enc1254.GetString(@([byte]$bytes[$i]))
            [void]$sb.Append($ch); $i++
        }
    }
    [System.IO.File]::WriteAllText($path, $sb.ToString(), $utf8bom)
    $donusturulen++
}

Write-Host "BOM ekleme tamamlandi:"
Write-Host "  cp1254 -> UTF-8 BOM cevirme:    $donusturulen"
Write-Host "  UTF-8 (BOM eklendi, icerik OK): $utf8bomEklendi"
Write-Host "  ASCII (sadece BOM eklendi):     $asciiBomEklendi"
Write-Host "  Zaten BOM olan (atlandi):       $atlanan"
