#!/usr/bin/env bash
# ============================================================================
#  Gentegre AI mockup — alan adi + HTTPS kurulumu   (gentegreai.com)
#
#  Calistirma:  ssh gentegre@46.36.201.170 'bash ~/alanadi.sh'
#  Sartlar   :  1) kur.sh ile site zaten yayinda olmali (/var/www/gentegre-mockup)
#               2) DNS A kaydi sunucunun IP'sine bakiyor olmali (asagida kontrol edilir)
#
#  Ne yapar  :  - nginx'i alan adiyla yeniden yapilandirir
#               - Let's Encrypt sertifikasi alir (certbot, webroot yontemi)
#               - http -> https ve www -> apex yonlendirmesi kurar
#               - otomatik yenilemeyi kurar, 443 portunu acar
#               - basic auth (kullanici/parola) aynen korunur
#
#  Yeniden calistirilabilir; sertifika varsa yeniden almaz.
# ============================================================================
set -euo pipefail

# ---------------------------------------------------------------- ayarlar
ALAN="${ALAN:-gentegreai.com}"
WWW="${WWW:-www.$ALAN}"
EPOSTA="${EPOSTA:-genoproje@gmail.com}"     # Let's Encrypt uyari e-postasi
KOK="${KOK:-/var/www/gentegre-mockup}"
SITE="${SITE:-gentegre-mockup}"
ACMEKOK="${ACMEKOK:-/var/www/certbot}"
ZORLA_HTTPS="${ZORLA_HTTPS:-1}"             # 0 yapilirsa http acik kalir
# ------------------------------------------------------------------------

bilgi(){ printf '\033[1;34m==>\033[0m %s\n' "$*"; }
uyar(){ printf '\033[1;33m!!\033[0m %s\n' "$*"; }
hata(){ printf '\033[1;31mHATA:\033[0m %s\n' "$*" >&2; exit 1; }

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  command -v sudo >/dev/null || hata "root degilsiniz ve sudo yok"
  SUDO="sudo"
fi

[ -d "$KOK" ] || hata "site dizini yok: $KOK  — once kur.sh calistirilmali"

# ---- 1. paketler ----------------------------------------------------------
EKSIK=""
command -v nginx   >/dev/null || EKSIK="$EKSIK nginx"
command -v certbot >/dev/null || EKSIK="$EKSIK certbot"
command -v dig     >/dev/null || command -v getent >/dev/null || EKSIK="$EKSIK dnsutils"
if [ -n "$EKSIK" ]; then
  bilgi "kuruluyor:$EKSIK"
  $SUDO apt-get update -qq
  $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $EKSIK
fi

# ---- 2. DNS kontrolu ------------------------------------------------------
coz(){
  if command -v dig >/dev/null; then dig +short A "$1" | tail -n1
  else getent ahostsv4 "$1" 2>/dev/null | awk 'NR==1{print $1}'; fi
}
SUNUCU_IP="$(curl -fsS --max-time 8 https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')"
bilgi "sunucu IP : $SUNUCU_IP"

A_ALAN="$(coz "$ALAN" || true)"
A_WWW="$(coz "$WWW" || true)"
bilgi "$ALAN -> ${A_ALAN:-(yok)}"
bilgi "$WWW -> ${A_WWW:-(yok)}"

if [ "$A_ALAN" != "$SUNUCU_IP" ]; then
  echo
  uyar "$ALAN bu sunucuya bakmiyor."
  echo "   Alan adi panelinde su kayitlari ekleyin, sonra bu betigi tekrar calistirin:"
  echo "     Tur  Ad    Deger"
  echo "     A    @     $SUNUCU_IP"
  echo "     A    www   $SUNUCU_IP"
  echo "   DNS yayilmasi 5 dk - 24 saat surebilir."
  hata "DNS hazir degil — kurulum durduruldu"
fi

ALANLAR="-d $ALAN"
if [ "$A_WWW" = "$SUNUCU_IP" ]; then
  ALANLAR="$ALANLAR -d $WWW"
else
  uyar "$WWW bu sunucuya bakmiyor — sertifikaya dahil edilmeyecek"
  WWW=""
fi

# ---- 3. ACME dogrulama dizini + gecici http yapilandirmasi ---------------
$SUDO mkdir -p "$ACMEKOK/.well-known/acme-challenge"
$SUDO chown -R www-data:www-data "$ACMEKOK"

