# ============================================================================
# rapor_ado_envanter.ps1 — FastReport sablonlarinda GOMULU ADO nesnesi envanteri
#
# Ne yapar: AYARLARYENI.AYARLAR (zlib sikistirilmis .fr3 XML) bloblarini acar,
#   TfrxADODatabase / TfrxADOQuery / TfrxADOTable / TfrxADOStoredProc arar.
#   Gomulu baglanti dizelerindeki Data Source / Initial Catalog degerlerini ve
#   Connected="True" durumunu raporlar.
#
# Neden: eski sablonlarda baska sunucuya kayitli TfrxADODatabase kalintisi
#   onizlemede DBNETLIB "SQL Server yok" hatasi veriyordu (UFastRap yuklemede
#   artik pasiflestiriyor). Bu envanter hangi sablonlarin elden gecirilecegini
#   ve ADOQuery ile rapor-ici SQL calistiran (SOKUMU RISKLI) sablonlari gosterir.
#
# Kullanim (musteri sunucusunda da calisir; yalniz OKUR, hicbir sey degistirmez):
#   powershell -ExecutionPolicy Bypass -File rapor_ado_envanter.ps1 `
#     -Server "SUNUCU\ORNEK" -Database GENTEGREDB -User sa -Password ***
#   Cikti: konsol ozeti + rapor_ado_envanter_<db>.txt (ayni klasore)
# ============================================================================
param(
    [string]$Server   = "DESKTOP-HL3J3AS\SQLEXPRESS",
    [string]$Database = "EKSPERT",
    [string]$User     = "sa",
    [string]$Password = "FETAGEN"
)

$ErrorActionPreference = "Stop"

function ZlibAc([byte[]]$veri) {
    # zlib akisi: 2 baytlik baslik (0x78 ..) atlanir -> ham deflate
    if ($veri.Length -lt 3) { return $null }
    $giris  = New-Object System.IO.MemoryStream(, $veri)
    [void]$giris.Seek(2, 'Begin')
    $def    = New-Object System.IO.Compression.DeflateStream($giris, [System.IO.Compression.CompressionMode]::Decompress)
    $cikis  = New-Object System.IO.MemoryStream
    $def.CopyTo($cikis); $def.Dispose(); $giris.Dispose()
    $bayt = $cikis.ToArray(); $cikis.Dispose()
    return [System.Text.Encoding]::UTF8.GetString($bayt)
}

$cnn = New-Object System.Data.SqlClient.SqlConnection(
    "Server=$Server;Database=$Database;User Id=$User;Password=$Password;TrustServerCertificate=True;")
$cnn.Open()

$cmd = $cnn.CreateCommand()
$cmd.CommandText = @"
SELECT A.ID AS AYARID, A.DOKUMID, D.RAPORADI, D.GRUBU, D.MODUL, A.AYARLAR
FROM AYARLARYENI A
INNER JOIN DOKUMLER D ON D.ID = A.DOKUMID
WHERE A.AYARLAR IS NOT NULL
ORDER BY D.GRUBU, D.RAPORADI
"@
$cmd.CommandTimeout = 300

$bulunan  = New-Object System.Collections.Generic.List[object]
$toplam   = 0
$acilamayan = 0

$rd = $cmd.ExecuteReader()
while ($rd.Read()) {
    $toplam++
    $blob = $rd["AYARLAR"]
    try { $xml = ZlibAc $blob } catch { $acilamayan++; continue }
    if (-not $xml) { continue }
    if ($xml -notmatch 'TfrxADO') { continue }

    $adoNesneler = ([regex]::Matches($xml, 'TfrxADO\w+') | ForEach-Object { $_.Value } | Sort-Object -Unique) -join ', '
    $baglantilar = ([regex]::Matches($xml, 'Data Source=([^;"&]+)')   | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique) -join ', '
    $kataloglar  = ([regex]::Matches($xml, 'Initial Catalog=([^;"&]+)')| ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique) -join ', '
    $bagliMi     = if ($xml -match '<TfrxADO\w+[^>]*Connected="True"') { 'EVET' } else { 'hayir' }
    $sorguluMu   = if ($xml -match 'TfrxADO(Query|Table|StoredProc)') { 'EVET (SOKUM RISKLI)' } else { 'hayir' }

    $bulunan.Add([pscustomobject]@{
        AYARID    = $rd["AYARID"]
        DOKUMID   = $rd["DOKUMID"]
        RAPORADI  = "$($rd["RAPORADI"])"
        GRUBU     = "$($rd["GRUBU"])"
        MODUL     = "$($rd["MODUL"])"
        ADONESNE  = $adoNesneler
        SUNUCU    = $baglantilar
        KATALOG   = $kataloglar
        CONNECTED = $bagliMi
        RAPORICISQL = $sorguluMu
    })
}
$rd.Close(); $cnn.Close()

# ToLowerInvariant: Turkce yerel ayarda 'BILIM'.ToLower() = 'bılım' (noktasiz i) oluyordu.
$dosya = Join-Path $PSScriptRoot ("rapor_ado_envanter_{0}.txt" -f ($Database.ToLowerInvariant()))
$baslik = "ADO sablon envanteri  DB=$Database  Sunucu=$Server  Tarih=$(Get-Date -Format 'yyyy-MM-dd HH:mm')"
$ozet   = "Toplam sablon: $toplam | ADO iceren: $($bulunan.Count) | Acilamayan blob: $acilamayan"

$baslik | Out-File -Encoding utf8 $dosya
$ozet   | Out-File -Encoding utf8 -Append $dosya
""      | Out-File -Encoding utf8 -Append $dosya
if ($bulunan.Count -gt 0) {
    $bulunan | Format-Table -AutoSize | Out-String -Width 260 | Out-File -Encoding utf8 -Append $dosya
}

Write-Host $baslik
Write-Host $ozet
if ($bulunan.Count -gt 0) {
    $bulunan | Format-Table AYARID, RAPORADI, GRUBU, ADONESNE, SUNUCU, CONNECTED, RAPORICISQL -AutoSize
    Write-Host "Ayrinti: $dosya"
} else {
    Write-Host "ADO nesnesi iceren sablon YOK."
}
