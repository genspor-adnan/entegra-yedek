# ============================================================================
#  Gentegre AI — API'yi elle deneme betigi
#
#  Kullanim:
#    1. API'yi baslat:  dotnet run --project src\Gentegre.Api --urls http://localhost:5180
#    2. Bu betigi calistir:
#         powershell -ExecutionPolicy Bypass -File .\dene.ps1              # tum akis
#         powershell -ExecutionPolicy Bypass -File .\dene.ps1 -Islem cari  # yalniz cari ekle
#         powershell -ExecutionPolicy Bypass -File .\dene.ps1 -Islem liste
#
#  NOT: Saf ASCII + UTF-8 BOM (Windows PowerShell 5.1 uyumu icin).
# ============================================================================
param(
  [string]$Adres   = "http://localhost:5180",
  [string]$Kod     = "admin",
  [string]$Parola  = "Gentegre!2026",
  [int]$SubeId     = 1,
  [ValidateSet("hepsi","cari","stok","belge","liste")]
  [string]$Islem   = "hepsi"
)
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Yaz($m) { Write-Host ("==> " + $m) -ForegroundColor Cyan }

function Istek($Yontem, $Yol, $Govde) {
  $p = @{ Uri = ($Adres + $Yol); Method = $Yontem; Headers = $script:Baslik
          ContentType = "application/json; charset=utf-8" }
  if ($Govde) { $p.Body = $Govde }
  try { Invoke-RestMethod @p }
  catch {
    $y = $_.Exception.Response
    if ($y) {
      $metin = (New-Object System.IO.StreamReader($y.GetResponseStream())).ReadToEnd()
      Write-Host ("HATA HTTP " + [int]$y.StatusCode + ": " + $metin) -ForegroundColor Red
    } else { Write-Host ("HATA: " + $_.Exception.Message) -ForegroundColor Red }
    throw
  }
}

# ---------------------------------------------------------------- giris ----
Yaz "Giris"
$giris = Invoke-RestMethod ($Adres + "/api/kimlik/giris") -Method Post `
           -ContentType "application/json; charset=utf-8" `
           -Body (@{ kod = $Kod; parola = $Parola; subeId = $SubeId } | ConvertTo-Json)
$script:Baslik = @{ Authorization = "Bearer " + $giris.accessToken }
Write-Host ("    kullanici: " + $giris.kullanici.ad + " | rol: " + $giris.kullanici.rolAdi +
            " | sube: " + $giris.kullanici.subeId + " | yazma: " + $giris.kullanici.subeYazma)
if ($giris.subeSecimiGerekli) { Write-Host "    (cok subeli kullanici - sube secimi gerekir)" -ForegroundColor Yellow }

$damga = (Get-Date).ToString("HHmmss")

# ----------------------------------------------------------------- cari ----
if ($Islem -in @("hepsi","cari")) {
  Yaz "Cari kart ekleniyor"
  $govde = @{
    kart = @{ kod = "DENE.$damga"; unvan = "Deneme Musteri $damga"
              vkno = "1234567890"; vd = "Kozyatagi"; telefon = "0216 000 00 00"
              musteri = $true; durum = 0 }
    detaylar = @{ adresler = @{ eklenen = @(
        @{ tur = 1; baslik = "Merkez"; adres = "Deneme Mah. 1 Sk. No:1"
           ilce = "Kadikoy"; il = "ISTANBUL"; varsayilan = $true; aktif = $true }) } }
  } | ConvertTo-Json -Depth 6
  $cari = Istek POST "/api/kart/cari" $govde
  Write-Host ("    id=" + $cari.kart.id + "  surum=" + $cari.kart.surum +
              "  adres=" + $cari.detaylar.adresler.Count)
  $script:CariId = $cari.kart.id
}

# ----------------------------------------------------------------- stok ----
if ($Islem -in @("hepsi","stok")) {
  Yaz "Stok kart ekleniyor"
  $govde = @{
    kart = @{ kod = "DSTOK.$damga"; ad = "Deneme Urun $damga"; kdv = 20; durum = 0 }
    detaylar = @{
      barkodlar = @{ eklenen = @(@{ barkod = "869$damga"; varsayilan = $true }) }
      fiyatlar  = @{ eklenen = @(@{ fiyat = "1500.00"; satis = $true }) } }
  } | ConvertTo-Json -Depth 6
  $stok = Istek POST "/api/kart/stok" $govde
  Write-Host ("    id=" + $stok.kart.id + "  barkod=" + $stok.detaylar.barkodlar.Count +
              "  fiyat=" + $stok.detaylar.fiyatlar.Count)
  $script:StokId = $stok.kart.id
}

# ---------------------------------------------------------------- belge ----
if ($Islem -in @("hepsi","belge")) {
  if (-not $script:CariId) { $script:CariId = 1874 }   # ornek cari
  if (-not $script:StokId) { $script:StokId = 1044 }   # ornek stok
  Yaz "Satis faturasi kesiliyor"
  $govde = @{
    belge = @{ tur = 15; tarafId = $script:CariId
               belgeTarihi = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
               belgeSeri = "DEN"; belgeDovizi = "TL"; dovizKuru = 1   # kdvDurum sunucu varsayilani
               vadeGun = 30; cikisDepoId = 1 }
    satirlar = @(
      @{ sira = 1; tur = 1; stokId = $script:StokId; adet = 10; miktar = 10
         birimFiyat = 1250.00; iskonto = 5; kdv = 20 },
      @{ sira = 2; tur = 1; stokId = $script:StokId; adet = 3; miktar = 3
         birimFiyat = 99.99; kdv = 10 })
    secenekler = @{ taslak = $false; stokKontrolu = $true }
  } | ConvertTo-Json -Depth 6
  $belge = Istek POST "/api/belge" $govde
  Write-Host ("    id=" + $belge.belge.id + "  no=" + $belge.belge.belgeNo +
              "  cari=" + $belge.belge.tarafUnvan)
  Write-Host ("    matrah=" + $belge.belge.matrah + "  kdv=" + $belge.belge.kdvTutari +
              "  genel=" + $belge.belge.genelToplam)
  $belge.dipToplam | Format-Table tur, aciklama, deger -AutoSize
  if ($belge.uyarilar) { Write-Host ("    UYARI: " + ($belge.uyarilar -join " | ")) -ForegroundColor Yellow }
}

# ---------------------------------------------------------------- liste ----
if ($Islem -in @("hepsi","liste")) {
  Yaz "Cari listesi (son eklenenler)"
  $govde = @{ sayfa = 1; boyut = 5; sirala = @(@{ alan = "id"; yon = "desc" }) } | ConvertTo-Json -Depth 4
  $liste = Istek POST "/api/liste/cari" $govde
  Write-Host ("    toplam kayit: " + $liste.toplamKayit + "  sure: " + $liste.sureMs + " ms")
  $liste.satirlar | Format-Table id, kod, unvan, vkno -AutoSize

  Yaz "Belge listesi (son 5)"
  $govde = @{ sayfa = 1; boyut = 5; sirala = @(@{ alan = "id"; yon = "desc" })
              toplam = @("matrah","kdvTutari","genelToplam") } | ConvertTo-Json -Depth 4
  $bl = Istek POST "/api/liste/belge" $govde
  $bl.satirlar | Format-Table belgeNo, belgeTarihi, tarafUnvan, genelToplam -AutoSize
  Write-Host ("    toplamlar: " + ($bl.toplamlar | ConvertTo-Json -Compress))
}

Write-Host ""
Write-Host "Bitti." -ForegroundColor Green
