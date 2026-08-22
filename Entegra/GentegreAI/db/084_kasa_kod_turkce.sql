-- ============================================================================
--  Gentegre AI — Kasa kod listeleri: Turkce adlar + fis kaynak turu
--  084_kasa_kod_turkce.sql
--
--  078 seed'i ASCII yazilmisti; bu adlar grid'de "Durum" kolonunda dogrudan
--  kullaniciya gorunuyor ("Gerceklesti" -> "Gerçekleşti").
--  Ayrica muhasebe_fis.kaynak_tur listesi eksikti: fis listesinde "Kaynak"
--  kolonu ham sayi (1/2/5) gosteriyordu.
-- ============================================================================
\set ON_ERROR_STOP on

update public.kod_deger d set ad = v.ad
  from (values
    ('kasa_islem.durum',   0, 'Taslak'),
    ('kasa_islem.durum',   1, 'Planlı'),
    ('kasa_islem.durum',   2, 'Gerçekleşti'),
    ('kasa_islem.durum',   3, 'İptal'),
    ('kasa_islem.durum',   4, 'Plan Kapandı'),
    ('muhasebe_fis.durum', 1, 'Kayıtlı'),
    ('muhasebe_fis.durum', 2, 'Ters Fişle İptal'),
    ('muhasebe_fis.durum', 3, 'Ters Fiş'),
    ('muhasebe_fis.tur',   1, 'Mahsup'),
    ('muhasebe_fis.tur',   2, 'Tahsil'),
    ('muhasebe_fis.tur',   3, 'Tediye'),
    ('muhasebe_fis.tur',   4, 'Açılış'),
    ('muhasebe_fis.tur',   5, 'Kapanış'),
    ('hesap.tur',          4, 'Kredi Kartı'),
    ('hesap.tur',          6, 'Kupon Kasası'),
    ('hesap_plani.sinif',  6, 'Nazım'),
    ('proje.durum',        0, 'İptal'),
    ('proje.durum',        1, 'Açık'),
    ('proje.durum',        2, 'Tamamlandı')
  ) as v(liste, deger, ad)
  join public.kod_liste l on l.kod = v.liste
 where d.liste_id = l.id and d.deger = v.deger and d.dil = 0 and d.ad <> v.ad;

update public.kod_liste set ad = v.ad from (values
    ('kasa_islem.durum',        'Kasa İşlem Durumu'),
    ('muhasebe_fis.durum',      'Fiş Durumu'),
    ('muhasebe_fis.tur',        'Fiş Türü'),
    ('hesap.tur',               'Hesap Türü'),
    ('hesap.alt_tur',           'Hesap Alt Türü'),
    ('hesap_plani.sinif',       'Hesap Sınıfı'),
    ('proje.durum',             'Proje Durumu'),
    ('cek_senet.tur',           'Çek/Senet Türü'),
    ('cek_senet.yon',           'Çek/Senet Yönü'),
    ('cek_senet.durum',         'Çek/Senet Durumu'),
    ('cek_senet_hareket.islem', 'Çek/Senet Hareket Türü')
) as v(kod, ad) where kod_liste.kod = v.kod and kod_liste.ad <> v.ad;

-- Fis kaynak turu (fn_kasa_islem_fisle / fn_belge_fisle hangi kaynaktan uretti)
insert into public.kod_liste (kod, ad) values ('muhasebe_fis.kaynak_tur', 'Fiş Kaynağı')
on conflict (kod) do update set ad = excluded.ad;

insert into public.kod_deger (liste_id, deger, ad, sira)
select l.id, v.deger, v.ad, v.sira
  from public.kod_liste l,
       (values (1, 'Kasa İşlemi', 10), (2, 'Belge', 20), (3, 'Elle Girilen', 30),
               (4, 'Kur Değerlemesi', 40), (5, 'Kapatma', 50), (6, 'İptal', 60)
       ) as v(deger, ad, sira)
 where l.kod = 'muhasebe_fis.kaynak_tur'
on conflict (liste_id, deger, dil) do update set ad = excluded.ad;

do $$
declare v integer;
begin
    select count(*) into v from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
     where l.kod like 'kasa%' or l.kod like 'muhasebe%' or l.kod like 'hesap%' or l.kod like 'cek%';
    raise notice '084 tamam: kasa/muhasebe kod degeri %', v;
end $$;
