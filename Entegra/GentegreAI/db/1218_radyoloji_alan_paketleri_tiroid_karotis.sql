-- =============================================================================
--  1218  RADYOLOJİ HAZIR ALAN PAKETLERİ - TİROİD USG (ACR TI-RADS) + KAROTİS DOPPLER
--
--  Kullanıcı (01.11.2026): "evet, tiroid ve karotis paketlerini de yap" (1217'nin devamı - tablolar, uygulama
--  fonksiyonu ve metne yazılış kuralı orada).
--
--  TİROİD: lob boyutları, istmus, parankim, vaskülarite; DOMİNANT nodül için ACR TI-RADS bileşenleri
--    (kompozisyon / ekojenite / şekil / kenar / ekojen odak), kategori TR1-TR5 ve öneri. Kategori hekim
--    tarafından seçilir - bileşen puanları seçenek adında değil (metne puan yazılmasın), alan adında belirtilir.
--  KAROTİS: sağ / sol ayrı - IMT, plak, ICA PSV / EDV / ICA-CCA oranı, SRU (2003) uzlaşı kriterlerine göre darlık
--    derecesi; vertebral akım yönü. Ölçüm alanları sayı (cm/s, mm), hekim kriteri kendisi uygular.
--  Desen: tiroid "TIROID" (BT / MR / sintigrafi hariç), karotis "KAROTIS" (MRA / BT / anjiyo hariç). İdempotent.
-- =============================================================================

begin;

create temp table _p (kod varchar(40), ad varchar(120), modalite smallint, bolge smallint, desen varchar(300),
                      haric varchar(300), aciklama text) on commit drop;
insert into _p values
  ('TIROID-US', 'Tiroid USG (ACR TI-RADS)', 3, 1, 'TIROID', 'BT|MR|SINTIGRAF',
   'Lob boyutları, parankim; dominant nodül ACR TI-RADS bileşenleri, kategori ve öneri; servikal lenf nodu.'),
  ('KAROTIS-DOPPLER', 'Karotis doppler', 3, 7, 'KAROTIS', 'MRA|BT|ANJIO',
   'Sağ / sol: IMT, plak, ICA PSV / EDV / ICA-CCA oranı, SRU kriterlerine göre darlık; vertebral akım yönü.');

insert into public.radyoloji_alan_paket (kod, ad, modalite, bolge, desen, haric_desen, aciklama)
select kod, ad, modalite, bolge, desen, haric, aciklama from _p
on conflict (kod) do update set ad = excluded.ad, modalite = excluded.modalite, bolge = excluded.bolge,
       desen = excluded.desen, haric_desen = excluded.haric_desen, aciklama = excluded.aciklama;

create temp table _a (paket varchar(40), sira smallint, grup varchar(40), kod varchar(40), ad varchar(80), tip smallint,
                      secenek varchar(400), kalip varchar(300), sifir varchar(300), birim varchar(20)) on commit drop;
