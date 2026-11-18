-- =============================================================================
--  1380 - RADYOLOJİ HAZIR ALAN PAKETLERİ: PROSTAT MR (PI-RADS v2.1) + KARACİĞER BT / MR (LI-RADS v2018)
--
--  Kullanıcı (18.11.2026): "1, 2 ve 3'ü yap, bitince 4 ve 5'e geç" (yapısal rapor önerileri 4 PI-RADS, 5 LI-RADS).
--
--  PROSTAT-PIRADS: boyut -> elipsoid hacim (otomatik), PSA -> PSA yoğunluğu (otomatik), BPH; indeks lezyon - zon,
--    yerleşim, boyut, T2 / DWI skoru (1-5), dinamik kontrast; PI-RADS kategorisi (otomatik, v2.1 zon kuralı - web
--    pirads.ts); evreleme: ekstraprostatik uzanım, seminal vezikül, lenf nodu, kemik.
--  KARACIGER-LIRADS: risk grubu; gözlem - segment, çap, non-rim APHE, non-periferik washout, kapsül, eşik büyüme;
--    özel kategori (LR-1 / LR-2 / LR-M / LR-TIV / LR-NC - hekim); LI-RADS kategorisi (otomatik, v2018 BT/MR tanı
--    tablosu - web lirads.ts). Yardımcı (ancillary) bulgularla ±1 düzeltme hekimin elle seçimidir.
--  Kategoriler / hesaplar ÖNERİDİR - hekim değiştirebilir. Desen şablon ADINA bakar (fn_rad_alan_paketi_uyar);
--    US / doppler / biyopsi şablonları hariç. İdempotent.
-- =============================================================================
begin;
create temp table _p (kod varchar(40), ad varchar(120), modalite smallint, bolge smallint, desen varchar(300),
                      haric varchar(300), aciklama text) on commit drop;
insert into _p values
  ('PROSTAT-PIRADS', 'Prostat MR (PI-RADS v2.1)', 2, 3, 'PROSTAT',
   '(^|[^A-Z])(US|USG|TRUS|BT)([^A-Z]|$)|BIYOPSI|SINTIGRAF',
   'Prostat boyutu, hacim ve PSA yoğunluğu (otomatik), BPH; indeks lezyon zon / yer / boyut, T2 - DWI skoru, dinamik kontrast; PI-RADS v2.1 kategorisi (otomatik); EPE, seminal vezikül, lenf nodu, kemik.'),
  ('KARACIGER-LIRADS', 'Karaciğer BT / MR (LI-RADS v2018)', null, 3,
   'KARACIGER|HEPAT|LI-?RADS|TRIFAZ|DINAMIK (UST |TUM )?(ABDOMEN|BATIN)',
   '(^|[^A-Z])(US|USG)([^A-Z]|$)|DOPPLER|ANJIO|ELASTO',
   'HCC risk grubu; gözlem segment / çap, non-rim APHE, washout, kapsül, eşik büyüme; özel kategori; LI-RADS v2018 kategorisi (otomatik).');
insert into public.radyoloji_alan_paket (kod, ad, modalite, bolge, desen, haric_desen, aciklama)
select kod, ad, modalite, bolge, desen, haric, aciklama from _p
on conflict (kod) do update set ad = excluded.ad, modalite = excluded.modalite, bolge = excluded.bolge,
       desen = excluded.desen, haric_desen = excluded.haric_desen, aciklama = excluded.aciklama;

create temp table _a (paket varchar(40), sira smallint, grup varchar(40), kod varchar(40), ad varchar(80), tip smallint,
                      secenek varchar(400), kalip varchar(300), sifir varchar(300), birim varchar(20)) on commit drop;
