-- ============================================================================
--  Gentegre AI — TAHAKKUK TURLERININ ADI: SATIS / ALIS
--  150_tahakkuk_adi.sql
--
--  Kullanici (siparis donusum listesinde): "Alacak Tahakkuku geldi, Satış
--  Tahakkuk olacaktı."
--
--  Katalogda 13 "Alacak Tahakkuku", 17 "Borç Tahakkuku" idi - muhasebe dili.
--  Ekranin geri kalani ise SATIS/ALIS diliyle konusuyor: Satış İrsaliyesi,
--  Satış Faturası, Satış Fişi... Ayni listede tek bir satirin muhasebe
--  terimine gecmesi kullaniciyi durduruyordu.
--
--  Adlar SATIS / ALIS'a cevrilir; yon ve muhasebe davranisi DEGISMEZ (13 hala
--  cariyi borclandirir, 17 alacaklandirir - bkz. 137).
-- ============================================================================
\set ON_ERROR_STOP on

update public.kasa_islem_turu set ad = 'Satış Tahakkuku' where kod = 13;
update public.kasa_islem_turu set ad = 'Alış Tahakkuku'  where kod = 17;

do $$
declare v_ad text;
begin
    select string_agg(kod || '=' || ad, ', ' order by kod) into v_ad
      from public.kasa_islem_turu where kod in (13, 17);
    raise notice '150 tamam: %', v_ad;
end $$;
