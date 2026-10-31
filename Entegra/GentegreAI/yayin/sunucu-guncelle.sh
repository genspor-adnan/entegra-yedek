#!/bin/bash
# ============================================================================
#  GentegreAI — SUNUCU tarafi guncelleme (yayinla.ps1 tarafindan cagrilir)
#
#  Paketi acar, DB goclerini uygular, web ve api'yi degistirir, saglik kontrolu
#  yapar. Kontrol basarisizsa ONCEKI SURUME GERI DONER.
#
#  IKI KURULUM (HBYS / ERP) AYNI BETIGI kullanir; hangisi oldugu ORTAM
#  DEGISKENIYLE gelir - betik tektir, kurulum coktur:
#      KOK   ev dizinindeki kok  (or. $HOME/gentegre-ai)
#      DB    veritabani adi      (or. gentegre_ai)
#      KAP   api konteyner adi   (or. gentegre-api)
#      PORT  api host portu      (or. 5180)
#      YOL   nginx alt yolu      (or. /genotipai/)
#
#  sudo GEREKTIRMEZ: nginx'e dokunulmaz (yollar sabit), yalniz ev dizini ve
#  docker kullanilir. API konteyneri YOKSA kurulur (yeni kurulum).
#
#  Kullanim (paket PAKET= ile verilen yolda, yoksa /tmp/gentegre-ai-paket.tgz):
#      KOK=$HOME/gentegre-erp DB=gentegre_erp KAP=gentegre-api-erp PORT=5181 \
#        bash ~/gentegre-erp/sunucu-guncelle.sh [--temel-al]
#
#      --temel-al : DB goclerini CALISTIRMADAN "uygulandi" diye isaretler.
#                   Ilk kurulumda kullanilir - sema zaten dump'tan geldi.
#
#  UYGULAMA ROLU (kod inceleme raporu 28.10.2026 B07): API postgres ile DEGIL,
#  kuruluma ozel sinirli rolle (<db kucuk harf>_uyg) baglanir. Rol ve parolasi
#  burada kurulur / her yayinda yeniden dogrulanir; parola $KOK/.db_uygulama_parolasi.
#  UYGULAMA_ROLU=0 (yayinla.ps1 -SuperRolIleBaglan): ACIL DURUM - rol adimi
#  atlanir, API eski usul appsettings.Production.json'daki postgres dizesiyle baglanir.
# ============================================================================
set -euo pipefail

KOK=${KOK:-$HOME/gentegre-ai}
DB=${DB:-gentegre_ai}
KAP=${KAP:-gentegre-api}
PORT=${PORT:-5180}
YOL=${YOL:-/ai/}
PG=gentegre-pg18
UYGULAMA_ROLU=${UYGULAMA_ROLU:-1}
AG=gentegre-net
IMAJ=mcr.microsoft.com/dotnet/aspnet:10.0

# Paket yolu yayinla.ps1'den gelir (kurulum + damga ile benzersiz): ayni
#   sabit dosyaya iki yayin birden yuklenince arsiv bozuluyordu (13.10.2026,
#   "tar: A lone zero block"). Eski cagri bicimi icin varsayilan durur.
PAKET=${PAKET:-/tmp/gentegre-ai-paket.tgz}
GECICI=$(mktemp -d)
DAMGA=$(date +%Y%m%d-%H%M%S)
TEMEL_AL=0
[ "${1:-}" = "--temel-al" ] && TEMEL_AL=1

# MSSQL aktarim adimlari, bos kurulum tohumu ve dis veri on kosullari artik
#   pakette db/kurulum altinda (tek kaynak) - goc_uygula.sh okur.
YEDEK_DIZIN=${YEDEK_DIZIN:-$KOK/yedek}

bilgi() { echo "  $*"; }
hata()  { echo "HATA: $*" >&2; exit 1; }

# GERİ ALMA TEK YERDEN (kod inceleme 30.10.2026 K49): web/api degistirildikten sonra herhangi bir komut
#   (docker restart, chmod…) `set -e` ile duserse betik geri alma blogunu gormeden cikiyordu - api/ yeni,
#   konteyner eski kalıyordu. DEGISTI=1 olduktan sonra her hata ayni geri almayi yapar.
DEGISTI=0
geri_al() {
    [ "$DEGISTI" = "1" ] || return 0
    DEGISTI=0
    echo "  geri aliniyor…" >&2
    [ -d "$KOK/api.onceki" ] && { rm -rf "$KOK/api"; mv "$KOK/api.onceki" "$KOK/api"; docker restart "$KAP" >/dev/null 2>&1 || true; }
    [ -d "$KOK/web.onceki" ] && { rm -rf "$KOK/web"; mv "$KOK/web.onceki" "$KOK/web"; }
    docker logs --tail 20 "$KAP" 2>&1 | sed 's/^/    /' >&2 || true
    echo "HATA: yayin geri alindi; onceki surum calisiyor" >&2
}
trap 'KOD_=$?; if [ $KOD_ -ne 0 ]; then geri_al; fi' EXIT
psqlq() { docker exec -i -e PGOPTIONS='-c client_min_messages=warning' "$PG" psql -U postgres -d "$DB" "$@"; }

