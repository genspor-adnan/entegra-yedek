-- ============================================================================
--  Gentegre AI — Kasa alt sistemi / YETKI ve KOD LISTELERI
--  078_kasa_yetki.sql
--
--  yetki tablosu deseni: 020_sema_kimlik.sql:341-369.
--    tur = 0  -> kaynak yetkisi (gor / ekle / degistir / sil dortlusu)
--    tur = 1  -> aksiyon yetkisi (tek bayrak; ornek: belge.kesinlestir)
--  Seed sonrasi yonetici rolune tum bayraklar, salt_okur'a yalniz "gor"
--    cross join ile verilir (020'deki ayni desen burada tekrarlanir).
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.yetki (kod, ad, grup, tur, sira) values
    ('kasa_islem',      'Kasa islemi (tahsilat/odeme/virman)', 'mali',    0, 42),
    ('hesap',           'Kasa / banka / POS / kredi hesabi',   'mali',    0, 43),
    ('cek_senet',       'Cek ve senet',                        'mali',    0, 44),
    ('kredi',           'Banka kredisi',                       'mali',    0, 45),
    ('proje',           'Proje',                               'mali',    0, 46),
    ('hesap_plani',     'Hesap plani',                         'mali',    0, 47),
    ('muhasebe_fis',    'Muhasebe fisi',                       'mali',    0, 48),
    ('kasa_kapatma',    'Fatura - tahsilat kapatma',           'mali',    0, 49),
    ('masraf_merkezi',  'Masraf merkezi',                      'mali',    0, 50),
    ('kasa_islem_turu', 'Islem turu katalogu',                 'yonetim', 0, 66),
    -- aksiyonlar
    ('kasa.kesinlestir',      'Kasa islemini kesinlestir',   'mali', 1, 140),
    ('kasa.iptal',            'Kasa islemini iptal et',      'mali', 1, 141),
    ('kasa.gerceklestir',     'Plani gerceklestir',          'mali', 1, 142),
    ('kasa.makbuz-yazdir',    'Makbuz yazdir',               'mali', 1, 143),
    ('kasa.kapat',            'Fatura kapatma',              'mali', 1, 144),
    ('ceksenet.tahsil',       'Cek/senet tahsil',            'mali', 1, 150),
    ('ceksenet.bozdur',       'Cek/senet bozdur',            'mali', 1, 151),
    ('ceksenet.ciro',         'Cek/senet ciro et',           'mali', 1, 152),
    ('ceksenet.iade',         'Cek/senet iade / karsiliksiz','mali', 1, 153),
    ('kredi.taksit-ode',      'Kredi taksiti ode',           'mali', 1, 160),
    ('fis.ters-kayit',        'Fisi ters kayitla iptal et',  'mali', 1, 170),
    ('muhasebe.donem-kilitle','Muhasebe donemini kilitle',   'mali', 1, 171)
on conflict (kod) do nothing;

-- ---- rollere dagit (020_sema_kimlik.sql:378-390 deseni) -------------------
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 1, 1, 1
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici'
   and y.kod in ('kasa_islem','hesap','cek_senet','kredi','proje','hesap_plani','muhasebe_fis',
                 'kasa_kapatma','masraf_merkezi','kasa_islem_turu',
                 'kasa.kesinlestir','kasa.iptal','kasa.gerceklestir','kasa.makbuz-yazdir','kasa.kapat',
                 'ceksenet.tahsil','ceksenet.bozdur','ceksenet.ciro','ceksenet.iade',
                 'kredi.taksit-ode','fis.ters-kayit','muhasebe.donem-kilitle')
   and not exists (select 1 from public.rol_yetki x where x.rol_id = r.id and x.yetki_id = y.id);

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 0, 0, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'salt_okur' and y.tur = 0
   and y.kod in ('kasa_islem','hesap','cek_senet','kredi','proje','hesap_plani','muhasebe_fis',
                 'kasa_kapatma','masraf_merkezi','kasa_islem_turu')
   and not exists (select 1 from public.rol_yetki x where x.rol_id = r.id and x.yetki_id = y.id);

-- rol.yetki_surumu trigger'la artar; JWT'deki yetkiSurumu bununla eslesir.

-- ------------------------------------------------------------ kod listeleri ----
insert into public.kod_liste (kod, ad) values
    ('hesap.tur',                'Hesap Turu'),
    ('hesap.alt_tur',            'Hesap Alt Turu'),
    ('kasa_islem.durum',         'Kasa Islem Durumu'),
    ('cek_senet.tur',            'Cek/Senet Turu'),
    ('cek_senet.yon',            'Cek/Senet Yonu'),
    ('cek_senet.durum',          'Cek/Senet Durumu'),
    ('cek_senet_hareket.islem',  'Cek/Senet Hareket Turu'),
    ('proje.durum',              'Proje Durumu'),
    ('hesap_plani.sinif',        'Hesap Sinifi'),
    ('muhasebe_fis.tur',         'Fis Turu'),
    ('muhasebe_fis.durum',       'Fis Durumu')
on conflict (kod) do nothing;

insert into public.kod_deger (liste_id, deger, ad, sira)
select kl.id, v.deger, v.ad, v.sira
  from (values
        ('hesap.tur',               1, 'Kasa',                    10),
        ('hesap.tur',               2, 'Banka',                   20),
        ('hesap.tur',               3, 'POS',                     30),
        ('hesap.tur',               4, 'Kredi Karti',             40),
        ('hesap.tur',               5, 'Kredi',                   50),
        ('hesap.tur',               6, 'Kupon Kasasi',            60),
        ('hesap.alt_tur',         100, 'Merkez Kasa',             10),
        ('hesap.alt_tur',         101, 'Satis Kasasi',            20),
        ('hesap.alt_tur',         195, 'Is Avansi Kasasi',        30),
        ('hesap.alt_tur',         196, 'Maas Avansi Kasasi',      40),
        ('hesap.alt_tur',         200, 'Kupon Kasasi',            50),
        ('kasa_islem.durum',        0, 'Taslak',                  10),
        ('kasa_islem.durum',        1, 'Planli',                  20),
        ('kasa_islem.durum',        2, 'Gerceklesti',             30),
        ('kasa_islem.durum',        3, 'Iptal',                   40),
        ('kasa_islem.durum',        4, 'Plan Kapandi',            50),
        ('cek_senet.tur',           1, 'Cek',                     10),
        ('cek_senet.tur',           2, 'Senet',                   20),
        ('cek_senet.yon',           1, 'Alinan',                  10),
        ('cek_senet.yon',           2, 'Verilen',                 20),
        ('cek_senet.durum',        10, 'Portfoyde',               10),
        ('cek_senet.durum',        20, 'Ciro Edildi',             20),
        ('cek_senet.durum',        30, 'Bankada Tahsilde',        30),
        ('cek_senet.durum',        40, 'Teminatta',               40),
        ('cek_senet.durum',        50, 'Tahsil Edildi / Odendi',  50),
        ('cek_senet.durum',        60, 'Karsiliksiz',             60),
        ('cek_senet.durum',        70, 'Iade Edildi',             70),
        ('cek_senet.durum',         0, 'Iptal',                   80),
        ('cek_senet_hareket.islem',130,'Portfoye Giris',          10),
        ('cek_senet_hareket.islem',131,'Ciro',                    20),
        ('cek_senet_hareket.islem',132,'Bankaya Tahsile',         30),
        ('cek_senet_hareket.islem',133,'Tahsil Edildi',           40),
        ('cek_senet_hareket.islem',134,'Karsiliksiz',             50),
        ('cek_senet_hareket.islem',135,'Iade',                    60),
        ('cek_senet_hareket.islem',136,'Odendi',                  70),
        ('cek_senet_hareket.islem',137,'Teminata Verildi',        80),
        ('cek_senet_hareket.islem',138,'Teminattan Donus',        90),
        ('cek_senet_hareket.islem',139,'Iptal / Geri Alma',      100),
        ('proje.durum',             1, 'Acik',                    10),
        ('proje.durum',             2, 'Tamamlandi',              20),
        ('proje.durum',             0, 'Iptal',                   30),
        ('hesap_plani.sinif',       1, 'Aktif',                   10),
        ('hesap_plani.sinif',       2, 'Pasif',                   20),
        ('hesap_plani.sinif',       3, 'Gelir',                   30),
        ('hesap_plani.sinif',       4, 'Gider',                   40),
        ('hesap_plani.sinif',       5, 'Maliyet',                 50),
        ('hesap_plani.sinif',       6, 'Nazim',                   60),
        ('muhasebe_fis.tur',        1, 'Mahsup',                  10),
        ('muhasebe_fis.tur',        2, 'Tahsil',                  20),
        ('muhasebe_fis.tur',        3, 'Tediye',                  30),
        ('muhasebe_fis.tur',        4, 'Acilis',                  40),
        ('muhasebe_fis.tur',        5, 'Kapanis',                 50),
        ('muhasebe_fis.durum',      1, 'Kayitli',                 10),
        ('muhasebe_fis.durum',      2, 'Ters Fisle Iptal',        20),
        ('muhasebe_fis.durum',      3, 'Ters Fis',                30)
       ) as v(liste, deger, ad, sira)
  join public.kod_liste kl on kl.kod = v.liste
 where not exists (select 1 from public.kod_deger kd
                    where kd.liste_id = kl.id and kd.deger = v.deger and kd.dil = 0);

-- ------------------------------------------------------------- dogrulama ----
do $$
declare v_y integer; v_ry integer; v_kd integer;
begin
    select count(*) into v_y from public.yetki
     where kod in ('kasa_islem','hesap','cek_senet','kredi','proje','hesap_plani','muhasebe_fis',
                   'kasa_kapatma','masraf_merkezi','kasa_islem_turu')
        or kod like 'kasa.%' or kod like 'ceksenet.%' or kod like 'kredi.%'
        or kod like 'fis.%'  or kod like 'muhasebe.%';
    select count(*) into v_ry from public.rol_yetki ry
      join public.rol r on r.id = ry.rol_id
      join public.yetki y on y.id = ry.yetki_id
     where r.kod = 'yonetici' and (y.kod like 'kasa%' or y.kod like 'ceksenet%' or y.kod in ('hesap','proje','muhasebe_fis'));
    select count(*) into v_kd from public.kod_deger kd
      join public.kod_liste kl on kl.id = kd.liste_id
     where kl.kod like 'hesap.%' or kl.kod like 'cek_senet%' or kl.kod like 'kasa_islem%'
        or kl.kod like 'muhasebe_fis%' or kl.kod like 'proje.%' or kl.kod like 'hesap_plani%';
    raise notice '078 tamam: % yetki, yonetici rolune % kayit, % kod degeri', v_y, v_ry, v_kd;
end $$;
