-- =====================================================================
--  906_lab_cekirdek_paneller.sql
--  ÇEKİRDEK LAB PANELLERİ — SUT eşlemeli tetkik + referans + panel.
--
--  Amaç (kullanıcı): yeni hastane sıfırdan 2000+ SUT hizmetini tek tek
--  girmesin; sık çalışılan çekirdek testler SUT hizmetine bağlı, referans
--  aralıklı ve panellenmiş HAZIR gelsin - hastane yalnız budar/ayarlar.
--
--  Zaten kurulu (dokunulmaz): Hemogram (25 param), TİT (strip+sediment),
--  6 kültür, 3 genetik panel, temel biyokimya (GLU/ÜRE/KRE/NA/K/CA/ALT/
--  AST/CRP/TSH/INR). Bu betik EKSİK çekirdeği tamamlar:
--    · Biyokimya rutini genişletme (TP, ALB, bilirubin, ALP, GGT, LDH,
--      amilaz, lipaz, ürik asit, Cl, P, Mg, HbA1c)
--    · Lipid (kolesterol, HDL, LDL, TG)
--    · Tiroid (sT3, sT4)  · Vitamin/mineral (B12, folat, D, ferritin)
--    · Koagülasyon (aPTT, fibrinojen)  · Akut faz (prokalsitonin)
--    · Hepatit/HIV serolojisi (HBsAg, Anti-HBs, Anti-HCV, Anti-HIV)
--
--  Her tetkik SUT hizmetine KODLA bağlanır (id makinede değişir). Hizmet
--  yoksa o satır atlanır (join boşa düşer) - betik yine çalışır.
--
--  Referans aralıkları YETİŞKİN GENEL değerlerdir; cihaz/yönteme göre
--  hastane kendi aralığını girer (lab_tetkik_referans). Nitel serolojide
--  aralık yok, "Non-reaktif" metni.
-- =====================================================================

-- ------------------------------------------------------- 1) TETKİKLER ----
insert into public.lab_tetkik
       (hizmet_id, kod, ad, kisa_ad, bolum, tur, numune_tipi, tup_tipi,
        birim, ondalik, loinc, yontem, deger_deseni, durum)
select h.id, v.kod, v.ad, v.kisa, 1, v.tur, v.numune, v.tup,
       v.birim, v.ondalik, '', '', '', 1
  from (values
    -- kod        ad                              kisa      sut        birim     ondalik tur numune tup
    ('TP',        'Total Protein',                'TP',     'L106300', 'g/dL',   1, 1, 1, 1),
    ('ALB',       'Albümin',                      'ALB',    'L100320', 'g/dL',   1, 1, 1, 1),
    ('TBIL',      'Bilirubin, Total',             'T.Bil',  'L101730', 'mg/dL',  2, 1, 1, 1),
    ('DBIL',      'Bilirubin, Direkt',            'D.Bil',  'L101710', 'mg/dL',  2, 1, 1, 1),
    ('ALP',       'Alkalen Fosfataz (ALP)',       'ALP',    'L100710', 'U/L',    0, 1, 1, 1),
    ('GGT',       'Gamma Glutamil Transferaz',    'GGT',    'L102780', 'U/L',    0, 1, 1, 1),
    ('LDH',       'Laktat Dehidrogenaz (LDH)',    'LDH',    'L104920', 'U/L',    0, 1, 1, 1),
    ('AMY',       'Amilaz',                       'AMY',    'L100800', 'U/L',    0, 1, 1, 1),
    ('LIP',       'Lipaz',                        'LIP',    'L105100', 'U/L',    0, 1, 1, 1),
    ('URIC',      'Ürik Asit',                    'Ürik',   'L107460', 'mg/dL',  1, 1, 1, 1),
    ('CL',        'Klorür',                       'Cl',     'L104180', 'mmol/L', 0, 1, 1, 1),
    ('P',         'Fosfor',                       'P',      'L102510', 'mg/dL',  1, 1, 1, 1),
    ('MG',        'Magnezyum',                    'Mg',     'L105230', 'mg/dL',  2, 1, 1, 1),
    ('HBA1C',     'HbA1c (Glike Hemoglobin)',     'HbA1c',  'L102820', '%',      1, 1, 1, 1),
    ('KOL',       'Total Kolesterol',             'Kol',    'L104520', 'mg/dL',  0, 1, 1, 1),
    ('HDL',       'HDL Kolesterol',               'HDL',    'L103050', 'mg/dL',  0, 1, 1, 1),
    ('LDL',       'LDL Kolesterol',               'LDL',    'L105000', 'mg/dL',  0, 1, 1, 1),
    ('TG',        'Trigliserid',                  'TG',     'L107250', 'mg/dL',  0, 1, 1, 1),
    ('FT3',       'Serbest T3 (sT3)',             'sT3',    'L106760', 'pg/mL',  2, 1, 1, 1),
    ('FT4',       'Serbest T4 (sT4)',             'sT4',    'L106770', 'ng/dL',  2, 1, 1, 1),
    ('FERR',      'Ferritin',                     'Ferr',   'L102410', 'ng/mL',  1, 1, 1, 1),
    ('B12',       'Vitamin B12',                  'B12',    'L107520', 'pg/mL',  0, 1, 1, 1),
    ('FOL',       'Folat',                        'Folat',  'L102480', 'ng/mL',  1, 1, 1, 1),
    ('VITD',      '25-OH Vitamin D',              'Vit D',  'L100220', 'ng/mL',  1, 1, 1, 1),
    ('PCT-INF',   'Prokalsitonin',                'PCT',    'L106240', 'ng/mL',  2, 1, 1, 1),
    ('APTT',      'aPTT',                         'aPTT',   'L101050', 'sn',     1, 1, 2, 1),
    ('FIB',       'Fibrinojen',                   'Fib',    'L102450', 'mg/dL',  0, 1, 2, 1),
    -- Nitel seroloji: birim yok, sonuç Reaktif/Non-reaktif.
    ('HBSAG',     'HBsAg',                        'HBsAg',  '907450', '',        0, 1, 1, 1),
    ('ANTIHBS',   'Anti-HBs',                     'A.HBs',  '906620', 'mIU/mL',  1, 1, 1, 1),
    ('ANTIHCV',   'Anti-HCV',                     'A.HCV',  '906640', '',        0, 1, 1, 1),
    ('ANTIHIV',   'Anti-HIV 1/2',                 'A.HIV',  '906660', '',        0, 1, 1, 1)
  ) as v(kod, ad, kisa, sut, birim, ondalik, tur, numune, tup)
  join public.hizmet h on h.kod = v.sut
 where not exists (select 1 from public.lab_tetkik t where t.kod = v.kod);

