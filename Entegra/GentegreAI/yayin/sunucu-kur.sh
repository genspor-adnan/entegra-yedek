#!/bin/bash
# ============================================================================
#  SIFIR UBUNTU SUNUCUYA GENTEGRE AI KURULUMU - bir kez, ROOT ILE.
#  Ilk kullanim: SONOMED (13.11.2026, kullanici: "localhost 3000'i musteri server'a kopyala: 90.158.5.227",
#  "kurumun ve DB'nin adi SONOMED, sube adi Kosuyolu", "IP uzerinden", "simdilik basit olsun").
#
#  46.36.201.170'teki yigin (docker, gentegre-pg18, nginx, gentegre kullanicisi) elle kurulmustu; bu betik ayni
#  yigini TEK musterilik bir sunucuda kurar. Sonraki her yayin yerelden yayinla.ps1 -Kurulum <ad> ile gelir
#  (sunucu-guncelle.sh: goc -> web -> api -> saglik; nginx'e dokunmaz).
#
#      scp yayin/sunucu-kur.sh yayin/nginx-<ad>.conf <DUMP> root@<ip>:/tmp/
#      ssh root@<ip> "sed -i 's/\r$//' /tmp/sunucu-kur.sh && AD=sonomed DB=SONOMED PORT=5180 \
#                     DUMP=/tmp/KOSUYOLU_20261113_1140.dump SUBE_AD=Kosuyolu KURUM_AD=SONOMED bash /tmp/sunucu-kur.sh"
#
#  Ne yapar (hepsi tekrar calistirilabilir - olan adim atlanir):
#    1. docker + nginx kurar; `gentegre` kullanicisi (docker grubu), root'un authorized_keys'i ona kopyalanir
#       (yayinla.ps1 gentegre@<ip> ile baglanir).
#    2. PostgreSQL 18 konteyneri `gentegre-pg18` (yalniz 127.0.0.1:5433, kalici hacim, UTC) + `gentegre-net` agi.
#       postgres parolasi uretilir, /root/.gentegre-pg-parola (600). API bu parolayi KULLANMAZ - sunucu-guncelle.sh
#       kuruluma ozel sinirli rolu (<db>_uyg) kurar.
#    3. $DB veritabani (UTF8 + ICU tr-TR) - VARSA DOKUNMAZ (veri ezilmez). Yeni actiysa $DUMP geri yuklenir.
#    4. Kurum / sube adlari (SUBE_AD, KURUM_AD verildiyse) ve "simdilik basit": yerel servislere bagli
#       entegrasyon hesaplari (PACS, TeleRadyoloji, Mirth, MWL) pasife alinir - sunucuda o servisler yok,
#       isci bos yere 127.0.0.1'e vurmasin. Acmak: Ayarlar > Entegrasyon Hesaplari.
#    5. nginx: /tmp/nginx-<ad>.conf -> sites-available/<ad>, default site kapatilir, kok yolda web + /api/ proxy.
#  Sonra yerelden: yayinla.ps1 -Kurulum <ad>  (ilk yayin api konteynerini kurar, web'i yerlestirir).
# ============================================================================
set -euo pipefail

AD=${AD:?AD gerekli (kurulum adi, or. sonomed)}
DB=${DB:?DB gerekli (veritabani adi, or. SONOMED)}
PORT=${PORT:-5180}
DUMP=${DUMP:-}
SUBE_AD=${SUBE_AD:-}
KURUM_AD=${KURUM_AD:-}
KULLANICI=gentegre
KOK=/home/$KULLANICI/gentegre-$AD
PG=gentegre-pg18
PG_IMAJ=postgres:18
AG=gentegre-net
NGINX_PARCA=/tmp/nginx-$AD.conf

[ "$(id -u)" = "0" ] || { echo "root ile calistirin" >&2; exit 1; }
bilgi() { echo "  $*"; }
adim()  { echo; echo "=== $*"; }