IPV6_80=""; IPV6_443=""
if [ -f /proc/net/if_inet6 ] && [ -s /proc/net/if_inet6 ]; then
  IPV6_80="    listen [::]:80;"
  IPV6_443="    listen [::]:443 ssl;"
fi

SUNUCUADI="$ALAN"; [ -n "$WWW" ] && SUNUCUADI="$ALAN $WWW"

# ortak govde (iki yapilandirmada da ayni) — degisken genisletme YAPILMAZ
govde(){
cat <<'GOVDE'
    root __KOK__;
    index index.html;
    charset utf-8;

    add_header X-Robots-Tag "noindex, nofollow" always;
    add_header X-Content-Type-Options "nosniff" always;

    auth_basic           "Gentegre AI — mockup";
    auth_basic_user_file /etc/nginx/.htpasswd-gentegre;

    gzip              on;
    gzip_comp_level   6;
    gzip_min_length   1024;
    gzip_types        text/css application/javascript application/json image/svg+xml;

    location = /robots.txt {
        auth_basic off;
        add_header Content-Type text/plain;
        return 200 "User-agent: *\nDisallow: /\n";
    }

    location / {
        try_files $uri $uri/ =404;
    }

    # DIKKAT: alt blokta add_header kullanilinca ust bloktakiler devre disi
    # kalir — bu yuzden her blokta tekrarlanir.
    location ~* \.html$ {
        add_header X-Robots-Tag           "noindex, nofollow" always;
        add_header X-Content-Type-Options "nosniff"           always;
        add_header Cache-Control          "no-cache, must-revalidate";
    }
    location ~* \.(js|css|png|jpg|jpeg|gif|svg|ico|woff2?)$ {
        add_header X-Robots-Tag           "noindex, nofollow" always;
        add_header X-Content-Type-Options "nosniff"           always;
        add_header Cache-Control          "public, max-age=604800";
    }

    access_log /var/log/nginx/__SITE__.access.log;
    error_log  /var/log/nginx/__SITE__.error.log;
GOVDE
}
GOVDE_METNI="$(govde | sed -e "s|__KOK__|$KOK|g" -e "s|__SITE__|$SITE|g")"

# ACME dogrulamasi basic auth'un ARKASINDA KALMAMALI — ayri location
ACME_BLOK="    location ^~ /.well-known/acme-challenge/ {
        auth_basic off;
        allow all;
        default_type \"text/plain\";
        root $ACMEKOK;
    }"

bilgi "gecici http yapilandirmasi yaziliyor ($SUNUCUADI)"
$SUDO tee "/etc/nginx/sites-available/$SITE" >/dev/null <<NGINX
server {
    listen 80 default_server;
$IPV6_80
    server_name $SUNUCUADI;

$ACME_BLOK

$GOVDE_METNI
}
NGINX
$SUDO ln -sfn "/etc/nginx/sites-available/$SITE" "/etc/nginx/sites-enabled/$SITE"
[ -e /etc/nginx/sites-enabled/default ] && $SUDO rm -f /etc/nginx/sites-enabled/default
$SUDO nginx -t
$SUDO systemctl reload nginx 2>/dev/null || $SUDO nginx -s reload

# ---- 4. guvenlik duvari ---------------------------------------------------
if command -v ufw >/dev/null && $SUDO ufw status 2>/dev/null | grep -q "Status: active"; then
  bilgi "ufw: 80 ve 443 aciliyor"
  $SUDO ufw allow 80/tcp  >/dev/null 2>&1 || true
  $SUDO ufw allow 443/tcp >/dev/null 2>&1 || true
fi

# ---- 5. sertifika ---------------------------------------------------------
CERT="/etc/letsencrypt/live/$ALAN/fullchain.pem"
if $SUDO test -f "$CERT"; then
  bilgi "sertifika zaten var — yenileme denenecek"
  $SUDO certbot renew --quiet --webroot -w "$ACMEKOK" || uyar "yenileme atlandi"
else
  bilgi "Let's Encrypt sertifikasi aliniyor: $ALANLAR"
  $SUDO certbot certonly --webroot -w "$ACMEKOK" $ALANLAR \
      --email "$EPOSTA" --agree-tos --no-eff-email -n \
      --deploy-hook "systemctl reload nginx" \
    || hata "sertifika alinamadi — /var/log/letsencrypt/letsencrypt.log dosyasina bakin"
