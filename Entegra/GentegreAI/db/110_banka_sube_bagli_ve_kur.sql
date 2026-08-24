-- ============================================================================
--  Gentegre AI — BAGLI SUBE LISTESI + DOVIZ KURU / YEREL TUTAR
--  110_banka_sube_bagli_ve_kur.sql
--
--  1) SUBE SECIMI BANKAYA BAGLANIR. 109'da sube listesi butun bankalarin
--     subelerini birden gosteriyordu: "Ziraat" secip "Kadıköy Şubesi" ararken
--     listede baska bankalarin subeleri de vardi. Gorunume ust_id (banka_id)
--     eklenir; kart, secili bankanin subelerini gosterir.
--
--     Ad'daki banka onekini de KALDIRIYORUZ: liste zaten tek bankanin
--     subeleri, "Ziraat — Ziraat Kadıköy" tekrar olurdu. Ayirt edicilik icin
--     ilce varsa parantez icinde eklenir (ayni ilde ayni adli sube olmaz).
--
--  2) DOVIZ KURU: kart alanlari icin merkezi kur okuma. Zaten kasa tarafinda
--     olan fn_doviz_kur_getir kullanilir; burada yalnizca cek/senette kur ve
--     yerel tutarin DOLU olmasini garanti eden geri-doldurma var (eski
--     kayitlarda yerel_tutar 0 kalmisti: TL kayitta bile tutar yazilmiyordu).
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------- sube lookup (ust) ---
create or replace view public.v_banka_sube_lookup as
select s.id,
       s.ad || case when s.ilce <> '' then ' (' || s.ilce || ')' else '' end as ad,
       s.aktif,
       s.banka_id as ust_id
  from public.banka_sube s;

comment on view public.v_banka_sube_lookup is
  'Sube secimi (110). ust_id = banka_id: kart yalniz secili bankanin subelerini listeler.';

-- ------------------------------------------------- cek/senet yerel tutar -----
-- yerel_tutar = tutar x kur. TL kayitlarda kur 1 oldugu icin yerel = tutar.
-- Sifir kalmis (hic hesaplanmamis) satirlari doldurur; dolu olanlara DOKUNMAZ -
-- kullanici elle duzeltmis olabilir.
update public.cek_senet
   set yerel_tutar = round(tutar * case when doviz_kuru > 0 then doviz_kuru else 1 end, 4)
 where yerel_tutar = 0 and tutar <> 0;

do $$
declare v_sube integer; v_bos integer;
begin
    select count(*) into v_sube from public.banka_sube;
    select count(*) into v_bos  from public.cek_senet where yerel_tutar = 0 and tutar <> 0;
    raise notice '110 tamam: % sube kaydi, yerel tutari bos kalan cek/senet: %', v_sube, v_bos;
end $$;
