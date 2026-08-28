-- ============================================================================
--  Gentegre AI — URUN MODU AYARI
--  215_urun_modu.sql
--
--  Iki urun tek koddan calisir (kullanici): 1 = Gentegre AI (ERP),
--  2 = GenoTIP AI (HBYS). Ad (sol ust marka), mesaj basliklari ve menu
--  buna gore degisir - su an yalniz "Kayıt Kabul" grubu GenoTIP'e ozel,
--  kalan moduller ortak. Deger giris yanitiyla istemciye tasinir
--  (KullaniciOzeti.UrunModu); Genel Ayarlar'dan degistirilebilir
--  (AyarDeposu beyaz listesi genel.urun_modu).
--
--  Varsayilan 1 (Gentegre AI) - mevcut kurulumlarin davranisi degismez.
-- ============================================================================

insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'genel.urun_modu', '1', 'sayi', 'firma',
       'Ürün modu: 1 Gentegre AI (ERP), 2 GenoTIP AI (HBYS)'
 where not exists (select 1 from public.referans where anahtar = 'genel.urun_modu');

do $$ begin
    raise notice '215 tamam: genel.urun_modu ayari (varsayilan 1 = Gentegre AI).';
end $$;
