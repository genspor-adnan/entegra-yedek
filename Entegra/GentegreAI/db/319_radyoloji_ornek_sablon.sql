-- 319: Üç örnek rapor şablonu (BT / MR / USG).
--
-- Rapor şablonu listesi kurulumda BOŞ geliyor; radyolog ilk raporu yazarken
-- boş sayfayla karşılaşıyor. Bunlar başlangıç örnekleri: bölüm iskeleti
-- (Klinik Bilgi / Teknik / Bulgular / Sonuç) ve normal metin varsayılanlarıyla
-- gelir - kurum kendi metnini üzerine yazar, silebilir de.
--
-- Idempotent: kod bazında var olan şablona dokunulmaz.

insert into public.radyoloji_sablon
       (kod, ad, modalite, bolum, varsayilan, surum, durum, aciklama, sube_id, ekleyen)
select v.kod, v.ad, v.modalite, v.bolum, 0, 1, 1, v.aciklama,
       (select min(id) from public.sube), 0
  from (values
    ('SBL-BT-TORAKS', 'Toraks BT — Standart', 1::smallint, 'Radyoloji',
     'Kontrastlı/kontrastsız toraks BT için başlangıç şablonu'),
    ('SBL-MR-LOMBER', 'Lomber MR — Standart', 2::smallint, 'Radyoloji',
     'Dejeneratif disk hastalığı odaklı lomber MR şablonu'),
    ('SBL-USG-BATIN', 'Batın USG — Standart', 3::smallint, 'Radyoloji',
     'Tüm batın ultrasonografi şablonu')
  ) v(kod, ad, modalite, bolum, aciklama)
 where not exists (select 1 from public.radyoloji_sablon s where s.kod = v.kod);

-- Bölümler: rapor ekranı bunları sırayla başlık + metin kutusu olarak açar.
insert into public.radyoloji_sablon_bolum (sablon_id, sira, baslik, varsayilan_metin, zorunlu, yazdir)
select s.id, v.sira, v.baslik, v.metin, v.zorunlu, 1
  from (values
    -- ---------------------------------------------------------- Toraks BT --
    ('SBL-BT-TORAKS', 1, 'Klinik Bilgi', '', 0::smallint),
    ('SBL-BT-TORAKS', 2, 'Teknik',
     'Toraks bölgesinden kontrast madde verilmeksizin aksiyel planda '
     || 'kesitler alındı; koronal ve sagital reformatlar oluşturuldu.', 0),
    ('SBL-BT-TORAKS', 3, 'Bulgular',
     'Trakea ve ana bronşlar açıktır. Her iki akciğer parankiminde '
     || 'konsolidasyon, buzlu cam dansitesi ya da nodüler lezyon '
     || 'izlenmemiştir. Plevral efüzyon yoktur. Mediastende patolojik boyutta '
     || 'lenf nodu saptanmamıştır. Kalp boyutları normaldir. Kemik yapılarda '
     || 'litik/blastik lezyon izlenmemiştir.', 1),
    ('SBL-BT-TORAKS', 4, 'Sonuç', 'Normal toraks BT bulguları.', 1),
    -- ---------------------------------------------------------- Lomber MR --
    ('SBL-MR-LOMBER', 1, 'Klinik Bilgi', '', 0),
    ('SBL-MR-LOMBER', 2, 'Teknik',
     'Lomber bölgeden sagital T1, T2 ve aksiyel T2 ağırlıklı sekanslar '
     || 'alınmıştır. Kontrast madde verilmemiştir.', 0),
    ('SBL-MR-LOMBER', 3, 'Bulgular',
     'Vertebra korpus yükseklikleri ve sinyal özellikleri doğaldır. '
     || 'Konus medullaris L1 düzeyindedir. Disk mesafelerinde belirgin '
     || 'yükseklik kaybı, herniasyon ya da spinal kanal darlığı '
     || 'izlenmemiştir. Faset eklemler doğaldır.', 1),
    ('SBL-MR-LOMBER', 4, 'Sonuç', 'Normal lomber MR bulguları.', 1),
    -- ---------------------------------------------------------- Batın USG --
    ('SBL-USG-BATIN', 1, 'Klinik Bilgi', '', 0),
    ('SBL-USG-BATIN', 2, 'Teknik',
     'Konveks prob ile tüm batın ultrasonografisi yapıldı. Hasta açlık '
     || 'durumundadır.', 0),
    ('SBL-USG-BATIN', 3, 'Bulgular',
     'Karaciğer boyut ve parankim ekojenitesi normaldir; fokal lezyon '
     || 'izlenmemiştir. Safra kesesi normal duvar kalınlığındadır, taş '
     || 'izlenmemiştir. Pankreas görülebilen kesimleri doğaldır. Dalak '
     || 'normal boyuttadır. Her iki böbrek normal boyut ve parankim '
     || 'kalınlığındadır; taş ya da hidronefroz saptanmamıştır. Batın içi '
     || 'serbest sıvı izlenmemiştir.', 1),
    ('SBL-USG-BATIN', 4, 'Sonuç', 'Normal batın USG bulguları.', 1)
  ) v(kod, sira, baslik, metin, zorunlu)
  join public.radyoloji_sablon s on s.kod = v.kod
 where not exists (select 1 from public.radyoloji_sablon_bolum b
                    where b.sablon_id = s.id and b.sira = v.sira);

-- Ölçüm/skor alanları: rapor ekranında bölümlerin yanında ayrı kutu olarak
-- çıkar, metne de basılır (rapora_bas = 1).
insert into public.radyoloji_sablon_alan
       (sablon_id, sira, alan_kod, alan_ad, tip, secenekler, zorunlu, rapora_bas)
select s.id, v.sira, v.alan_kod, v.alan_ad, v.tip, v.secenekler, 0, 1
  from (values
    -- tip: 1 = liste (secenekler | ile ayrilir), 2 = serbest sayi/metin.
    ('SBL-BT-TORAKS', 1, 'dlp',        'DLP (mGy·cm)',      2::smallint, ''),
    ('SBL-MR-LOMBER', 1, 'pfirrmann',  'Pfirrmann Derecesi',1, 'I|II|III|IV|V'),
    ('SBL-USG-BATIN', 1, 'kc_boyut',   'Karaciğer (mm)',    2, ''),
    ('SBL-USG-BATIN', 2, 'dalak_boyut','Dalak (mm)',        2, '')
  ) v(kod, sira, alan_kod, alan_ad, tip, secenekler)
  join public.radyoloji_sablon s on s.kod = v.kod
 where not exists (select 1 from public.radyoloji_sablon_alan a
                    where a.sablon_id = s.id and a.alan_kod = v.alan_kod);

-- ------------------------------------------------- ŞUBESİZ ŞABLON ONARIMI --
-- Kurulumla gelen örnek şablonlar sube_id = 0 ile yazılmış: liste şube
-- süzmesiyle çalıştığı için ekran BOŞ görünüyordu (aynı hata cihazlarda da
-- vardı, 315'te düzeltilmişti). Şubesiz kayıtlar ilk şubeye taşınır.
update public.radyoloji_sablon
   set sube_id = (select min(id) from public.sube)
 where coalesce(sube_id, 0) = 0
   and exists (select 1 from public.sube);