insert into _a values
-- ======================================================== PROSTAT MR (PI-RADS v2.1)
  ('PROSTAT-PIRADS', 1, 'Prostat', 'prostat_boyut', 'Boyutlar (AP x TR x KK, mm)', 5, '',
   'Prostat {değer} mm boyutlarındadır.', '', ''),
  ('PROSTAT-PIRADS', 2, 'Prostat', 'prostat_hacim', 'Hacim (elipsoid)', 2, '',
   'Prostat hacmi (elipsoid formülü) {değer} mL hesaplanmıştır.', '', 'mL'),
  ('PROSTAT-PIRADS', 3, 'Prostat', 'psa', 'Serum PSA', 2, '', 'Serum PSA düzeyi {değer} ng/mL.', '', 'ng/mL'),
  ('PROSTAT-PIRADS', 4, 'Prostat', 'psad', 'PSA yoğunluğu', 2, '', 'PSA yoğunluğu {değer} ng/mL/mL.', '', 'ng/mL/mL'),
  ('PROSTAT-PIRADS', 5, 'Prostat', 'bph', 'Benign prostat hiperplazisi', 1, 'Yok|Var',
   'Transizyonel zonda benign prostat hiperplazisi ile uyumlu nodüler değişiklikler izlenmiştir.', '', ''),
  ('PROSTAT-PIRADS', 10, 'İndeks lezyon', 'lezyon', 'İndeks lezyon', 1, 'Yok|Var',
   'Prostatta aşağıda tanımlanan indeks lezyon izlenmiştir.',
   'Klinik olarak anlamlı kanser düşündüren odak lezyon izlenmemiştir.', ''),
  ('PROSTAT-PIRADS', 11, 'İndeks lezyon', 'zon', 'Zon', 1, 'Periferik zon|Transizyonel zon',
   'Lezyon {değer} yerleşimlidir.', '', ''),
  ('PROSTAT-PIRADS', 12, 'İndeks lezyon', 'lezyon_yer', 'Yerleşim (taraf / seviye / sektör)', 5, '',
   'Lezyon yerleşimi: {değer}.', '', ''),
  ('PROSTAT-PIRADS', 13, 'İndeks lezyon', 'lezyon_boyut', 'Lezyon boyutu', 2, '', 'Lezyon {değer} mm boyutundadır.', '', 'mm'),
  ('PROSTAT-PIRADS', 14, 'İndeks lezyon', 't2', 'T2A skoru', 1, '1|2|3|4|5', 'T2A skoru {değer}.', '', ''),
  ('PROSTAT-PIRADS', 15, 'İndeks lezyon', 'dwi', 'DAG / ADC skoru', 1, '1|2|3|4|5', 'Difüzyon (DAG / ADC) skoru {değer}.', '', ''),
  ('PROSTAT-PIRADS', 16, 'İndeks lezyon', 'dce', 'Dinamik kontrastlanma', 1, 'Negatif|Pozitif',
   'Dinamik kontrastlı serilerde {değer} kontrastlanma paterni izlenmiştir.', '', ''),
  ('PROSTAT-PIRADS', 17, 'İndeks lezyon', 'pirads', 'PI-RADS kategorisi', 1,
   'PI-RADS 1 (çok düşük olasılık)|PI-RADS 2 (düşük olasılık)|PI-RADS 3 (orta düzey olasılık)|PI-RADS 4 (yüksek olasılık)|PI-RADS 5 (çok yüksek olasılık)',
   'İndeks lezyon {değer} kategorisindedir (klinik olarak anlamlı kanser).', '', ''),
  ('PROSTAT-PIRADS', 20, 'Evreleme', 'epe', 'Ekstraprostatik uzanım', 1, 'Yok|Şüpheli|Var',
   'Ekstraprostatik uzanım: {değer}.', 'Ekstraprostatik uzanım izlenmemiştir.', ''),
  ('PROSTAT-PIRADS', 21, 'Evreleme', 'sv', 'Seminal vezikül invazyonu', 1, 'Yok|Şüpheli|Var',
   'Seminal vezikül invazyonu: {değer}.', 'Seminal veziküller olağandır.', ''),
  ('PROSTAT-PIRADS', 22, 'Evreleme', 'lenf', 'Pelvik lenf nodu', 1, 'Yok|Şüpheli|Patolojik',
   'Pelvik lenf nodu: {değer}.', 'Patolojik boyutta pelvik lenf nodu izlenmemiştir.', ''),
  ('PROSTAT-PIRADS', 23, 'Evreleme', 'kemik', 'Kemik lezyonu', 1, 'Yok|Şüpheli|Metastaz ile uyumlu',
   'Görüntülenen kemik yapılarda {değer} lezyon izlenmiştir.',
   'Görüntülenen kemik yapılarda metastaz lehine lezyon izlenmemiştir.', ''),
