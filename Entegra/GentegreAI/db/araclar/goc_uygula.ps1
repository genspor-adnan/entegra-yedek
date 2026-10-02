# ============================================================================
#  Gentegre AI — ATOMIK GOC UYGULAYICI  (kur.ps1 kullanir; sunucu esi:
#  yayin/goc_uygula.sh - AYNI kurallar)
#
#  SORUN (denetim 28.09.2026 #10): goc dosyasi ile goc_gecmisi kaydi iki ayri
#  psql cagrisiydi ve dosyalar islem icinde calismiyordu. ON_ERROR_STOP hatadan
#  sonra devami durdurur ama ONCEKI ifadeleri geri almaz: yarim sema ya da
#  "uygulandi ama deftere yazilmadi" dosya kalabiliyordu. Iki guncelleyici ayni
#  anda calisirsa ayni dosyayi iki kez uygulayabiliyordu.
#
#  KURALLAR
#   * ISLEMLI dosya: BEGIN -> kilit -> defter kontrolu -> dosya -> defter kaydi
#     -> COMMIT tek islemde. Dosyanin ortasindaki hata, onceki ifadeleri de
#     defter kaydini da geri alir.
#   * ISLEM DISI dosya: kendi BEGIN/COMMIT'ini tasiyan dosyalar (dosyanin
#     COMMIT'i dis islemi erken bitirirdi). Dosya kendi isleminde atomiktir;
#     defter kaydi hemen ardindan yazilir. Hangi dosyanin bu sinifta oldugu
#     METINDEN tespit edilir ve deftere `yontem = 'islem_disi'` yazilir.
#   * ESZAMANLILIK: pg_advisory kilidi (7340928). Ikinci guncelleyici kilidi
#     bekler, sonra defterde dosyayi gorur ve ATLAR - ayni dosya iki kez
#     calismaz.
#   * DEFTER: dosya + icerik ozeti (sha256, LF'e normalize) + yontem.
#     Eski kayitlarda ozet YOKTUR (dogrulanmamis) - bugun hesaplanan ozet
#     onlarin yerine yazilmaz.
#   * CIKIS KODU: 0 basari · 1 goc/defter hatasi · 2 dis veri on kosulu
#     (db/kurulum/dis_veri_onkosullari.txt) - kosul saglaninca ayni komut
#     kaldigi yerden devam eder.
#   * BOS KURULUM (-BosKurulum): her bekleyen dosyadan once
#     db/kurulum/000_bos_kurulum.sql (idempotent tohum); MSSQL aktarim adimlari
#     (db/kurulum/aktarim_adimlari.txt) CALISTIRILMAZ, deftere
#     `yontem = 'aktarim_yok'` yazilir - "uygulandi" ile karismaz.
#
#  Kullanim: -Dosyalar verilmezse Dizin'deki tum NNN_*.sql sirayla.
# ============================================================================
param(
  [string]$Kap      = "gentegre-pg18",
  # [Parameter()] KONMAZ: betigi "gelismis" yapar ve -Db, -Debug'in "db"
  #   takma adiyla cakisir (kur.ps1 de ayni sebeple duz parametre kullanir).
  [string]$Db       = "",
  [string]$PgHost   = "",
  [int]$PgPort      = 5432,
  [string]$Kul      = "postgres",
  [string]$Parola   = "FETAGEN",
  [string]$Dizin    = "",
  [string[]]$Dosyalar = @(),
  # Siralı dosya adlari, satir basina bir ad (uzun listeler icin - kur.ps1).
  [string]$ListeDosyasi = "",
  [switch]$BosKurulum
)
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
if ($Db -eq "") { Write-Host "HATA: -Db gerekli" -ForegroundColor Red; exit 1 }
$DbDizin = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Definition)
if ($Dizin -eq "") { $Dizin = $DbDizin }
$Kilit = 7340928

