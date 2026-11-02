-- =============================================================================
--  1220  RADYOLOJİ HAZIR ALAN PAKETLERİ - TORAKS BT (FLEISCHNER 2017) + BEYİN MR
--
--  Kullanıcı (01.11.2026): "Fleischner ve beyin MR paketlerini de yap" (1217-1219'un devamı).
--
--  TORAKS BT: amfizem, plevral efüzyon, lenf nodu; nodül - sayı, tip (solid / parsiyel solid / buzlu cam),
--    yerleşim, ortalama çap, solid komponent, kontur, kalsifikasyon, risk grubu ve Fleischner 2017 önerisi.
--    Öneri hekim tarafından seçilir (35 yaş altı, tarama ve kanser öyküsünde kriter uygulanmaz - ayrı seçenek).
--  BEYİN MR: Fazekas, difüzyon, laküner infarkt, mikrokanama; kitle (yer / boyut / kontrastlanma / ödem);
--    ventrikül, atrofi, orta hat kayması; sinüs / mastoid. Çocuk kranial (USG), BT, MRA / venografi eşleşmez.
--  İdempotent.
-- =============================================================================

begin;

create temp table _p (kod varchar(40), ad varchar(120), modalite smallint, bolge smallint, desen varchar(300),
                      haric varchar(300), aciklama text) on commit drop;
insert into _p values
  ('TORAKS-FLEISCHNER', 'Toraks BT (Fleischner)', 1, 2, 'TORAKS|AKCIGER|HRCT|GOGUS', 'MR|DOPPLER|GRAFI|USG',
   'Amfizem, efüzyon, lenf nodu; pulmoner nodül tipi / boyutu / konturu, risk grubu ve Fleischner 2017 önerisi.'),
  ('BEYIN-MR', 'Beyin MR', 2, 1, 'KRANI|BEYIN|DIF+UZYON', 'BT|MRA|VENOGRAF|ANJIO|SPEKTRO|COCUK|USG',
   'Fazekas, difüzyon, laküner infarkt, mikrokanama; kitle; ventrikül / atrofi / orta hat; sinüs, mastoid.');

insert into public.radyoloji_alan_paket (kod, ad, modalite, bolge, desen, haric_desen, aciklama)
select kod, ad, modalite, bolge, desen, haric, aciklama from _p
on conflict (kod) do update set ad = excluded.ad, modalite = excluded.modalite, bolge = excluded.bolge,
       desen = excluded.desen, haric_desen = excluded.haric_desen, aciklama = excluded.aciklama;

create temp table _a (paket varchar(40), sira smallint, grup varchar(40), kod varchar(40), ad varchar(80), tip smallint,
                      secenek varchar(400), kalip varchar(300), sifir varchar(300), birim varchar(20)) on commit drop;
insert into _a values
-- ======================================================== TORAKS BT (FLEISCHNER)
  ('TORAKS-FLEISCHNER', 1, 'Genel', 'amfizem', 'Amfizem', 1, 'Yok|Hafif|Orta|Belirgin',
   'Akciğerlerde {değer} amfizem izlenmiştir.', '', ''),
  ('TORAKS-FLEISCHNER', 2, 'Genel', 'efuzyon', 'Plevral efüzyon', 1, 'Yok|Sağda|Solda|Bilateral',
   '{değer} plevral efüzyon izlenmiştir.', 'Plevral efüzyon izlenmemiştir.', ''),
  ('TORAKS-FLEISCHNER', 3, 'Genel', 'lenf', 'Lenf nodu', 1,
   'Normal|Mediastinal lenfadenopati|Hiler lenfadenopati|Mediastinal ve hiler lenfadenopati',
   'Toraksta {değer} izlenmiştir.', 'Mediasten ve hilusta patolojik boyutta lenf nodu izlenmemiştir.', ''),
  ('TORAKS-FLEISCHNER', 10, 'Pulmoner nodül', 'nodul', 'Nodül', 1, 'Yok|Tek|Multiple',
   'Akciğer parankiminde {değer} nodül izlenmiştir.', 'Akciğer parankiminde nodül izlenmemiştir.', ''),
  ('TORAKS-FLEISCHNER', 11, 'Pulmoner nodül', 'nodul_tip', 'Nodül tipi', 1, 'Solid|Parsiyel solid|Saf buzlu cam',
   'En belirgin nodül {değer} yapıdadır.', '', ''),
  ('TORAKS-FLEISCHNER', 12, 'Pulmoner nodül', 'nodul_yer', 'Yerleşim', 1,
   'Sağ üst lob|Sağ orta lob|Sağ alt lob|Sol üst lob|Lingula|Sol alt lob',
   'Nodül {değer} yerleşimlidir.', '', ''),
  ('TORAKS-FLEISCHNER', 13, 'Pulmoner nodül', 'nodul_cap', 'Ortalama çap', 2, '', 'Nodülün ortalama çapı {değer} mm ölçülmüştür.', '', 'mm'),
  ('TORAKS-FLEISCHNER', 14, 'Pulmoner nodül', 'solid_komp', 'Solid komponent (parsiyel solid)', 2, '',
   'Solid komponent {değer} mm ölçülmüştür.', '', 'mm'),
  ('TORAKS-FLEISCHNER', 15, 'Pulmoner nodül', 'kontur', 'Kontur', 1, 'Düzgün|Lobüle|Spiküle',
   'Nodül konturları {değer}.', '', ''),
  ('TORAKS-FLEISCHNER', 16, 'Pulmoner nodül', 'kalsifikasyon', 'Kalsifikasyon', 1,
   'Yok|Benign paternde (santral / laminer / popcorn)|Benign olmayan paternde',
   'Nodülde {değer} kalsifikasyon izlenmiştir.', '', ''),
  ('TORAKS-FLEISCHNER', 17, 'Pulmoner nodül', 'risk', 'Hasta risk grubu', 1, 'Düşük risk|Yüksek risk',
   'Hasta {değer} grubundadır.', '', ''),
  ('TORAKS-FLEISCHNER', 18, 'Pulmoner nodül', 'fleischner', 'Fleischner 2017 önerisi', 1,
   'Rutin takip gerekmez|12. ayda isteğe bağlı BT|6-12. ayda BT, sonra 18-24. ayda BT düşünülebilir|3-6. ayda BT, sonra 18-24. ayda BT|3. ayda BT, PET-BT ya da biyopsi düşünülmeli|6-12. ayda BT, kalıcıysa 5 yıla kadar 2 yılda bir BT|3-6. ayda BT, kalıcı ve solid kısım 6 mm altıysa 5 yıl yıllık BT|Kriter uygulanmaz (tarama, kanser öyküsü, 35 yaş altı)',
   'Fleischner 2017 kriterlerine göre: {değer}.', '', ''),
-- ======================================================== BEYİN MR
  ('BEYIN-MR', 1, 'Parankim', 'fazekas', 'Beyaz cevher (Fazekas)', 1, 'Yok (Fazekas 0)|Fazekas 1|Fazekas 2|Fazekas 3',
   '{değer} ile uyumlu periventriküler ve derin beyaz cevher iskemik-gliotik değişiklikleri izlenmiştir.',
   'Beyaz cevherde patolojik sinyal değişikliği izlenmemiştir.', ''),
  ('BEYIN-MR', 2, 'Parankim', 'difuzyon', 'Difüzyon', 1, 'Yok|Akut infarkt ile uyumlu difüzyon kısıtlanması|Difüzyon kısıtlanması',
   'Difüzyon ağırlıklı görüntülerde {değer} izlenmiştir.',
   'Difüzyon ağırlıklı görüntülerde akut iskemi ile uyumlu difüzyon kısıtlanması izlenmemiştir.', ''),
  ('BEYIN-MR', 3, 'Parankim', 'infarkt_yer', 'Difüzyon kısıtlanan alan', 5, '', 'Difüzyon kısıtlanması {değer} yerleşimlidir.', '', ''),
  ('BEYIN-MR', 4, 'Parankim', 'lakun', 'Kronik laküner infarkt', 1, 'Yok|Tek|Multiple',
   '{değer} kronik laküner infarkt izlenmiştir.', '', ''),
  ('BEYIN-MR', 5, 'Parankim', 'mikrokanama', 'Mikrokanama (SWI)', 1, 'Yok|Var',
   'SWI sekansında mikrokanama odakları izlenmiştir.', '', ''),
  ('BEYIN-MR', 10, 'Kitle', 'kitle', 'Kitle lezyonu', 1, 'Yok|Var',
   'Kitle lezyonu izlenmiştir.', 'Kitle lezyonu izlenmemiştir.', ''),
  ('BEYIN-MR', 11, 'Kitle', 'kitle_yer', 'Yerleşim', 5, '', 'Lezyon {değer} yerleşimlidir.', '', ''),
  ('BEYIN-MR', 12, 'Kitle', 'kitle_boyut', 'Boyutlar (mm)', 5, '', 'Lezyon {değer} mm boyutlarındadır.', '', ''),
  ('BEYIN-MR', 13, 'Kitle', 'kontrast', 'Kontrastlanma', 1, 'Yok|Homojen kontrastlanma|Halkasal kontrastlanma|Heterojen kontrastlanma',
   'Kontrastlı incelemede lezyonda {değer} izlenmiştir.', '', ''),
  ('BEYIN-MR', 14, 'Kitle', 'odem', 'Perilezyonel ödem', 1, 'Yok|Var',
   'Lezyon çevresinde vazojenik ödem izlenmiştir.', '', ''),
  ('BEYIN-MR', 20, 'Ventrikül / sulkus', 'ventrikul', 'Ventriküler sistem', 1,
   'Normal|Genişlemiş (atrofi ile uyumlu)|Genişlemiş (hidrosefali)',
   'Ventriküler sistem {değer}.', 'Ventriküler sistem normal genişliktedir.', ''),
  ('BEYIN-MR', 21, 'Ventrikül / sulkus', 'atrofi', 'Atrofi', 1, 'Yok|Yaşla uyumlu|Yaşa göre belirgin',
   'Serebral sulkuslarda {değer} belirginleşme (atrofi) izlenmiştir.', '', ''),
  ('BEYIN-MR', 22, 'Ventrikül / sulkus', 'orta_hat', 'Orta hat kayması', 2, '', 'Orta hat yapılarında {değer} mm kayma izlenmiştir.', '', 'mm'),
  ('BEYIN-MR', 30, 'Diğer', 'sinus', 'Paranazal sinüsler', 1, 'Normal|Mukozal kalınlaşma|Sıvı seviyesi',
   'Paranazal sinüslerde {değer} izlenmiştir.', 'Görüntülenen paranazal sinüsler havalıdır.', ''),
  ('BEYIN-MR', 31, 'Diğer', 'mastoid', 'Mastoid hücreler', 1, 'Normal|Effüzyon',
   'Mastoid hücrelerde {değer} izlenmiştir.', '', '');

delete from public.radyoloji_alan_paket_alan a using public.radyoloji_alan_paket p, _p
 where a.paket_id = p.id and p.kod = _p.kod;
insert into public.radyoloji_alan_paket_alan (paket_id, sira, grup, alan_kod, alan_ad, tip, secenekler, birim,
                                              kalip, sifir_kalip, hedef_bolum, zorunlu, rapora_bas)
select p.id, a.sira, a.grup, a.kod, a.ad, a.tip, a.secenek, a.birim, a.kalip, a.sifir, 'Bulgular', 0, 0
  from _a a join public.radyoloji_alan_paket p on p.kod = a.paket;

commit;
