# ============================================================================
#  Gentegre izleme betiğini sunucuya kurar / günceller.
#
#    powershell -ExecutionPolicy Bypass -File yayin\izleme-kur.ps1            # kur / güncelle
#    powershell -ExecutionPolicy Bypass -File yayin\izleme-kur.ps1 -Dene      # + deneme alarmı
#    powershell -ExecutionPolicy Bypass -File yayin\izleme-kur.ps1 -Durum     # sunucudaki anlık durum
#
#  Ne yapar:
#   - izleme.sh'i ~/izleme/'ye kopyalar (LF satır sonuyla), chmod 700
#   - ~/izleme/izleme.conf YOKSA örneği koyar (600). VARSA DOKUNMAZ - Telegram anahtarı orada.
#   - kullanıcının crontab'ına 5 dakikada bir satırını ekler (zaten varsa eklemez). sudo gerekmez.
#
#  Telegram anahtarı / sohbet no depoya ve bu betiğe YAZILMAZ: sunucuda izleme.conf düzenlenir
#    ssh gentegre@46.36.201.170  ->  nano ~/izleme/izleme.conf
# ============================================================================
param(
    [string]$Sunucu = 'gentegre@46.36.201.170',
    [switch]$Dene,
    [switch]$Durum
)
$ErrorActionPreference = 'Stop'
$burasi = $PSScriptRoot

function LfKopya($kaynak, $ad) {
    $hedef = Join-Path $env:TEMP $ad
    [IO.File]::WriteAllText($hedef, ((Get-Content $kaynak -Raw -Encoding UTF8) -replace "`r`n", "`n"),
                            (New-Object Text.UTF8Encoding $false))
    return $hedef
}

if ($Durum) {
    ssh $Sunucu 'bash ~/izleme/izleme.sh --durum'
    exit $LASTEXITCODE
}

$betik = LfKopya (Join-Path $burasi 'izleme.sh') 'izleme.sh'
$ornek = LfKopya (Join-Path $burasi 'izleme.conf.ornek') 'izleme.conf.ornek'

ssh $Sunucu 'mkdir -p ~/izleme/durum && chmod 700 ~/izleme'
if ($LASTEXITCODE -ne 0) { throw 'sunucuya baglanilamadi' }
scp -q $betik $ornek "${Sunucu}:~/izleme/"
if ($LASTEXITCODE -ne 0) { throw 'scp basarisiz' }

$kur = @'
set -e
chmod 700 ~/izleme/izleme.sh
if [ ! -f ~/izleme/izleme.conf ]; then
    cp ~/izleme/izleme.conf.ornek ~/izleme/izleme.conf
    echo "izleme.conf ORNEKTEN olusturuldu - Telegram anahtarini girin: nano ~/izleme/izleme.conf"
fi
chmod 600 ~/izleme/izleme.conf
SATIR='*/5 * * * * bash $HOME/izleme/izleme.sh >/dev/null 2>&1'
# Mevcut satirlar korunur; grep bos donerse (crontab bos) set -e betigi DURDURMASIN.
{ crontab -l 2>/dev/null | grep -v 'izleme/izleme.sh' || true; echo "$SATIR"; } | crontab -
crontab -l | grep -q izleme/izleme.sh || { echo "crontab satiri YAZILAMADI" >&2; exit 1; }
echo "crontab: $(crontab -l | grep izleme)"
'@
# DOSYA OLARAK gider: PowerShell 5.1 ssh argumanindaki tirnaklari dusuruyor, cron satirindaki `*` uzakta
#   glob olarak genisleyip "bad hour" veriyordu.
$kurDosya = Join-Path $env:TEMP 'izleme-kur.sh'
[IO.File]::WriteAllText($kurDosya, ($kur -replace "`r`n", "`n"), (New-Object Text.UTF8Encoding $false))
scp -q $kurDosya "${Sunucu}:~/izleme/kur.sh"
if ($LASTEXITCODE -ne 0) { throw 'scp basarisiz' }
ssh $Sunucu 'bash ~/izleme/kur.sh; r=$?; rm -f ~/izleme/kur.sh; exit $r'
if ($LASTEXITCODE -ne 0) { throw 'kurulum adimi basarisiz' }

ssh $Sunucu 'bash ~/izleme/izleme.sh --durum'
if ($Dene) { ssh $Sunucu 'bash ~/izleme/izleme.sh --dene' }
Write-Host "IZLEME KURULDU -> ~/izleme (5 dakikada bir)"