function Satirlar([string]$Yol) {
  if (-not (Test-Path $Yol)) { return @() }
  return @([System.IO.File]::ReadAllLines($Yol) | ForEach-Object { $_.Trim() } |
           Where-Object { $_ -ne "" -and -not $_.StartsWith("#") })
}
$Aktarim = Satirlar (Join-Path $DbDizin "kurulum\aktarim_adimlari.txt")
$DisVeri = @{}
foreach ($s in (Satirlar (Join-Path $DbDizin "kurulum\dis_veri_onkosullari.txt"))) {
  $p = $s.Split("|", 2); $DisVeri[$p[0]] = $p[1]
}
$Tohum = Join-Path $DbDizin "kurulum\000_bos_kurulum.sql"

# KENDI ISLEMINI YONETEN DOSYA (tekrar denetim 28.09.2026 #2): USTDUZEYDE bir
#   IFADENIN TAMAMI BEGIN/COMMIT/ROLLBACK/END [WORK|TRANSACTION] ya da START
#   TRANSACTION ise. Eskiden satir basinda `end;` aranirdi: DO/fonksiyon
#   govdesindeki PL/pgSQL `end;` ve `case ... end;` transaction sanildi, normal
#   dosyalar islem DISINDA calisip ortadaki hatada YARIM kaldi.
#   1) Yorum, metin sabiti ve $tag$ govdesi TEK GECISTE ayiklanir: hangisi
#      once gelirse o (yorumdaki `$$` govde sanilmasin, govdedeki `--` yorum
#      sanilmasin). (\w*): bos etiket ($$) de grup olarak katilir.
#   2) Kalan metin `;` ile ifadelere bolunur; IFADENIN KENDISI islem komutu mu.
#   Sunucu esi (yayin/goc_uygula.sh) AYNI kurali uygular.
$Ayiklanacak = [regex]'--[^\n]*|/\*[\s\S]*?\*/|''(?:[^'']|'''')*''|\$(\w*)\$[\s\S]*?\$\1\$'
$IslemKomutu = [regex]'(?i)^(?:(?:begin|commit|rollback|end)(?:\s+(?:work|transaction))?|start\s+transaction\b.*)$'
function IslemDisiMi([string]$Metin) {
  $m = $Ayiklanacak.Replace($Metin, ' ')
  foreach ($ifade in $m.Split(';')) {
    if ($IslemKomutu.IsMatch(($ifade -replace '\s+', ' ').Trim())) { return $true }
  }
  return $false
}

function Normal([string]$Yol) { return [System.IO.File]::ReadAllText($Yol).Replace("`r`n", "`n").Replace("`r", "`n") }
function Ozet([string]$Metin) {
  $b = [System.Security.Cryptography.SHA256]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Metin))
  return ([BitConverter]::ToString($b) -replace "-", "").ToLowerInvariant()
}

# ---- gecici calisma dizini: dosyalar LF + BOM'suz (psql ve Turkce icin) ----
$Gecici = Join-Path ([System.IO.Path]::GetTempPath()) ("goc_" + [guid]::NewGuid().ToString("N").Substring(0, 8))
New-Item -ItemType Directory -Path $Gecici | Out-Null
$KapDizin = "/tmp/" + (Split-Path -Leaf $Gecici)
$Utf8 = New-Object System.Text.UTF8Encoding $false

function Psql([string]$YerelDosya, [hashtable]$Degisken = @{}) {
  $ad = Split-Path -Leaf $YerelDosya
  $v = @(); foreach ($k in $Degisken.Keys) { $v += @("-v", ($k + "=" + $Degisken[$k])) }
  # psql'in STDERR'i (NOTICE/ERROR) PowerShell 5.1'de hata kaydina donusur;
  #   "Stop" altinda betik KENDI cikis kodu mantigina gelmeden kesilirdi.
  #   Karar psql'in cikis kodundan verilir.
  $ErrorActionPreference = "Continue"
  if ($PgHost -eq "") {
    $cikti = & docker exec -e ("PGPASSWORD=" + $Parola) -e "PGCLIENTENCODING=UTF8" `
        -e "PGOPTIONS=-c client_min_messages=warning" $Kap `
        psql -U $Kul -d $Db -v ON_ERROR_STOP=1 -q @v -f ($KapDizin + "/" + $ad) 2>&1
  } else {
    $cikti = & docker run --rm -e ("PGPASSWORD=" + $Parola) -e "PGCLIENTENCODING=UTF8" `
        -e "PGOPTIONS=-c client_min_messages=warning" -v ($Gecici + ":" + $KapDizin) postgres:18 `
        psql -h $PgHost -p $PgPort -U $Kul -d $Db -v ON_ERROR_STOP=1 -q @v -f ($KapDizin + "/" + $ad) 2>&1
  }
  return @{ Kod = $LASTEXITCODE; Cikti = (@($cikti) -join "`n") }
}

function Gonder() {
  if ($PgHost -ne "") { return }   # uzak modda dizin baglanir (-v)
  & docker exec $Kap mkdir -p $KapDizin | Out-Null
  & docker cp ($Gecici + "\.") ($Kap + ":" + $KapDizin) | Out-Null
  if ($LASTEXITCODE -ne 0) { throw "docker cp basarisiz" }
}

function Yaz([string]$Ad, [string]$Metin) { [System.IO.File]::WriteAllText((Join-Path $Gecici $Ad), $Metin, $Utf8) }

try {
  # ---- defter ----
  # Kilit altinda: iki uygulayici ayni anda "create table if not exists"
  #   calistirirsa PG katalogunda cakisir (pg_type benzersizlik hatasi).
  Yaz "_defter.sql" @"
begin;
do `$`$ begin perform pg_advisory_xact_lock($Kilit); end `$`$;
create table if not exists public.goc_gecmisi (
    dosya      varchar(200) primary key,
    uygulama   timestamp not null default now()::timestamp
);
-- 28.09.2026: icerik ozeti ve uygulama yontemi. Eski kayitlarda NULL kalir -
--   gecmis icin bugun ozet uydurulmaz (dogrulanmamis).
alter table public.goc_gecmisi add column if not exists ozet varchar(64);
alter table public.goc_gecmisi add column if not exists yontem varchar(20);
commit;
"@
  if ($ListeDosyasi -ne "") {
    $Dosyalar = @([System.IO.File]::ReadAllLines($ListeDosyasi) | Where-Object { $_.Trim() -ne "" })
  }
  $Sirali = if ($Dosyalar.Count -gt 0) { $Dosyalar } else {
    @(Get-ChildItem $Dizin -Filter "*.sql" | Where-Object { $_.Name -match '^\d{3}_' } | Sort-Object Name | ForEach-Object { $_.Name })
  }
  $Bilgi = @{}
  foreach ($ad in $Sirali) {
    $metin = Normal (Join-Path $Dizin $ad)
    Yaz $ad $metin
    $Bilgi[$ad] = @{ Ozet = (Ozet $metin); IslemDisi = (IslemDisiMi $metin) }
  }
  if (Test-Path $Tohum) { Yaz "_tohum.sql" (Normal $Tohum) }

  # Sarmalayicilar: psql degiskenleriyle (dosya, ozet, yol) her dosyada ayni.
  Yaz "_islemli.sql" @"
begin;
do `$`$ begin perform pg_advisory_xact_lock($Kilit); end `$`$;
select exists (select 1 from public.goc_gecmisi where dosya = :'dosya') as goc_var \gset
\if :goc_var
  \echo GOC_ZATEN_UYGULANMIS
  rollback;
\else
  \i :yol
  insert into public.goc_gecmisi (dosya, ozet, yontem) values (:'dosya', :'ozet', 'islem');
  commit;
\endif
"@
  Yaz "_islemdisi.sql" @"
do `$`$ begin perform pg_advisory_lock($Kilit); end `$`$;
select exists (select 1 from public.goc_gecmisi where dosya = :'dosya') as goc_var \gset
\if :goc_var
  \echo GOC_ZATEN_UYGULANMIS
\else
  \i :yol
  insert into public.goc_gecmisi (dosya, ozet, yontem) values (:'dosya', :'ozet', 'islem_disi');
\endif
do `$`$ begin perform pg_advisory_unlock($Kilit); end `$`$;
"@
  Yaz "_aktarim.sql" @"
insert into public.goc_gecmisi (dosya, ozet, yontem) values (:'dosya', :'ozet', 'aktarim_yok')
on conflict (dosya) do nothing;
"@
  Gonder

  $r = Psql "_defter.sql"
  if ($r.Kod -ne 0) { Write-Host $r.Cikti; exit 1 }

  # Defterdekiler bir kez okunur (hiz); sarmalayici kilit altinda YINE bakar
  #   - arada baska guncelleyici uygulamis olabilir.
  Yaz "_defter_oku.sql" "\pset format unaligned`n\pset tuples_only on`nselect dosya from public.goc_gecmisi;`n"
  Gonder
  $r = Psql "_defter_oku.sql"
  if ($r.Kod -ne 0) { Write-Host $r.Cikti; exit 1 }
  $Defter = @{}; foreach ($s in ($r.Cikti -split "`n")) { if ($s.Trim() -ne "") { $Defter[$s.Trim()] = 1 } }

  if ($BosKurulum) {
    # Isaret: bu veritabani BOS KURULUMLA acildi - sunucu esi (goc_uygula.sh)
    #   sonraki calismalarda bos kurulum kipini buradan anlar.
    Yaz "_isaret.sql" "insert into public.goc_gecmisi (dosya, yontem) values ('000_bos_kurulum.sql', 'tohum') on conflict (dosya) do nothing;`n"
    Gonder
    $r = Psql "_isaret.sql"
    if ($r.Kod -ne 0) { Write-Host $r.Cikti; exit 1 }
  }

  $uygulanan = 0; $atlanan = 0; $aktarimYok = 0
  foreach ($ad in $Sirali) {
    $b = $Bilgi[$ad]
    if ($Defter.ContainsKey($ad)) { $atlanan++; continue }
    if ($BosKurulum -and (Test-Path $Tohum)) {
      $t = Psql "_tohum.sql"
      if ($t.Kod -ne 0) { Write-Host $t.Cikti; Write-Host "HATA: bos kurulum tohumu" -ForegroundColor Red; exit 1 }
    }
    if ($BosKurulum -and $Aktarim -contains $ad) {
      $r = Psql "_aktarim.sql" @{ dosya = $ad; ozet = $b.Ozet }
      if ($r.Kod -ne 0) { Write-Host $r.Cikti; exit 1 }
      $aktarimYok++; continue
    }
    $sarmal = if ($b.IslemDisi) { "_islemdisi.sql" } else { "_islemli.sql" }
    $r = Psql $sarmal @{ dosya = $ad; ozet = $b.Ozet; yol = ($KapDizin + "/" + $ad) }
    if ($r.Kod -ne 0) {
      Write-Host $r.Cikti
      if ($DisVeri.ContainsKey($ad)) {
        Write-Host ("DIS VERI BEKLENIYOR: " + $ad) -ForegroundColor Yellow
        Write-Host ("  " + $DisVeri[$ad]) -ForegroundColor Yellow
        Write-Host "  On kosul saglaninca ayni komutu yeniden calistirin - uygulananlar atlanir."
        exit 2
      }
      Write-Host ("HATA: goc basarisiz: " + $ad + $(if ($b.IslemDisi) { " (ISLEM DISI dosya: yalniz dosyanin KENDI BEGIN/COMMIT araligi geri alinir; disindaki ifadeler KALMIS olabilir - dosyayi inceleyin; defter yazilmadi)" } else { " (islem geri alindi, defter yazilmadi)" })) -ForegroundColor Red
      exit 1
    }
    if ($r.Cikti -match "GOC_ZATEN_UYGULANMIS") { $atlanan++; continue }
    Write-Host ("  goc: " + $ad + $(if ($b.IslemDisi) { " [islem disi]" } else { "" }))
    $uygulanan++
  }
  Write-Host ("goc: {0} uygulandi, {1} zaten uygulanmis, {2} aktarim adimi bos kurulumda atlandi" -f $uygulanan, $atlanan, $aktarimYok)
  exit 0
}
finally {
  Remove-Item $Gecici -Recurse -Force -ErrorAction SilentlyContinue
  if ($PgHost -eq "") { & docker exec $Kap rm -rf $KapDizin 2>$null | Out-Null }
}
