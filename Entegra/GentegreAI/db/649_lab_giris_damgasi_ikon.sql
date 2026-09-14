-- =====================================================================
--  649_lab_giris_damgasi_ikon.sql
--  "Elle · <kişi>" damgası İKONA çevrilir (kullanıcı: "elle yerine ikon
--  çıksın").
--
--  Satırın "Giriş" kolonu dar; "Elle · " öneki kişi adını kırpıyordu.
--  Kalem işareti aynı şeyi tek karakterde söylüyor: ✍ <kişi>.
--
--  YALNIZ 648'in yazdığı biçim dönüştürülür ("Elle · X" ve "Elle giriş").
--  Cihazdan gelen damgalara (cihaz kodu) dokunulmaz.
-- =====================================================================

update public.lab_istem_satir
   set cihaz = '✍ ' || substring(cihaz from 8)
 where cihaz like 'Elle · %';

update public.lab_istem_satir
   set cihaz = '✍'
 where cihaz in ('Elle giriş', 'Elle');

do $kontrol$
begin
    raise notice '649 tamam: elle damgali % satir',
        (select count(*) from public.lab_istem_satir where cihaz like '✍%');
end $kontrol$;
