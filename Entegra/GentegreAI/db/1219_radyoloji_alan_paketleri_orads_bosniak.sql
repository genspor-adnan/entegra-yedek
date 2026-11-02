-- =============================================================================
--  1219  RADYOLOJİ HAZIR ALAN PAKETLERİ - O-RADS US (PELVİK) + BOSNİAK (BÖBREK KİSTİ)
--
--  Kullanıcı (01.11.2026): "O-RADS ve Bosniak paketlerini de yap" (1217 / 1218'in devamı).
--
--  O-RADS US (ACR 2022): menopoz durumu, uterus / endometrium; adneksiyal lezyon - taraf, boyut, sözlük tipi
--    (klasik benign lezyonlar ayrı seçenek), renk skoru 1-4, asit / peritoneal nodül; O-RADS 0-5 ve öneri.
--  BOSNİAK (2019): böbrek boyutu / parankim, hidronefroz (sağ / sol), taş; kist - taraf, boyut, duvar, septa,
--    kalsifikasyon, kontrastlanma (kontrastsız incelemede boş), nodül; Bosniak I-IV ve öneri. (2019 sürümü BT / MR içindir; USG'de kist
--    tanımlaması aynı sözlükle yazılır, kategori hekim kararıdır.)
--  Kategoriler hekim tarafından seçilir (otomatik hesap yalnız TI-RADS'ta). İdempotent.
-- =============================================================================

begin;

create temp table _p (kod varchar(40), ad varchar(120), modalite smallint, bolge smallint, desen varchar(300),
                      haric varchar(300), aciklama text) on commit drop;
insert into _p values
  ('PELVIK-ORADS', 'Pelvik USG (O-RADS)', 3, 3, 'PELVI|TRANSVAJ|ADNEKS|(^|[^A-Z])OVER([^A-Z]|$)', 'ERKEK|MR|BT|DOPPLER',
   'Menopoz, uterus, endometrium; adneksiyal lezyon tipi (O-RADS sözlüğü), renk skoru, asit; O-RADS 0-5 ve öneri.'),
  ('BOBREK-BOSNIAK', 'Böbrek (Bosniak)', 3, 3, 'BOBREK|RENAL|URINER|UROGRAF', 'MRA|ANJIO|DOPPLER|ARTER',
   'Böbrek boyutu, parankim, hidronefroz, taş; kist duvar / septa / kalsifikasyon / kontrastlanma / nodül; Bosniak I-IV ve öneri.');

insert into public.radyoloji_alan_paket (kod, ad, modalite, bolge, desen, haric_desen, aciklama)
select kod, ad, modalite, bolge, desen, haric, aciklama from _p
on conflict (kod) do update set ad = excluded.ad, modalite = excluded.modalite, bolge = excluded.bolge,
       desen = excluded.desen, haric_desen = excluded.haric_desen, aciklama = excluded.aciklama;

create temp table _a (paket varchar(40), sira smallint, grup varchar(40), kod varchar(40), ad varchar(80), tip smallint,
                      secenek varchar(400), kalip varchar(300), sifir varchar(300), birim varchar(20)) on commit drop;
insert into _a values
-- ======================================================== PELVİK USG (O-RADS)
  ('PELVIK-ORADS', 1, 'Uterus', 'menopoz', 'Menopoz durumu', 1, 'Premenopozal|Postmenopozal',
   'Hasta {değer} dönemdedir.', '', ''),
  ('PELVIK-ORADS', 2, 'Uterus', 'uterus_boyut', 'Uterus boyutları (mm)', 5, '', 'Uterus {değer} mm boyutlarındadır.', '', ''),
  ('PELVIK-ORADS', 3, 'Uterus', 'endometrium', 'Endometrium kalınlığı', 2, '', 'Endometrium kalınlığı {değer} mm ölçülmüştür.', '', 'mm'),
  ('PELVIK-ORADS', 4, 'Uterus', 'myom', 'Myom', 1, 'Yok|Tek|Multiple',
   'Uteruste {değer} myom izlenmiştir.', '', ''),
  ('PELVIK-ORADS', 5, 'Uterus', 'myom_boyut', 'En büyük myom', 2, '', 'En büyük myom {değer} mm çapındadır.', '', 'mm'),
  ('PELVIK-ORADS', 10, 'Adneksiyal lezyon', 'lezyon', 'Lezyon', 1, 'Yok|Sağ adnekste|Sol adnekste|Bilateral adnekslerde',
   '{değer} lezyon izlenmiştir.', 'Bilateral adneksiyal alanlarda patolojik lezyon izlenmemiştir.', ''),
  ('PELVIK-ORADS', 11, 'Adneksiyal lezyon', 'lezyon_boyut', 'Lezyon boyutları (mm)', 5, '', 'Lezyon {değer} mm boyutlarındadır.', '', ''),
  ('PELVIK-ORADS', 12, 'Adneksiyal lezyon', 'lezyon_tip', 'Lezyon tipi', 1,
   'Basit unilokuler kist (düz duvarlı)|Hemorajik kist (klasik)|Dermoid kist (klasik)|Endometrioma (klasik)|'
   || 'Paraovaryan kist|Peritoneal inklüzyon kisti|Hidrosalpinks|Bilokuler kist|Multilokuler kist|'
   || 'Solid komponentli unilokuler kist|Solid komponentli multilokuler kist|Solid lezyon (düzgün konturlu)|Solid lezyon (düzensiz konturlu)',
   'Lezyon {değer} ile uyumludur.', '', ''),
  ('PELVIK-ORADS', 13, 'Adneksiyal lezyon', 'renk_skor', 'Renk skoru', 1, '1 (akım yok)|2 (minimal akım)|3 (orta akım)|4 (belirgin akım)',
   'Renkli doppler skoru {değer}.', '', ''),
  ('PELVIK-ORADS', 14, 'Adneksiyal lezyon', 'asit', 'Asit / peritoneal nodül', 1, 'Yok|Az miktarda serbest sıvı|Asit|Peritoneal nodül',
   'Pelviste {değer} izlenmiştir.', '', ''),
  ('PELVIK-ORADS', 15, 'Adneksiyal lezyon', 'orads', 'O-RADS US kategorisi', 1,
   '0 (yetersiz inceleme)|1 (normal over)|2 (neredeyse kesin benign)|3 (düşük risk)|4 (orta risk)|5 (yüksek risk)',
   'Lezyon O-RADS US {değer} kategorisindedir.', '', ''),
  ('PELVIK-ORADS', 16, 'Adneksiyal lezyon', 'oneri', 'Öneri', 1,
   'Takip gerekmez|Ultrasonografi ile takip önerilir|MRG ile değerlendirme önerilir|Jinekolojik onkoloji konsültasyonu önerilir',
   '{değer}.', '', ''),
-- ======================================================== BÖBREK (BOSNİAK)
  ('BOBREK-BOSNIAK', 1, 'Böbrekler', 'sag_bobrek', 'Sağ böbrek boyutları (mm)', 5, '', 'Sağ böbrek {değer} mm boyutlarındadır.', '', ''),
  ('BOBREK-BOSNIAK', 2, 'Böbrekler', 'sol_bobrek', 'Sol böbrek boyutları (mm)', 5, '', 'Sol böbrek {değer} mm boyutlarındadır.', '', ''),
  ('BOBREK-BOSNIAK', 3, 'Böbrekler', 'parankim', 'Parankim', 1, 'Normal|İnceleşmiş|Ekojenitesi artmış|İnceleşmiş ve ekojenitesi artmış',
   'Böbrek parankiminde {değer} görünüm izlenmiştir.', 'Bilateral böbrek parankim kalınlığı ve ekojenitesi normaldir.', ''),
  ('BOBREK-BOSNIAK', 4, 'Böbrekler', 'sag_hidro', 'Sağ hidronefroz', 1, 'Yok|Grade 1|Grade 2|Grade 3|Grade 4',
   'Sağ böbrekte {değer} hidronefroz izlenmiştir.', '', ''),
  ('BOBREK-BOSNIAK', 5, 'Böbrekler', 'sol_hidro', 'Sol hidronefroz', 1, 'Yok|Grade 1|Grade 2|Grade 3|Grade 4',
   'Sol böbrekte {değer} hidronefroz izlenmiştir.', '', ''),
  ('BOBREK-BOSNIAK', 6, 'Böbrekler', 'tas', 'Taş', 1, 'Yok|Sağ böbrekte|Sol böbrekte|Bilateral böbreklerde',
   '{değer} taş izlenmiştir.', '', ''),
  ('BOBREK-BOSNIAK', 7, 'Böbrekler', 'tas_boyut', 'En büyük taş', 2, '', 'En büyük taş {değer} mm ölçülmüştür.', '', 'mm'),
  ('BOBREK-BOSNIAK', 10, 'Kist (Bosniak)', 'kist', 'Kistik lezyon', 1, 'Yok|Sağ böbrekte|Sol böbrekte|Bilateral böbreklerde',
   '{değer} kistik lezyon izlenmiştir.', '', ''),
  ('BOBREK-BOSNIAK', 11, 'Kist (Bosniak)', 'kist_boyut', 'En büyük kist', 2, '', 'En büyük kist {değer} mm çapındadır.', '', 'mm'),
  ('BOBREK-BOSNIAK', 12, 'Kist (Bosniak)', 'duvar', 'Duvar', 1, 'İnce (≤ 2 mm) ve düzgün|Minimal kalın (3 mm)|Kalın (≥ 4 mm) ya da düzensiz',
   'Kist duvarı {değer}.', '', ''),
  ('BOBREK-BOSNIAK', 13, 'Kist (Bosniak)', 'septa', 'Septa', 1, 'Yok|1-3 ince septa|4 ve üzeri ince septa|Minimal kalın septa|Kalın ya da düzensiz septa',
   'Kistte {değer} izlenmiştir.', '', ''),
  ('BOBREK-BOSNIAK', 14, 'Kist (Bosniak)', 'kalsifikasyon', 'Kalsifikasyon', 1, 'Yok|İnce kalsifikasyon|Kaba / nodüler kalsifikasyon',
   'Kistte {değer} izlenmiştir.', '', ''),
  ('BOBREK-BOSNIAK', 15, 'Kist (Bosniak)', 'kontrast', 'Kontrastlanma', 1,
   'Yok|Duvar / septada ölçülebilir kontrastlanma|Kontrastlanan nodül',
   'Kontrastlı incelemede {değer} izlenmiştir.', '', ''),
  ('BOBREK-BOSNIAK', 16, 'Kist (Bosniak)', 'nodul', 'Nodül', 1, 'Yok|Geniş tabanlı (≥ 4 mm)|Dar açılı (herhangi boyutta)',
   'Kistte {değer} solid nodül izlenmiştir.', '', ''),
  ('BOBREK-BOSNIAK', 17, 'Kist (Bosniak)', 'bosniak', 'Bosniak kategorisi', 1, 'Bosniak I|Bosniak II|Bosniak IIF|Bosniak III|Bosniak IV',
   '{değer} kategorisinde kistik lezyon.', '', ''),
  ('BOBREK-BOSNIAK', 18, 'Kist (Bosniak)', 'oneri', 'Öneri', 1,
   'Takip gerekmez|Görüntüleme ile takip önerilir|Üroloji konsültasyonu önerilir',
   '{değer}.', '', '');

delete from public.radyoloji_alan_paket_alan a using public.radyoloji_alan_paket p, _p
 where a.paket_id = p.id and p.kod = _p.kod;
insert into public.radyoloji_alan_paket_alan (paket_id, sira, grup, alan_kod, alan_ad, tip, secenekler, birim,
                                              kalip, sifir_kalip, hedef_bolum, zorunlu, rapora_bas)
select p.id, a.sira, a.grup, a.kod, a.ad, a.tip, a.secenek, a.birim, a.kalip, a.sifir, 'Bulgular', 0, 0
  from _a a join public.radyoloji_alan_paket p on p.kod = a.paket;

commit;
