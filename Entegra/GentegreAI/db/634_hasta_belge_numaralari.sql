-- =====================================================================
--  634_hasta_belge_numaralari.sql
--  HASTA BELGELERİ NUMARALANDIRMASI TEK GRİDDE (kullanici: "Genel
--  ayarlarda belgeno sekmesi altina Hasta Belgeleri diye yeni grid
--  olustur... Dosya No, Protokol No, Muayene, Laboratuvar, Radyoloji,
--  e-Nabiz").
--
--  Hasta dosya no (900) ve başvuru protokol no (19) ayarlanabiliyordu,
--  laboratuvar istem no 633'te eklendi. MUAYENE, RADYOLOJİ ve e-NABIZ
--  numaraları ayarlanamıyordu:
--    * `muayene.muayene_no` ve `radyoloji_istem.accession_no` kolonları
--      VAR ama hiç doldurulmuyordu - kurulumda ikisi de boş.
--    * `enabiz_paket.paket_no` kodda gömülüydü ("PK-2026-000776").
--
--  SIRA GÖRÜNÜMDEN GELİR. Grid alfabetik dizilseydi kullanıcının istediği
--  akış (dosya > protokol > muayene > lab > radyoloji > e-Nabız) bozulurdu;
--  bu sıra hastanın izlediği yolun kendisidir, kozmetik değil.
--
--  ŞABLONSUZ DAVRANIŞ HER TÜRDE KORUNUR - bu bir AYAR, bir zorunluluk
--  değil:
--    900 / 19  : bugünkü davranış (366 / belge numarası)
--    901       : LAB-YYYY/#####  (633)
--    904       : PK-YYYY-NNNNNN  (paket kimliğinden, kodda olduğu gibi)
--    902 / 903 : BOŞ KALIR. Numarası olmayan bir alana kendiliğinden
--                numara basmak, kurumun hiç istemediği bir kimliği
--                kayıtlara yazmak olurdu. Kurum satır açarsa numaralanır.
-- =====================================================================

create or replace view public.v_numara_turu_kimlik as
 select 900 as id, 'Hasta Dosya No'::varchar as ad, 1::smallint as aktif,
        1::smallint as sira
union all
 select  19, 'Başvuru Protokol No'::varchar, 1::smallint, 2::smallint
union all
 select 902, 'Muayene No'::varchar,          1::smallint, 3::smallint
union all
 select 901, 'Laboratuvar İstem No'::varchar, 1::smallint, 4::smallint
union all
 select 903, 'Radyoloji İstem No'::varchar,  1::smallint, 5::smallint
union all
 select 904, 'e-Nabız Paket No'::varchar,    1::smallint, 6::smallint;

comment on view public.v_numara_turu_kimlik is
  '634: hasta belgelerinin numara turleri. `sira` hastanin izledigi yolu '
  'verir (dosya > protokol > muayene > lab > radyoloji > e-Nabiz); grid '
  'alfabetik dizilmesin diye gorunumde tutulur.';

-- ------------------------------------------------- ortak numara uretici
--  Dört tür de AYNI işi yapıyor: şablonu bul, ön ekteki YYYY/YY'yi çöz,
--  sayacı şablona (ve yıllıysa yıla) bağla. Her tür için ayrı fonksiyon
--  yazmak aynı kuralın dördüncü kopyası olurdu - 366 ve 633'te iki kopya
--  zaten vardı.
--
--  ŞABLON YOKSA BOŞ DÖNER, uydurmaz: çağıran kendi eski davranışına düşer.
--  Böylece "ayar yapılmamış" ile "ayar boş bırakılmış" karışmaz.
create or replace function public.fn_numara_kimlik_uret(
        p_tur     integer,
        p_sube_id integer,
        p_tablo   text,
        p_alan    text,
        p_tarih   date default null)
returns character varying
language plpgsql as $govde$
declare
    v_sablon public.numara_sablonu;
    v_tarih  date := coalesce(p_tarih, current_date);
    v_yil    text;
begin
    v_sablon := public.fn_numara_sablonu_bul(p_tur, p_sube_id, v_tarih);
    if v_sablon.id is null then
        return '';
    end if;

    -- YIL KAPSAMI ÖN EKTEN ANLAŞILIR (366): ön ekte YYYY/YY varsa sayaç her
    --   yıl baştan akar. Yılsız ön ekte sürekli artar - o da meşru bir
    --   tercihtir, ama yıl konmadan sayacı sıfırlamak numaraları çakıştırırdı.
    v_yil := case when public.fn_numara_onek_yilli(v_sablon.on_ek)
                  then '|Y' || to_char(v_tarih, 'YYYY') else '' end;

    return public.fn_numara_onek_coz(v_sablon.on_ek, v_tarih)
           || public.fn_numara_sirada(
                p_tablo || '.' || p_alan
                || '|SUBE' || coalesce(p_sube_id, 0)::text
                || '|N' || v_sablon.id::text || v_yil,
                p_tablo, p_alan,
                p_tablo || ' / sablon ' || v_sablon.id::text
                || ' / sube ' || coalesce(p_sube_id, 0)::text,
                v_sablon.hane, v_sablon.baslangic);
end $govde$;

comment on function public.fn_numara_kimlik_uret(integer, integer, text, text, date) is
  '634: sablona gore siradaki kimlik numarasi (900/19/901/902/903/904). '
  'Sablon yoksa BOS doner - cagiran kendi eski davranisina duser.';

-- 633'teki lab fonksiyonu ortak uretici uzerine alinir: kural tek yerde
--   kalsin, iki kopya zamanla ayrismasin.
create or replace function public.fn_lab_istem_no_uret(p_sube_id integer default 0,
                                                       p_tarih date default null)
returns character varying
language plpgsql as $govde$
declare
    v_tarih date := coalesce(p_tarih, current_date);
    v_no    varchar;
begin
    v_no := public.fn_numara_kimlik_uret(901, p_sube_id, 'lab_istem', 'istem_no', v_tarih);
    if coalesce(v_no, '') <> '' then
        return v_no;
    end if;

    -- ŞABLONSUZ: 418'deki davranış birebir.
    return 'LAB-' || to_char(v_tarih, 'YYYY') || '/' ||
           public.fn_numara_sirada(
               'lab_istem.istem_no|Y' || to_char(v_tarih, 'YYYY'),
               'lab_istem', 'istem_no',
               'yil ' || to_char(v_tarih, 'YYYY'), 5, 1);
end $govde$;

do $kontrol$
begin
    raise notice '634 tamam: % kimlik numara turu, tanimli sablon satiri %',
        (select count(*) from public.v_numara_turu_kimlik),
        (select count(*) from public.numara_sablonu
          where tur in (900, 19, 901, 902, 903, 904) and durum = 1);
end $kontrol$;