-- ------------------------------------------------- 2) REFERANS ARALIK ----
-- Yetişkin genel (cinsiyet=0). Cihaz/yönteme göre hastane değiştirir.
insert into public.lab_tetkik_referans
       (tetkik_id, cinsiyet, yas_alt_gun, yas_ust_gun, gebelik, alt, ust, metin,
        kaynak, gecerli_bas, sira)
select t.id, 0, 0, 0, 0, v.alt, v.ust, v.metin, 'Genel (yetişkin)', current_date, 1
  from (values
    ('TP',    6.4, 8.3, ''), ('ALB',  3.5, 5.2, ''),
    ('TBIL',  0.3, 1.2, ''), ('DBIL', 0.0, 0.3, ''),
    ('ALP',   40,  129, ''), ('GGT',  0,   55,  ''),
    ('LDH',   135, 225, ''), ('AMY',  28,  100, ''),
    ('LIP',   13,  60,  ''), ('URIC', 3.5, 7.2, ''),
    ('CL',    98,  107, ''), ('P',    2.5, 4.5, ''),
    ('MG',    1.7, 2.2, ''), ('HBA1C',4.0, 5.6, ''),
    ('KOL',   0,   200, 'İstenen < 200'), ('HDL', 40, 200, 'İstenen > 40'),
    ('LDL',   0,   100, 'İstenen < 100'), ('TG',  0,  150, 'İstenen < 150'),
    ('FT3',   2.3, 4.2, ''), ('FT4',  0.8, 1.7, ''),
    ('FERR',  22,  322, ''), ('B12',  197, 771, ''),
    ('FOL',   3.0, 17.0,''), ('VITD', 30,  100, 'Yeterli ≥ 30'),
    ('PCT-INF',0,  0.5, 'Bakteriyel enf. riski < 0,5'),
    ('APTT',  25,  35,  ''), ('FIB',  200, 400, ''),
    ('ANTIHBS',10, 1000,'Koruyucu ≥ 10 mIU/mL'),
    ('HBSAG', 0,   0,   'Non-reaktif'), ('ANTIHCV',0,0,'Non-reaktif'),
    ('ANTIHIV',0,  0,   'Non-reaktif')
  ) as v(kod, alt, ust, metin)
  join public.lab_tetkik t on t.kod = v.kod
 where not exists (select 1 from public.lab_tetkik_referans r where r.tetkik_id = t.id);

-- --------------------------------------------------------- 3) PANELLER ----
-- Panel modeli: lab_panel bir BİLEŞİK HİZMETE bağlıdır (tg_lab_panel_hizmet
--   hizmet_id'yi zorunlu tutar), üyeler hizmet_paket'te (paket_hizmet_id ->
--   icerik_hizmet_id) tutulur; lab_panel_satir bunun view'ıdır. SUT'ta tek
--   kodu olmayan paneller için yerel bileşik hizmet (PNL-*) açıyoruz -
--   hastane isterse SUT panel koduna remaple eder.

-- 3a) Panel bileşik hizmetleri.
insert into public.hizmet (kod, ad, paket, kdv, durum, sube_id)
select v.kod, v.ad, 1, 0, 1, (select min(id) from public.sube)
  from (values
    ('PNL-BIYORUTIN',  'Biyokimya Rutini (panel)'),
    ('PNL-KCFT',       'Karaciğer Fonksiyon Paneli'),
    ('PNL-BFT',        'Böbrek Fonksiyon Paneli'),
    ('PNL-LIPID',      'Lipid Paneli'),
    ('PNL-TIROID',     'Tiroid Paneli'),
    ('PNL-HEPHIV',     'Hepatit / HIV Seroloji Paneli'),
    ('PNL-KOAGULASYON','Koagülasyon Paneli')
  ) as v(kod, ad)
 where not exists (select 1 from public.hizmet h where h.kod = v.kod);

