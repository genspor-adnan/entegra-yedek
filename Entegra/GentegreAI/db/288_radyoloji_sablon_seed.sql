-- 288: HAZIR RAPOR ŞABLONLARI (kullanıcı: "şablonları da oluştur").
--
-- Beş modalitenin en sık kullanılan şablonu, bölümleri ve makrolarıyla.
-- Kurulum bunlarla açılır; hastane kendi dilini oturttukça düzenler ya da
-- kopyalayıp kendi sürümünü yapar.
--
-- Bölüm iskeleti radyoloji raporunun standardıdır: Klinik Bilgi → Teknik →
-- Karşılaştırma → Bulgular → Sonuç (→ Öneri). "Zorunlu" işaretli bölüm boşken
-- rapor onaylanamaz (284); "Yazdır" kapalı bölüm hasta çıktısına basılmaz.
--
-- İdempotent: kod alanı benzersiz, var olan şablona dokunulmaz.

do $$
declare
  v_sablon integer;
begin
  -- ================================================== 1) BEYİN BT (normal) ==
  if not exists (select 1 from public.radyoloji_sablon where kod = 'RS-BT-001') then
    insert into public.radyoloji_sablon (kod, ad, modalite, bolum, varsayilan, surum, durum, aciklama)
    values ('RS-BT-001', 'Beyin BT — Normal', 1, 'Nöroradyoloji', 0, 1, 1,
            'Kontrastsız beyin BT standart raporu.')
    returning id into v_sablon;

    insert into public.radyoloji_sablon_bolum (sablon_id, sira, baslik, varsayilan_metin, zorunlu, yazdir)
    values (v_sablon, 1, 'Klinik Bilgi', '', 1, 1),
           (v_sablon, 2, 'Teknik',
            'Kontrast madde verilmeksizin aksiyel planda beyin BT incelemesi yapıldı.', 0, 1),
           (v_sablon, 3, 'Karşılaştırma', '', 0, 1),
           (v_sablon, 4, 'Bulgular',
            'Serebral hemisferler normal görünümde. Akut kanama, iskemi ya da kitle lezyonu '
            'izlenmedi. Ventriküler sistem normal genişlikte, orta hat yapıları yerindedir. '
            'Sisternalar açıktır. Kemik yapılarda fraktür saptanmadı.', 1, 1),
           (v_sablon, 5, 'Sonuç', 'Beyin BT incelemesi normal sınırlardadır.', 1, 1),
           (v_sablon, 6, 'Öneri', '', 0, 1);

    insert into public.radyoloji_sablon_makro (sablon_id, kisayol, ad, metin, hedef_bolum)
    values (v_sablon, '.nrm', 'Normal beyin',
            'Serebral hemisferler normal görünümde, patolojik dansite değişikliği izlenmedi.', 'Bulgular'),
           (v_sablon, '.kri', 'Kronik iskemik',
            'Derin ak maddede kronik iskemik gliotik değişikliklerle uyumlu hipodens alanlar mevcuttur.', 'Bulgular'),
           (v_sablon, '.sin', 'Sinüzit',
            'Maksiller sinüslerde mukozal kalınlaşma izlenmektedir.', 'Bulgular'),
           (v_sablon, '.atr', 'Atrofi',
            'Yaşa göre belirgin kortikal atrofi ve buna sekonder ventriküler genişleme izlenmektedir.', 'Bulgular'),
           (v_sablon, '.kon', 'Kontrol önerisi',
            'Klinik korelasyon ve gerekirse kontrastlı MR ile ileri inceleme önerilir.', 'Öneri');
  end if;

  -- ================================================= 2) TORAKS BT (rutin) ==
  if not exists (select 1 from public.radyoloji_sablon where kod = 'RS-BT-002') then
    insert into public.radyoloji_sablon (kod, ad, modalite, bolum, varsayilan, surum, durum, aciklama)
    values ('RS-BT-002', 'Toraks BT — Rutin', 1, 'Toraks', 0, 1, 1,
            'Kontrastsız toraks BT; nodül tarifi makrolarla.')
    returning id into v_sablon;

    insert into public.radyoloji_sablon_bolum (sablon_id, sira, baslik, varsayilan_metin, zorunlu, yazdir)
    values (v_sablon, 1, 'Klinik Bilgi', '', 1, 1),
           (v_sablon, 2, 'Teknik',
            'Kontrast madde verilmeksizin toraks BT incelemesi yapıldı; ince kesit '
            'rekonstrüksiyonlar değerlendirildi.', 0, 1),
           (v_sablon, 3, 'Karşılaştırma', '', 0, 1),
           (v_sablon, 4, 'Bulgular',
            'Her iki akciğer parankiminde konsolidasyon, buzlu cam dansitesi ya da nodüler '
            'lezyon izlenmedi. Mediastende patolojik boyutta lenf nodu saptanmadı. '
            'Plevral efüzyon ve pnömotoraks yoktur. Kalp boyutları normaldir.', 1, 1),
           (v_sablon, 5, 'Sonuç', 'Toraks BT incelemesi normal sınırlardadır.', 1, 1),
           (v_sablon, 6, 'Öneri', '', 0, 1),
           -- Doz kaydı hastaya basılmaz, iç takip içindir.
           (v_sablon, 7, 'Doz Notu', '', 0, 0);

    insert into public.radyoloji_sablon_makro (sablon_id, kisayol, ad, metin, hedef_bolum)
    values (v_sablon, '.nod', 'Pulmoner nodül',
            'Sağ/sol akciğer üst/alt lobda … mm çapında düzgün konturlu solid nodül izlenmektedir.', 'Bulgular'),
           (v_sablon, '.amf', 'Amfizem',
            'Her iki akciğerde sentrilobüler amfizematöz değişiklikler mevcuttur.', 'Bulgular'),
           (v_sablon, '.efz', 'Plevral efüzyon',
            'Sağ/sol hemitoraksta … mm kalınlığında plevral efüzyon izlenmektedir.', 'Bulgular'),
           (v_sablon, '.fls', 'Fleischner takip',
            'Nodül boyutu ve hasta risk grubuna göre Fleischner kriterlerine uygun aralıkla '
            'BT kontrolü önerilir.', 'Öneri');
  end if;

  -- ============================================= 3) LOMBER MR (dejeneratif) ==
  if not exists (select 1 from public.radyoloji_sablon where kod = 'RS-MR-004') then
    insert into public.radyoloji_sablon (kod, ad, modalite, bolum, varsayilan, surum, durum, aciklama)
    values ('RS-MR-004', 'Lomber MR — Dejeneratif', 2, 'Kas-İskelet', 0, 1, 1,
            'Kontrastsız lomber vertebra MR; Pfirrmann derecelemesi ile.')
    returning id into v_sablon;

    insert into public.radyoloji_sablon_bolum (sablon_id, sira, baslik, varsayilan_metin, zorunlu, yazdir)
    values (v_sablon, 1, 'Klinik Bilgi', '', 1, 1),
           (v_sablon, 2, 'Teknik',
            '1.5T MR cihazında sagital T1, sagital T2, aksiyel T2 ve koronal STIR sekansları '
            'ile kontrast madde verilmeksizin lomber vertebra incelemesi yapıldı.', 0, 1),
           (v_sablon, 3, 'Karşılaştırma', '', 0, 1),
           (v_sablon, 4, 'Bulgular',
            'Lomber lordoz doğaldır. Vertebra korpus yükseklikleri ve sinyal özellikleri '
            'normaldir. Disk mesafelerinde belirgin dejeneratif değişiklik izlenmedi. '
            'Konus medullaris L1 düzeyinde sonlanmakta olup sinyal özellikleri normaldir.', 1, 1),
           (v_sablon, 5, 'Sonuç', '', 1, 1),
           (v_sablon, 6, 'Öneri', '', 0, 1);

    insert into public.radyoloji_sablon_makro (sablon_id, kisayol, ad, metin, hedef_bolum)
    values (v_sablon, '.dej', 'Dejeneratif disk',
            'L4-L5 ve L5-S1 düzeylerinde disk dejenerasyonu ve posterior anüler bulging '
            'izlenmektedir.', 'Bulgular'),
           (v_sablon, '.kok', 'Kök basısı',
            '… düzeyinde sağ/sol paramedian protrüzyon mevcut olup ilgili sinir kökünde '
            'basıya yol açmaktadır.', 'Bulgular'),
           (v_sablon, '.mod', 'Modic değişiklik',
            'End plaklarda Modic tip … değişiklikler izlenmektedir.', 'Bulgular'),
           (v_sablon, '.spo', 'Spondilolistezis',
            '… düzeyinde grade … anterolistezis mevcuttur.', 'Bulgular'),
           (v_sablon, '.kon', 'Klinik korelasyon',
            'Klinik ve nörolojik muayene ile korelasyonu önerilir.', 'Öneri');

    insert into public.radyoloji_sablon_alan (sablon_id, sira, alan_kod, alan_ad, tip, secenekler, zorunlu, rapora_bas)
    values (v_sablon, 1, 'pfirrmann', 'Pfirrmann Derecesi', 1, 'I|II|III|IV|V', 0, 1),
           (v_sablon, 2, 'kok_basisi', 'Kök Basısı', 1,
            'Yok|Sağ L4|Sağ L5|Sağ S1|Sol L4|Sol L5|Sol S1|Bilateral', 0, 1);
  end if;

  -- =============================================== 4) TİROİD USG (TI-RADS) ==
  if not exists (select 1 from public.radyoloji_sablon where kod = 'RS-USG-002') then
    insert into public.radyoloji_sablon (kod, ad, modalite, bolum, varsayilan, surum, durum, aciklama)
    values ('RS-USG-002', 'Tiroid USG — TI-RADS', 3, 'Baş-Boyun', 0, 1, 1,
            'ACR TI-RADS kategorisi ile tiroid ultrasonografi raporu.')
    returning id into v_sablon;

    insert into public.radyoloji_sablon_bolum (sablon_id, sira, baslik, varsayilan_metin, zorunlu, yazdir)
    values (v_sablon, 1, 'Klinik Bilgi', '', 1, 1),
           (v_sablon, 2, 'Teknik',
            'Yüksek frekanslı lineer prob ile tiroid bezi ve boyun ultrasonografisi yapıldı.', 0, 1),
           (v_sablon, 3, 'Bulgular',
            'Tiroid bezi normal boyut ve ekojenitededir. Parankim homojen olup nodüler lezyon '
            'izlenmemiştir. Boyunda patolojik boyut ve morfolojide lenf nodu saptanmadı.', 1, 1),
           (v_sablon, 4, 'Sonuç', 'Tiroid ultrasonografisi normal sınırlardadır.', 1, 1),
           (v_sablon, 5, 'Öneri', '', 0, 1);

    insert into public.radyoloji_sablon_makro (sablon_id, kisayol, ad, metin, hedef_bolum)
    values (v_sablon, '.nod', 'Nodül tarifi',
            'Sağ/sol lobda … x … mm boyutunda, solid/kistik, düzgün konturlu, izoekoik nodül '
            'izlenmektedir. Mikrokalsifikasyon ve şüpheli vaskülarite yoktur.', 'Bulgular'),
           (v_sablon, '.tir', 'Tiroidit',
            'Parankim heterojen ve hipoekoik olup kronik tiroidit ile uyumludur.', 'Bulgular'),
           (v_sablon, '.bio', 'Biyopsi önerisi',
            'TI-RADS kategorisi ve nodül boyutu birlikte değerlendirildiğinde ince iğne '
            'aspirasyon biyopsisi önerilir.', 'Öneri');

    insert into public.radyoloji_sablon_alan (sablon_id, sira, alan_kod, alan_ad, tip, secenekler, zorunlu, rapora_bas)
    values (v_sablon, 1, 'tirads', 'ACR TI-RADS', 1, 'TR1|TR2|TR3|TR4|TR5', 0, 1);
  end if;

  -- ============================================== 5) AKCİĞER GRAFİSİ (PA) ==
  if not exists (select 1 from public.radyoloji_sablon where kod = 'RS-DR-003') then
    insert into public.radyoloji_sablon (kod, ad, modalite, bolum, varsayilan, surum, durum, aciklama)
    values ('RS-DR-003', 'Akciğer Grafisi — Normal', 4, 'Toraks', 0, 1, 1,
            'PA akciğer grafisi standart raporu.')
    returning id into v_sablon;

    insert into public.radyoloji_sablon_bolum (sablon_id, sira, baslik, varsayilan_metin, zorunlu, yazdir)
    values (v_sablon, 1, 'Klinik Bilgi', '', 1, 1),
           (v_sablon, 2, 'Teknik', 'PA akciğer grafisi ayakta çekildi.', 0, 1),
           (v_sablon, 3, 'Bulgular',
            'Her iki akciğer alanları havalanması normaldir. Aktif infiltrasyon ve konsolidasyon '
            'izlenmedi. Kostofrenik sinüsler açıktır. Kalp gölgesi ve mediasten normal '
            'genişliktedir. Kemik yapılar doğaldır.', 1, 1),
           (v_sablon, 4, 'Sonuç', 'Akciğer grafisi normal sınırlardadır.', 1, 1);

    insert into public.radyoloji_sablon_makro (sablon_id, kisayol, ad, metin, hedef_bolum)
    values (v_sablon, '.inf', 'İnfiltrasyon',
            'Sağ/sol akciğer alt/orta zonda infiltratif dansite artışı izlenmektedir.', 'Bulgular'),
           (v_sablon, '.kmg', 'Kardiyomegali',
            'Kalp gölgesi boyutları artmış olup kardiyotorasik indeks sınırdadır.', 'Bulgular'),
           (v_sablon, '.pnx', 'Pnömotoraks',
            'Sağ/sol hemitoraksta apikal yerleşimli pnömotoraks hattı izlenmektedir.', 'Bulgular');
  end if;

  -- =========================================== 6) MAMOGRAFİ (BI-RADS) ======
  if not exists (select 1 from public.radyoloji_sablon where kod = 'RS-MG-001') then
    insert into public.radyoloji_sablon (kod, ad, modalite, bolum, varsayilan, surum, durum, aciklama)
    values ('RS-MG-001', 'Mamografi — BI-RADS', 5, 'Meme', 0, 1, 1,
            'Bilateral mamografi; ACR meme kompozisyonu ve BI-RADS kategorisi.')
    returning id into v_sablon;

    insert into public.radyoloji_sablon_bolum (sablon_id, sira, baslik, varsayilan_metin, zorunlu, yazdir)
    values (v_sablon, 1, 'Klinik Bilgi', '', 1, 1),
           (v_sablon, 2, 'Teknik',
            'Bilateral kraniokaudal ve mediolateral oblik projeksiyonlarda dijital mamografi '
            'incelemesi yapıldı.', 0, 1),
           (v_sablon, 3, 'Karşılaştırma', '', 0, 1),
           (v_sablon, 4, 'Bulgular',
            'Her iki memede kitle, yapısal distorsiyon ya da şüpheli mikrokalsifikasyon '
            'izlenmedi. Cilt ve meme başı doğaldır. Aksiller bölgede patolojik lenf nodu '
            'saptanmadı.', 1, 1),
           (v_sablon, 5, 'Sonuç', '', 1, 1),
           (v_sablon, 6, 'Öneri', '', 0, 1);

    insert into public.radyoloji_sablon_makro (sablon_id, kisayol, ad, metin, hedef_bolum)
    values (v_sablon, '.kit', 'Kitle tarifi',
            'Sağ/sol memede saat … kadranda, … mm boyutunda, düzgün konturlu opasite '
            'izlenmektedir.', 'Bulgular'),
           (v_sablon, '.mkl', 'Mikrokalsifikasyon',
            'Sağ/sol memede kümelenmiş pleomorfik mikrokalsifikasyonlar mevcuttur.', 'Bulgular'),
           (v_sablon, '.usg', 'USG tamamlayıcı',
            'Yoğun meme paterni nedeniyle tamamlayıcı meme ultrasonografisi önerilir.', 'Öneri'),
           (v_sablon, '.tkp', 'Rutin takip',
            'Yaşa uygun aralıkla rutin mamografi takibi önerilir.', 'Öneri');

    insert into public.radyoloji_sablon_alan (sablon_id, sira, alan_kod, alan_ad, tip, secenekler, zorunlu, rapora_bas)
    values (v_sablon, 1, 'birads', 'BI-RADS Kategorisi', 1, '0|1|2|3|4A|4B|4C|5|6', 1, 1),
           (v_sablon, 2, 'meme_komp', 'Meme Kompozisyonu (ACR)', 1, 'A|B|C|D', 0, 1);
  end if;
end $$;

-- Tetkiki olan şablonu o tetkikin VARSAYILANI yap (birden çok varsa ilki).
update public.radyoloji_sablon s
   set varsayilan = 1
 where s.hizmet_id is not null
   and s.durum = 1
   and not exists (select 1 from public.radyoloji_sablon x
                    where x.hizmet_id = s.hizmet_id and x.varsayilan = 1);