[ -f "$PAKET" ] || hata "paket yok: $PAKET"
mkdir -p "$KOK"
tar xzf "$PAKET" -C "$GECICI"
bilgi "kurulum: $DB -> $YOL ($KAP:$PORT)"
bilgi "paket acildi: $(du -sh "$GECICI" | cut -f1)"

# ----------------------------------------------------------------- DB gocu ---
# Uygulama kurallari goc_uygula.sh'ta (yerel esi db/araclar/goc_uygula.ps1):
#   dosya + defter TEK islem, eszamanli guncelleyiciye karsi kilit, bos
#   kurulumda tohum + aktarim adimlari, dis veri on kosulunda 2 ile cikis.
#
# DB GERI ALINMAZ (denetim 28.09.2026 #10): asagidaki saglik kontrolu
#   duserse API ve web ONCEKI surume doner ama uygulanmis goc YERINDE KALIR.
#   Bu yuzden (1) gocler ekleyici yazilir - onceki kod yeni semayla calismali;
#   (2) bekleyen goc varsa once pg_dump yedegi alinir. Semayi geri dondurmek
#   gerekirse yol bu yedektir, otomatik degildir.
if [ -d "$GECICI/db" ]; then
    BEKLEYEN=0
    # Ilk kurulumda defter henuz yok: hata "bekleyen = hepsi" demektir.
    UYGULANMIS=" $( (psqlq -tA -c "select dosya from public.goc_gecmisi" 2>/dev/null || true) | tr '\n' ' ') "
    # En az uc hane (1000+ goc dahil) - goc_uygula.sh ile ayni kalip.
    for D in "$GECICI"/db/[0-9][0-9][0-9]*_*.sql; do
        [ -e "$D" ] || continue
        case "$UYGULANMIS" in *" $(basename "$D") "*) ;; *) BEKLEYEN=$((BEKLEYEN+1)) ;; esac
    done
    if [ "$BEKLEYEN" -gt 0 ] && [ "$TEMEL_AL" != "1" ]; then
        # YEDEK YALNIZ SAHIBINE (kod inceleme 30.10.2026 K10): dump hasta verisi + parola hash'leri tasir.
        mkdir -p "$YEDEK_DIZIN"; chmod 700 "$YEDEK_DIZIN"
        ( umask 077; docker exec "$PG" pg_dump -U postgres -Fc "$DB" > "$YEDEK_DIZIN/$DB-$DAMGA.dump" ) \
            || hata "goc oncesi yedek alinamadi - goc CALISTIRILMADI"
        bilgi "goc oncesi yedek: $YEDEK_DIZIN/$DB-$DAMGA.dump ($BEKLEYEN bekleyen goc)"
        ls -1t "$YEDEK_DIZIN/$DB-"*.dump 2>/dev/null | tail -n +6 | xargs -r rm -f   # son 5 yedek
    fi
    set +e
    DB="$DB" PG="$PG" bash "$GECICI/goc_uygula.sh" "$GECICI" $([ "$TEMEL_AL" = "1" ] && echo --temel-al)
    GOC_KOD=$?
    set -e
    [ "$GOC_KOD" = "2" ] && hata "goc dis veri on kosulu bekliyor (yukaridaki mesaj) - kod DEGISTIRILMEDI"
    [ "$GOC_KOD" != "0" ] && hata "goc basarisiz - kod DEGISTIRILMEDI (islem geri alindi; yedek: $YEDEK_DIZIN)"
fi

# ------------------------------------------------------- uygulama rolu ---
# Gocten SONRA calisir: yeni tablolar / fonksiyonlar da yetkisini alir.
#   Rol hatasinda yayin DURUR - web ve api degismeden kalir.
if [ "$UYGULAMA_ROLU" = "1" ]; then
    [[ "$DB" =~ ^[A-Za-z0-9_]+$ ]] || hata "DB adi rol icin uygun degil: $DB"
    ROL="$(echo "$DB" | tr 'A-Z' 'a-z')_uyg"
    [ -f "$GECICI/uygulama-rolu.sql" ] || hata "pakette uygulama-rolu.sql yok"
    if [ ! -s "$KOK/.db_uygulama_parolasi" ]; then
        # Yalniz harf/rakam: SQL ve baglanti dizesinde kacis gerektirmez.
        ( umask 077; head -c 64 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 40 > "$KOK/.db_uygulama_parolasi" )
        bilgi "uygulama rolu parolasi URETILDI: $ROL"
    fi
    chmod 600 "$KOK/.db_uygulama_parolasi"
    DB_UYG_PAROLA=$(cat "$KOK/.db_uygulama_parolasi")
    # Parola komut satirinda DEGIL, stdin'in ilk satirinda (ps ciktisinda gorunmez).
    { printf '\\set parola %s\n' "'$DB_UYG_PAROLA'"; cat "$GECICI/uygulama-rolu.sql"; } \
        | psqlq -v db="$DB" -v rol="$ROL" -q \
        || hata "uygulama rolu kurulamadi ($ROL) - web/api DEGISTIRILMEDI"
    bilgi "uygulama rolu hazir: $ROL (yalniz $DB, super degil)"
