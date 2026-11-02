#!/bin/bash
# ============================================================================
#  TLS (kod inceleme 30.10.2026 K09): IP sitesindeki düz HTTP girişi kapatır.
#  SUDO ile:   sudo bash /tmp/nginx-tls-uygula.sh
#  Geri alma:  sudo bash /tmp/nginx-tls-uygula.sh --geri
#  Deneme:     bash nginx-tls-uygula.sh --donustur <mockup> <mockup.yeni> <firma> <firma.yeni>   (kök gerekmez)
#
#  Önce: http://46.36.201.170/<yol>/ yalnız 80'de (giriş parolası ve token düz metin gidiyordu).
#  Sonra:
#    - IP sitesi (mockup + /genotipai + /gentegreai + delphi pilotu ...) AYNI içerikle
#      https://demo.gentegreai.com adıyla da sunulur (Cloudflare Origin sertifikası *.gentegreai.com).
#    - http://46.36.201.170/... SAYFA istekleri 301:
#          /feta|zone|medx|bilim/...  ->  https://<kod>.gentegreai.com/<kod>/...   (müşteri, basic auth yok)
#          geri kalanı                ->  https://demo.gentegreai.com/...          (basic auth sürer)
#    - /.../api/ yolları IP'de HTTP'de KALIR (geçici): Delphi aktarım ajanı / cihazlar POST eder,
#      301 POST'u GET'e çevirip bozardı. Tarayıcı artık HTTPS sayfadan aynı kökene gider.
#      Ajanlar https adresine geçirilince bu istisna kaldırılmalı.
#    - BİLİM firma haritasına eklenir: https://bilim.gentegreai.com/bilim/
#  Yönlendirme yalnız Host gentegreai.com DEĞİLKEN çalışır: Cloudflare "Flexible" modda origin'e
#  80'den gelse de döngü olmaz.
#
#  Her adımda yedek alınır, `nginx -t` geçmezse yedek geri yüklenir.
# ============================================================================
set -euo pipefail
MOCKUP=/etc/nginx/sites-available/gentegre-mockup
FIRMA=/etc/nginx/sites-available/gentegreai
DAMGA=$(date +%Y%m%d-%H%M%S)
ISARET="# TLS-K09"

# ---------------------------------------------------------------- dönüşümler --
# Gerçek uygulama ve --donustur deneme kipi AYNI kodu kullanır.
mockup_donustur() {   # $1 giris  $2 cikis
    awk -v isaret="$ISARET" '
        !yapildi && /^[[:space:]]*server_name _;/ {
            print "    server_name _ demo.gentegreai.com;   " isaret
            print "    include /etc/nginx/gentegreai-ssl*.conf;   " isaret " Cloudflare Origin (*.gentegreai.com)"
            print "    " isaret ": IP adresine HTTP ile gelen SAYFA istekleri HTTPS alan adina (API yollari haric)."
            print "    set $tls_yon \"\";"
            print "    set $tls_kod \"\";"
            print "    if ($host !~* \"gentegreai[.]com$\") { set $tls_yon \"ip\"; }"
            print "    if ($request_uri ~ \"/api/\") { set $tls_yon \"\"; }"
            print "    if ($request_uri ~ \"^/(feta|zone|medx|bilim)([/?]|$)\") { set $tls_kod $1; }"
            print "    set $tls_yer \"${tls_yon}:${tls_kod}\";"
            print "    if ($tls_yer = \"ip:\") { return 301 https://demo.gentegreai.com$request_uri; }"
            print "    if ($tls_yer ~ \"^ip:(.+)$\") { return 301 https://$1.gentegreai.com$request_uri; }"
            yapildi = 1; next
        }
        { print }' "$1" > "$2"
    grep -q "$ISARET" "$2"
}

firma_donustur() {    # $1 giris  $2 cikis
    awk -v isaret="$ISARET" '
        { print }
        !yapildi && /^[[:space:]]*medx[[:space:]]+5185;/ { print "    bilim   5182;   " isaret; yapildi = 1 }' "$1" > "$2"
    grep -qE "^[[:space:]]*bilim[[:space:]]+5182;" "$2"
}

if [ "${1:-}" = "--donustur" ]; then
    mockup_donustur "$2" "$3"
    firma_donustur "$4" "$5"
    echo "donusturuldu"
    exit 0
fi

# ------------------------------------------------------------------ uygulama --
[ "$(id -u)" = 0 ] || { echo "sudo ile calistirin: sudo bash $0" >&2; exit 1; }

if [ "${1:-}" = "--geri" ]; then
    son_m=$(ls -1t "$MOCKUP".tls-yedek-* 2>/dev/null | head -1 || true)
    son_f=$(ls -1t "$FIRMA".tls-yedek-* 2>/dev/null | head -1 || true)
    [ -n "$son_m" ] && cp "$son_m" "$MOCKUP"
    [ -n "$son_f" ] && cp "$son_f" "$FIRMA"
    nginx -t && systemctl reload nginx && echo "GERI ALINDI ($son_m, $son_f)"
    exit 0
fi

if grep -q "$ISARET" "$MOCKUP"; then
    echo "TLS bloklari zaten uygulanmis ($MOCKUP) - degisiklik yok."
else
    cp "$MOCKUP" "$MOCKUP.tls-yedek-$DAMGA"
    mockup_donustur "$MOCKUP.tls-yedek-$DAMGA" "$MOCKUP" \
        || { cp "$MOCKUP.tls-yedek-$DAMGA" "$MOCKUP"; echo "server_name _; bulunamadi" >&2; exit 1; }
fi

if grep -qE "^[[:space:]]*bilim[[:space:]]+5182;" "$FIRMA"; then
    echo "bilim firma haritasinda zaten var."
else
    cp "$FIRMA" "$FIRMA.tls-yedek-$DAMGA"
    firma_donustur "$FIRMA.tls-yedek-$DAMGA" "$FIRMA" \
        || { cp "$FIRMA.tls-yedek-$DAMGA" "$FIRMA"; echo "harita satiri eklenemedi" >&2; exit 1; }
fi

if ! nginx -t; then
    echo "nginx -t BASARISIZ - yedekler geri yukleniyor" >&2
    [ -f "$MOCKUP.tls-yedek-$DAMGA" ] && cp "$MOCKUP.tls-yedek-$DAMGA" "$MOCKUP"
    [ -f "$FIRMA.tls-yedek-$DAMGA" ] && cp "$FIRMA.tls-yedek-$DAMGA" "$FIRMA"
    nginx -t; exit 1
fi
systemctl reload nginx

# Doğrulama (sunucunun kendisinden; Host başlığıyla)
k() { curl -s -o /dev/null -w "%{http_code} %{redirect_url}" -m 5 "$@"; }
echo "IP sayfa  : $(k -H 'Host: 46.36.201.170' http://127.0.0.1/feta/)"
echo "IP demo   : $(k -H 'Host: 46.36.201.170' http://127.0.0.1/genotipai/)"
echo "IP api    : $(k -H 'Host: 46.36.201.170' -X POST http://127.0.0.1/feta/api/kimlik/giris -H 'Content-Type: application/json' -d '{}')"
echo "demo https: $(k -k --resolve demo.gentegreai.com:443:127.0.0.1 https://demo.gentegreai.com/)"
echo "bilim     : $(k -k --resolve bilim.gentegreai.com:443:127.0.0.1 https://bilim.gentegreai.com/bilim/)"
echo "TAMAM: TLS yonlendirmeleri yuklendi. Geri almak: sudo bash $0 --geri"
