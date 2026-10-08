-- =====================================================================
-- 993 - KENDI OTURUMUNU ONAYLAMA (opsiyonel)
--
-- Kullanici 08.10.2026: "Banko Onay Kuyrugu nu onaylayamiyorum" - oturum
--   kendi adina acik oldugu icin 987'deki "sorumlu kendi oturumunu
--   onaylayamaz" kurali dugmeleri kapatiyordu.
--
-- KURAL DOGRU AMA HER KURUMA UYMUYOR: tek hekimli muayenehanede, tek
--   kisilik laboratuvarda banko gorevlisi ile sorumlu AYNI KISI. Kurali
--   mutlak tutmak o kurumlarda gun sonunu hic kapatilamaz hale getirir;
--   kaldirmak ise cok kisili kurumda karsilikli imzayi yok eder.
--
-- COZUM: kurum ayari. Varsayilan KAPALI (denetim korunur); acan kurum
--   bilerek aciyor ve onay logunda "kendi oturumu" notu duruyor.
-- =====================================================================

insert into public.referans (anahtar, deger, aciklama)
select 'banko.kendi_onay', '0',
       'Görevli kendi oturumunu onaylayabilir mi (1/0) - tek kişilik kurum için'
 where not exists (select 1 from public.referans where anahtar = 'banko.kendi_onay');

do $$
begin
  raise notice '993: banko.kendi_onay ayari eklendi (varsayilan 0)';
end $$;
