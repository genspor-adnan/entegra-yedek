-- =====================================================================
-- 991 - GUN SONU CEK TESLIM LISTESI
--
-- Mockup banko_gun_sonu_kasa_teslimi.html: cek satiri "Fiziken evet ·
--   sayima girmez | Portfoye alindi · cek teslim listesi".
--
-- CEK KASADA PARA DEGIL: fiziken banko cekmecesinde durur ama nakit
--   sayimina GIRMEZ (988'de ozete ayri kova olarak eklendi). Gun sonunda
--   gorevli cekleri FIZIKEN teslim eder; tutanakta seri no ve vade ile
--   dokumu olmali - "3 cek teslim edildi" tek basina kontrol edilemez.
--
-- YENI TABLO YOK: cek zaten `cek_senet` kaydi ve tahsilat fisine
--   `giris_kasa_islem_id` ile bagli. Oturumun cekleri o bagdan turetilir -
--   ikinci bir cek listesi tutmak, ikisinin ayrismasi demekti.
-- =====================================================================

create or replace view public.v_banko_oturum_cek as
select k.oturum_id,
       c.id                                   as cek_id,
       c.tur,                                        -- 1 cek, 2 senet
       c.seri_no,
       coalesce(nullif(c.banka_adi, ''), coalesce(bk.ad, '')) as banka_adi,
       c.banka_subesi,
       c.kesideci,
       c.vade,
       (c.vade - current_date)                as kalan_gun,
       c.yerel_tutar,
       c.durum,                                      -- 10 portfoyde, ...
       coalesce(t.unvan, '')                  as taraf_unvan,
       c.giris_kasa_islem_id                  as kasa_islem_id
  from public.cek_senet c
  join public.kasa_islem k on k.id = c.giris_kasa_islem_id
  left join public.banka bk on bk.id = c.banka_id
  left join public.taraf t on t.id = c.taraf_id
 where k.oturum_id is not null and k.durum <> 9;

do $$
begin
  raise notice '991: v_banko_oturum_cek hazir';
end $$;
