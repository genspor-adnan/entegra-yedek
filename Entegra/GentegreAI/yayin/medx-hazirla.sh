#!/bin/bash
# ============================================================================
#  MEDX KURULUMU - sunucu hazirligi (bir kez, SUDO ILE):
#      scp yayin/nginx-medx.conf yayin/medx-hazirla.sh MEDX.dump gentegre@46.36.201.170:/tmp/
#      ssh -t gentegre@46.36.201.170 "sed -i 's/\r$//' /tmp/medx-hazirla.sh && sudo bash /tmp/medx-hazirla.sh"
#  Sonra yerelden: yayinla.ps1 -Kurulum medx (web + api; gocler zaten uygulanmis).
#
#  1. Veritabani "MEDX" (UTF8 + ICU tr-TR) - VARSA DOKUNMAZ (veri ezilmez).
#  2. Yeni actiysa /tmp/MEDX.dump geri yuklenir (yerelde Delphi MEDX'dan
#     aktarilip mutabakatla dogrulanmis veritabani).
#  3. nginx /medx/ bloklari - varsa yeniden yazmaz; nginx -t dusurse yedek geri.
# ============================================================================
set -euo pipefail
DB=MEDX
SITE=/etc/nginx/sites-available/gentegre-mockup
PARCA=/tmp/nginx-medx.conf
DUMP=/tmp/MEDX.dump

if docker exec gentegre-pg18 psql -U postgres -tAc "select 1 from pg_database where datname = '$DB'" | grep -q 1; then
    echo "DB zaten var: $DB (dokunulmadi, geri yukleme YAPILMADI)"
else
    [ -f "$DUMP" ] || { echo "dump yok: $DUMP (once scp)" >&2; exit 1; }
    docker exec gentegre-pg18 psql -U postgres -c "CREATE DATABASE \"$DB\" TEMPLATE template0 ENCODING 'UTF8' LOCALE_PROVIDER icu ICU_LOCALE 'tr-TR' LOCALE 'en_US.utf8'"
    docker exec -i gentegre-pg18 pg_restore -U postgres -d "$DB" --no-owner < "$DUMP"
    docker exec gentegre-pg18 psql -U postgres -d "$DB" -c "alter database \"$DB\" set timezone to 'UTC'"
    echo "DB kuruldu ve geri yuklendi: $DB ($(docker exec gentegre-pg18 psql -U postgres -d "$DB" -tAc 'select count(*) from public.goc_gecmisi') goc kayitli)"
fi
mkdir -p /home/gentegre/gentegre-medx && chown gentegre:gentegre /home/gentegre/gentegre-medx

[ -f "$PARCA" ] || { echo "parca yok: $PARCA (once scp)" >&2; exit 1; }
if grep -q "location ^~ /medx/" "$SITE"; then
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
i = s.rstrip().rfind("}")
io.open(site, "w", encoding="utf-8").write(s[:i] + "\n" + p + "\n" + s[i:])
PY
if nginx -t; then
    systemctl reload nginx
    echo "TAMAM: /medx/ hazir - simdi yayinla.ps1 -Kurulum medx"
else
    cp "$YEDEK" "$SITE"; nginx -t >/dev/null 2>&1 && systemctl reload nginx || true
    echo "HATA: nginx dogrulamasi dustu - yedek geri yuklendi ($YEDEK)" >&2
    exit 1
fi