else
    echo "UYARI: UYGULAMA_ROLU=0 - API postgres (super kullanici) ile baglanacak" >&2
fi

# -------------------------------------------------------------------- web ---
if [ -d "$GECICI/web" ]; then
    rm -rf "$KOK/web.yeni"
    cp -r "$GECICI/web" "$KOK/web.yeni"
    chmod -R a+rX "$KOK/web.yeni"
    # Degisim ATOMIK'e yakin olsun: kullanicinin yarim dosya gormemesi icin
    #   kopyalama bitince tek hamlede yer degistirilir.
    [ -d "$KOK/web" ] && { rm -rf "$KOK/web.onceki"; mv "$KOK/web" "$KOK/web.onceki"; }
    mv "$KOK/web.yeni" "$KOK/web"
    DEGISTI=1
    bilgi "web guncellendi"
fi

# -------------------------------------------------------------------- api ---
if [ -d "$GECICI/api" ]; then
    [ -d "$KOK/api" ] && { rm -rf "$KOK/api.onceki"; cp -r "$KOK/api" "$KOK/api.onceki"; chmod 700 "$KOK/api.onceki"; }
    rm -rf "$KOK/api"; cp -r "$GECICI/api" "$KOK/api"
    DEGISTI=1

    # KURULUM JWT ANAHTARI (kod inceleme raporu 28.10.2026 B01): depodaki geliştirme anahtarı sunucuya gitmez.
    #   Her kurulumun KENDİ rastgele anahtarı kurulum klasöründe kalıcı durur (ilk yayında üretilir; sonraki
    #   yayınlar aynısını kullanır - oturumlar düşmez) ve API'nin yanına appsettings.Gizli.json olarak yazılır.
    #   A kurulumunun token'ı B'de geçmez. Anahtar dönüşümü: dosyayı silip yayınla (herkes yeniden giriş yapar).
    if [ ! -s "$KOK/.jwt_imza_anahtari" ]; then
        head -c 48 /dev/urandom | base64 | tr -d '\n' > "$KOK/.jwt_imza_anahtari"
        chmod 600 "$KOK/.jwt_imza_anahtari"
        bilgi "kurulum JWT anahtari URETILDI (mevcut oturumlar yeniden giris yapacak)"
    fi
    # Baglanti dizesi de burada (B07): API uygulama rolüyle baglanir. appsettings.Gizli.json en son
    #   yuklenir, Production.json'daki dizeyi ezer.
    # IZINLER (kod inceleme 30.10.2026 K10): api klasoru ve Gizli.json YALNIZ SAHIBINE - konteyner ayni
    #   kullanici kimligiyle (--user) calisir, nginx api klasorune girmez. Eskiden a+rX idi: JWT anahtari ve
    #   DB parolasi sunucudaki her yerel surece acikti.
    if [ "$UYGULAMA_ROLU" = "1" ]; then
        printf '{ "Guvenlik": { "ImzaAnahtari": "%s" },\n  "ConnectionStrings": { "Gentegre": "Host=%s;Port=5432;Database=%s;Username=%s;Password=%s" } }\n' \
            "$(cat "$KOK/.jwt_imza_anahtari")" "$PG" "$DB" "$ROL" "$DB_UYG_PAROLA" > "$KOK/api/appsettings.Gizli.json"
    else
        printf '{ "Guvenlik": { "ImzaAnahtari": "%s" } }\n' "$(cat "$KOK/.jwt_imza_anahtari")" > "$KOK/api/appsettings.Gizli.json"
    fi
    chmod -R u+rwX,go-rwx "$KOK/api"
    chmod 600 "$KOK/api/appsettings.Gizli.json"

    # KONTEYNER: host kullanicisiyla (--user) calisir (K10) ve taban imaj her yayinda tazelenir (K86).
    #   Kullanici / imaj degistiyse konteyner YENIDEN KURULUR (docker restart eski ayarlarla kalkardi);
    #   yoksa yalniz yeniden baslatilir. HOME=/tmp: salt-okunur /app'te veri koruma anahtari yazmaya calismasin.
    KULLANICI="$(id -u):$(id -g)"
    docker pull -q "$IMAJ" >/dev/null 2>&1 || bilgi "imaj cekilemedi, eldeki kullanilacak: $IMAJ"
    kap_kur() {
        docker network inspect "$AG" >/dev/null 2>&1 || docker network create "$AG" >/dev/null
        docker run -d --name "$KAP" --restart unless-stopped --network "$AG" \
            --user "$KULLANICI" \
            -p "127.0.0.1:$PORT:8080" \
            -e ASPNETCORE_ENVIRONMENT=Production \
            -e ASPNETCORE_URLS=http://0.0.0.0:8080 \
            -e HOME=/tmp \
            -v "$KOK/api:/app:ro" -w /app \
            "$IMAJ" dotnet /app/Gentegre.Api.dll >/dev/null
        # PG konteyneri ayni agda degilse baglanamaz - bir kez baglanir.
        docker network connect "$AG" "$PG" 2>/dev/null || true
    }
    if ! docker inspect "$KAP" >/dev/null 2>&1; then
        kap_kur
        bilgi "api konteyneri KURULDU: $KAP (127.0.0.1:$PORT)"
    else
        ESKI_KULLANICI=$(docker inspect -f '{{.Config.User}}' "$KAP" 2>/dev/null || true)
        ESKI_IMAJ=$(docker inspect -f '{{.Image}}' "$KAP" 2>/dev/null || true)
        YENI_IMAJ=$(docker image inspect -f '{{.Id}}' "$IMAJ" 2>/dev/null || true)
        if [ "$ESKI_KULLANICI" != "$KULLANICI" ] || { [ -n "$YENI_IMAJ" ] && [ "$ESKI_IMAJ" != "$YENI_IMAJ" ]; }; then
            docker rm -f "$KAP" >/dev/null
            kap_kur
            bilgi "api konteyneri YENIDEN KURULDU (kullanici/imaj degisti): $KAP"
        else
            docker restart "$KAP" >/dev/null
            bilgi "api guncellendi, konteyner yeniden baslatildi"
        fi
    fi
