#!/bin/bash
# ============================================================================
#  IKI KURULUM nginx bloklarini mevcut siteye ekler. SUDO ILE calistirilir:
#      sudo bash ~/nginx-ikili-uygula.sh
#
#  Ne yapar:
#    1. Siteyi yedekler.
#    2. /genotipai/ ve /gentegreai/ bloklarini server{} icine ekler.
#    3. ESKI /ai/ bloklarini KALDIRIR ve yerine /genotipai/ya 301 koyar -
#       kaydedilmis yer imleri kirilmasin.
#    4. nginx -t ile dogrular; hata varsa YEDEGI GERI YUKLER ve cikar.
#
#  Betik tekrar tekrar calistirilabilir: bloklar zaten varsa dokunmaz.
# ============================================================================
set -euo pipefail

SITE=/etc/nginx/sites-available/gentegre-mockup
PARCA=/tmp/nginx-ikili.conf
YEDEK="$SITE.yedek-$(date +%Y%m%d-%H%M%S)"

[ -f "$SITE" ]  || { echo "site yok: $SITE" >&2; exit 1; }
[ -f "$PARCA" ] || { echo "parca yok: $PARCA (once scp ile yukleyin)" >&2; exit 1; }

cp "$SITE" "$YEDEK"
echo "yedek: $YEDEK"

python3 - "$SITE" "$PARCA" <<'PY'
import io, re, sys
site, parca = sys.argv[1], sys.argv[2]
s = io.open(site, encoding="utf-8").read()
p = io.open(parca, encoding="utf-8").read()

if "location ^~ /genotipai/" in s:
    print("bloklar zaten ekli - yalniz /ai yonlendirmesi kontrol edilecek")
else:
    # server{} icine, SON kapanis suslu parantezinden hemen ONCE.
    i = s.rstrip().rfind("}")
    s = s[:i] + "\n" + p + "\n" + s[i:]

# ESKI /ai BLOKLARI: iki location (api + statik) ve = /ai yonlendirmesi.
#   Yerlerine tek bir 301 konur; adres degisti ama link olmedi.
s = re.sub(r"\n[ \t]*location \^~ /ai/api/ \{.*?\n[ \t]*\}\n", "\n", s, flags=re.S)
s = re.sub(r"\n[ \t]*location \^~ /ai/ \{.*?\n[ \t]*\}\n", "\n", s, flags=re.S)
s = re.sub(r"\n[ \t]*location = /ai \{[^}]*\}\n", "\n", s)

if "location ^~ /ai/ { return 301" not in s:
    yon = ('\n    # ESKI ADRES (tek kurulum donemi): yer imleri kirilmasin.\n'
           '    location ^~ /ai/ { return 301 /genotipai/; }\n'
           '    location = /ai  { return 301 /genotipai/; }\n')
    i = s.rstrip().rfind("}")
    s = s[:i] + yon + s[i:]

io.open(site, "w", encoding="utf-8").write(s)
print("site guncellendi")
PY

if nginx -t; then
    systemctl reload nginx
    echo "TAMAM: /genotipai/ ve /gentegreai/ yayinda (/ai -> /genotipai/)"
else
    cp "$YEDEK" "$SITE"
    nginx -t >/dev/null 2>&1 && systemctl reload nginx || true
    echo "HATA: nginx dogrulamasi dustu - yedek geri yuklendi ($YEDEK)" >&2
    exit 1
fi
