#!/bin/bash
# ============================================================================
#  GentegreAI — ATOMIK GOC UYGULAYICI (sunucu). Yerel esi:
#  db/araclar/goc_uygula.ps1 - AYNI kurallar, AYNI defter.
#
#  Kullanim:  DB=gentegre_ai PG=gentegre-pg18 bash goc_uygula.sh <paket> [--temel-al]
#     <paket>/db/NNN_*.sql            goc dosyalari
#     <paket>/kurulum/000_bos_kurulum.sql, aktarim_adimlari.txt,
#                     dis_veri_onkosullari.txt
#
#  KURALLAR (denetim 28.09.2026 #10)
#   * ISLEMLI dosya + defter kaydi TEK islem: dosyanin ortasindaki hata onceki
#     ifadeleri de defter kaydini da geri alir.
#   * Kendi BEGIN/COMMIT'ini tasiyan dosya ISLEM DISI calisir (kendi islemi
#     atomik; defter ardindan), deftere `islem_disi` yazilir.
#   * pg_advisory kilidi: iki guncelleyici ayni dosyayi iki kez calistiramaz.
#   * Bos kurulum (stg semasi yok): her bekleyen dosyadan once tohum;
#     MSSQL aktarim adimlari calistirilmaz, `aktarim_yok` yazilir.
#   * Cikis: 0 basari · 1 hata · 2 dis veri on kosulu bekleniyor.
#
#  DB GERI ALINMAZ: yayin geri alma yalniz api/web dosyalarini geri getirir.
#   Uygulanmis goc geri alinmaz; eski kod YENI semayla calismak zorundadir
#   (gocler ekleyici yazilir: kolon/tablo silmek ayri, planli bir yayindir).
#   Gerekirse donus yolu yayin oncesi alinan pg_dump yedegidir.
# ============================================================================
set -euo pipefail

PAKET=${1:?paket dizini gerekli}
TEMEL_AL=0; [ "${2:-}" = "--temel-al" ] && TEMEL_AL=1
DB=${DB:?DB gerekli}
PG=${PG:-gentegre-pg18}
KILIT=7340928

GECICI=$(mktemp -d)
KAPDIZIN=/tmp/goc_$$_$RANDOM
temizle() { rm -rf "$GECICI"; docker exec "$PG" rm -rf "$KAPDIZIN" >/dev/null 2>&1 || true; }
trap temizle EXIT

psqlq() { docker exec -i -e PGOPTIONS='-c client_min_messages=warning' "$PG" psql -U postgres -d "$DB" -v ON_ERROR_STOP=1 -q "$@"; }

liste() { [ -f "$1" ] && grep -v '^\s*#' "$1" | sed 's/\r$//' | grep -v '^\s*$' || true; }
AKTARIM=" $(liste "$PAKET/kurulum/aktarim_adimlari.txt" | tr '\n' ' ') "

# KENDI ISLEMINI YONETEN DOSYA (tekrar denetim 28.09.2026 #2): ust duzeyde bir
#   IFADENIN TAMAMI BEGIN/COMMIT/ROLLBACK/END [WORK|TRANSACTION] ya da START
#   TRANSACTION ise. Yorum, metin sabiti ve $tag$ govdesi TEK GECISTE
#   ayiklanir (hangisi once gelirse), sonra `;` ile ifadelere bolunur -
#   DO/fonksiyon govdesindeki `end;` ve `case ... end;` transaction degildir.
#   Yerel esi (db/araclar/goc_uygula.ps1) AYNI kural.
islem_disi_mi() {
    perl -0777 -ne '
        s{--[^\n]*|/\*.*?\*/|\x27(?:[^\x27]|\x27\x27)*\x27|\$(\w*)\$.*?\$\1\$}{ }gs;
        for my $i (split /;/) {
            $i =~ s/\s+/ /g; $i =~ s/^ | $//g;
            exit 0 if $i =~ /^(?:(?:begin|commit|rollback|end)(?: (?:work|transaction))?|start transaction\b.*)$/i;
        }
        exit 1;
    ' "$1"
}

# LF + BOM'suz normal bicim; ozet bunun uzerinden (yerel esiyle ayni sonuc).
normal() { sed -e '1s/^\xEF\xBB\xBF//' -e 's/\r$//' "$1"; }

# ---- defter ---- (kilit altinda: es zamanli iki "create if not exists" cakisir)
psqlq <<SQL
begin;
do \$\$ begin perform pg_advisory_xact_lock($KILIT); end \$\$;
create table if not exists public.goc_gecmisi (
    dosya      varchar(200) primary key,
    uygulama   timestamp not null default now()::timestamp
);
alter table public.goc_gecmisi add column if not exists ozet varchar(64);
alter table public.goc_gecmisi add column if not exists yontem varchar(20);
commit;
SQL

# BOS KURULUM mu: defterde tohum/aktarim_yok isareti varsa (onceki bos kurulum
#   calismasi) ya da defter de stg semasi da BOSSA (ilk calisma). stg'ye tek
#   basina bakmak yetmez: 002 bos kurulumda da BOS stg tablolarini kurar.
STG=$(psqlq -tA -c "select count(*) from information_schema.tables where table_schema = 'stg'")
DEFTER=$(psqlq -tA -c "select count(*) from public.goc_gecmisi")
ISARET=$(psqlq -tA -c "select count(*) from public.goc_gecmisi where yontem in ('tohum', 'aktarim_yok')")
if [ "${ISARET:-0}" -gt 0 ] || { [ "${DEFTER:-0}" = "0" ] && [ "${STG:-0}" = "0" ]; }; then BOS=1; else BOS=0; fi
if [ "$BOS" = "1" ] && [ "$TEMEL_AL" != "1" ]; then
    # Isaret: bu veritabani BOS KURULUMLA acildi (sonraki calismalar da bilsin).
    psqlq -c "insert into public.goc_gecmisi (dosya, yontem) values ('000_bos_kurulum.sql', 'tohum') on conflict (dosya) do nothing" >/dev/null