-- 3b) Paneller (bileşik hizmete bağlı).
insert into public.lab_panel (kod, ad, bolum, hizmet_id, durum, aciklama)
select v.kod, v.ad, 1, h.id, 1, v.aciklama
  from (values
    ('BIYORUTIN',  'Biyokimya Rutini',           'PNL-BIYORUTIN',  'Sık istenen tam biyokimya'),
    ('KCFT',       'Karaciğer Fonksiyon (KCFT)', 'PNL-KCFT',       'TP/ALB/bilirubin/ALT/AST/ALP/GGT/LDH'),
    ('BFT',        'Böbrek Fonksiyon (BFT)',     'PNL-BFT',        'Üre/kreatinin/ürik asit/elektrolit'),
    ('LIPID',      'Lipid Paneli',               'PNL-LIPID',      'Kolesterol/HDL/LDL/TG'),
    ('TIROID',     'Tiroid Paneli',              'PNL-TIROID',     'TSH/sT3/sT4'),
    ('HEPHIV',     'Hepatit / HIV Serolojisi',   'PNL-HEPHIV',     'HBsAg/Anti-HBs/Anti-HCV/Anti-HIV'),
    ('KOAGULASYON','Koagülasyon',                'PNL-KOAGULASYON','PT-INR/aPTT/fibrinojen')
  ) as v(kod, ad, hkod, aciklama)
  join public.hizmet h on h.kod = v.hkod
 where not exists (select 1 from public.lab_panel p where p.kod = v.kod);

-- 3c) Panel üyeleri -> hizmet_paket (paket = panel hizmeti, içerik = üye tetkiğin hizmeti).
insert into public.hizmet_paket (paket_hizmet_id, icerik_hizmet_id, sira, adet)
select p.hizmet_id, t.hizmet_id, v.sira, 1
  from (values
    ('BIYORUTIN','GLU',1),('BIYORUTIN','URE',2),('BIYORUTIN','KRE',3),('BIYORUTIN','URIC',4),
    ('BIYORUTIN','NA',5),('BIYORUTIN','K',6),('BIYORUTIN','CL',7),('BIYORUTIN','CA',8),
    ('BIYORUTIN','P',9),('BIYORUTIN','MG',10),('BIYORUTIN','TP',11),('BIYORUTIN','ALB',12),
    ('BIYORUTIN','TBIL',13),('BIYORUTIN','DBIL',14),('BIYORUTIN','ALT',15),('BIYORUTIN','AST',16),
    ('BIYORUTIN','ALP',17),('BIYORUTIN','GGT',18),('BIYORUTIN','LDH',19),('BIYORUTIN','AMY',20),
    ('BIYORUTIN','LIP',21),('BIYORUTIN','KOL',22),('BIYORUTIN','HDL',23),('BIYORUTIN','LDL',24),
    ('BIYORUTIN','TG',25),('BIYORUTIN','CRP',26),
    ('KCFT','TP',1),('KCFT','ALB',2),('KCFT','TBIL',3),('KCFT','DBIL',4),('KCFT','ALT',5),
    ('KCFT','AST',6),('KCFT','ALP',7),('KCFT','GGT',8),('KCFT','LDH',9),
    ('BFT','URE',1),('BFT','KRE',2),('BFT','URIC',3),('BFT','NA',4),('BFT','K',5),
    ('BFT','CL',6),('BFT','CA',7),('BFT','P',8),
    ('LIPID','KOL',1),('LIPID','HDL',2),('LIPID','LDL',3),('LIPID','TG',4),
    ('TIROID','TSH',1),('TIROID','FT3',2),('TIROID','FT4',3),
    ('HEPHIV','HBSAG',1),('HEPHIV','ANTIHBS',2),('HEPHIV','ANTIHCV',3),('HEPHIV','ANTIHIV',4),
    ('KOAGULASYON','INR',1),('KOAGULASYON','APTT',2),('KOAGULASYON','FIB',3)
  ) as v(panel_kod, tetkik_kod, sira)
  join public.lab_panel  p on p.kod = v.panel_kod
  join public.lab_tetkik t on t.kod = v.tetkik_kod
 where t.hizmet_id is not null and p.hizmet_id is not null
   and not exists (select 1 from public.hizmet_paket hp
                    where hp.paket_hizmet_id = p.hizmet_id
                      and hp.icerik_hizmet_id = t.hizmet_id);

do $$
begin
    raise notice '906 tamam: tetkik %, referans %, panel %, panel satiri %',
        (select count(*) from public.lab_tetkik),
        (select count(*) from public.lab_tetkik_referans),
        (select count(*) from public.lab_panel),
        (select count(*) from public.lab_panel_satir);
end $$;
