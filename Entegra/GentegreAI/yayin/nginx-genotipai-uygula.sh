#!/bin/bash
# ============================================================================
#  /genotipai PROFIL bloklarini siteye uygular. SUDO ILE:
#      sudo bash ~/nginx-genotipai-uygula.sh
#
#  Ne yapar:
#    1. Siteyi yedekler.
#    2. ESKI tek-HBYS /genotipai/ bloklarini (api + statik + =) KALDIRIR.
#    3. Yeni 7 profil bloku + /genotipai/ landing'i server{} icine ekler.
#    4. Landing HTML'i /home/gentegre/genotipai-landing/index.html'e koyar.
#    5. nginx -t; hata varsa YEDEGI GERI YUKLER.
#
#  Once scp ile: nginx-genotipai-profiller.conf -> /tmp/,
#                genotipai-landing-index.html   -> /tmp/.
#  Tekrar calistirilabilir (bloklar varsa yeniden yazmaz).
# ============================================================================
set -euo pipefail

SITE=/etc/nginx/sites-available/gentegre-mockup
PARCA=/tmp/nginx-genotipai-profiller.conf
LANDING_SRC=/tmp/genotipai-landing-index.html
LANDING_DIR=/home/gentegre/genotipai-landing
YEDEK="$SITE.yedek-$(date +%Y%m%d-%H%M%S)"

[ -f "$SITE" ]  || { echo "site yok: $SITE" >&2; exit 1; }
[ -f "$PARCA" ] || { echo "parca yok: $PARCA (once scp)" >&2; exit 1; }

cp "$SITE" "$YEDEK"; echo "yedek: $YEDEK"

# Landing dosyasi.
mkdir -p "$LANDING_DIR"
[ -f "$LANDING_SRC" ] && { cp "$LANDING_SRC" "$LANDING_DIR/index.html"; chmod -R a+rX "$LANDING_DIR"; echo "landing kondu"; }

python3 - "$SITE" "$PARCA" <<'PY'
import io, re, sys
site, parca = sys.argv[1], sys.argv[2]
s = io.open(site, encoding="utf-8").read()
p = io.open(parca, encoding="utf-8").read()

# TUM /genotipai... location bloklari KALDIRILIR (bare + profil + api + =),
#   sonra guncel parca TEK SEFER eklenir. Boylece yeni profil eklemek /
#   degistirmek icin tekrar calistirmak yeter - eski bloklar duplike olmaz.
#   Bu location bloklarinda ic-ice { } yok, [^}]* yeterli.
n = len(re.findall(r"location[^\n{]*genotipai", s))
# DESEN `\n` ILE BASLAMAZ (07.10.2026'da bulunan hata): eski hali satir
#   sonundaki `\n`'i tuketip bir SONRAKI blogun basindaki `\n`'i yok ediyordu;
#   ardisik bloklarin yarisi silinmeden kaliyor, guncel parca eklenince nginx
#   "duplicate location" diyor ve betik yedegi geri yukluyordu. Gorunen sonuc:
#   calistirdiginiz halde yeni profil (goruntuleme, muayene) siteye hic girmez.
s = re.sub(r"[ \t]*location[^\n{]*genotipai[^\n{]*\{[^{}]*\}[ \t]*\n", "", s)
s = re.sub(r"[ \t]*location = /genotipai \{[^{}]*\}[ \t]*\n", "", s)

kalan = re.findall(r"location[^\n{]*genotipai", s)
if kalan:
    # Temizlik yarim kalirsa parcayi eklemek duplicate uretir: siteye hic
    #   dokunmadan dur - nginx -t hatasindan sonra geri almak degil, hic
    #   bozmamak dogru.
    sys.stderr.write("HATA: su genotipai bloklari temizlenemedi, site DEGISTIRILMEDI:\n")
    for k in kalan[:10]:
        sys.stderr.write("   " + k.strip() + "\n")
    sys.exit(2)

i = s.rstrip().rfind("}")               # server{} son kapanisi
s = s[:i] + "\n" + p + "\n" + s[i:]
print(f"eski {n} genotipai bloku temizlendi, guncel parca eklendi")

io.open(site, "w", encoding="utf-8").write(s)
PY

if nginx -t; then
    systemctl reload nginx
    echo "TAMAM: /genotipai/<profil>/ yayinda (landing: /genotipai/)"
else
    echo "nginx -t BASARISIZ - yedek geri yukleniyor" >&2
    cp "$YEDEK" "$SITE"
    nginx -t && systemctl reload nginx || true
    exit 1
fi
