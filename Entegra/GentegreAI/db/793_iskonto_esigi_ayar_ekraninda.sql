-- ============================================================================
--  Gentegre AI — İSKONTO ONAY EŞİĞİ EKRANDAN DEĞİŞTİRİLEBİLİR
--  793_iskonto_esigi_ayar_ekraninda.sql
--
--  Kullanıcı: *"oranları nereden değiştireceğim"*.
--
--  Cevap üç yerdi ve biri EKSİKTİ:
--    1. Rol tavanı  (`basvuru.iskonto` yetkisinin değeri) -> Yönetim › Roller
--       ve Yetkiler › ilgili rol › "Sınır" kutusu.  (661, ekran hazır)
--    2. Basamak eşiği (`onay_akis_adim.esik_alt`) -> Onay Akışları ekranı.
--       (754, ekran hazır)
--    3. Onay eşiği (`basvuru.iskonto_onay_esik`) -> HİÇBİR EKRANDA YOKTU.
--       783 ayarı `referans` tablosuna yazmıştı ama `AyarDeposu` beyaz
--       listesine eklenmemişti: kural işliyor, oranı yalnız SQL ile
--       değişiyordu. Kurumun kendi kararı olması gereken bir sayı, kuruma
--       kapalıydı.
--
--  Bu göç ayarın AÇIKLAMASINI tazeliyor (ekranda "?" ikonunda görünür);
--  beyaz liste + ekran alanı kod tarafında (AyarDeposu, Kayıt Kabul Ayarları ›
--  Başvuru).
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'basvuru.iskonto_onay_esik', '10', 'sayi', 'firma', ''
 where not exists (select 1 from public.referans
                    where anahtar = 'basvuru.iskonto_onay_esik');

-- ACIKLAMA 200 KARAKTER (referans.aciklama): "?" ikonunda gorunen metin kisa
--   olmak zorunda - uzun gerekce bu dosyanin basliginda duruyor.
update public.referans
   set aciklama = 'Bu oranin (%) ustundeki iskonto, tavan yetse bile onayli '
                  'talep ister (783). 0 = kapali. Zincirin ilk imzasi kendisinde '
                  'olan kisi muaftir, sinir kendi tavanidir (792).'
 where anahtar = 'basvuru.iskonto_onay_esik';

do $$
declare v_esik text; v_tavan text;
begin
    select deger into v_esik from public.referans
     where anahtar = 'basvuru.iskonto_onay_esik';
    select string_agg(r.ad || ' %' || ry.deger, ' · ' order by r.ad) into v_tavan
      from public.rol r
      join public.rol_yetki ry on ry.rol_id = r.id
      join public.yetki y on y.id = ry.yetki_id and y.kod = 'basvuru.iskonto'
     where coalesce(nullif(ry.deger, ''), '0') <> '0';
    raise notice '793: onay esigi %%% · rol tavanlari: %', v_esik, v_tavan;
end $$;
