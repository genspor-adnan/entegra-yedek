-- =====================================================================
--  633_lab_istem_no_ayari.sql
--  LABORATUVAR İSTEM NUMARASI AYARLANABİLİR OLDU (kullanici: "lab istem no
--  için opsiyona ayarlama ekle").
--
--  Numara koda gömülüydü: `'LAB-' || YYYY || '/' || 5 hane` (LabServisi).
--  Ön ek, hane, başlangıç ve sıfırlama dönemi kurumun kararıdır - hasta
--  dosya no (900) ve başvuru protokol no (19) için zaten `numara_sablonu`
--  tablosunda ayarlanıyor, istem numarası için ayarlanamıyordu.
--
--  TÜR 901: kimlik numaraları uzayının üçüncü değeri. Belge türü değil -
--  istem bir belge değildir - bu yüzden `v_numara_turu_kimlik` görünümüne
--  girer, `kasa_islem_turu`na değil.
--
--  ŞABLON YOKSA DAVRANIŞ AYNEN KALIR. Göç, kurulmuş bir sistemde numara
--  biçimini kendiliğinden değiştirmemeli: satır eklenmiyor, fonksiyon
--  şablon bulamazsa bugünkü `LAB-2026/00042` düzenini üretiyor. Kurum
--  isterse Genel Ayarlar › Numaralama'dan satır açar.
-- =====================================================================

create or replace view public.v_numara_turu_kimlik as
 select 900 as id, 'Hasta Dosya No'::varchar as ad, 1::smallint as aktif
union all
 select 19, 'Başvuru Protokol No'::varchar, 1::smallint
union all
 select 901, 'Laboratuvar İstem No'::varchar, 1::smallint;

comment on view public.v_numara_turu_kimlik is
  '633: kimlik numarasi turleri - 900 hasta dosya, 19 basvuru protokol, '
  '901 laboratuvar istem. Belge turu DEGILLER, kendi gorunumlerinde durur.';

-- ------------------------------------------------------- istem numarası
create or replace function public.fn_lab_istem_no_uret(p_sube_id integer default 0,
                                                       p_tarih date default null)
returns character varying
language plpgsql as $govde$
declare
    v_sablon public.numara_sablonu;
    v_tarih  date := coalesce(p_tarih, current_date);
    v_yil    text;
begin
    v_sablon := public.fn_numara_sablonu_bul(901, p_sube_id, v_tarih);

    -- ŞABLONSUZ: 418'deki davranış birebir - hiçbir ayar yapılmamış
    --   kurulumda numara biçimi değişmez.
    if v_sablon.id is null then
        return 'LAB-' || to_char(v_tarih, 'YYYY') || '/' ||
               public.fn_numara_sirada(
                   'lab_istem.istem_no|Y' || to_char(v_tarih, 'YYYY'),
                   'lab_istem', 'istem_no',
                   'yil ' || to_char(v_tarih, 'YYYY'), 5, 1);
    end if;

    -- YIL KAPSAMI ÖN EKTEN ANLAŞILIR (366): ön ekte YYYY/YY varsa sayaç her
    --   yıl baştan akar - yoksa aynı ön ekle iki yılın numarası çakışırdı.
    --   Ön ek yılsızsa sayaç sürekli artar; bu da meşru bir tercihtir.
    v_yil := case when public.fn_numara_onek_yilli(v_sablon.on_ek)
                  then '|Y' || to_char(v_tarih, 'YYYY') else '' end;

    -- SAYAÇ ŞABLONA VE ŞUBEYE BAĞLI: ön ek ya da başlangıç değişince yeni
    --   sayaç açılır, eski numaralar olduğu gibi kalır.
    return public.fn_numara_onek_coz(v_sablon.on_ek, v_tarih)
           || public.fn_numara_sirada(
                'lab_istem.istem_no|SUBE' || coalesce(p_sube_id, 0)::text
                || '|N' || v_sablon.id::text || v_yil,
                'lab_istem', 'istem_no',
                'lab istem no / sablon ' || v_sablon.id::text
                || ' / sube ' || coalesce(p_sube_id, 0)::text,
                v_sablon.hane, v_sablon.baslangic);
end $govde$;

comment on function public.fn_lab_istem_no_uret(integer, date) is
  '633: siradaki laboratuvar istem numarasi. numara_sablonu tur 901 satiri '
  'varsa on ek (YYYY/YY cozulur) + hane + baslangic; yoksa LAB-YYYY/#####.';

-- DOGRULAMA FONKSIYONU CAGIRMAZ: `fn_lab_istem_no_uret` SAYACI ILERLETIR -
--   gocun kendisi bir numara tuketmis olurdu (ilk denemede LAB-2026/00037
--   bosa gitti). Kurulum yalnizca turun tanimli oldugunu bildirir.
do $kontrol$
begin
    raise notice '633 tamam: 901 (Laboratuvar Istem No) tanimli, sablon satiri: %',
        coalesce((select id::text from public.numara_sablonu
                   where tur = 901 and durum = 1 limit 1), 'yok (LAB-YYYY/##### surer)');
end $kontrol$;