# ------------------------------------------------------------ 1. paketler ----
adim "paketler"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq docker.io nginx curl ca-certificates >/dev/null
systemctl enable --now docker >/dev/null
systemctl enable --now nginx >/dev/null
bilgi "docker $(docker --version | cut -d' ' -f3 | tr -d ,) · nginx $(nginx -v 2>&1 | cut -d/ -f2)"

if ! id "$KULLANICI" >/dev/null 2>&1; then
    useradd -m -s /bin/bash -G docker "$KULLANICI"
    bilgi "kullanici acildi: $KULLANICI"
else
    usermod -aG docker "$KULLANICI"
fi
# Yayin anahtari: root'a eklenen anahtar(lar) gentegre'ye de gecer - yayinla.ps1 gentegre@ ile baglanir.
if [ -s /root/.ssh/authorized_keys ]; then
    install -d -m 700 -o "$KULLANICI" -g "$KULLANICI" "/home/$KULLANICI/.ssh"
    touch "/home/$KULLANICI/.ssh/authorized_keys"
    while read -r satir; do
        [ -n "$satir" ] && ! grep -qxF "$satir" "/home/$KULLANICI/.ssh/authorized_keys" \
            && echo "$satir" >> "/home/$KULLANICI/.ssh/authorized_keys"
    done < /root/.ssh/authorized_keys
    chown "$KULLANICI:$KULLANICI" "/home/$KULLANICI/.ssh/authorized_keys"; chmod 600 "/home/$KULLANICI/.ssh/authorized_keys"
    bilgi "ssh anahtarlari $KULLANICI'ye kopyalandi"
fi
install -d -o "$KULLANICI" -g "$KULLANICI" "$KOK"

# ---------------------------------------------------------- 2. postgresql ----
adim "postgresql ($PG)"
docker network inspect "$AG" >/dev/null 2>&1 || docker network create "$AG" >/dev/null
if ! docker inspect "$PG" >/dev/null 2>&1; then
    if [ ! -s /root/.gentegre-pg-parola ]; then
        ( umask 077; head -c 48 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 32 > /root/.gentegre-pg-parola )
    fi
    docker run -d --name "$PG" --restart unless-stopped --network "$AG" \
        -p 127.0.0.1:5433:5432 \
        -e POSTGRES_PASSWORD="$(cat /root/.gentegre-pg-parola)" \
        -e TZ=UTC -e PGTZ=UTC \
        -v gentegre-pg18-veri:/var/lib/postgresql \
        --shm-size=512m \
        "$PG_IMAJ" -c shared_buffers=512MB -c max_connections=200 -c timezone=UTC >/dev/null
    bilgi "konteyner kuruldu (127.0.0.1:5433, parola /root/.gentegre-pg-parola)"
else
    docker network connect "$AG" "$PG" 2>/dev/null || true
    bilgi "konteyner zaten var"
fi
for i in $(seq 1 30); do docker exec "$PG" pg_isready -U postgres >/dev/null 2>&1 && break; sleep 1; done
docker exec "$PG" pg_isready -U postgres >/dev/null || { echo "postgres ayaga kalkmadi" >&2; exit 1; }
bilgi "$(docker exec "$PG" psql -U postgres -tAc 'select version()' | cut -d, -f1)"

# -------------------------------------------------------- 3. veritabani ----
adim "veritabani $DB"
if docker exec "$PG" psql -U postgres -tAc "select 1 from pg_database where datname = '$DB'" | grep -q 1; then
    bilgi "DB zaten var: $DB (dokunulmadi, geri yukleme YAPILMADI)"
