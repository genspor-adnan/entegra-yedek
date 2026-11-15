-- ============================================================================================
--  KOŞUYOLU RADYOLOJİ ENVANTERİ (15.11.2026, kullanıcı: "Envanter Listesi - Koşuyolu Radyoloji.pdf'i sabit varlıklar
--  listesine ekle; cihazlar radyoloji cihaz listesinde ve randevu listesinde de bulunsun").
--  Kaynak: Dosya/Envanter Listesi - Koşuyolu Radyoloji.pdf (Sonomed Biyomedikal Asset Manager, 13.11.2026).
--
--  * radyoloji_cihaz: görüntüleme cihazları (7) - randevu verilir, 08:00-20:00 Cumartesi dahil (kullanıcı 15.11.2026),
--    slot modaliteye göre
--    (MR 30 dk, diğerleri 15, DR 10). BT enjektörü aksesuardır: cihaz listesine girmez, yalnız demirbaş.
--  * demirbas (Sabit Varlıklar): 8 kalem, kategori Tıbbi Cihaz. demirbas.cihaz_id lab/göz ARAYÜZ cihazı (public.cihaz)
--    içindir, radyoloji cihazına bağ radyoloji_cihaz.demirbas_no = demirbas.kod üstünden kurulur.
--  Tekrar çalıştırılabilir: kod üstünden günceller (ux_radyoloji_cihaz_kod, ux_demirbas_kod).
-- ============================================================================================
\set ON_ERROR_STOP on
begin;

create temp table zz_env (sira int, modalite int, cihaz_kodu text, ad text, marka text, model text, stok_no text, seri_no text,
                          uretim_yili int, slot_dk int, cihaz_mi int);
insert into zz_env values
 (1, 1, 'KOS-BT-001',  'BT Siemens Somatom go.Now 16',       'SIEMENS',      'SOMATOM GO NOW 16',       'KOS-BT-001',  '107246',       2016, 15, 1),
 (2, 1, 'KOS-BT-002',  'BT Enjektör LF Optivantage CT 9000', 'LF',           'OPTIVANTAGE CT 9000',     'KOS-BT-002',  'CI1208B023',   null, 15, 0),
 (3, 4, 'KOS-DR-001',  'DR Ecoray SMS-TS-2',                 'ECORAY',       'SMS-TS-2',                'KOS-DR-001',  '1606123',      2016, 10, 1),
 (4, 6, 'KOS-KEM-001', 'Kemik Dansitometre GE Lunar DPX',    'GE',           'LUNAR DPX',               'KOS-KEM-001', '72149',        2000, 15, 1),
 (5, 5, 'KOS-MG-001',  'Mamografi Metaltronika Helianthus',  'METALTRONIKA', 'HELIANTHUS',              'KOS-MG-001',  'HELI/0120/C2', 2017, 15, 1),
 (6, 2, 'KOS-MR-001',  'MR GE Signa Victor 1.5T (2025 upgrade)', 'GE',       'SIGNA VICTOR 1.5T',       'KOS-MR-001',  'R4856',        2006, 30, 1),
 (7, 3, 'KOS-USG-002', 'USG Siemens Acuson S2000',           'SIEMENS',      'ACUSON S 2000',           'KOS-USG-002', '202104',       2012, 15, 1),
 (8, 3, 'KOS-USG-001', 'USG GE Voluson E9',                  'GE',           'VOLUSON E9',              'KOS-USG-001', '132791US5',    2013, 15, 1);

-- ------------------------------------------------------------- radyoloji cihazları --
insert into public.radyoloji_cihaz (kod, ad, modalite, sube_id, durum, randevu_verilir, baslangic_saat, bitis_saat,
                                    slot_dk, varsayilan_sure, calisma_gunleri, marka, model, seri_no, uretim_yili, demirbas_no, aciklama)
select e.cihaz_kodu, e.ad, e.modalite, 1, 1, 1, '08:00', '20:00', e.slot_dk, e.slot_dk, '1,2,3,4,5,6',
       e.marka, e.model, e.seri_no, e.uretim_yili, e.stok_no, 'Envanter listesi 13.11.2026 (Sonomed Asset Manager)'
  from zz_env e
 where e.cihaz_mi = 1
   and not exists (select 1 from public.radyoloji_cihaz c where lower(c.kod) = lower(e.cihaz_kodu));
-- Var olan kayıt: kimlik alanları ve çalışma saatleri envanter kuralından tazelenir (08:00-20:00, Pzt-Cmt).
update public.radyoloji_cihaz c
   set marka = e.marka, model = e.model, seri_no = e.seri_no, uretim_yili = e.uretim_yili, demirbas_no = e.stok_no,
       modalite = e.modalite, ad = case when c.ad = '' then e.ad else c.ad end, durum = 1,
       baslangic_saat = '08:00', bitis_saat = '20:00', calisma_gunleri = '1,2,3,4,5,6'
  from zz_env e
 where e.cihaz_mi = 1 and lower(c.kod) = lower(e.cihaz_kodu);

-- ------------------------------------------------------------- sabit varlıklar (demirbaş) --
insert into public.demirbas (kod, ad, kategori, marka, model, seri_no, model_yili, durum, lokasyon, sube_id, aciklama)
select e.stok_no, e.ad, 2, e.marka, e.model, e.seri_no, e.uretim_yili, 1, 1, 1,
       'Envanter Listesi - Koşuyolu Radyoloji (Sonomed Biyomedikal Asset Manager, 13.11.2026)'
  from zz_env e
on conflict (kod) where (kod <> '') do update
   set ad = excluded.ad, kategori = excluded.kategori, marka = excluded.marka, model = excluded.model,
       seri_no = excluded.seri_no, model_yili = excluded.model_yili;

select 'radyoloji cihazı (randevu verilir, aktif): ' || count(*) as rapor from public.radyoloji_cihaz where durum = 1 and randevu_verilir = 1
union all select 'demirbaş (Tıbbi Cihaz, Koşuyolu): ' || count(*) from public.demirbas where kategori = 2 and sube_id = 1
union all select 'radyoloji cihazıyla eşleşen demirbaş: ' || count(*) from public.demirbas d where exists (select 1 from public.radyoloji_cihaz c where c.demirbas_no = d.kod);

commit;
