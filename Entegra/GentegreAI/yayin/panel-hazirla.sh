#!/bin/bash
# ============================================================================
#  ORTAK GİRİŞ PANELİ + gentegreai.com ALT ALAN ADLARI - sunucu hazırlığı (SUDO İLE, kullanıcının KENDİ terminalinde)
#      scp yayin/nginx-gentegreai.conf yayin/panel-hazirla.sh gentegre@46.36.201.170:/tmp/
#      scp panel/index.html gentegre@46.36.201.170:/tmp/panel-index.html
#      ssh -t gentegre@46.36.201.170 "sudo bash /tmp/panel-hazirla.sh"             # 1) nginx + panel (HTTP)
#      scp gentegreai-origin.pem gentegreai-origin.key gentegre@46.36.201.170:/tmp/
#      ssh -t gentegre@46.36.201.170 "sudo bash /tmp/panel-hazirla.sh cloudflare"  # 2) HTTPS (Cloudflare Origin)
#
#  1) /etc/nginx/sites-available/gentegreai (+ sites-enabled bağı); ~/gentegre-panel/index.html.
#     nginx -t düşerse eski hal geri yüklenir. IP üzerindeki mevcut site (gentegre-mockup) DEĞİŞMEZ.
#  2) cloudflare: DNS Cloudflare'de (gentegreai.com + * , turuncu bulut); Cloudflare Origin sertifikası 443'e,
#     joker (*.gentegreai.com) ve 15 yıl - yeni müşteri için sertifika / DNS işi yok.
# ============================================================================
set -euo pipefail
SITE=/etc/nginx/sites-available/gentegreai
BAG=/etc/nginx/sites-enabled/gentegreai
PARCA=/tmp/nginx-gentegreai.conf
PANEL=/home/gentegre/gentegre-panel

if [ "${1:-}" = "cloudflare" ]; then
    # HTTPS - Cloudflare Origin sertifikası (gentegreai.com + *.gentegreai.com, 15 yıl; yenileme yok). Cloudflare
    #   panelinden alınan sertifika ve anahtar önce /tmp'ye: gentegreai-origin.pem, gentegreai-origin.key
    [ -f /tmp/gentegreai-origin.pem ] && [ -f /tmp/gentegreai-origin.key ] || {
        echo "sertifika yok: /tmp/gentegreai-origin.pem + /tmp/gentegreai-origin.key (Cloudflare > SSL/TLS > Origin Server)" >&2; exit 1; }
    grep -q "BEGIN CERTIFICATE" /tmp/gentegreai-origin.pem || { echo "pem bozuk" >&2; exit 1; }
    grep -q "PRIVATE KEY" /tmp/gentegreai-origin.key || { echo "anahtar bozuk" >&2; exit 1; }
    mkdir -p /etc/ssl/gentegreai
    install -m 644 /tmp/gentegreai-origin.pem /etc/ssl/gentegreai/origin.pem
    install -m 600 /tmp/gentegreai-origin.key /etc/ssl/gentegreai/origin.key
    shred -u /tmp/gentegreai-origin.key 2>/dev/null || rm -f /tmp/gentegreai-origin.key
    cat > /etc/nginx/gentegreai-ssl.conf <<'SSL'
listen 443 ssl http2;
ssl_certificate     /etc/ssl/gentegreai/origin.pem;
ssl_certificate_key /etc/ssl/gentegreai/origin.key;
ssl_protocols       TLSv1.2 TLSv1.3;
SSL
    if command -v ufw >/dev/null && ufw status | grep -q "Status: active"; then ufw allow 443/tcp; fi
    if nginx -t; then
        systemctl reload nginx
        echo "TAMAM: 443 acik (Cloudflare Origin). Cloudflare'de SSL/TLS modu: Full (strict); 'Always Use HTTPS' acik."
    else
        rm -f /etc/nginx/gentegreai-ssl.conf; nginx -t >/dev/null 2>&1 && systemctl reload nginx || true
        echo "HATA: nginx dogrulamasi dustu - 443 eklenmedi" >&2; exit 1
    fi
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
    echo "TAMAM: panel ve gentegreai.com bloklari yuklendi (HTTP). HTTPS: sudo bash /tmp/panel-hazirla.sh cloudflare"
else
    if [ -n "$YEDEK" ]; then cp "$YEDEK" "$SITE"; else rm -f "$SITE" "$BAG"; fi
    nginx -t >/dev/null 2>&1 && systemctl reload nginx || true
    echo "HATA: nginx dogrulamasi dustu - eski hal geri yuklendi" >&2
    exit 1
fi