insert into _a values
-- ======================================================== TİROİD USG
  ('TIROID-US', 1, 'Bez', 'sag_lob', 'Sağ lob boyutları (mm)', 5, '', 'Sağ lob {değer} mm boyutlarındadır.', '', ''),
  ('TIROID-US', 2, 'Bez', 'sol_lob', 'Sol lob boyutları (mm)', 5, '', 'Sol lob {değer} mm boyutlarındadır.', '', ''),
  ('TIROID-US', 3, 'Bez', 'istmus', 'İstmus kalınlığı', 2, '', 'İstmus kalınlığı {değer} mm ölçülmüştür.', '', 'mm'),
  ('TIROID-US', 4, 'Bez', 'parankim', 'Parankim', 1, 'Homojen|Heterojen|Kaba heterojen (tiroidit ile uyumlu)',
   'Tiroid parankimi {değer} ekodadır.', '', ''),
  ('TIROID-US', 5, 'Bez', 'vaskularite', 'Vaskülarite', 1, 'Normal|Artmış|Azalmış',
   'Renkli doppler incelemede parankim vaskülaritesi {değer}.', 'Parankim vaskülaritesi normaldir.', ''),
  ('TIROID-US', 10, 'Dominant nodül', 'nodul', 'Nodül', 1, 'Yok|Tek|Multiple',
   '{değer} nodül izlenmiştir.', 'Tiroid bezinde nodül izlenmemiştir.', ''),
  ('TIROID-US', 11, 'Dominant nodül', 'nodul_yer', 'Yerleşim', 1,
   'Sağ lob üst|Sağ lob orta|Sağ lob alt|İstmus|Sol lob üst|Sol lob orta|Sol lob alt',
   'En belirgin nodül {değer} kesimde yerleşimlidir.', '', ''),
  ('TIROID-US', 12, 'Dominant nodül', 'nodul_boyut', 'Boyutlar (mm)', 5, '', 'Nodül {değer} mm boyutlarındadır.', '', ''),
  ('TIROID-US', 13, 'Dominant nodül', 'kompozisyon', 'Kompozisyon (0-2 puan)', 1,
   'Kistik / neredeyse tamamen kistik|Süngerimsi|Mikst kistik-solid|Solid / neredeyse tamamen solid',
   'Kompozisyonu {değer} yapıdadır.', '', ''),
  ('TIROID-US', 14, 'Dominant nodül', 'ekojenite', 'Ekojenite (0-3 puan)', 1, 'Anekoik|Hiperekoik / izoekoik|Hipoekoik|Belirgin hipoekoik',
   'Nodül {değer} görünümdedir.', '', ''),
  ('TIROID-US', 15, 'Dominant nodül', 'sekil', 'Şekil (0 / 3 puan)', 1, 'Genişliği yüksekliğinden fazla|Yüksekliği genişliğinden fazla (taller-than-wide)',
   'Nodülün {değer}.', '', ''),
  ('TIROID-US', 16, 'Dominant nodül', 'kenar', 'Kenar (0-3 puan)', 1, 'Düzgün|Belirsiz|Lobüle / düzensiz|Tiroid dışı uzanım gösteriyor',
   'Nodül kenarı {değer}.', '', ''),
  ('TIROID-US', 17, 'Dominant nodül', 'ekojen_odak', 'Ekojen odak (0-3 puan)', 1,
   'Yok|Büyük kuyruklu yıldız artefaktı|Makrokalsifikasyon|Periferik (rim) kalsifikasyon|Punktat ekojen odak',
   'Nodülde {değer} izlenmiştir.', '', ''),
  ('TIROID-US', 18, 'Dominant nodül', 'tirads', 'ACR TI-RADS kategorisi', 1,
   'TR1 (benign)|TR2 (şüpheli değil)|TR3 (hafif şüpheli)|TR4 (orta derecede şüpheli)|TR5 (yüksek derecede şüpheli)',
   'Nodül ACR TI-RADS {değer} kategorisindedir.', '', ''),
  ('TIROID-US', 19, 'Dominant nodül', 'oneri', 'Öneri', 1, 'İİAB gerekmez|Ultrasonografi ile takip önerilir|İİAB önerilir',
   '{değer}.', '', ''),
  ('TIROID-US', 30, 'Boyun', 'lenf', 'Servikal lenf nodu', 1, 'Normal|Reaktif görünümlü|Patolojik görünümlü',
   'Boyun düzeylerinde {değer} lenf nodu izlenmiştir.', 'Boyunda patolojik görünümlü lenf nodu izlenmemiştir.', ''),
