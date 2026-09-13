-- =====================================================================
--  640_tam_idrar_paneli.sql
--  TAM İDRAR TAHLİLİ (TİT) PANELİ - 21 parametre.
--
--  SUT'ta TEK kalem: `L107010 TAM İDRAR ANALİZİ (STRİP+MİKROSKOPİ)`.
--  Adından da anlaşıldığı gibi iki ayrı çalışma tek raporda birleşir:
--    * STRİP (kimyasal) - dansite, pH, protein, glukoz, keton, bilirubin,
--      ürobilinojen, nitrit, lökosit esteraz, kan
--    * MİKROSKOPİ (sediment) - lökosit, eritrosit, epitel, silendir,
--      kristal, bakteri, maya, mukus
--  Buna fiziksel bakı (renk, görünüm) eklenir.
--
--  SONUÇ TÜRÜ ÇOĞUNLUKLA SAYISAL DEĞİL (639'daki hemogramdan farkı):
--    * Renk/görünüm METİN (2) - "sarı", "berrak"
--    * Strip kalemleri SEÇENEK (3) - negatif / + / ++ / +++
--    * Dansite, pH ve sediment sayımları SAYISAL (1)
--  Türü yanlış koymak sonucu girilemez yapar: sayısal alana "negatif"
--  yazılamaz, delta kontrolü ve panik sınırı da anlamını yitirir.
--
--  NUMUNE İDRAR KABI (tüp 6): hemogramın EDTA tüpüyle birleşmez - numune
--  planı tüp tipine göre grupluyor, hasta zaten tek idrar kabı veriyor.
--
--  Panel düzeni 638/639 ile aynı: parametreler kurum içi `LAB-*`
--  hizmetlere bağlı (SUT'ta ayrı kalemleri yok), fatura panelden kesilir.
-- =====================================================================

-- ------------------------------------------------ parametre hizmetleri (21)
insert into public.hizmet (kod, ad, baslik_mi, ust_id, grubu, tur, kdv,
                           birim, durum, kategori, paket, sube_id)
select v.kod, v.ad || ' (TİT parametresi)', 0, h.ust_id, 0, 0, h.kdv,
       h.birim, 1, h.kategori, 0, h.sube_id
  from (values
        ('LAB-IRENK','Renk'), ('LAB-IGORUNUM','Görünüm'),
        ('LAB-IDANSITE','Dansite'), ('LAB-IPH','pH'),
        ('LAB-IPRO','Protein'), ('LAB-IGLU','Glukoz'),
        ('LAB-IKET','Keton'), ('LAB-IBIL','Bilirubin'),
        ('LAB-IURO','Ürobilinojen'), ('LAB-INIT','Nitrit'),
        ('LAB-ILE','Lökosit esteraz'), ('LAB-IKAN','Kan (eritrosit)'),
        ('LAB-ISLEU','Sediment lökosit'), ('LAB-ISERI','Sediment eritrosit'),
        ('LAB-ISEPI','Epitel hücresi'), ('LAB-ISSIL','Silendir'),
        ('LAB-ISKRI','Kristal'), ('LAB-ISBAK','Bakteri'),
        ('LAB-ISMAY','Maya'), ('LAB-ISMUK','Mukus'),
        ('LAB-ISPAR','Parazit / Trichomonas')
       ) v(kod, ad)
  join public.hizmet h on h.kod = 'L107010'
 where not exists (select 1 from public.hizmet x where x.kod = v.kod);

-- FATURA PANELDEN: içerik kalemlerinden ayrıca ücret alınmaz.
update public.hizmet set paket = 1 where kod = 'L107010' and paket <> 1;

-- ----------------------------------------------------- parametre tetkikleri
--  Bölüm 7 = İdrar. Numune 4 (idrar), tüp 6 (idrar kabı).
insert into public.lab_tetkik
       (kod, ad, kisa_ad, bolum, tur, numune_tipi, tup_tipi, birim, ondalik,
        loinc, hedef_tat_dk, acil_tat_dk, oto_onay, durum, sube_id)
select v.kod, v.ad, v.kod, 7, v.tur, 4, 6, v.birim, v.ondalik,
       v.loinc, 60, 30, 1, 0, 1
  from (values
        -- FİZİKSEL BAKI
        ('IRENK',    'İdrar Rengi',            2::smallint, '',       0::smallint, '5778-6'),
        ('IGORUNUM', 'İdrar Görünümü',         2,           '',       0,           '5767-9'),
        ('IDANSITE', 'Dansite (Özgül Ağırlık)', 1,          '',       3,           '5811-5'),
        -- STRİP (KİMYASAL)
        ('IPH',      'İdrar pH',               1,           '',       1,           '5803-2'),
        ('IPRO',     'Protein (strip)',        3,           '',       0,           '5804-0'),
        ('IGLU',     'Glukoz (strip)',         3,           '',       0,           '5792-7'),
        ('IKET',     'Keton (strip)',          3,           '',       0,           '5797-6'),
        ('IBIL',     'Bilirubin (strip)',      3,           '',       0,           '5770-3'),
        ('IURO',     'Ürobilinojen (strip)',   3,           '',       0,           '5818-0'),
        ('INIT',     'Nitrit (strip)',         3,           '',       0,           '5802-4'),
        ('ILE',      'Lökosit Esteraz (strip)', 3,          '',       0,           '5799-2'),
        ('IKAN',     'Kan / Eritrosit (strip)', 3,          '',       0,           '5794-3'),
        -- MİKROSKOPİ (SEDİMENT)
        ('ISLEU',    'Sediment Lökosit',       1,           '/HPF',   0,           '5821-4'),
        ('ISERI',    'Sediment Eritrosit',     1,           '/HPF',   0,           '5808-1'),
        ('ISEPI',    'Epitel Hücresi',         3,           '/HPF',   0,           '5787-7'),
        ('ISSIL',    'Silendir',               3,           '/LPF',   0,           '5783-6'),
        ('ISKRI',    'Kristal',                3,           '/HPF',   0,           '5769-5'),
        ('ISBAK',    'Bakteri',                3,           '/HPF',   0,           '5769-5'),
        ('ISMAY',    'Maya',                   3,           '/HPF',   0,           '5799-2'),
        ('ISMUK',    'Mukus',                  3,           '',       0,           ''),
        ('ISPAR',    'Parazit / Trichomonas',  3,           '',       0,           '')
       ) v(kod, ad, tur, birim, ondalik, loinc)
 where not exists (select 1 from public.lab_tetkik x where x.kod = v.kod);

-- ------------------------------------------------- tetkik -> hizmet köprüsü
update public.lab_tetkik t
   set hizmet_id = h.id, degistirme_tarihi = now()
  from (values
        ('IRENK','LAB-IRENK'), ('IGORUNUM','LAB-IGORUNUM'),
        ('IDANSITE','LAB-IDANSITE'), ('IPH','LAB-IPH'),
        ('IPRO','LAB-IPRO'), ('IGLU','LAB-IGLU'), ('IKET','LAB-IKET'),
        ('IBIL','LAB-IBIL'), ('IURO','LAB-IURO'), ('INIT','LAB-INIT'),
        ('ILE','LAB-ILE'), ('IKAN','LAB-IKAN'),
        ('ISLEU','LAB-ISLEU'), ('ISERI','LAB-ISERI'), ('ISEPI','LAB-ISEPI'),
        ('ISSIL','LAB-ISSIL'), ('ISKRI','LAB-ISKRI'), ('ISBAK','LAB-ISBAK'),
        ('ISMAY','LAB-ISMAY'), ('ISMUK','LAB-ISMUK'), ('ISPAR','LAB-ISPAR')
       ) v(tetkik_kod, hizmet_kod)
  join public.hizmet h on h.kod = v.hizmet_kod
 where t.kod = v.tetkik_kod
   and coalesce(t.hizmet_id, 0) = 0;

-- --------------------------------------------------------------- panel
insert into public.lab_panel (kod, ad, bolum, hizmet_id, durum, sube_id)
select 'TIT', 'Tam İdrar Tahlili (Strip + Mikroskopi)', 7, h.id, 0, h.sube_id
  from public.hizmet h
 where h.kod = 'L107010'
   and not exists (select 1 from public.lab_panel p where p.kod = 'TIT');

-- Sıra rapor sırasıdır: fiziksel bakı, strip, sediment.
insert into public.lab_panel_satir (panel_id, tetkik_id, sira)
select p.id, t.id, v.sira
  from (values
        ('IRENK', 10::smallint), ('IGORUNUM', 20), ('IDANSITE', 30),
        ('IPH', 40), ('IPRO', 50), ('IGLU', 60), ('IKET', 70),
        ('IBIL', 80), ('IURO', 90), ('INIT', 100), ('ILE', 110), ('IKAN', 120),
        ('ISLEU', 130), ('ISERI', 140), ('ISEPI', 150), ('ISSIL', 160),
        ('ISKRI', 170), ('ISBAK', 180), ('ISMAY', 190), ('ISMUK', 200),
        ('ISPAR', 210)
       ) v(kod, sira)
  join public.lab_tetkik t on t.kod = v.kod
  join public.lab_panel p on p.kod = 'TIT'
 where not exists (select 1 from public.lab_panel_satir s
                    where s.panel_id = p.id and s.tetkik_id = t.id);

do $kontrol$
begin
    raise notice '640 tamam: TİT paneli % parametre, hizmete baglanmamis tetkik %',
        (select count(*) from public.lab_panel_satir s
           join public.lab_panel p on p.id = s.panel_id and p.kod = 'TIT'),
        (select count(*) from public.lab_tetkik where coalesce(hizmet_id, 0) = 0);
end $kontrol$;
