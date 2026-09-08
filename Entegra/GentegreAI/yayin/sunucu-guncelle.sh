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

# MSSQL'DEN VERI GOCU ADIMLARI: kaynak MSSQL'i olmayan YENI kurulumda
#   calistirilamaz (stg semasi bos). Bos kurulumda "uygulandi" isaretlenir -
#   sema goclerinin sirasi bozulmasin, ama olmayan veri aranmasin.
GOC_ADIMLARI="002_stg_kaynak_tablolar.sql 003_goc_taraf.sql 013_goc_faz1.sql 014_goc_belge.sql 018_goc_sube_rol.sql 021_goc_kimlik.sql 079_stg_kasa_master.sql 080_goc_kasa.sql 081_goc_legacy_bacak.sql"

bilgi() { echo "  $*"; }
hata()  { echo "HATA: $*" >&2; exit 1; }
psqlq() { docker exec -i -e PGOPTIONS='-c client_min_messages=warning' "$PG" psql -U postgres -d "$DB" "$@"; }

[ -f "$PAKET" ] || hata "paket yok: $PAKET"
mkdir -p "$KOK"
tar xzf "$PAKET" -C "$GECICI"
bilgi "kurulum: $DB -> $YOL ($KAP:$PORT)"
bilgi "paket acildi: $(du -sh "$GECICI" | cut -f1)"

# ----------------------------------------------------------------- DB gocu ---
# Uygulanan gocler DB'de tutulur; ayni dosya iki kez calistirilmaz. Gocler
#   idempotent yazilsa da (create if not exists / on conflict) kayit tutmak
#   "hangi surum sunucuda" sorusunun tek cevabidir.
# NOTICE'ler bastirilir: psql onlari STDERR'e yazar, yerelde yayinla.ps1'i
#   calistiran PowerShell de native STDERR'i HATA sayip yayini yarida kesiyordu
#   ("relation goc_gecmisi already exists, skipping" gibi zararsiz bir satir).
psqlq -q <<'SQL'
create table if not exists public.goc_gecmisi (
    dosya      varchar(200) primary key,
    uygulama   timestamp not null default now()::timestamp
);
comment on table public.goc_gecmisi is
  'Sunucuda calistirilmis db/NNN_*.sql goc dosyalari (yayinla.ps1).';
SQL

# BOS KURULUM TOHUMU: sube ve varsayilan depo. Idempotent - dolu kurulumda
#   hicbir sey yapmaz, bos kurulumda 020 ve 116 dayanacaklari kaydi bulur.
if [ -f "$GECICI/bos_kurulum.sql" ]; then
    psqlq -q < "$GECICI/bos_kurulum.sql" || hata "bos kurulum tohumu basarisiz"
fi

# MSSQL kaynagi var mi: stg semasinda tablo varsa GERCEK GOC kurulumudur.
STG=$(psqlq -tA -c "select count(*) from information_schema.tables where table_schema = 'stg'")
[ "${STG:-0}" -gt 0 ] && BOS_KURULUM=0 || BOS_KURULUM=1

if [ -d "$GECICI/db" ]; then
    UYGULANAN=0; ATLANAN=0; GOC_ATLANAN=0
    for D in $(ls "$GECICI"/db/*.sql 2>/dev/null | sort); do
        AD=$(basename "$D")
        VAR=$(psqlq -tA -c "select 1 from public.goc_gecmisi where dosya = '$AD'")
        [ -n "$VAR" ] && { ATLANAN=$((ATLANAN+1)); continue; }

        # Bos kurulumda MSSQL veri gocu adimlari CALISTIRILMAZ, isaretlenir.
        if [ "$BOS_KURULUM" = "1" ] && echo " $GOC_ADIMLARI " | grep -q " $AD "; then
            psqlq -q -c "insert into public.goc_gecmisi(dosya) values ('$AD')"
            GOC_ATLANAN=$((GOC_ATLANAN+1)); continue
        fi

        if [ "$TEMEL_AL" = "1" ]; then
            psqlq -q -c "insert into public.goc_gecmisi(dosya) values ('$AD')"
            UYGULANAN=$((UYGULANAN+1))
            continue
        fi

        bilgi "goc: $AD"
        # Goc PATLARSA yayindan cikilir: yarim sema ile yeni kodu acmak,
        #   eski kodu birakmaktan daha kotudur.
        psqlq -v ON_ERROR_STOP=1 -q < "$D" || hata "goc basarisiz: $AD (kod DEGISTIRILMEDI)"
        psqlq -q -c "insert into public.goc_gecmisi(dosya) values ('$AD')"
        UYGULANAN=$((UYGULANAN+1))
    done
    [ "$TEMEL_AL" = "1" ] \
        && bilgi "goc: $UYGULANAN dosya 'uygulandi' isaretlendi (calistirilmadi), $ATLANAN zaten kayitli" \
        || bilgi "goc: $UYGULANAN yeni, $ATLANAN atlandi${GOC_ATLANAN:+, $GOC_ATLANAN veri-gocu adimi bos kurulumda atlandi}"
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
