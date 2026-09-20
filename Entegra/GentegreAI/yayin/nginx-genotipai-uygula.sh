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

# 1) ESKI tek-HBYS /genotipai/ bloklari (profil ALT yollari DEGIL) kaldirilir.
#    Profil bloklari '/genotipai/<ad>/' icerir; eskiler tam '/genotipai/'dir.
s = re.sub(r"\n[ \t]*location \^~ /genotipai/api/ \{.*?\n[ \t]*\}\n", "\n", s, flags=re.S)
s = re.sub(r"\n[ \t]*location \^~ /genotipai/ \{.*?\n[ \t]*\}\n", "\n", s, flags=re.S)
s = re.sub(r"\n[ \t]*location = /genotipai \{[^}]*\}\n", "\n", s)
s = re.sub(r"\n[ \t]*location = /genotipai/ \{.*?\n[ \t]*\}\n", "\n", s, flags=re.S)

# 2) Profil bloklari zaten ekliyse dokunma.
if "location ^~ /genotipai/hastane/" in s:
    print("profil bloklari zaten ekli - eskiler temizlendi")
else:
    i = s.rstrip().rfind("}")           # server{} son kapanisi
    s = s[:i] + "\n" + p + "\n" + s[i:]
    print("profil bloklari eklendi")

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