fi

# -------------------------------------------------------- saglik + geri alma --
bilgi "saglik kontrolu…"
SAGLAM=0
for i in $(seq 1 20); do
    sleep 2
    # /api/saglik DB'ye sorar (select version()): uygulama rolu yeni semaya erisemiyorsa / baglanti dizesi
    #   bozuksa 500 doner - eski "giris 401" kontrolu DB'ye hic ugramadan geciyordu (K49).
    KOD=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "http://127.0.0.1:$PORT/api/saglik" || true)
    [ "$KOD" = "200" ] && { SAGLAM=1; break; }
done

if [ "$SAGLAM" != "1" ]; then
    hata "SAGLIK KONTROLU BASARISIZ (son kod: ${KOD:-yok})"
fi

# API'nin DB baglantisi gercekten uygulama rolüyle mi (B07)? Giris denemesi DB'ye sorar; havuzda
#   baglanti kalir. Postgres ile bagli gorunurse yalniz UYARI - yayin ayakta, geri alinmaz.
if [ "$UYGULAMA_ROLU" = "1" ] && [ -d "$GECICI/api" ]; then
    BAGLI=$(psqlq -tA -c "select string_agg(distinct usename, ',') from pg_stat_activity where datname = '$DB' and application_name not like 'psql%' and backend_type = 'client backend'" || true)
    case ",$BAGLI," in
        *",postgres,"*) echo "UYARI: $DB'ye postgres ile bagli istemci var ($BAGLI) - API ayarini kontrol edin" >&2 ;;
        *",$ROL,"*)     bilgi "api DB baglantisi: $ROL" ;;
        *)              bilgi "api DB baglantisi henuz gorunmedi (havuz bos) - beklenen rol: $ROL" ;;
    esac
fi

WEB=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "http://127.0.0.1$YOL" || true)   # 401 = basic auth (beklenen)
# Web de karara bagli (K49): index yoksa / nginx okuyamiyorsa (403/404/5xx) yayin "TAMAM" bitmesin.
case "$WEB" in 200|301|302|304|401) ;; *) hata "WEB SAGLIK KONTROLU BASARISIZ (kod: ${WEB:-yok})" ;; esac
[ -f "$KOK/web/index.html" ] || hata "web/index.html yok"
DEGISTI=0
bilgi "saglik: api=$KOD web=$WEB"
echo "$DAMGA" > "$KOK/son-yayin.txt"
rm -rf "$GECICI" "$PAKET"
echo "TAMAM: yayin $DAMGA ($DB -> $YOL)"
