#!/bin/bash
# ============================================================================
#  BILIM - eski Delphi aktarimi pilotunun (/gentegreai/delphi/) yeni adi.
#  Sunucu nginx hazirligi (bir kez, SUDO ILE):
#      scp yayin/nginx-bilim.conf yayin/bilim-hazirla.sh gentegre@46.36.201.170:/tmp/
#      ssh -t gentegre@46.36.201.170 "sed -i 's/\r$//' /tmp/bilim-hazirla.sh && sudo bash /tmp/bilim-hazirla.sh"
#
#  DB / klasor / konteyner adlari sudo istemez, ayrica yapilir:
#      gentegre_erp_delphi -> "BILIM", ~/gentegre-erp-delphi -> ~/gentegre-bilim,
#      gentegre-api-erp-delphi -> gentegre-api-bilim (ilk yayin kurar).
#
#  1. /bilim/ bloklari eklenir (varsa yeniden yazilmaz).
#  2. Eski /gentegreai/delphi/ WEB blogu /bilim/'e 301 yonlendirmeye cevrilir.
#     Eski /gentegreai/delphi/api/ blogu AYNEN kalir (5182): Delphi tarafindaki
#     aktarim ajaninin ApiAdres ayari degismeden calismaya devam eder.
#  3. nginx -t dusurse site yedegi geri yuklenir.
# ============================================================================
set -euo pipefail
SITE=/etc/nginx/sites-available/gentegre-mockup
PARCA=/tmp/nginx-bilim.conf

[ -f "$PARCA" ] || { echo "parca yok: $PARCA (once scp)" >&2; exit 1; }
YEDEK="$SITE.yedek-$(date +%Y%m%d-%H%M%S)"
cp "$SITE" "$YEDEK"; echo "yedek: $YEDEK"

python3 - "$SITE" "$PARCA" <<'PY'
import io, re, sys
site, parca = sys.argv[1], sys.argv[2]
s = io.open(site, encoding="utf-8").read()
p = io.open(parca, encoding="utf-8").read()

# Eski web blogu -> yonlendirme (api blogu ^~ /gentegreai/delphi/api/ daha uzun onek, ona dokunulmaz).
eski = re.compile(r"location \^~ /gentegreai/delphi/ \{[^}]*\}")
if eski.search(s):
    s = eski.sub("location ^~ /gentegreai/delphi/ { return 301 /bilim/; }", s, count=1)
    print("eski /gentegreai/delphi/ web blogu -> 301 /bilim/")
s = s.replace("location = /gentegreai/delphi { return 301 /gentegreai/delphi/; }",
              "location = /gentegreai/delphi { return 301 /bilim/; }")

if "location ^~ /bilim/" in s:
    print("/bilim/ bloklari zaten ekli")
else:
    i = s.rstrip().rfind("}")          # server{} icine, son kapanistan once
    s = s[:i] + "\n" + p + "\n" + s[i:]
    print("/bilim/ bloklari eklendi")
io.open(site, "w", encoding="utf-8").write(s)
PY

if nginx -t; then
    systemctl reload nginx
    echo "TAMAM: /bilim/ hazir"
else
    cp "$YEDEK" "$SITE"; nginx -t >/dev/null 2>&1 && systemctl reload nginx || true
    echo "HATA: nginx dogrulamasi dustu - yedek geri yuklendi ($YEDEK)" >&2
    exit 1
fi