-- ======================================================== KAROTİS DOPPLER
  ('KAROTIS-DOPPLER', 1, 'Sağ karotis', 'sag_imt', 'Sağ CCA intima-media kalınlığı', 2, '',
   'Sağ ana karotis arterde intima-media kalınlığı {değer} mm ölçülmüştür.', '', 'mm'),
  ('KAROTIS-DOPPLER', 2, 'Sağ karotis', 'sag_plak', 'Sağ plak', 1, 'Yok|Kalsifik|Hipoekoik (yumuşak)|Mikst|Ülsere yüzeyli',
   'Sağ karotis bulbus / ICA proksimalinde {değer} plak izlenmiştir.', '', ''),
  ('KAROTIS-DOPPLER', 3, 'Sağ karotis', 'sag_psv', 'Sağ ICA PSV', 2, '', 'Sağ ICA''da pik sistolik hız {değer} cm/s ölçülmüştür.', '', 'cm/s'),
  ('KAROTIS-DOPPLER', 4, 'Sağ karotis', 'sag_edv', 'Sağ ICA EDV', 2, '', 'Sağ ICA''da diyastol sonu hız {değer} cm/s ölçülmüştür.', '', 'cm/s'),
  ('KAROTIS-DOPPLER', 5, 'Sağ karotis', 'sag_oran', 'Sağ ICA/CCA PSV oranı', 2, '', 'Sağda ICA/CCA PSV oranı {değer}.', '', ''),
  ('KAROTIS-DOPPLER', 6, 'Sağ karotis', 'sag_darlik', 'Sağ ICA darlık (SRU)', 1,
   'Yok|%50''nin altında darlık|%50-69 darlık|%70 ve üzeri darlık|Tama yakın tıkanıklık|Tam tıkanıklık',
   'Sağ ICA''da SRU kriterlerine göre {değer} ile uyumlu bulgular izlenmiştir.',
   'Sağ ICA''da hemodinamik açıdan anlamlı darlık saptanmamıştır.', ''),
  ('KAROTIS-DOPPLER', 11, 'Sol karotis', 'sol_imt', 'Sol CCA intima-media kalınlığı', 2, '',
   'Sol ana karotis arterde intima-media kalınlığı {değer} mm ölçülmüştür.', '', 'mm'),
  ('KAROTIS-DOPPLER', 12, 'Sol karotis', 'sol_plak', 'Sol plak', 1, 'Yok|Kalsifik|Hipoekoik (yumuşak)|Mikst|Ülsere yüzeyli',
   'Sol karotis bulbus / ICA proksimalinde {değer} plak izlenmiştir.', '', ''),
  ('KAROTIS-DOPPLER', 13, 'Sol karotis', 'sol_psv', 'Sol ICA PSV', 2, '', 'Sol ICA''da pik sistolik hız {değer} cm/s ölçülmüştür.', '', 'cm/s'),
  ('KAROTIS-DOPPLER', 14, 'Sol karotis', 'sol_edv', 'Sol ICA EDV', 2, '', 'Sol ICA''da diyastol sonu hız {değer} cm/s ölçülmüştür.', '', 'cm/s'),
  ('KAROTIS-DOPPLER', 15, 'Sol karotis', 'sol_oran', 'Sol ICA/CCA PSV oranı', 2, '', 'Solda ICA/CCA PSV oranı {değer}.', '', ''),
  ('KAROTIS-DOPPLER', 16, 'Sol karotis', 'sol_darlik', 'Sol ICA darlık (SRU)', 1,
   'Yok|%50''nin altında darlık|%50-69 darlık|%70 ve üzeri darlık|Tama yakın tıkanıklık|Tam tıkanıklık',
   'Sol ICA''da SRU kriterlerine göre {değer} ile uyumlu bulgular izlenmiştir.',
   'Sol ICA''da hemodinamik açıdan anlamlı darlık saptanmamıştır.', ''),
  ('KAROTIS-DOPPLER', 21, 'Vertebral', 'sag_vertebral', 'Sağ vertebral arter', 1, 'Antegrad akım|Retrograd akım (subklavyen çalma)|Oklüzyon (akım yok)',
   'Sağ vertebral arterde {değer} izlenmiştir.', '', ''),
  ('KAROTIS-DOPPLER', 22, 'Vertebral', 'sol_vertebral', 'Sol vertebral arter', 1, 'Antegrad akım|Retrograd akım (subklavyen çalma)|Oklüzyon (akım yok)',
   'Sol vertebral arterde {değer} izlenmiştir.', '', '');

delete from public.radyoloji_alan_paket_alan a using public.radyoloji_alan_paket p, _p
 where a.paket_id = p.id and p.kod = _p.kod;
insert into public.radyoloji_alan_paket_alan (paket_id, sira, grup, alan_kod, alan_ad, tip, secenekler, birim,
                                              kalip, sifir_kalip, hedef_bolum, zorunlu, rapora_bas)
select p.id, a.sira, a.grup, a.kod, a.ad, a.tip, a.secenek, a.birim, a.kalip, a.sifir, 'Bulgular', 0, 0
  from _a a join public.radyoloji_alan_paket p on p.kod = a.paket;

commit;
