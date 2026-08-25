-- ============================================================================
--  Gentegre AI — DONEM KONTROLU TIMESTAMP KABUL ETSIN
--  147_donem_kontrol_timestamp.sql
--
--  146'da `kasa_islem.islem_tarihi` date -> timestamp oldu. Motor
--  (fn_kasa_islem_kesinlestir) donem kilidini `fn_muhasebe_donem_kontrol(
--  ki.islem_tarihi)` ile soruyor; fonksiyonun tek surumu `date` parametreliydi
--  ve PL/pgSQL timestamp -> date ORTULU cevrim yapmaz:
--
--      function public.fn_muhasebe_donem_kontrol(timestamp without time zone)
--      does not exist
--
--  Sonuc: 146'dan sonra HICBIR kasa islemi kesinlestirilemiyordu (kullanici:
--  "tahsilat kaydedemedim").
--
--  Cozum, cagiran fonksiyonu degistirmek yerine TIMESTAMP ASIRI YUKLEMESI:
--  donem GUN bazlidir, timestamp'in saati onemsizdir - ::date'e indirip asil
--  kurali tek yerde birakiyoruz. Ileride baska bir yer timestamp ile cagirirsa
--  o da calisir.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_muhasebe_donem_kontrol(p_tarih timestamp)
returns void
language sql
as $$ select public.fn_muhasebe_donem_kontrol(p_tarih::date) $$;

comment on function public.fn_muhasebe_donem_kontrol(timestamp) is
  'Donem kilidi kontrolu - timestamp asiri yuklemesi (147). Saat atilir, kural gun bazlidir.';

do $$
declare v_adet integer;
begin
    select count(*) into v_adet from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname = 'fn_muhasebe_donem_kontrol';
    raise notice '147 tamam: fn_muhasebe_donem_kontrol % surum (date + timestamp)', v_adet;
end $$;