fi

cat > "$GECICI/_islemli.sql" <<SQL
begin;
do \$\$ begin perform pg_advisory_xact_lock($KILIT); end \$\$;
select exists (select 1 from public.goc_gecmisi where dosya = :'dosya') as goc_var \gset
\if :goc_var
  \echo GOC_ZATEN_UYGULANMIS
  rollback;
\else
  \i :yol
  insert into public.goc_gecmisi (dosya, ozet, yontem) values (:'dosya', :'ozet', 'islem');
  commit;
\endif
SQL
cat > "$GECICI/_islemdisi.sql" <<SQL
do \$\$ begin perform pg_advisory_lock($KILIT); end \$\$;
select exists (select 1 from public.goc_gecmisi where dosya = :'dosya') as goc_var \gset
\if :goc_var
  \echo GOC_ZATEN_UYGULANMIS
\else
  \i :yol
  insert into public.goc_gecmisi (dosya, ozet, yontem) values (:'dosya', :'ozet', 'islem_disi');
\endif
do \$\$ begin perform pg_advisory_unlock($KILIT); end \$\$;
SQL
[ -f "$PAKET/kurulum/000_bos_kurulum.sql" ] && normal "$PAKET/kurulum/000_bos_kurulum.sql" > "$GECICI/_tohum.sql"

DOSYALAR=$(ls "$PAKET"/db/[0-9][0-9][0-9]_*.sql 2>/dev/null | sort || true)
for D in $DOSYALAR; do normal "$D" > "$GECICI/$(basename "$D")"; done
docker exec "$PG" mkdir -p "$KAPDIZIN"
# Windows'ta (Git Bash, yerel test) docker.exe MSYS yolunu anlamaz; sunucuda
#   cygpath yoktur ve yol oldugu gibi gider.
KAYNAK="$GECICI"; command -v cygpath >/dev/null 2>&1 && KAYNAK=$(cygpath -w "$GECICI")
docker cp "$KAYNAK/." "$PG:$KAPDIZIN" >/dev/null

UYGULANMIS=" $(psqlq -tA -c "select dosya from public.goc_gecmisi" | tr '\n' ' ') "
UYGULANAN=0; ATLANAN=0; AKTARIM_YOK=0
for D in $DOSYALAR; do
    AD=$(basename "$D")
    case "$UYGULANMIS" in *" $AD "*) ATLANAN=$((ATLANAN+1)); continue ;; esac
    OZET=$(sha256sum "$GECICI/$AD" | cut -d' ' -f1)

    if [ "$TEMEL_AL" = "1" ]; then
        psqlq -v dosya="$AD" -v ozet="$OZET" <<'SQL'
insert into public.goc_gecmisi (dosya, ozet, yontem) values (:'dosya', :'ozet', 'temel_al')
on conflict (dosya) do nothing;
SQL
        UYGULANAN=$((UYGULANAN+1)); continue
    fi

    if [ "$BOS" = "1" ] && [ -f "$GECICI/_tohum.sql" ]; then
        psqlq -f "$KAPDIZIN/_tohum.sql" >/dev/null || { echo "HATA: bos kurulum tohumu" >&2; exit 1; }
    fi
    if [ "$BOS" = "1" ] && [[ "$AKTARIM" == *" $AD "* ]]; then
        psqlq -v dosya="$AD" -v ozet="$OZET" <<'SQL'
insert into public.goc_gecmisi (dosya, ozet, yontem) values (:'dosya', :'ozet', 'aktarim_yok')
on conflict (dosya) do nothing;
SQL
        AKTARIM_YOK=$((AKTARIM_YOK+1)); continue
    fi

    if islem_disi_mi "$GECICI/$AD"; then
        SARMAL=_islemdisi.sql; ETIKET=" [islem disi]"
    else
        SARMAL=_islemli.sql; ETIKET=""
    fi
    if ! CIKTI=$(psqlq -v dosya="$AD" -v ozet="$OZET" -v yol="$KAPDIZIN/$AD" -f "$KAPDIZIN/$SARMAL" 2>&1); then
        echo "$CIKTI" >&2
        ONKOSUL=$(liste "$PAKET/kurulum/dis_veri_onkosullari.txt" | grep "^$AD|" | cut -d'|' -f2- || true)
        if [ -n "$ONKOSUL" ]; then
            echo "DIS VERI BEKLENIYOR: $AD - $ONKOSUL" >&2
            exit 2
        fi
        if [ "$SARMAL" = "_islemdisi.sql" ]; then
            echo "HATA: goc basarisiz: $AD (ISLEM DISI dosya: yalniz dosyanin KENDI BEGIN/COMMIT araligi geri alinir; disindaki ifadeler KALMIS olabilir - dosyayi inceleyin; defter yazilmadi)" >&2
        else
            echo "HATA: goc basarisiz: $AD (islem geri alindi, defter yazilmadi)" >&2
        fi
        exit 1
    fi
    case "$CIKTI" in *GOC_ZATEN_UYGULANMIS*) ATLANAN=$((ATLANAN+1)); continue ;; esac
    echo "  goc: $AD$ETIKET"
    UYGULANAN=$((UYGULANAN+1))
done
echo "  goc: $UYGULANAN uygulandi, $ATLANAN zaten kayitli, $AKTARIM_YOK aktarim adimi bos kurulumda atlandi"
