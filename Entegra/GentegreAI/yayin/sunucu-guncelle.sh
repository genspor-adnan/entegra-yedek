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
#  Kullanim (paket /tmp/gentegre-ai-paket.tgz olarak yuklenmis olmali):
#      KOK=$HOME/gentegre-erp DB=gentegre_erp KAP=gentegre-api-erp PORT=5181 \
#        bash ~/gentegre-erp/sunucu-guncelle.sh [--temel-al]
#
#      --temel-al : DB goclerini CALISTIRMADAN "uygulandi" diye isaretler.
#                   Ilk kurulumda kullanilir - sema zaten dump'tan geldi.
# ============================================================================
set -euo pipefail

KOK=${KOK:-$HOME/gentegre-ai}
DB=${DB:-gentegre_ai}
KAP=${KAP:-gentegre-api}
PORT=${PORT:-5180}
YOL=${YOL:-/ai/}
PG=gentegre-pg18
AG=gentegre-net
IMAJ=mcr.microsoft.com/dotnet/aspnet:10.0

PAKET=/tmp/gentegre-ai-paket.tgz
GECICI=$(mktemp -d)
DAMGA=$(date +%Y%m%d-%H%M%S)
TEMEL_AL=0
[ "${1:-}" = "--temel-al" ] && TEMEL_AL=1

# MSSQL aktarim adimlari, bos kurulum tohumu ve dis veri on kosullari artik
#   pakette db/kurulum altinda (tek kaynak) - goc_uygula.sh okur.
YEDEK_DIZIN=${YEDEK_DIZIN:-$KOK/yedek}

bilgi() { echo "  $*"; }
hata()  { echo "HATA: $*" >&2; exit 1; }
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
    for D in "$GECICI"/db/[0-9][0-9][0-9]_*.sql; do
        [ -e "$D" ] || continue
        case "$UYGULANMIS" in *" $(basename "$D") "*) ;; *) BEKLEYEN=$((BEKLEYEN+1)) ;; esac
    done
    if [ "$BEKLEYEN" -gt 0 ] && [ "$TEMEL_AL" != "1" ]; then
        mkdir -p "$YEDEK_DIZIN"
        docker exec "$PG" pg_dump -U postgres -Fc "$DB" > "$YEDEK_DIZIN/$DB-$DAMGA.dump" \
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

# -------------------------------------------------------------------- web ---
if [ -d "$GECICI/web" ]; then
    rm -rf "$KOK/web.yeni"
    cp -r "$GECICI/web" "$KOK/web.yeni"
    chmod -R a+rX "$KOK/web.yeni"
    # Degisim ATOMIK'e yakin olsun: kullanicinin yarim dosya gormemesi icin
    #   kopyalama bitince tek hamlede yer degistirilir.
    [ -d "$KOK/web" ] && { rm -rf "$KOK/web.onceki"; mv "$KOK/web" "$KOK/web.onceki"; }
    mv "$KOK/web.yeni" "$KOK/web"
    bilgi "web guncellendi"
fi

# -------------------------------------------------------------------- api ---
if [ -d "$GECICI/api" ]; then
    [ -d "$KOK/api" ] && { rm -rf "$KOK/api.onceki"; cp -r "$KOK/api" "$KOK/api.onceki"; }
    rm -rf "$KOK/api"; cp -r "$GECICI/api" "$KOK/api"
    chmod -R a+rX "$KOK/api"

    # Konteyner YOKSA kurulur: yeni kurulum ilk yayininda elle docker run
    #   yazdirmak, kurulumu belgeye degil hafizaya baglar.
    if ! docker inspect "$KAP" >/dev/null 2>&1; then
        docker network inspect "$AG" >/dev/null 2>&1 || docker network create "$AG" >/dev/null
        docker run -d --name "$KAP" --restart unless-stopped --network "$AG" \
            -p "127.0.0.1:$PORT:8080" \
            -e ASPNETCORE_ENVIRONMENT=Production \
            -e ASPNETCORE_URLS=http://0.0.0.0:8080 \
            -v "$KOK/api:/app:ro" -w /app \
            "$IMAJ" dotnet /app/Gentegre.Api.dll >/dev/null
        bilgi "api konteyneri KURULDU: $KAP (127.0.0.1:$PORT)"
        # PG konteyneri ayni agda degilse baglanamaz - bir kez baglanir.
        docker network connect "$AG" "$PG" 2>/dev/null || true
    else
        docker restart "$KAP" >/dev/null
        bilgi "api guncellendi, konteyner yeniden baslatildi"
    fi
fi

# -------------------------------------------------------- saglik + geri alma --
bilgi "saglik kontrolu…"
SAGLAM=0
for i in $(seq 1 20); do
    sleep 2
    KOD=$(curl -s -o /dev/null -w "%{http_code}" -m 5 -X POST \
          "http://127.0.0.1:$PORT/api/kimlik/giris" -H "Content-Type: application/json" \
          -d '{"kod":"?","parola":"?"}' || true)
    # 401 = servis ayakta, kimlik reddedildi (beklenen). 000/502 = ayakta degil.
    [ "$KOD" = "401" ] && { SAGLAM=1; break; }
done

if [ "$SAGLAM" != "1" ]; then
    echo "SAGLIK KONTROLU BASARISIZ (son kod: ${KOD:-yok}) - geri aliniyor" >&2
    [ -d "$KOK/api.onceki" ] && { rm -rf "$KOK/api"; mv "$KOK/api.onceki" "$KOK/api"; docker restart "$KAP" >/dev/null; }
    [ -d "$KOK/web.onceki" ] && { rm -rf "$KOK/web"; mv "$KOK/web.onceki" "$KOK/web"; }
    docker logs --tail 20 "$KAP" 2>&1 | sed 's/^/    /' >&2
    hata "yayin geri alindi; onceki surum calisiyor"
fi

WEB=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "http://127.0.0.1$YOL" || true)   # 401 = basic auth (beklenen)
bilgi "saglik: api=$KOD web=$WEB"
echo "$DAMGA" > "$KOK/son-yayin.txt"
rm -rf "$GECICI" "$PAKET"
echo "TAMAM: yayin $DAMGA ($DB -> $YOL)"
