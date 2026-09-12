-- =====================================================================
--  623_enabiz_islem_paketi.sql
--  102 HASTA İŞLEM BİLGİSİ — hizmet / ilaç / malzeme bildirimi.
--
--  Kılavuz (rehber.enabiz.gov.tr, prod:102): "Bu paket hasta dosyasına
--  hizmet, ilaç, malzeme, vaka başı veya paket işlem eklendiğinde
--  gönderilir."
--
--  Bizdeki karşılığı BELGE KALEMİDİR: başvurunun ücret satırları. Paket
--  TEKRARLI bir gruptur - her kalem bir `ISLEM_BILGISI`.
--
--  Zorunlu alanlar (kılavuz):
--    HASTA_TAKIP_BILGISI/SYSTakipNo        (101'in döndürdüğü numara)
--    .../ISLEM_BILGISI/KLINIK_KODU         (işlemin yapıldığı branş)
--    .../ISLEM_BILGISI/ISLEM_TURU          (SKRS Hizmet Türü)
--    .../ISLEM_BILGISI/ISLEM_ZAMANI        (istem tarihi)
--    .../ISLEM_BILGISI/ISLEM_REFERANS_NUMARASI (hizmet sunucusuna özel tekil)
--
--  ISLEM_KODU kılavuzda: "hizmetler için SUT Listesi kodları, İlaç için
--  Barkod, SGK ödemeye tabi malzemeler için SUT Kodu". Bizde hizmetin
--  kodu zaten SUT kodudur (`hizmet.kod`), stokta barkod vardır.
--
--  HASTA_TUTARI / KURUM_TUTARI: kılavuz bu ikisini ÖZEL VE ÜNİVERSİTE
--  hastanelerinden istiyor - biz özel hastaneyiz, gönderilir. Kaynak
--  `belge_satir_dagilim`: kuruma yansıyan SGK + ÖSS, hastaya yansıyan
--  provizyon + ek katkı + SGK katılım payı.
-- =====================================================================

-- --------------------------------------------------------------------
--  SKRS listeleri
-- --------------------------------------------------------------------
insert into public.kod_liste (kod, ad, skrs_liste) values
       ('hizmet.skrs_turu', 'Hizmet Türü (SKRS)', 'd03e562d-252e-451f-9a80-98d48b47c2f2'),
       ('islem.taraf',      'İşlem Taraf Bilgisi (SKRS)', '05c03e8c-79fd-461e-8b78-99c3cfad011e')
on conflict (kod) do update set ad = excluded.ad, skrs_liste = excluded.skrs_liste;

with v(liste, deger, ad) as (values
      ('hizmet.skrs_turu', 1, 'DİĞER (SUT, VAKA BAŞI VEYA PAKET İŞLEMLER)'),
      ('hizmet.skrs_turu', 2, 'İLAÇ'),
      ('hizmet.skrs_turu', 3, 'MALZEME'),
      ('islem.taraf',      1, 'SAĞ'),
      ('islem.taraf',      2, 'SOL'),
      ('islem.taraf',      3, 'SAĞ-SOL BELİRSİZ'),
      ('islem.taraf',      4, 'SAĞ-SOL BİRLİKTE'))
insert into public.kod_deger (liste_id, deger, dil, ad, sira, aktif, skrs_kod)
select l.id, v.deger, 0, v.ad, v.deger::smallint, 1, v.deger::varchar
  from v join public.kod_liste l on l.kod = v.liste
on conflict (liste_id, deger, dil) do update
   set ad = excluded.ad, skrs_kod = excluded.skrs_kod, aktif = excluded.aktif;

-- --------------------------------------------------------------------
--  Paket türü
-- --------------------------------------------------------------------
insert into public.enabiz_paket_turu (kod, ad, uss_paket_kodu, aktif, zorunlu_alanlar)
values ('HASTA_ISLEM', 'Hasta İşlem Bilgisi', '102', 1,
        '["HASTA_TAKIP_BILGISI/SYSTakipNo"]'::jsonb)
on conflict (kod) do update
   set ad = excluded.ad, uss_paket_kodu = excluded.uss_paket_kodu,
       aktif = excluded.aktif, zorunlu_alanlar = excluded.zorunlu_alanlar;

-- NOT: Kalem alanlari (KLINIK_KODU, ISLEM_TURU, ISLEM_ZAMANI,
--   ISLEM_REFERANS_NUMARASI) kilavuzda zorunlu ama ZORUNLU LISTESINE
--   YAZILMAZ: liste tam yol esitligiyle kontrol ediliyor, oysa bu alanlar
--   tekrarli grupta `ISLEM_BILGISI[1]/...` diye indeksli geliyor.
--   Eksiklik zaten uretimde olamaz - dordu de kalemin kendi verisinden
--   dogar ve bos kalirsa paket hic acilmaz (uretici bos kalem atlar).

do $$
begin
    raise notice '623 tamam: 102 paket turu ve % SKRS kod degeri kurulu',
        (select count(*) from public.kod_deger d
           join public.kod_liste l on l.id = d.liste_id
          where l.kod in ('hizmet.skrs_turu', 'islem.taraf'));
end $$;
