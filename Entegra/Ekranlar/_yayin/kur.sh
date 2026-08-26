#!/usr/bin/env bash
# ============================================================================
#  Gentegre AI web (v4) — sunucu kurulum betigi  (Ubuntu / Debian, nginx)
#  Calistirma:  ssh gentegre@46.36.201.170 'bash -s' < kur.sh
#  Sartlar   :  ~/gentegre-v4.tar.gz sunucuya kopyalanmis olmali
#
#  KAPSAM (18.08.2026 - duzeltme): tek sayfalik web uygulamasi
#    (gentegre_v4_web.html -> index.html + gentegre_data.js) VE uygulamanin
#    iframe ile actigi ekran dosyalari (gentegre_data.js icinde gecen ~108 html
#    + gengrid.js) birlikte yayinlanir. Ekran dosyalari olmadan uygulamada her
#    sekme bos/ana ekran gorunuyordu. Belge/sunum HTML'leri kapsam disi.
#    Eski icerik yayin oncesi ev dizinine yedeklenir.
# ============================================================================
set -euo pipefail

# ---------------------------------------------------------------- ayarlar
PAKET="${PAKET:-$HOME/gentegre-v4.tar.gz}"
KOK="${KOK:-/var/www/gentegre-mockup}"
SITE="${SITE:-gentegre-mockup}"
PORT="${PORT:-80}"
KULLANICI="${KULLANICI:-gentegre}"          # tarayicida sorulacak kullanici adi
PAROLA="${PAROLA:-bEV6uIrKF2A7Gd}"          # tarayicida sorulacak parola
YEDEK="${YEDEK:-$HOME/gentegre-yayin-yedek-$(date +%F-%H%M).tar.gz}"
# ------------------------------------------------------------------------

bilgi(){ printf '\033[1;34m==>\033[0m %s\n' "$*"; }
uyar(){ printf '\033[1;33m!!\033[0m %s\n' "$*"; }
hata(){ printf '\033[1;31mHATA:\033[0m %s\n' "$*" >&2; exit 1; }

[ -f "$PAKET" ] || hata "paket bulunamadi: $PAKET  (once scp ile kopyalayin)"

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  command -v sudo >/dev/null || hata "root degilsiniz ve sudo yok"
  SUDO="sudo"
  bilgi "sudo parolasi istenebilir"
fi

# ---- 1. nginx + apache2-utils
bilgi "gerekli paketler kontrol ediliyor"
EKSIK=""
command -v nginx    >/dev/null || EKSIK="$EKSIK nginx"
command -v htpasswd >/dev/null || EKSIK="$EKSIK apache2-utils"
if [ -n "$EKSIK" ]; then
  bilgi "kuruluyor:$EKSIK"
  $SUDO apt-get update -qq
  $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $EKSIK
else
  bilgi "nginx ve htpasswd zaten kurulu"
fi

# ---- 2. mevcut yayinin yedegi (geri donus icin)
if [ -d "$KOK" ] && [ -n "$(ls -A "$KOK" 2>/dev/null || true)" ]; then
  bilgi "mevcut yayin yedekleniyor -> $YEDEK"
  tar czf "$YEDEK" -C "$KOK" . 2>/dev/null || uyar "yedek alinamadi (devam ediliyor)"
fi

# ---- 3. dosyalari ac (YALNIZ tek sayfa uygulamasi)
bilgi "dosyalar aciliyor -> $KOK"
$SUDO mkdir -p "$KOK"
GECICI="$(mktemp -d)"
tar xzf "$PAKET" -C "$GECICI"
KAYNAK="$GECICI"
[ -f "$KAYNAK/index.html" ] || KAYNAK="$GECICI/site"
[ -f "$KAYNAK/index.html" ] || hata "pakette index.html yok (yayinla.ps1 paketi uretmeli)"

$SUDO rm -rf "${KOK:?}/"*
$SUDO cp -a "$KAYNAK"/. "$KOK"/
$SUDO chown -R www-data:www-data "$KOK"
$SUDO find "$KOK" -type d -exec chmod 755 {} \;
$SUDO find "$KOK" -type f -exec chmod 644 {} \;
rm -rf "$GECICI"
ADET=$(find "$KOK" -type f | wc -l)
bilgi "$ADET dosya yerlestirildi"
$SUDO ls -la "$KOK"

# ---- 4. basic auth
bilgi "parola dosyasi yaziliyor"
$SUDO htpasswd -bc /etc/nginx/.htpasswd-gentegre "$KULLANICI" "$PAROLA" >/dev/null 2>&1
$SUDO chown root:www-data /etc/nginx/.htpasswd-gentegre
$SUDO chmod 640 /etc/nginx/.htpasswd-gentegre

