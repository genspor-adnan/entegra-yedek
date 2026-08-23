#!/bin/bash
# ============================================================================
#  GentegreAI — SUNUCU tarafi guncelleme (yayinla.ps1 tarafindan cagrilir)
#
#  Paketi acar, DB goclerini uygular, web ve api'yi degistirir, saglik kontrolu
#  yapar. Kontrol basarisizsa ONCEKI SURUME GERI DONER.
#
#  sudo GEREKTIRMEZ: nginx'e dokunulmaz (yollar sabit), yalniz ev dizini ve
#  docker kullanilir.
#
#  Kullanim (paket /tmp/gentegre-ai-paket.tgz olarak yuklenmis olmali):
#      bash ~/gentegre-ai/sunucu-guncelle.sh [--temel-al]
#
#      --temel-al : DB goclerini CALISTIRMADAN "uygulandi" diye isaretler.
#                   Ilk kurulumda kullanilir - sema zaten dump'tan geldi.
# ============================================================================
set -euo pipefail

KOK=~/gentegre-ai
PAKET=/tmp/gentegre-ai-paket.tgz
GECICI=$(mktemp -d)
DAMGA=$(date +%Y%m%d-%H%M%S)
TEMEL_AL=0
[ "${1:-}" = "--temel-al" ] && TEMEL_AL=1

bilgi() { echo "  $*"; }
hata()  { echo "HATA: $*" >&2; exit 1; }

[ -f "$PAKET" ] || hata "paket yok: $PAKET"
mkdir -p "$KOK"
tar xzf "$PAKET" -C "$GECICI"
bilgi "paket acildi: $(du -sh "$GECICI" | cut -f1)"

# ----------------------------------------------------------------- DB gocu ---
# Uygulanan gocler DB'de tutulur; ayni dosya iki kez calistirilmaz. Gocler
#   idempotent yazilsa da (create if not exists / on conflict) kayit tutmak
#   "hangi surum sunucuda" sorusunun tek cevabidir.
docker exec -i gentegre-pg18 psql -U postgres -d gentegre_ai -q <<'SQL'
create table if not exists public.goc_gecmisi (
    dosya      varchar(200) primary key,
    uygulama   timestamp not null default now()::timestamp
);
comment on table public.goc_gecmisi is
  'Sunucuda calistirilmis db/NNN_*.sql goc dosyalari (yayinla.ps1).';
SQL

if [ -d "$GECICI/db" ]; then
    UYGULANAN=0; ATLANAN=0
    for D in $(ls "$GECICI"/db/*.sql 2>/dev/null | sort); do
        AD=$(basename "$D")
        VAR=$(docker exec gentegre-pg18 psql -U postgres -d gentegre_ai -tA \
              -c "select 1 from public.goc_gecmisi where dosya = '$AD'")
        [ -n "$VAR" ] && { ATLANAN=$((ATLANAN+1)); continue; }

        if [ "$TEMEL_AL" = "1" ]; then
            docker exec -i gentegre-pg18 psql -U postgres -d gentegre_ai -q \
                -c "insert into public.goc_gecmisi(dosya) values ('$AD')"
            UYGULANAN=$((UYGULANAN+1))
            continue
        fi

        bilgi "goc: $AD"
        # Goc PATLARSA yayindan cikilir: yarim sema ile yeni kodu acmak,
        #   eski kodu birakmaktan daha kotudur.
        docker exec -i gentegre-pg18 psql -U postgres -d gentegre_ai \
            -v ON_ERROR_STOP=1 -q < "$D" || hata "goc basarisiz: $AD (kod DEGISTIRILMEDI)"
        docker exec -i gentegre-pg18 psql -U postgres -d gentegre_ai -q \
            -c "insert into public.goc_gecmisi(dosya) values ('$AD')"
        UYGULANAN=$((UYGULANAN+1))
    done
    [ "$TEMEL_AL" = "1" ] \
        && bilgi "goc: $UYGULANAN dosya 'uygulandi' isaretlendi (calistirilmadi), $ATLANAN zaten kayitli" \
        || bilgi "goc: $UYGULANAN yeni, $ATLANAN atlandi"
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
    docker restart gentegre-api >/dev/null
    bilgi "api guncellendi, konteyner yeniden baslatildi"
fi

# -------------------------------------------------------- saglik + geri alma --
bilgi "saglik kontrolu…"
SAGLAM=0
for i in $(seq 1 20); do
    sleep 2
    KOD=$(curl -s -o /dev/null -w "%{http_code}" -m 5 -X POST \
          http://127.0.0.1:5180/api/kimlik/giris -H "Content-Type: application/json" \
          -d '{"kod":"?","parola":"?"}' || true)
    # 401 = servis ayakta, kimlik reddedildi (beklenen). 000/502 = ayakta degil.
    [ "$KOD" = "401" ] && { SAGLAM=1; break; }
done

if [ "$SAGLAM" != "1" ]; then
    echo "SAGLIK KONTROLU BASARISIZ (son kod: ${KOD:-yok}) - geri aliniyor" >&2
    [ -d "$KOK/api.onceki" ] && { rm -rf "$KOK/api"; mv "$KOK/api.onceki" "$KOK/api"; docker restart gentegre-api >/dev/null; }
    [ -d "$KOK/web.onceki" ] && { rm -rf "$KOK/web"; mv "$KOK/web.onceki" "$KOK/web"; }
    docker logs --tail 20 gentegre-api 2>&1 | sed 's/^/    /' >&2
    hata "yayin geri alindi; onceki surum calisiyor"
fi

WEB=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://127.0.0.1/ai/ || true)   # 401 = basic auth (beklenen)
bilgi "saglik: api=$KOD web=$WEB"
echo "$DAMGA" > "$KOK/son-yayin.txt"
rm -rf "$GECICI" "$PAKET"
echo "TAMAM: yayin $DAMGA"
