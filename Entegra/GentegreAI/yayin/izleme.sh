#!/usr/bin/env bash
# ============================================================================
#  Gentegre AI — sunucu izleme ve alarm (cron ile 5 dakikada bir)
#
#  Ne bakar (her kurulum için, izleme.conf'taki KURULUMLAR):
#    - API konteyneri çalışıyor mu, /api/saglik 200 mü (DB'ye de sorar)
#    - web/index.html yerinde mi
#    - bildirim kuyruğu: bekleyen birikiyor mu (işçi durmuş), hata oranı
#    - Medula / e-Nabız kuyruğu: hatalı / takılı kalan
#    - zamanlı işler: son çalışması başarısız olan, 6 saattir "çalışıyor" kalan
#  Sunucu geneli: disk doluluğu, PG konteyneri, bellek.
#
#  Alarm: durum DEĞİŞİNCE gönderilir (sorun başladı / düzeldi); sorun sürerse
#  TEKRAR_DK'da bir hatırlatma. Kanal: Telegram (önerilen - API çökse de çalışır)
#  ve/veya bir kurulumun kendi bildirim kuyruğu (e-posta / SMS; o API ayaktaysa).
#
#  Kullanım:  izleme.sh            # bir tur (cron)
#             izleme.sh --dene     # deneme alarmı gönder, durum dosyalarına dokunma
#             izleme.sh --durum    # yalnız ekrana yaz, alarm gönderme
#
#  Kurulum: yayin/izleme-kur.ps1 (betiği + örnek ayarı kopyalar, crontab'a ekler).
# ============================================================================
set -uo pipefail

DIZIN=${IZLEME_DIZIN:-$HOME/izleme}
AYAR=${IZLEME_AYAR:-$DIZIN/izleme.conf}
DURUM_DIZIN=$DIZIN/durum
GUNLUK=$DIZIN/izleme.log

# ------------------------------------------------------------ varsayılanlar --
PG=gentegre-pg18
KURULUMLAR=""                 # "ad:kok:konteyner:port:db ..." (izleme.conf)
DISK_ESIK=85                  # %
BELLEK_ESIK=92                # %
KUYRUK_BEKLEME_DK=20          # bildirim: bu kadar dakikadır bekleyen varsa işçi durmuş sayılır
BILDIRIM_HATA_ESIK=10         # son 1 saatte hatalı bildirim
TEKRAR_DK=120                 # sorun sürüyorsa hatırlatma aralığı
TELEGRAM_TOKEN=""
TELEGRAM_SOHBET=""
KUYRUK_DB=""                  # alarmı bu kurulumun bildirim kuyruğuna da yaz (ör. FETA)
KUYRUK_EPOSTA=""              # alıcı e-posta (kanal 2)
KUYRUK_TEL=""                 # alıcı cep (kanal 1, SMS)
SUNUCU_ADI=$(hostname)

[ -f "$AYAR" ] && . "$AYAR"
mkdir -p "$DURUM_DIZIN"; chmod 700 "$DIZIN" 2>/dev/null || true

KIP=tur
case "${1:-}" in --dene) KIP=dene ;; --durum) KIP=durum ;; esac

gunluk() { echo "$(date '+%F %T') $*" >> "$GUNLUK"; }
psqlq() { docker exec -i -e PGOPTIONS='-c client_min_messages=warning' "$PG" psql -U postgres -d "$1" -tAX -c "$2" 2>/dev/null; }
tablo_var() { [ "$(psqlq "$1" "select to_regclass('public.$2') is not null")" = "t" ]; }

