-- ============================================================================
--  Gentegre AI — MENÜ GRUBU OLMAYAN EKRAN KENDİ BAŞLIĞIDIR
--  683_yetki_demirbas_grubu.sql
--
--  682 grubu menüden alıyor; Demirbaş ana menüde bir GRUBUN altında değil,
--  tek başına bir madde olduğu için grubu boş geliyor ve matriste "Diğer"
--  başlığına düşüyordu. Menüde kendi adıyla duran ekran, matriste de kendi
--  adıyla dursun - "Diğer" başlığı kullanıcının aradığı yeri gizler.
--
--  (Aynı durumdaki her ekran için kural budur: menü grubu yoksa başlık = ekran
--  adı. Bugün tek örnek Demirbaş.)
-- ============================================================================
\set ON_ERROR_STOP on

update public.yetki
   set grup = ad
 where tur = 0 and grup = 'Diğer' and coalesce(ad, '') <> '';

do $$
begin
    raise notice '683 tamam: menu grubu olmayan ekranlar kendi basligina tasindi.';
end $$;
