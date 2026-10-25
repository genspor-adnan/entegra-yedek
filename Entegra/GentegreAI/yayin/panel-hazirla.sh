#!/bin/bash
# ============================================================================
#  ORTAK GİRİŞ PANELİ + gentegreai.com ALT ALAN ADLARI - sunucu hazırlığı (SUDO İLE, kullanıcının KENDİ terminalinde)
#      scp yayin/nginx-gentegreai.conf yayin/panel-hazirla.sh gentegre@46.36.201.170:/tmp/
#      scp panel/index.html gentegre@46.36.201.170:/tmp/panel-index.html
#      ssh -t gentegre@46.36.201.170 "sudo bash /tmp/panel-hazirla.sh"             # 1) nginx + panel (HTTP)
#      ssh -t gentegre@46.36.201.170 "sudo bash /tmp/panel-hazirla.sh sertifika"   # 2) DNS çözülünce HTTPS
#
#  1) /etc/nginx/sites-available/gentegreai (+ sites-enabled bağı); ~/gentegre-panel/index.html.
#     nginx -t düşerse eski hal geri yüklenir. IP üzerindeki mevcut site (gentegre-mockup) DEĞİŞMEZ.
#  2) sertifika: certbot yoksa kurulur; panel + kayıtlı firma alt alan adları için Let's Encrypt (otomatik
#     yenilenir), http -> https yönlendirmesi. Önce DNS: *.gentegreai.com A 46.36.201.170.
# ============================================================================
set -euo pipefail
SITE=/etc/nginx/sites-available/gentegreai
BAG=/etc/nginx/sites-enabled/gentegreai
PARCA=/tmp/nginx-gentegreai.conf
PANEL=/home/gentegre/gentegre-panel
ALANLAR="panel feta zone medx"

if [ "${1:-}" = "sertifika" ]; then
    for a in $ALANLAR; do
        getent hosts "$a.gentegreai.com" >/dev/null || { echo "DNS yok: $a.gentegreai.com (once *.gentegreai.com A kaydi)" >&2; exit 1; }
    done
    command -v certbot >/dev/null || { apt-get update -q && apt-get install -y -q certbot python3-certbot-nginx; }
    ARG=""; for a in $ALANLAR; do ARG="$ARG -d $a.gentegreai.com"; done
    certbot --nginx --non-interactive --agree-tos --register-unsafely-without-email --redirect $ARG
    echo "TAMAM: HTTPS hazir - https://panel.gentegreai.com"
    exit 0
fi

[ -f "$PARCA" ] || { echo "parca yok: $PARCA (once scp)" >&2; exit 1; }
[ -f /tmp/panel-index.html ] || { echo "panel sayfasi yok: /tmp/panel-index.html (once scp)" >&2; exit 1; }

mkdir -p "$PANEL"
cp /tmp/panel-index.html "$PANEL/index.html"
chown -R gentegre:gentegre "$PANEL"; chmod 755 "$PANEL"; chmod 644 "$PANEL/index.html"
# nginx (www-data) firma web klasörlerini okuyabilmeli (mevcut alias'lar zaten okuyor)
chmod o+x /home/gentegre || true

YEDEK=""
if [ -f "$SITE" ]; then YEDEK="$SITE.yedek-$(date +%Y%m%d-%H%M%S)"; cp "$SITE" "$YEDEK"; echo "yedek: $YEDEK"; fi
cp "$PARCA" "$SITE"
ln -sf "$SITE" "$BAG"
if nginx -t; then
    systemctl reload nginx
    echo "TAMAM: panel ve gentegreai.com bloklari yuklendi (HTTP). DNS gelince: sudo bash /tmp/panel-hazirla.sh sertifika"
else
    if [ -n "$YEDEK" ]; then cp "$YEDEK" "$SITE"; else rm -f "$SITE" "$BAG"; fi
    nginx -t >/dev/null 2>&1 && systemctl reload nginx || true
    echo "HATA: nginx dogrulamasi dustu - eski hal geri yuklendi" >&2
    exit 1
fi