fi
$SUDO test -f "$CERT" || hata "sertifika dosyasi olusmadi: $CERT"

# ---- 6. https yapilandirmasi ---------------------------------------------
# nginx 1.25.1+ ayri "http2 on;" ister; eskisi "listen ... http2" kullanir
NGV="$(nginx -v 2>&1 | sed -e 's|.*/||' -e 's|[^0-9.].*||')"
surum_ge(){ [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]; }
if surum_ge "${NGV:-1.18.0}" "1.25.1"; then HTTP2="    http2 on;"; SSLSAT="    listen 443 ssl;"
else HTTP2=""; SSLSAT="    listen 443 ssl http2;"; fi

SSLOPT=""
$SUDO test -f /etc/letsencrypt/options-ssl-nginx.conf && \
  SSLOPT="    include /etc/letsencrypt/options-ssl-nginx.conf;"
DHP=""
$SUDO test -f /etc/letsencrypt/ssl-dhparams.pem && \
  DHP="    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;"

# www -> apex yonlendirme blogu (yalniz www sertifikada varsa)
WWWBLOK=""
if [ -n "$WWW" ]; then
WWWBLOK="server {
$SSLSAT
$IPV6_443
    server_name $WWW;
    ssl_certificate     /etc/letsencrypt/live/$ALAN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$ALAN/privkey.pem;
$SSLOPT
$DHP
    return 301 https://$ALAN\$request_uri;
}
"
fi

if [ "$ZORLA_HTTPS" = "1" ]; then
  HTTP80="server {
    listen 80 default_server;
$IPV6_80
    server_name $SUNUCUADI _;

$ACME_BLOK

    location / { return 301 https://$ALAN\$request_uri; }
}"
else
  HTTP80="server {
    listen 80 default_server;
$IPV6_80
    server_name $SUNUCUADI _;

$ACME_BLOK

$GOVDE_METNI
}"
fi

bilgi "https yapilandirmasi yaziliyor"
$SUDO tee "/etc/nginx/sites-available/$SITE" >/dev/null <<NGINX
# ---- 80: ACME dogrulamasi + https yonlendirmesi ----
$HTTP80

# ---- 443: www -> apex ----
$WWWBLOK
# ---- 443: asil site ----
server {
$SSLSAT
$HTTP2
$IPV6_443
    server_name $ALAN;

    ssl_certificate     /etc/letsencrypt/live/$ALAN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$ALAN/privkey.pem;
$SSLOPT
$DHP

$ACME_BLOK

$GOVDE_METNI
}
NGINX

$SUDO nginx -t
$SUDO systemctl reload nginx 2>/dev/null || $SUDO nginx -s reload

# ---- 7. otomatik yenileme -------------------------------------------------
if $SUDO systemctl list-timers 2>/dev/null | grep -q certbot; then
  bilgi "otomatik yenileme zamanlayicisi aktif (certbot.timer)"
else
  uyar "certbot.timer yok — cron kaydi ekleniyor"
  echo "17 3 * * * root certbot renew --quiet --webroot -w $ACMEKOK --deploy-hook 'systemctl reload nginx'" \
    | $SUDO tee /etc/cron.d/certbot-gentegre >/dev/null
fi
$SUDO certbot renew --dry-run --webroot -w "$ACMEKOK" >/dev/null 2>&1 \
  && bilgi "yenileme provasi basarili" || uyar "yenileme provasi basarisiz — elle kontrol edin"

BITIS="$($SUDO openssl x509 -enddate -noout -in "$CERT" 2>/dev/null | cut -d= -f2)"

echo
printf '\033[1;32m================ YAYINDA ================\033[0m\n'
echo "  Adres          : https://$ALAN/"
[ -n "$WWW" ] && echo "  Yonlendirme    : https://$WWW/ -> https://$ALAN/"
echo "  http           : $([ "$ZORLA_HTTPS" = 1 ] && echo 'https adresine yonlendiriliyor' || echo 'acik')"
echo "  Sertifika sonu : ${BITIS:-?}   (otomatik yenilenir)"
echo "  Kullanici adi  : gentegre   (basic auth aynen korundu)"
echo
echo "  Guncelleme: yayinla.ps1 ile paketi atmaya devam edin; bu betik"
echo "              yalniz alan adi/sertifika degisirse tekrar calistirilir."
printf '\033[1;32m========================================\033[0m\n'