-- ======================================================== KARACİĞER BT / MR (LI-RADS v2018)
  ('KARACIGER-LIRADS', 1, 'Risk', 'risk', 'HCC risk grubu', 1, 'Siroz|Kronik hepatit B|Önceki HCC|Risk grubunda değil',
   'HCC risk durumu: {değer}.', '', ''),
  ('KARACIGER-LIRADS', 10, 'Gözlem', 'lezyon', 'Gözlem (lezyon)', 1, 'Yok|Var',
   'Karaciğerde aşağıda tanımlanan gözlem izlenmiştir.',
   'Karaciğerde LI-RADS kapsamında değerlendirilecek gözlem izlenmemiştir.', ''),
  ('KARACIGER-LIRADS', 11, 'Gözlem', 'segment', 'Segment', 1,
   'Segment 1|Segment 2|Segment 3|Segment 4a|Segment 4b|Segment 5|Segment 6|Segment 7|Segment 8',
   'Gözlem {değer} yerleşimlidir.', '', ''),
  ('KARACIGER-LIRADS', 12, 'Gözlem', 'lezyon_cap', 'Çap', 2, '', 'Gözlemin çapı {değer} mm ölçülmüştür.', '', 'mm'),
  ('KARACIGER-LIRADS', 13, 'Majör bulgular', 'aphe', 'Non-rim arteryel faz hiperenhansmanı (APHE)', 1, 'Yok|Var',
   'Arteryel fazda non-rim hiperenhansman (APHE) izlenmiştir.',
   'Arteryel fazda non-rim hiperenhansman izlenmemiştir.', ''),
  ('KARACIGER-LIRADS', 14, 'Majör bulgular', 'washout', 'Non-periferik washout', 1, 'Yok|Var',
   'Portal venöz / geç fazda non-periferik washout izlenmiştir.', 'Non-periferik washout izlenmemiştir.', ''),
  ('KARACIGER-LIRADS', 15, 'Majör bulgular', 'kapsul', 'Kontrastlanan kapsül', 1, 'Yok|Var',
   'Kontrastlanan kapsül görünümü izlenmiştir.', 'Kapsül görünümü izlenmemiştir.', ''),
  ('KARACIGER-LIRADS', 16, 'Majör bulgular', 'buyume', 'Eşik büyüme', 1, 'Yok|Var',
   'Eşik büyüme (6 ay içinde %50 ve üzeri) saptanmıştır.', '', ''),
  ('KARACIGER-LIRADS', 20, 'Kategori', 'ozel', 'Özel kategori', 1,
   'Yok|LR-1 (kesin benign)|LR-2 (muhtemel benign)|LR-M (HCC dışı malignite olası)|LR-TIV (vende tümör)|LR-NC (kategorize edilemez)',
   'Gözlem {değer} olarak değerlendirilmiştir.', '', ''),
  ('KARACIGER-LIRADS', 21, 'Kategori', 'lirads', 'LI-RADS kategorisi', 1,
   'LR-1|LR-2|LR-3 (orta olasılık)|LR-4 (muhtemel HCC)|LR-5 (kesin HCC)|LR-M|LR-TIV|LR-NC',
   'Gözlem LI-RADS v2018 {değer} kategorisindedir.', '', '');

delete from public.radyoloji_alan_paket_alan a using public.radyoloji_alan_paket p, _p
 where a.paket_id = p.id and p.kod = _p.kod;
insert into public.radyoloji_alan_paket_alan (paket_id, sira, grup, alan_kod, alan_ad, tip, secenekler, birim,
                                              kalip, sifir_kalip, hedef_bolum, zorunlu, rapora_bas)
select p.id, a.sira, a.grup, a.kod, a.ad, a.tip, a.secenek, a.birim, a.kalip, a.sifir, 'Bulgular', 0, 0
  from _a a join public.radyoloji_alan_paket p on p.kod = a.paket;
commit;
