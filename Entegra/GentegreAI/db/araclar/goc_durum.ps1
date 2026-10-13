# ============================================================================
#  Gentegre AI - GOC DURUMU  (dokuman/17 2.5)  - SALT OKUR
#
#  "Bu veritabaninda hangi goc dosyalari uygulandi, hangileri bekliyor?"
#  db/NNN_*.sql dosyalarini goc defteriyle (public.goc_gecmisi) karsilastirir:
#
#    BEKLEYEN   dosya var, defterde yok - yayinda / goc_uygula'da calisacak
#    DEGISMIS   defterdeki icerik ozeti dosyayla tutmuyor: uygulandiktan
#               SONRA duzenlenmis (kural: goc dosyasi duzenlenmez); sunucuda
#               calisan surum depodakiyle ayni degil
#    SAHIPSIZ   defterde var, dosyasi yok (silinmis / yeniden adlandirilmis)
#
#  Ozet, goc_uygula.ps1 / yayin/goc_uygula.sh ile AYNI kural (LF'e normalize,
#  BOM'suz, sha256). Eski kayitlarda ozet yoktur - onlar karsilastirilamaz,
#  raporda "ozetsiz" sayisi olarak gecer.
#
#  Kullanim:
#    .\goc_durum.ps1                                   # yerel docker, gentegre_ai
#    .\goc_durum.ps1 -Db gentegre_ai_test
#    .\goc_durum.ps1 -Sunucu gentegre@46.36.201.170 -Db gentegre_ai_dis
#    .\goc_durum.ps1 -Tumu                             # bekleyenlerin hepsini yaz
#
#  Cikis kodu: 0 guncel / 2 bekleyen ya da degismis var / 1 hata.
#  Hicbir sey YAZMAZ; uygulamak icin goc_uygula.ps1 (yerel) / yayinla.ps1.
#  NOT: Saf ASCII + UTF-8 BOM (Windows PowerShell 5.1 uyumu icin).
# ============================================================================
param(
  [string]$Db      = "gentegre_ai",
  [string]$Kap     = "gentegre-pg18",
  # Dolu ise sunucudaki ayni adli PG konteyneri ssh ile sorgulanir.
  [string]$Sunucu  = "",
  [switch]$Tumu
)
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$DbDizin = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Definition)

function Ozet([string]$Yol) {
  # goc_uygula.ps1 ile ayni: ReadAllText BOM'u atar, satir sonu LF.
  $m = [System.IO.File]::ReadAllText($Yol).Replace("`r`n", "`n").Replace("`r", "`n")
  $b = [System.Security.Cryptography.SHA256]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($m))
  return ([BitConverter]::ToString($b) -replace "-", "").ToLowerInvariant()
}
function No([string]$Ad) { return [int]($Ad -split '_')[0] }

# ---- defter ----
$sql = "select dosya || '|' || coalesce(ozet, '') || '|' || coalesce(yontem, '') || '|' || " +
       "to_char(uygulama, 'YYYY-MM-DD') from public.goc_gecmisi"
$var = "select to_regclass('public.goc_gecmisi') is not null"
if ($Sunucu -ne "") {
  $q = { param($s) ssh $Sunucu "docker exec $Kap psql -U postgres -d $Db -tA -c `"$s`"" }
} else {
  $env:MSYS_NO_PATHCONV = "1"
  $q = { param($s) docker exec $Kap psql -U postgres -d $Db -tA -c $s }
}
$tabloVar = (& $q $var)
if ($LASTEXITCODE -ne 0) { Write-Host "HATA: veritabanina baglanilamadi ($Db)" -ForegroundColor Red; exit 1 }
$defter = @{}
if ($tabloVar -eq "t") {
  foreach ($s in (& $q $sql)) {
    if (-not $s) { continue }
    $p = $s.Split('|')
    $defter[$p[0]] = @{ Ozet = $p[1]; Yontem = $p[2]; Tarih = $p[3] }
  }
}

# ---- dosyalar (sayisal sira; 1000+ dahil) ----
$dosyalar = @(Get-ChildItem $DbDizin -Filter "*.sql" |
              Where-Object { $_.Name -match '^\d{3,}_' } |
              Sort-Object { No $_.Name }, Name)

$bekleyen = @(); $degismis = @(); $ozetsiz = 0
foreach ($d in $dosyalar) {
  $k = $defter[$d.Name]
  if (-not $k) { $bekleyen += $d.Name; continue }
  if ($k.Ozet -eq "") { $ozetsiz++; continue }
  if ($k.Ozet -ne (Ozet $d.FullName)) { $degismis += $d.Name }
}
$adlar = @{}; foreach ($d in $dosyalar) { $adlar[$d.Name] = 1 }
$sahipsiz = @($defter.Keys | Where-Object { $_ -match '^\d{3,}_' -and -not $adlar[$_] } |
              Sort-Object { No $_ })

$uygulanan = @($defter.Keys | Where-Object { $_ -match '^\d{3,}_' })
$son = if ($uygulanan.Count) { $uygulanan | Sort-Object { No $_ } | Select-Object -Last 1 } else { "-" }
$sonTarih = if ($defter.Count) { ($defter.Values | ForEach-Object { $_.Tarih } | Sort-Object | Select-Object -Last 1) } else { "-" }

# ---- rapor ----
$yer = if ($Sunucu -ne "") { "$Sunucu / $Db" } else { "yerel $Kap / $Db" }
Write-Host "Goc durumu: $yer" -ForegroundColor Cyan
if ($tabloVar -ne "t") { Write-Host "  goc_gecmisi tablosu YOK - bu veritabani goc defteriyle kurulmamis." -ForegroundColor Yellow }
Write-Host ("  Dosya: {0}   Defterde: {1}   En yuksek uygulanan: {2}   Son kayit: {3}" -f
            $dosyalar.Count, $uygulanan.Count, $son, $sonTarih)
if ($ozetsiz -gt 0) { Write-Host "  Ozetsiz (eski) kayit: $ozetsiz - icerikleri karsilastirilamaz." }

function Liste([string]$Baslik, [object[]]$L, [string]$Renk) {
  if ($L.Count -eq 0) { return }
  Write-Host ""
  Write-Host ("{0}: {1}" -f $Baslik, $L.Count) -ForegroundColor $Renk
  $goster = if ($Tumu -or $L.Count -le 25) { $L } else { $L | Select-Object -Last 25 }
  if ($goster.Count -lt $L.Count) { Write-Host ("  ... ilk {0} gizli (-Tumu ile hepsi)" -f ($L.Count - $goster.Count)) }
  foreach ($a in $goster) { Write-Host "  $a" }
}
Liste "BEKLEYEN" $bekleyen "Yellow"
Liste "DEGISMIS (uygulandiktan sonra duzenlenmis)" $degismis "Red"
Liste "SAHIPSIZ (defterde var, dosyasi yok)" $sahipsiz "DarkYellow"

Write-Host ""
if ($bekleyen.Count -eq 0 -and $degismis.Count -eq 0) {
  Write-Host "Guncel." -ForegroundColor Green; exit 0
}
exit 2