else
    [ -n "$DUMP" ] && [ -f "$DUMP" ] || { echo "dump yok: ${DUMP:-<bos>} (once scp; DUMP=/tmp/x.dump)" >&2; exit 1; }
    # medx-hazirla.sh ile ayni: ICU tr-TR (yerel gentegre-pg18 ile ayni siralama), UTC.
    docker exec "$PG" psql -U postgres -c "CREATE DATABASE \"$DB\" TEMPLATE template0 ENCODING 'UTF8' LOCALE_PROVIDER icu ICU_LOCALE 'tr-TR' LOCALE 'en_US.utf8'" >/dev/null
    docker exec -i "$PG" pg_restore -U postgres -d "$DB" --no-owner --exit-on-error < "$DUMP"
    docker exec "$PG" psql -U postgres -d "$DB" -c "alter database \"$DB\" set timezone to 'UTC'" >/dev/null
    bilgi "geri yuklendi: $DB ($(docker exec "$PG" psql -U postgres -d "$DB" -tAc 'select count(*) from public.goc_gecmisi') goc kayitli)"

    # ---- 4. kurum / sube adi + "simdilik basit" (yalniz YENI kurulumda, bir kez)
    if [ -n "$SUBE_AD" ]; then
        # :'ad' yerlestirmesi yalniz stdin/-f girdisinde calisir, -c ile DEGIL (13.11.2026 ilk kurulumda dustu).
        docker exec -i "$PG" psql -U postgres -d "$DB" -v ad="$SUBE_AD" >/dev/null <<< "update public.sube set ad = :'ad' where id = (select min(id) from public.sube);"
        bilgi "sube adi: $SUBE_AD"
    fi
    if [ -n "$KURUM_AD" ]; then
        # unvan: ciktilardaki kurum basligi; bakanlik_ad: Bakanlik/e-Nabiz'a giden kurum adi (fn_kurum_kimlik).
        docker exec -i "$PG" psql -U postgres -d "$DB" -v ad="$KURUM_AD" >/dev/null <<< "update public.sube set unvan = :'ad' where id = (select min(id) from public.sube); update public.kurum_profil set bakanlik_ad = :'ad' where coalesce(bakanlik_ad, '') = '';"
        bilgi "kurum adi: $KURUM_AD"
    fi
    # Yerel makinedeki servislere bagli hesaplar (127.0.0.1 / localhost): sunucuda yok.
    PASIF=$(docker exec "$PG" psql -U postgres -d "$DB" -tAc "update public.entegrasyon_hesap set aktif = 0 where aktif = 1 and (url ~ '127\.0\.0\.1|localhost' or kod in ('PACS','TELERADYOLOJI','MIRTH','MWL')) returning kod || ' ' || ad" | tr '\n' ';')
    [ -n "$PASIF" ] && bilgi "pasife alinan yerel hesaplar: $PASIF"
fi

# ---------------------------------------------------------------- 5. nginx ----
adim "nginx"
SITE=/etc/nginx/sites-available/$AD
if [ -f "$SITE" ]; then
    bilgi "site zaten var: $SITE (dokunulmadi)"
else
    [ -f "$NGINX_PARCA" ] || { echo "nginx parcasi yok: $NGINX_PARCA (once scp)" >&2; exit 1; }
    sed -e "s#__KOK__#$KOK#g" -e "s#__PORT__#$PORT#g" "$NGINX_PARCA" > "$SITE"
    ln -sf "$SITE" /etc/nginx/sites-enabled/$AD
    rm -f /etc/nginx/sites-enabled/default
    # Web dizini yayina kadar bos: nginx -t yine gecer; ilk yayin index.html'i koyar.
    install -d -o "$KULLANICI" -g "$KULLANICI" "$KOK/web"
    if nginx -t 2>/dev/null; then
        systemctl reload nginx
        bilgi "site etkin: $SITE"
    else
        rm -f /etc/nginx/sites-enabled/$AD "$SITE"; nginx -t
        echo "nginx dogrulamasi dustu - site geri alindi" >&2; exit 1
    fi
fi

echo
echo "TAMAM. Simdi yerelden: powershell -File GentegreAI/yayin/yayinla.ps1 -Kurulum $AD"
echo "  ($KULLANICI@$(hostname -I | awk '{print $1}') · DB $DB · api 127.0.0.1:$PORT · web $KOK/web)"