# --------------------------------------------------------------- gönderim --
gonder() {   # $1 = metin
    local metin="[$SUNUCU_ADI] $1"
    if [ "$KIP" = durum ]; then echo "ALARM: $metin"; return; fi
    gunluk "ALARM: $metin"
    if [ -n "$TELEGRAM_TOKEN" ] && [ -n "$TELEGRAM_SOHBET" ]; then
        curl -s -m 15 -o /dev/null "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
             --data-urlencode "chat_id=$TELEGRAM_SOHBET" --data-urlencode "text=$metin" \
             || gunluk "telegram gonderilemedi"
    fi
    if [ -n "$KUYRUK_DB" ]; then
        local m=${metin//\'/\'\'}
        [ -n "$KUYRUK_EPOSTA" ] && psqlq "$KUYRUK_DB" "insert into public.bildirim (kanal, alici, konu, govde, oncelik, kaynak_tur)
            values (2, '${KUYRUK_EPOSTA//\'/}', 'Gentegre izleme alarmı', '$m', 1, 'izleme')" >/dev/null
        [ -n "$KUYRUK_TEL" ] && psqlq "$KUYRUK_DB" "insert into public.bildirim (kanal, alici, govde, oncelik, kaynak_tur)
            values (1, '${KUYRUK_TEL//\'/}', left('$m', 300), 1, 'izleme')" >/dev/null
    fi
}

# ------------------------------------------------- durum (yalnız değişimde) --
SORUNLAR=0
denetim() {  # $1 = anahtar, $2 = sorun metni ("" = sağlam)
    local anahtar=${1//[^a-zA-Z0-9._-]/_} metin=$2 dosya="$DURUM_DIZIN/${1//[^a-zA-Z0-9._-]/_}"
    if [ "$KIP" = durum ]; then
        [ -n "$metin" ] && { echo "SORUN  $anahtar: $metin"; SORUNLAR=$((SORUNLAR + 1)); } || echo "tamam  $anahtar"
        return
    fi
    if [ -n "$metin" ]; then
        SORUNLAR=$((SORUNLAR + 1))
        if [ ! -f "$dosya" ]; then
            echo "$(date +%s)" > "$dosya"; gonder "🔴 $metin"
        elif [ $(( $(date +%s) - $(stat -c %Y "$dosya") )) -ge $((TEKRAR_DK * 60)) ]; then
            touch "$dosya"; gonder "🔴 (sürüyor) $metin"
        fi
    elif [ -f "$dosya" ]; then
        local bas; bas=$(cat "$dosya" 2>/dev/null || echo 0)
        rm -f "$dosya"; gonder "🟢 düzeldi: $anahtar ($(( ($(date +%s) - bas) / 60 )) dk sürdü)"
    fi
}

if [ "$KIP" = dene ]; then
    gonder "🧪 deneme alarmı - izleme çalışıyor ($(echo $KURULUMLAR | wc -w) kurulum)"
    echo "deneme alarmı gönderildi"; exit 0
fi

# ------------------------------------------------------------ sunucu geneli --
for bolum in / /var/lib/docker; do
    [ -d "$bolum" ] || continue
    dolu=$(df -P "$bolum" 2>/dev/null | awk 'NR==2 {v=$(NF-1); gsub("%","",v); print v}')
    [ -n "$dolu" ] && denetim "disk$bolum" "$( [ "$dolu" -ge "$DISK_ESIK" ] && echo "Disk $bolum %$dolu dolu (eşik %$DISK_ESIK)")"
done
bellek=$(command -v free >/dev/null && free | awk '/^Mem:/ {printf "%d", ($2 - $7) * 100 / $2}')
[ -n "$bellek" ] && denetim "bellek" "$( [ "$bellek" -ge "$BELLEK_ESIK" ] && echo "Bellek kullanımı %$bellek (eşik %$BELLEK_ESIK)")"
kap_durum() { local d; d=$(docker inspect -f '{{.State.Running}}' "$1" 2>/dev/null | head -1); echo "${d:-yok}"; }
pg_calisiyor=$(kap_durum "$PG")
denetim "pg" "$( [ "$pg_calisiyor" != "true" ] && echo "PostgreSQL konteyneri ($PG) çalışmıyor: $pg_calisiyor")"

# --------------------------------------------------------------- kurulumlar --
for k in $KURULUMLAR; do
    IFS=: read -r ad kok kap port db <<< "$k"
    [ -d "$HOME/$kok" ] || continue                      # bu sunucuda kurulu değil

    calisiyor=$(kap_durum "$kap")
    denetim "$ad.konteyner" "$( [ "$calisiyor" != "true" ] && echo "$ad: API konteyneri ($kap) çalışmıyor: $calisiyor")"

    saglik() { local k; k=$(curl -s -o /dev/null -w "%{http_code}" -m 10 "http://127.0.0.1:$port/api/saglik" || true); echo "${k:-000}"; }
    # Tek seferlik aksama alarm değil: 5 sn sonra bir kez daha denenir.
    kod=$(saglik); [ "$kod" != "200" ] && { sleep 5; kod=$(saglik); }
    denetim "$ad.saglik" "$( [ "$kod" != "200" ] && echo "$ad: /api/saglik yanıtı $kod (API ya da DB bağlantısı sorunlu)")"

    denetim "$ad.web" "$( [ ! -f "$HOME/$kok/web/index.html" ] && echo "$ad: web/index.html yok")"

    [ "$pg_calisiyor" = "true" ] || continue
    if tablo_var "$db" bildirim; then
        birikmis=$(psqlq "$db" "select count(*) from public.bildirim where durum = 1 and planlanan < now() - interval '$KUYRUK_BEKLEME_DK minutes'")
        denetim "$ad.bildirim.bekleyen" "$( [ "${birikmis:-0}" -gt 0 ] && echo "$ad: $birikmis bildirim $KUYRUK_BEKLEME_DK dakikadan uzun süredir kuyrukta (bildirim işçisi durmuş olabilir)")"
        hatali=$(psqlq "$db" "select count(*) from public.bildirim where durum in (4, 6) and ekleme_tarihi > now() - interval '1 hour'")
        denetim "$ad.bildirim.hata" "$( [ "${hatali:-0}" -ge "$BILDIRIM_HATA_ESIK" ] && echo "$ad: son 1 saatte $hatali bildirim gönderilemedi (SMS/e-posta hesabı?)")"
    fi
    if tablo_var "$db" medula_kuyruk; then
        mh=$(psqlq "$db" "select count(*) from public.medula_kuyruk where durum in (4, 5) and ekleme_tarihi > now() - interval '1 day'")
        denetim "$ad.medula" "$( [ "${mh:-0}" -gt 0 ] && echo "$ad: son 24 saatte $mh Medula çağrısı hatada")"
    fi
    if tablo_var "$db" zamanli_is; then
        takili=$(psqlq "$db" "select string_agg(kod, ', ') from public.zamanli_is where aktif = 1 and calisiyor = 1 and calisma_bas < now() - interval '6 hours'")
        denetim "$ad.is.takili" "$( [ -n "$takili" ] && echo "$ad: 6 saattir 'çalışıyor' kalan zamanlı iş: $takili")"
        # Her iş kendi anahtarıyla: biri düzelince ötekinin alarmı kapanmaz.
        while IFS='|' read -r is_kod sonuc; do
            [ -z "$is_kod" ] && continue
            denetim "$ad.is.$is_kod" "$ad: zamanlı iş '$is_kod' başarısız: ${sonuc:0:160}"
        done < <(psqlq "$db" "select kod, replace(son_sonuc, '|', '/') from public.zamanli_is where aktif = 1 and basarili = 0 and son_calisma > now() - interval '26 hours'")
        # Artık başarısız olmayan işlerin açık alarmları kapanır.
        for f in "$DURUM_DIZIN/$ad.is."*; do
            [ -e "$f" ] || continue
            is_kod=${f##*/$ad.is.}; [ "$is_kod" = takili ] && continue
            hala=$(psqlq "$db" "select count(*) from public.zamanli_is where kod = '${is_kod//\'/}' and aktif = 1 and basarili = 0 and son_calisma > now() - interval '26 hours'")
            [ "${hala:-0}" = 0 ] && denetim "$ad.is.$is_kod" ""
        done
    fi
done

[ "$KIP" = durum ] && echo "--- $SORUNLAR sorun"
exit 0