# ---- 5. nginx site tanimi
# IPv6 her sunucuda yok; olmayan yerde "Address family not supported" ile patlar
IPV6=""
if [ -f /proc/net/if_inet6 ] && [ -s /proc/net/if_inet6 ]; then
  IPV6="    listen [::]:$PORT;"
  bilgi "IPv6 destegi var — dinleme eklenecek"
else
  uyar "IPv6 yok — yalnizca IPv4 dinlenecek"
fi

bilgi "nginx yapilandirmasi yaziliyor"
$SUDO tee "/etc/nginx/sites-available/$SITE" >/dev/null <<NGINX
server {
    listen $PORT;
$IPV6
    server_name _;

    root $KOK;
    index index.html;
    charset utf-8;

    # arama motorlarina kapali
    add_header X-Robots-Tag "noindex, nofollow" always;
    add_header X-Content-Type-Options "nosniff" always;

    auth_basic           "Gentegre AI";
    auth_basic_user_file /etc/nginx/.htpasswd-gentegre;

    gzip              on;
    gzip_comp_level   6;
    gzip_min_length   1024;
    gzip_types        text/html text/css application/javascript application/json image/svg+xml;

    location = /robots.txt {
        auth_basic off;
        add_header Content-Type text/plain;
        return 200 "User-agent: *\nDisallow: /\n";
    }

    # Kok adres -> uygulama. Var olan ekran dosyalari dogrudan servis edilir.
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # DIKKAT: alt blokta add_header kullanilinca ust bloktaki add_header'lar
    # devre disi kalir — bu yuzden X-Robots-Tag her blokta tekrarlanir.
    location ~* \.html\$ {
        add_header X-Robots-Tag         "noindex, nofollow" always;
        add_header X-Content-Type-Options "nosniff"          always;
        add_header Cache-Control        "no-cache, must-revalidate";
        # DIKKAT: regex location secilince ustteki "location /" blogunun try_files'i
        #   CALISMAZ; bu blokta tekrar tanimlanmali.
        #   Ekran dosyalari artik yayinda oldugu icin index.html'e DUSURULMEZ:
        #   yoksa eksik bir ekran (or. /cari_karti.html) iframe icinde uygulamanin
        #   kendisi olarak acilir ve hata gorunmez. Eksikse acikca 404 versin.
        try_files \$uri =404;
    }
    location ~* \.(js|css|png|jpg|jpeg|gif|svg|ico|woff2?)\$ {
        add_header X-Robots-Tag         "noindex, nofollow" always;
        add_header X-Content-Type-Options "nosniff"          always;
        # veri dosyasi sayfayla birlikte degisiyor -> uzun onbellek YOK
        add_header Cache-Control        "no-cache, must-revalidate";
    }

    access_log /var/log/nginx/$SITE.access.log;
    error_log  /var/log/nginx/$SITE.error.log;
}
NGINX

$SUDO ln -sfn "/etc/nginx/sites-available/$SITE" "/etc/nginx/sites-enabled/$SITE"

# ayni portta varsayilan site varsa cakisir -> devre disi birak
if [ "$PORT" = "80" ] && [ -e /etc/nginx/sites-enabled/default ]; then
  uyar "varsayilan nginx sitesi devre disi birakiliyor (80 portu cakismasin)"
  $SUDO mv /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled.default.devredisi 2>/dev/null \
    || $SUDO unlink /etc/nginx/sites-enabled/default
fi

# ---- 6. test + yeniden yukle
bilgi "yapilandirma test ediliyor"
$SUDO nginx -t
$SUDO systemctl reload nginx 2>/dev/null || $SUDO service nginx reload

# ---- 7. ufw
if command -v ufw >/dev/null && $SUDO ufw status 2>/dev/null | grep -q "Status: active"; then
  bilgi "ufw aktif — $PORT portu aciliyor"
  $SUDO ufw allow "$PORT"/tcp >/dev/null 2>&1 || true
fi

# ---- 8. dogrulama
bilgi "yayin dogrulaniyor"
KOD_ANONIM=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT/" || echo "-")
KOD_PAROLALI=$(curl -s -o /dev/null -w '%{http_code}' -u "$KULLANICI:$PAROLA" "http://127.0.0.1:$PORT/" || echo "-")
bilgi "parolasiz istek: $KOD_ANONIM (401 bekleniyor) | parolali istek: $KOD_PAROLALI (200 bekleniyor)"
[ "$KOD_PAROLALI" = "200" ] || uyar "beklenen 200 alinamadi - error_log'a bakin"

echo
bilgi "BITTI -> http://$(hostname -I 2>/dev/null | awk '{print $1}')/  (kullanici: $KULLANICI)"
[ -f "$YEDEK" ] && bilgi "onceki yayin yedegi: $YEDEK"
exit 0
