#!/bin/bash
# ============================================================================
#  DELPHI AKTARIMI PILOTU - sunucu hazirligi (bir kez, SUDO ILE):
#      scp yayin/nginx-delphi.conf yayin/delphi-pilot-hazirla.sh gentegre@46.36.201.170:/tmp/
#      ssh gentegre@46.36.201.170 "sudo bash /tmp/delphi-pilot-hazirla.sh"
#  Sonra yerelden: yayinla.ps1 -Kurulum delphi  (bos DB'ye tohum + butun gocler,
#  api konteyneri yoksa kurulur, web).
#
#  1. Bos veritabani gentegre_erp_delphi (UTF8 + ICU tr-TR, kur.ps1 ile ayni) -
#     VARSA DOKUNMAZ.
#  2. nginx /gentegreai/delphi/ bloklari - varsa yeniden yazmaz; nginx -t
#     dusurse site yedegi geri yuklenir.
# ============================================================================
set -euo pipefail
DB=gentegre_erp_delphi
SITE=/etc/nginx/sites-available/gentegre-mockup
PARCA=/tmp/nginx-delphi.conf

if docker exec gentegre-pg18 psql -U postgres -tAc "select 1 from pg_database where datname = '$DB'" | grep -q 1; then
    echo "DB zaten var: $DB (dokunulmadi)"
else
    docker exec gentegre-pg18 psql -U postgres -c "CREATE DATABASE $DB TEMPLATE template0 ENCODING 'UTF8' LOCALE_PROVIDER icu ICU_LOCALE 'tr-TR' LOCALE 'en_US.utf8'"
    echo "DB olusturuldu: $DB (bos - ilk yayin tohum + gocleri uygular)"
fi
mkdir -p /home/gentegre/gentegre-erp-delphi && chown gentegre:gentegre /home/gentegre/gentegre-erp-delphi

[ -f "$PARCA" ] || { echo "parca yok: $PARCA (once scp)" >&2; exit 1; }
if grep -q "location ^~ /gentegreai/delphi/" "$SITE"; then
    echo "nginx bloklari zaten ekli"
    exit 0
fi
YEDEK="$SITE.yedek-$(date +%Y%m%d-%H%M%S)"
cp "$SITE" "$YEDEK"; echo "yedek: $YEDEK"
python3 - "$SITE" "$PARCA" <<'PY'
import io, sys
site, parca = sys.argv[1], sys.argv[2]
s = io.open(site, encoding="utf-8").read()
p = io.open(parca, encoding="utf-8").read()
i = s.rstrip().rfind("}")          # server{} icine, son kapanistan once
io.open(site, "w", encoding="utf-8").write(s[:i] + "\n" + p + "\n" + s[i:])
PY
if nginx -t; then
    systemctl reload nginx
    echo "TAMAM: /gentegreai/delphi/ hazir - simdi yayinla.ps1 -Kurulum delphi"
else
    cp "$YEDEK" "$SITE"; nginx -t >/dev/null 2>&1 && systemctl reload nginx || true
    echo "HATA: nginx dogrulamasi dustu - yedek geri yuklendi ($YEDEK)" >&2
    exit 1
fi
