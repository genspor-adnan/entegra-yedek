# depo_adlandirma_kontrol.ps1   —  SALT OKUMA (hicbir sey degistirmez)
#
# DEPO ADLANDIRMA KURALI (05.08.2026): depo veritabani adi  <ANA_DB>_GENDEPO  olmak zorunda.
#   Ayni sunucuda birden fazla Gentegre veritabani bulunabildigi icin ortak 'GENDEPO' adi
#   yanlis depoya (log / e-belge / DOSYA) yazma riski tasiyordu. Uygulama acilista
#   (ULog.DepoKuralDenetle) denetler ve kurala uymayan kurulumda HATA verir.
#
# Bu betik yalniz RAPORLAR. Duzeltme icin:  depo_adlandirma_duzelt.ps1
#
# Kullanim:
#   powershell -ExecutionPolicy Bypass -File depo_adlandirma_kontrol.ps1
#   powershell -ExecutionPolicy Bypass -File depo_adlandirma_kontrol.ps1 -Sunucu "SRV\ORNEK" -Kullanici sa -Sifre ***

param(
    [string]$Sunucu    = "DESKTOP-HL3J3AS\SQLEXPRESS",
    [string]$Kullanici = "sa",
    [string]$Sifre     = "FETAGEN",
    [switch]$Trusted
)

$ErrorActionPreference = "Stop"
$DEPO_OPSIYON = -24120   # Ops_FaturaOpsiyon_DepoDBAdi

function Sql($db, $q) {
    $tmp = [System.IO.Path]::GetTempFileName()
    $q | Out-File -Encoding utf8 $tmp
    try {
        $a = @("-S", $Sunucu, "-d", $db, "-C", "-f", "65001", "-h", "-1", "-W", "-i", $tmp)
        if ($Trusted) { $a += "-E" } else { $a += @("-U", $Kullanici, "-P", $Sifre) }
        & sqlcmd @a 2>&1
    } finally { Remove-Item $tmp -ErrorAction SilentlyContinue }
}

$hepsi = (Sql "master" "SET NOCOUNT ON; SELECT name FROM sys.databases WHERE database_id > 4 AND state = 0 ORDER BY name") |
         Where-Object { $_ -match '^\w' }

$rapor = @()
foreach ($db in $hepsi) {
    $var = (Sql $db "SET NOCOUNT ON; SELECT CASE WHEN OBJECT_ID('dbo.GENINI') IS NULL THEN 0 ELSE 1 END") |
           Where-Object { $_ -match '^\d' } | Select-Object -First 1
    if ($var -ne '1') { continue }   # Gentegre ana veritabani degil (depo DB'sinin kendisi olabilir)

    $mevcut = (Sql $db "SET NOCOUNT ON; SELECT ISNULL((SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM=$DEPO_OPSIYON),'')") |
              Where-Object { $_ -match '\S' } | Select-Object -First 1
    if ($null -ne $mevcut) { $mevcut = $mevcut.Trim() }
    $beklenen = "${db}_GENDEPO"

    $depoVar = (Sql "master" "SET NOCOUNT ON; SELECT CASE WHEN DB_ID('$beklenen') IS NULL THEN 'YOK' ELSE 'VAR' END") |
               Where-Object { $_ -match '\S' } | Select-Object -First 1

    $rapor += [pscustomobject]@{
        AnaDB       = $db
        TanimliDepo = if ($mevcut) { $mevcut } else { "(bos -> GENDEPO)" }
        OlmasiGerek = $beklenen
        HedefDB     = $depoVar.Trim()
        Sonuc       = if (($mevcut -eq $beklenen) -and ($depoVar.Trim() -eq 'VAR')) { "UYGUN" } else { "DUZELTILMELI" }
    }
}

"=== DEPO ADLANDIRMA DURUMU ($Sunucu) ==="
$rapor | Format-Table -AutoSize

$bozuk = @($rapor | Where-Object { $_.Sonuc -ne 'UYGUN' })
if ($bozuk.Count -eq 0) {
    "Tum veritabanlari kurala uygun."
    exit 0
}

""
"Duzeltilmesi gereken: $($bozuk.Count)"
"Duzeltme betigi:  powershell -ExecutionPolicy Bypass -File depo_adlandirma_duzelt.ps1 -Onayla"
"UYARI: Duzeltme sirasinda ilgili veritabanlarina baglanti OLMAMALI (uygulamalari kapatin)."
exit 1
