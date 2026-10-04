-- ============================================================================
--  Gentegre AI — RADYOLOJİ ÖRNEK RAPOR ŞABLONLARI + ÇEKİM PROTOKOLLERİ
--  966_radyoloji_ornek_sablon_protokol.sql
--
--  Kullanıcı: "bölgeler için örnek şablonlar ve çekim protokolleri ekle".
--  Her bölge (rad.bolge) için başlangıç içeriği: kurum kendi hekimleriyle
--  düzenler; sürüm 1 olarak gelir.
--
--  KURALLAR:
--   * İdempotent: şablon KOD'una, protokol TETKİK'ine göre yalnız EKSİK olan
--     eklenir; var olana (kurumun düzenlediğine) DOKUNULMAZ.
--   * Tetkik hizmet ADINDAN bulunur; kurumda o tetkik yoksa şablon modalite
--     şablonu olarak (tetkiksiz) eklenir, protokol hiç eklenmez.
--   * Malzeme / cihaz eklenmez - stok kalemi ve cihaz kuruma özeldir.
--   * Bakanlık rapor parçası: 1 Teknik · 2 Karşılaştırma · 3 Bulgular · 4 Sonuç
--     ve Öneriler (0 = gönderilmez). Alan tipi: 1 seçim · 2 sayı · 3 skor ·
--     4 evet / hayır · 5 metin.
-- ============================================================================

create or replace function pg_temp.rad_hizmet(p_ad text) returns integer language sql as
$$ select id from public.hizmet where ad = p_ad order by id limit 1 $$;

-- ŞABLON: kod yoksa ekler; ana tetkik + ek tetkikler, bölümler, alanlar, makrolar.
create or replace function pg_temp.rad_sablon(
    p_kod text, p_ad text, p_modalite smallint, p_bolge smallint, p_baslik text,
    p_ana text, p_ekler text[], p_bolumler jsonb, p_alanlar jsonb, p_makrolar jsonb, p_varsayilan smallint default 1)
returns void language plpgsql as $f$
declare v_id integer; v_ek text; v_hz integer;
begin
    if exists (select 1 from public.radyoloji_sablon where kod = p_kod) then return; end if;
    insert into public.radyoloji_sablon (kod, ad, modalite, bolge, hizmet_id, varsayilan, surum, durum, kullanim,
                                         aciklama, rapor_basligi, sube_id, ekleyen)
    values (p_kod, p_ad, p_modalite, p_bolge, pg_temp.rad_hizmet(p_ana), p_varsayilan, 1, 1, 0,
            'Örnek şablon (966) - kurum hekimleriyle gözden geçirin.', p_baslik,
            (select min(id) from public.sube), 0)
    returning id into v_id;
    foreach v_ek in array coalesce(p_ekler, '{}') loop
        v_hz := pg_temp.rad_hizmet(v_ek);
        if v_hz is not null then
            insert into public.radyoloji_sablon_hizmet (sablon_id, hizmet_id, ekleyen) values (v_id, v_hz, 0) on conflict do nothing;
        end if;
    end loop;
    insert into public.radyoloji_sablon_bolum (sablon_id, sira, baslik, varsayilan_metin, zorunlu, yazdir, bakanlik_parca, ekleyen)
    select v_id, x.sira, x.baslik, x.metin, coalesce(x.zorunlu, 0), 1, coalesce(x.parca, 0), 0
      from jsonb_to_recordset(p_bolumler) as x(sira smallint, baslik varchar, metin text, zorunlu smallint, parca smallint);
    insert into public.radyoloji_sablon_alan (sablon_id, sira, alan_kod, alan_ad, tip, secenekler, zorunlu, rapora_bas,
                                              birim, kalip, hedef_bolum, ekleyen)
    select v_id, x.sira, x.kod, x.ad, x.tip, coalesce(x.secenekler, ''), coalesce(x.zorunlu, 0), 1,
           coalesce(x.birim, ''), coalesce(x.kalip, ''), coalesce(x.bolum, 'Bulgular'), 0
      from jsonb_to_recordset(coalesce(p_alanlar, '[]')) as x(sira smallint, kod varchar, ad varchar, tip smallint,
                                                              secenekler varchar, zorunlu smallint, birim varchar, kalip varchar, bolum varchar);
    insert into public.radyoloji_sablon_makro (sablon_id, kisayol, ad, metin, hedef_bolum, ekleyen)
    select v_id, x.k, x.ad, x.metin, coalesce(x.bolum, 'Bulgular'), 0
      from jsonb_to_recordset(coalesce(p_makrolar, '[]')) as x(k varchar, ad varchar, metin text, bolum varchar);
end $f$;

-- PROTOKOL: tetkik bulunur ve protokolü yoksa ekler; seriler + çekim öncesi kontroller.
create or replace function pg_temp.rad_protokol(
    p_tetkik text, p_modalite smallint, p_bolge smallint, p_sure smallint, p_kontrast smallint,
    p_seri smallint, p_hazirlik smallint, p_uyari smallint, p_sablon text, p_ek jsonb, p_seriler jsonb, p_kontroller jsonb)
returns void language plpgsql as $f$
declare v_hz integer := pg_temp.rad_hizmet(p_tetkik); v_id integer;
begin
    if v_hz is null or exists (select 1 from public.radyoloji_protokol where hizmet_id = v_hz) then return; end if;
    insert into public.radyoloji_protokol (hizmet_id, modalite, bolge, sure_dk, kontrast, seri_kodu, hazirlik_kodu, uyari_kodu,
                                           sablon_id, hazirlik_once_dk, kontrast_ajan, kontrast_doz, kontrast_en_cok, kontrast_hiz,
                                           kontrast_takip, damar_yolu, oral_tarif, kontrendikasyon, endikasyon, ctdi_hedef, dlp_hedef,
                                           yetkinlik, durum, ekleyen)
    values (v_hz, p_modalite, p_bolge, p_sure, p_kontrast, p_seri, p_hazirlik, p_uyari,
            (select id from public.radyoloji_sablon where kod = p_sablon),
            (p_ek ->> 'once')::smallint, coalesce(p_ek ->> 'ajan', ''), coalesce(p_ek ->> 'doz', ''),
            (p_ek ->> 'enCok')::numeric, coalesce(p_ek ->> 'hiz', ''), coalesce(p_ek ->> 'takip', ''),
            coalesce(p_ek ->> 'damar', ''), coalesce(p_ek ->> 'oral', ''), coalesce(p_ek ->> 'kontrendikasyon', ''),
            coalesce(p_ek ->> 'endikasyon', ''), (p_ek ->> 'ctdi')::numeric, (p_ek ->> 'dlp')::numeric,
            coalesce(p_ek ->> 'yetkinlik', ''), 1, 0)
    returning id into v_id;
    insert into public.radyoloji_protokol_seri (protokol_id, sira, ad, faz, kesit, kv_mas, rekon, notu, ekleyen)
    select v_id, x.sira, x.ad, coalesce(x.faz, ''), coalesce(x.kesit, ''), coalesce(x.kv, ''), coalesce(x.rekon, ''), coalesce(x.notu, ''), 0
      from jsonb_to_recordset(coalesce(p_seriler, '[]')) as x(sira smallint, ad varchar, faz varchar, kesit varchar, kv varchar, rekon varchar, notu varchar);
    insert into public.radyoloji_protokol_kontrol (protokol_id, sira, ad, kural, kaynak, engel, ekleyen)
    select v_id, x.sira, x.ad, coalesce(x.kural, ''), x.kaynak, coalesce(x.engel, 1), 0
      from jsonb_to_recordset(coalesce(p_kontroller, '[]')) as x(sira smallint, ad varchar, kural varchar, kaynak smallint, engel smallint);
end $f$;

-- ================================================================ ŞABLONLAR ==
-- ---- 1 Baş - Boyun ----
select pg_temp.rad_sablon('BT-BEY-01', 'Beyin BT (kontrastsız)', 1::smallint, 1::smallint, 'BEYİN BİLGİSAYARLI TOMOGRAFİ',
  'BT, Beyin, Kontrastsız', null,
  '[{"sira":1,"baslik":"Teknik","metin":"Kontrast madde verilmeden aksiyel kesitler elde edildi; koronal ve sagital reformat görüntüler değerlendirildi.","parca":1},
    {"sira":2,"baslik":"Klinik bilgi","metin":"{istem.on_tani}"},
    {"sira":3,"baslik":"Karşılaştırma","metin":"Karşılaştırılabilecek önceki tetkik yok.","parca":2},
    {"sira":4,"baslik":"Bulgular","metin":"Beyin parankiminde akut kanama, kitle ya da yer kaplayan lezyon izlenmedi. Gri-beyaz cevher ayrımı korunmuştur. Ventrikül sistemi ve sulkuslar yaşla uyumlu genişliktedir. Orta hat yapıları normal konumdadır. Kalvaryumda kırık izlenmedi.","zorunlu":1,"parca":3},
    {"sira":5,"baslik":"Sonuç","metin":"Akut intrakraniyal patoloji saptanmadı.","zorunlu":1,"parca":4}]',
  '[{"sira":1,"kod":"kanama","ad":"İntrakraniyal kanama","tip":1,"secenekler":"Yok|Epidural|Subdural|Subaraknoid|Parankimal|İntraventriküler","zorunlu":1},
    {"sira":2,"kod":"orta_hat","ad":"Orta hat kayması","tip":2,"birim":"mm","kalip":"Orta hatta {değer} mm kayma izlendi."},
    {"sira":3,"kod":"kritik","ad":"Kritik bulgu","tip":4,"zorunlu":1}]',
  '[{"k":".nl","ad":"Normal beyin BT","metin":"Beyin parankiminde akut kanama, kitle ya da yer kaplayan lezyon izlenmedi. Ventrikül sistemi orta hatta, normal genişliktedir."},
    {"k":".atr","ad":"Yaşla uyumlu atrofi","metin":"Yaşla uyumlu serebral ve serebellar atrofik değişiklikler izlendi."},
    {"k":".isk","ad":"Erken iskemi notu","metin":"BT erken dönem iskemide normal olabilir; klinik şüphe sürüyorsa difüzyon ağırlıklı MR önerilir.","bolum":"Sonuç"}]');

select pg_temp.rad_sablon('MR-BEY-01', 'Beyin MR', 2::smallint, 1::smallint, 'BEYİN MANYETİK REZONANS GÖRÜNTÜLEME',
  'MRG, Beyin, Kontrastlı', array['MRG, Beyin, Kontrastsız'],
  '[{"sira":1,"baslik":"Teknik","metin":"T1A, T2A, FLAIR, difüzyon ağırlıklı (DWI/ADC) ve SWI sekanslar; kontrast sonrası T1A görüntüler elde edildi.","parca":1},
    {"sira":2,"baslik":"Klinik bilgi","metin":"{istem.on_tani}"},
    {"sira":3,"baslik":"Bulgular","metin":"Difüzyon kısıtlaması gösteren alan izlenmedi. Beyin parankiminde patolojik sinyal değişikliği ya da patolojik kontrastlanma saptanmadı. Ventrikül sistemi orta hatta ve normal genişliktedir. Hipofiz bezi ve sella normaldir.","zorunlu":1,"parca":3},
    {"sira":4,"baslik":"Sonuç","metin":"Beyin MR incelemesi normal sınırlardadır.","zorunlu":1,"parca":4}]',
  '[{"sira":1,"kod":"difuzyon","ad":"Difüzyon kısıtlaması","tip":4,"zorunlu":1},
    {"sira":2,"kod":"fazekas","ad":"Fazekas skoru","tip":3,"secenekler":"0|1|2|3"}]',
  '[{"k":".nl","ad":"Normal beyin MR","metin":"Beyin parankiminde patolojik sinyal değişikliği, difüzyon kısıtlaması ya da patolojik kontrastlanma izlenmedi."},
    {"k":".gli","ad":"Nonspesifik gliotik odaklar","metin":"Periventriküler ve subkortikal beyaz cevherde nonspesifik T2/FLAIR hiperintens gliotik odaklar izlendi (küçük damar hastalığı ile uyumlu)."}]');

select pg_temp.rad_sablon('US-TIR-01', 'Tiroid US (TI-RADS)', 3::smallint, 1::smallint, 'TİROİD ULTRASONOGRAFİSİ',
  'Tiroid US', array['Tiroid Bezi Renkli Doppler US'],
  '[{"sira":1,"baslik":"Bulgular","metin":"Tiroid bezi boyutları normal, parankim ekosu homojendir. Her iki lobda nodül izlenmedi. Boyun bilateral lenf nodları patolojik görünümde değildir.","zorunlu":1,"parca":3},
    {"sira":2,"baslik":"Sonuç","metin":"Tiroid US normal sınırlardadır.","zorunlu":1,"parca":4}]',
  '[{"sira":1,"kod":"tirads","ad":"ACR TI-RADS","tip":3,"secenekler":"TR1|TR2|TR3|TR4|TR5"},
    {"sira":2,"kod":"nodul_boyut","ad":"En büyük nodül","tip":2,"birim":"mm","kalip":"En büyük nodül {değer} mm ölçüldü."}]',
  '[{"k":".nl","ad":"Normal tiroid","metin":"Tiroid bezi boyutları normal, parankim ekosu homojendir. Nodül izlenmedi."},
    {"k":".hash","ad":"Tiroidit paterni","metin":"Tiroid parankim ekosu heterojen, psödonodüler görünümdedir (kronik tiroidit ile uyumlu)."}]');

-- ---- 2 Toraks ----
select pg_temp.rad_sablon('BT-TOR-01', 'Toraks BT', 1::smallint, 2::smallint, 'TORAKS BİLGİSAYARLI TOMOGRAFİ',
  'BT, Toraks, Kontrastlı', array['BT, Toraks, Kontrastsız'],
  '[{"sira":1,"baslik":"Teknik","metin":"Aksiyel kesitler elde edildi; akciğer ve mediasten pencerelerinde değerlendirildi.","parca":1},
    {"sira":2,"baslik":"Klinik bilgi","metin":"{istem.on_tani}"},
    {"sira":3,"baslik":"Karşılaştırma","metin":"Karşılaştırılabilecek önceki tetkik yok.","parca":2},
    {"sira":4,"baslik":"Bulgular","metin":"Her iki akciğer parankiminde nodül, kitle ya da konsolidasyon izlenmedi. Plevral ya da perikardiyal efüzyon yoktur. Mediastende patolojik boyutta lenf nodu saptanmadı. Kalp boyutları normaldir.","zorunlu":1,"parca":3},
    {"sira":5,"baslik":"Sonuç","metin":"Toraks BT normal sınırlardadır.","zorunlu":1,"parca":4}]',
  '[{"sira":1,"kod":"nodul","ad":"Pulmoner nodül","tip":1,"secenekler":"Yok|Solid|Subsolid|Buzlu cam"},
    {"sira":2,"kod":"nodul_boyut","ad":"En büyük nodül","tip":2,"birim":"mm","kalip":"En büyük nodül {değer} mm."},
    {"sira":3,"kod":"lung_rads","ad":"Lung-RADS","tip":3,"secenekler":"1|2|3|4A|4B|4X"}]',
  '[{"k":".nl","ad":"Normal toraks BT","metin":"Her iki akciğer parankimi normal havalanmaktadır; nodül, kitle ya da konsolidasyon izlenmedi."},
    {"k":".flei","ad":"Fleischner önerisi","metin":"Fleischner Derneği önerilerine göre nodül takibi önerilir.","bolum":"Sonuç"}]');

select pg_temp.rad_sablon('DR-AC-01', 'PA akciğer grafisi', 4::smallint, 2::smallint, 'AKCİĞER GRAFİSİ (PA)',
  'Akciğer Grafisi P.A. (Tek Yön)', array['Akciğer Grafisi (İki Yön)'],
  '[{"sira":1,"baslik":"Bulgular","metin":"Kostofrenik sinüsler açıktır. Kardiyotorasik oran normal sınırdadır. Her iki akciğer parankiminde aktif infiltrasyon izlenmedi. Hiluslar normal görünümdedir.","zorunlu":1,"parca":3},
    {"sira":2,"baslik":"Sonuç","metin":"Akciğer grafisi normal sınırlardadır.","zorunlu":1,"parca":4}]',
  null,
  '[{"k":".nl","ad":"Normal akciğer grafisi","metin":"Kostofrenik sinüsler açık, kardiyotorasik oran normal, aktif infiltrasyon izlenmedi."},
    {"k":".pnm","ad":"Pnömoni şüphesi","metin":"Akciğer parankiminde pnömoni ile uyumlu olabilecek konsolidasyon alanı izlendi; klinik korelasyon önerilir."}]');

-- ---- 3 Abdomen - Pelvis ----
select pg_temp.rad_sablon('BT-ABD-01', 'Üst abdomen BT', 1::smallint, 3::smallint, 'ABDOMEN BİLGİSAYARLI TOMOGRAFİ',
  'BT, Abdomen - Üst, Kontrastlı', array['BT, Abdomen - Üst, Kontrastsız'],
  '[{"sira":1,"baslik":"Teknik","metin":"IV kontrast madde verilerek portal venöz fazda aksiyel kesitler elde edildi; koronal reformat görüntüler değerlendirildi.","parca":1},
    {"sira":2,"baslik":"Klinik bilgi","metin":"{istem.on_tani}"},
    {"sira":3,"baslik":"Bulgular","metin":"Karaciğer boyutları normal, parankim homojendir; fokal lezyon izlenmedi. Safra kesesi ve safra yolları normaldir. Pankreas, dalak ve her iki böbrek normal görünümdedir. Batın içinde serbest sıvı ya da patolojik boyutta lenf nodu saptanmadı.","zorunlu":1,"parca":3},
    {"sira":4,"baslik":"Sonuç","metin":"Üst abdomen BT normal sınırlardadır.","zorunlu":1,"parca":4}]',
  '[{"sira":1,"kod":"serbest_sivi","ad":"Serbest sıvı","tip":1,"secenekler":"Yok|Az|Orta|Fazla"}]',
  '[{"k":".nl","ad":"Normal üst abdomen","metin":"Karaciğer, safra kesesi, pankreas, dalak ve böbrekler normal görünümdedir; serbest sıvı izlenmedi."},
    {"k":".steat","ad":"Hepatosteatoz","metin":"Karaciğer parankiminde yaygın dansite azalması izlendi (hepatosteatoz ile uyumlu)."}]');

select pg_temp.rad_sablon('US-ABD-01', 'Tüm abdomen US', 3::smallint, 3::smallint, 'TÜM ABDOMEN ULTRASONOGRAFİSİ',
  'Abdomen US, Tüm', array['Abdomen US, Üst'],
  '[{"sira":1,"baslik":"Bulgular","metin":"Karaciğer boyutları normal, parankim ekosu homojendir; fokal lezyon izlenmedi. Safra kesesi normal duvar kalınlığında, lümeninde taş izlenmedi. Safra yolları dilate değildir. Pankreas ve dalak normaldir. Her iki böbrek normal boyut ve parankim kalınlığında; pelvikalisiyel ektazi ya da taş izlenmedi. Mesane normal doluluktadır. Batın içinde serbest sıvı yoktur.","zorunlu":1,"parca":3},
    {"sira":2,"baslik":"Sonuç","metin":"Tüm abdomen US normal sınırlardadır.","zorunlu":1,"parca":4}]',
  '[{"sira":1,"kod":"steatoz","ad":"Hepatosteatoz","tip":1,"secenekler":"Yok|Grade 1|Grade 2|Grade 3"}]',
  '[{"k":".nl","ad":"Normal tüm abdomen","metin":"Karaciğer, safra kesesi, pankreas, dalak, böbrekler ve mesane normal görünümdedir; serbest sıvı izlenmedi."},
    {"k":".kolelit","ad":"Kolelitiazis","metin":"Safra kesesi lümeninde akustik gölge veren taş(lar) izlendi (kolelitiazis)."}]');

-- ---- 4 Kas - İskelet ----
select pg_temp.rad_sablon('MR-DIZ-01', 'Diz MR', 2::smallint, 4::smallint, 'DİZ MANYETİK REZONANS GÖRÜNTÜLEME',
  'MRG, Diz - Sağ, Kontrastsız', array['MRG, Diz - Sol, Kontrastsız'],
  '[{"sira":1,"baslik":"Teknik","metin":"Üç düzlemde PD yağ baskılı, T1A ve T2A sekanslar elde edildi.","parca":1},
    {"sira":2,"baslik":"Klinik bilgi","metin":"{istem.on_tani}"},
    {"sira":3,"baslik":"Bulgular","metin":"Medial ve lateral menisküslerde yırtık izlenmedi. Ön ve arka çapraz bağlar ile kollateral bağlar intakttır. Kemik iliği sinyali normaldir. Eklem kıkırdağı korunmuştur. Eklem sıvısı fizyolojik miktardadır.","zorunlu":1,"parca":3},
    {"sira":4,"baslik":"Sonuç","metin":"Diz MR incelemesi normal sınırlardadır.","zorunlu":1,"parca":4}]',
  '[{"sira":1,"kod":"menisk","ad":"Menisküs yırtığı","tip":1,"secenekler":"Yok|Medial|Lateral|Her ikisi"},
    {"sira":2,"kod":"ack","ad":"Ön çapraz bağ","tip":1,"secenekler":"İntakt|Kısmi yırtık|Tam yırtık"}]',
  '[{"k":".nl","ad":"Normal diz MR","metin":"Menisküsler, çapraz ve kollateral bağlar intakttır; kemik iliği sinyali normaldir."}]');

-- ---- 5 Omurga ----
select pg_temp.rad_sablon('MR-LOM-01', 'Lomber MR', 2::smallint, 5::smallint, 'LOMBER VERTEBRA MANYETİK REZONANS GÖRÜNTÜLEME',
  'MRG, Lomber Vertebra, Kontrastsız', null,
  '[{"sira":1,"baslik":"Teknik","metin":"Sagital T1A, T2A, STIR ve aksiyel T2A sekanslar elde edildi.","parca":1},
    {"sira":2,"baslik":"Klinik bilgi","metin":"{istem.on_tani}"},
    {"sira":3,"baslik":"Bulgular","metin":"Lomber lordoz korunmuştur. Vertebra korpus yükseklikleri ve kemik iliği sinyali normaldir. İntervertebral disklerde belirgin protrüzyon ya da herniasyon izlenmedi. Spinal kanal ve nöral foramenler açıktır. Konus medullaris normal seviyede ve sinyaldedir.","zorunlu":1,"parca":3},
    {"sira":4,"baslik":"Sonuç","metin":"Lomber MR incelemesi normal sınırlardadır.","zorunlu":1,"parca":4}]',
  '[{"sira":1,"kod":"l4l5","ad":"L4-L5 disk","tip":1,"secenekler":"Normal|Bulging|Protrüzyon|Ekstrüzyon"},
    {"sira":2,"kod":"l5s1","ad":"L5-S1 disk","tip":1,"secenekler":"Normal|Bulging|Protrüzyon|Ekstrüzyon"},
    {"sira":3,"kod":"stenoz","ad":"Spinal stenoz","tip":1,"secenekler":"Yok|Hafif|Orta|İleri"}]',
  '[{"k":".nl","ad":"Normal lomber MR","metin":"İntervertebral disklerde herniasyon izlenmedi; spinal kanal ve nöral foramenler açıktır."},
    {"k":".dej","ad":"Dejeneratif değişiklik","metin":"Disklerde dejenerasyona bağlı T2A sinyal kaybı ve hafif bulging izlendi."}]');

select pg_temp.rad_sablon('MR-SER-01', 'Servikal MR', 2::smallint, 5::smallint, 'SERVİKAL VERTEBRA MANYETİK REZONANS GÖRÜNTÜLEME',
  'MRG, Servikal Vertebra, Kontrastsız', array['Boyun (Servikal) MR'],
  '[{"sira":1,"baslik":"Teknik","metin":"Sagital T1A, T2A, STIR ve aksiyel T2A sekanslar elde edildi.","parca":1},
    {"sira":2,"baslik":"Bulgular","metin":"Servikal lordoz korunmuştur. Disklerde belirgin herniasyon izlenmedi. Spinal kord normal kalibrasyon ve sinyaldedir. Nöral foramenler açıktır.","zorunlu":1,"parca":3},
    {"sira":3,"baslik":"Sonuç","metin":"Servikal MR incelemesi normal sınırlardadır.","zorunlu":1,"parca":4}]',
  '[{"sira":1,"kod":"kord","ad":"Kord sinyal değişikliği","tip":4}]',
  '[{"k":".nl","ad":"Normal servikal MR","metin":"Disklerde herniasyon izlenmedi; spinal kord normal sinyaldedir."}]');

-- ---- 6 Meme ----
select pg_temp.rad_sablon('MG-01', 'Mamografi (BI-RADS)', 5::smallint, 6::smallint, 'MAMOGRAFİ',
  'Mammografi (Bilateral Meme)', array['Mammografi (Tek Meme)'],
  '[{"sira":1,"baslik":"Teknik","metin":"Her iki memenin CC ve MLO projeksiyonlarında dijital mamografi görüntüleri elde edildi.","parca":1},
    {"sira":2,"baslik":"Karşılaştırma","metin":"Karşılaştırılabilecek önceki tetkik yok.","parca":2},
    {"sira":3,"baslik":"Bulgular","metin":"Her iki memede kitle, şüpheli mikrokalsifikasyon ya da yapısal distorsiyon izlenmedi. Cilt ve meme başı normaldir. Aksiller bölgede patolojik lenf nodu saptanmadı.","zorunlu":1,"parca":3},
    {"sira":4,"baslik":"Sonuç","metin":"BI-RADS 1 - Negatif.","zorunlu":1,"parca":4}]',
  '[{"sira":1,"kod":"birads","ad":"BI-RADS kategorisi","tip":3,"secenekler":"0|1|2|3|4A|4B|4C|5|6","zorunlu":1,"bolum":"Sonuç"},
    {"sira":2,"kod":"yogunluk","ad":"Meme yoğunluğu","tip":1,"secenekler":"A|B|C|D","zorunlu":1}]',
  '[{"k":".nl","ad":"Negatif mamografi","metin":"Her iki memede kitle, şüpheli mikrokalsifikasyon ya da yapısal distorsiyon izlenmedi."},
    {"k":".tak","ad":"Yıllık tarama önerisi","metin":"Yaşa uygun yıllık tarama önerilir.","bolum":"Sonuç"}]');

select pg_temp.rad_sablon('US-MEM-01', 'Meme US (BI-RADS)', 3::smallint, 6::smallint, 'MEME ULTRASONOGRAFİSİ',
  'Meme US (Bilateral)', array['Meme US (Unilateral)', 'Meme Renkli Doppler US'],
  '[{"sira":1,"baslik":"Bulgular","metin":"Her iki memede solid ya da kistik kitle izlenmedi. Fibroglandüler doku dağılımı normaldir. Bilateral aksiller bölgede patolojik lenf nodu saptanmadı.","zorunlu":1,"parca":3},
    {"sira":2,"baslik":"Sonuç","metin":"BI-RADS 1 - Negatif.","zorunlu":1,"parca":4}]',
  '[{"sira":1,"kod":"birads","ad":"BI-RADS kategorisi","tip":3,"secenekler":"0|1|2|3|4A|4B|4C|5|6","zorunlu":1,"bolum":"Sonuç"}]',
  '[{"k":".nl","ad":"Normal meme US","metin":"Her iki memede solid ya da kistik kitle izlenmedi; aksillalar normaldir."},
    {"k":".kist","ad":"Basit kist","metin":"Basit kist ile uyumlu, anekoik, düzgün sınırlı lezyon izlendi (BI-RADS 2)."}]');

-- ---- 7 Vasküler ----
select pg_temp.rad_sablon('US-VEN-01', 'Alt ekstremite venöz Doppler US', 3::smallint, 7::smallint, 'ALT EKSTREMİTE VENÖZ DOPPLER ULTRASONOGRAFİSİ',
  'Alt Ekstremite Perforan Ven Renkli Doppler US, Tek Taraflı', null,
  '[{"sira":1,"baslik":"Bulgular","metin":"Ana femoral, süperfisiyal femoral, popliteal ve krural derin venler komprese edilebilir; lümenlerinde trombüs izlenmedi. Akım spontan ve fazik özelliktedir. Safenofemoral bileşkede reflü saptanmadı.","zorunlu":1,"parca":3},
    {"sira":2,"baslik":"Sonuç","metin":"Derin ven trombozu bulgusu saptanmadı.","zorunlu":1,"parca":4}]',
  '[{"sira":1,"kod":"dvt","ad":"Derin ven trombozu","tip":1,"secenekler":"Yok|Akut|Subakut|Kronik","zorunlu":1},
    {"sira":2,"kod":"reflu","ad":"Reflü","tip":4}]',
  '[{"k":".nl","ad":"Normal venöz Doppler","metin":"Derin venler komprese edilebilir, lümenlerinde trombüs izlenmedi; akım fazik özelliktedir."}]');

-- ============================================================== PROTOKOLLER ==
-- Hazır talimat (rad.hazirlik; 0 = hazırlık gerekmez): 1 kontrastlı BT · 2 MR metal · 3 US açlık · 4 röntgen takı / gebelik · 5 mamografi
-- Uyarı (rad.uyari): 1 gebelik · 2 kreatinin · 3 kalp pili / implant · 4 klostrofobi · 5 kontrast alerjisi
-- Seri (rad.seri): 1 rutin kontrastsız · 2 kontrastlı tek faz · 3 kontrastsız + kontrastlı · 4 dinamik · 6 DWI · 7 ince kesit · 10 AP+lateral · 11 tek yön
select pg_temp.rad_protokol('BT, Beyin, Kontrastsız', 1::smallint, 1::smallint, 10::smallint, 0::smallint, 1::smallint, 4::smallint, 1::smallint,
  'BT-BEY-01', '{"once":15,"endikasyon":"Travma, akut nörolojik defisit, başağrısı ön değerlendirmesi.","ctdi":60,"dlp":1000,"yetkinlik":"BT teknisyeni"}',
  '[{"sira":1,"ad":"Topogram","kv":"120 / 50"},{"sira":2,"ad":"Aksiyel","kesit":"5 / 5 mm","kv":"120 / doz modülasyonu","rekon":"beyin + kemik penceresi; koronal / sagital reformat"}]',
  '[{"sira":1,"ad":"Gebelik","kural":"15-50 yaş kadın: sorgu","kaynak":4,"engel":1}]');

select pg_temp.rad_protokol('MRG, Beyin, Kontrastlı', 2::smallint, 1::smallint, 35::smallint, 1::smallint, 3::smallint, 2::smallint, 3::smallint,
  'MR-BEY-01', '{"once":30,"ajan":"Gadolinyum bazlı ajan (makrosiklik)","doz":"0,1 mmol/kg","hiz":"2 ml/sn","takip":"20 ml SF","damar":"20-22G","kontrendikasyon":"eGFR < 30 (hekim onayı olmadan), önceki ağır gadolinyum reaksiyonu","yetkinlik":"MR teknisyeni"}',
  '[{"sira":1,"ad":"Lokalizer"},{"sira":2,"ad":"Aksiyel T2 / FLAIR","kesit":"5 mm"},{"sira":3,"ad":"DWI / ADC","kesit":"5 mm"},{"sira":4,"ad":"SWI"},{"sira":5,"ad":"Kontrast sonrası T1 (3D)","faz":"enjeksiyon sonrası","kesit":"1 mm izotropik","rekon":"3 düzlem MPR"}]',
  '[{"sira":1,"ad":"MR güvenlik formu","kural":"kalp pili, implant, metal yabancı cisim sorgusu","kaynak":4,"engel":1},
    {"sira":2,"ad":"eGFR","kural":"son 90 gün; < 30 ise hekim onayı","kaynak":1,"engel":1},
    {"sira":3,"ad":"Klostrofobi","kural":"öykü varsa sedasyon için hekime danış","kaynak":4,"engel":0}]');

select pg_temp.rad_protokol('Tiroid US', 3::smallint, 1::smallint, 15::smallint, 0::smallint, 1::smallint, 0::smallint, 9::smallint,
  'US-TIR-01', '{"endikasyon":"Tiroid nodülü, tiroid fonksiyon bozukluğu, boyunda şişlik."}', null, null);

select pg_temp.rad_protokol('BT, Toraks, Kontrastsız', 1::smallint, 2::smallint, 10::smallint, 0::smallint, 7::smallint, 4::smallint, 1::smallint,
  'BT-TOR-01', '{"once":15,"endikasyon":"Nodül takibi, interstisyel akciğer hastalığı, enfeksiyon.","ctdi":12,"dlp":450}',
  '[{"sira":1,"ad":"Topogram"},{"sira":2,"ad":"Aksiyel (tek nefes tutma)","kesit":"1,25 / 1,25 mm","kv":"120 / doz modülasyonu","rekon":"akciğer + mediasten penceresi"}]',
  '[{"sira":1,"ad":"Gebelik","kural":"15-50 yaş kadın: sorgu","kaynak":4,"engel":1}]');

select pg_temp.rad_protokol('BT, Toraks, Kontrastlı', 1::smallint, 2::smallint, 15::smallint, 1::smallint, 2::smallint, 1::smallint, 2::smallint,
  'BT-TOR-01', '{"once":30,"ajan":"İyotlu kontrast (350 mgI/ml)","doz":"1 ml/kg","enCok":100,"hiz":"3 ml/sn","takip":"40 ml SF","damar":"20G, antekübital","kontrendikasyon":"eGFR < 30, önceki ağır iyotlu kontrast reaksiyonu","ctdi":15,"dlp":600}',
  '[{"sira":1,"ad":"Topogram"},{"sira":2,"ad":"Venöz faz","faz":"60 sn","kesit":"1,25 / 1,25 mm","rekon":"akciğer + mediasten penceresi"}]',
  '[{"sira":1,"ad":"eGFR","kural":"son 90 gün; < 30 ise hekim onayı","kaynak":1,"engel":1},
    {"sira":2,"ad":"Kontrast alerjisi","kural":"öykü varsa premedikasyon","kaynak":2,"engel":1},
    {"sira":3,"ad":"Metformin","kural":"eGFR < 45 ise 48 saat ara","kaynak":3,"engel":0},
    {"sira":4,"ad":"Gebelik","kural":"15-50 yaş kadın: sorgu","kaynak":4,"engel":1}]');

select pg_temp.rad_protokol('Akciğer Grafisi P.A. (Tek Yön)', 4::smallint, 2::smallint, 5::smallint, 0::smallint, 11::smallint, 4::smallint, 1::smallint,
  'DR-AC-01', '{"endikasyon":"Öksürük, ateş, göğüs ağrısı, operasyon öncesi."}',
  '[{"sira":1,"ad":"PA (ayakta, derin inspiryum)","kv":"120 / AEC"}]',
  '[{"sira":1,"ad":"Gebelik","kural":"15-50 yaş kadın: sorgu","kaynak":4,"engel":1}]');

select pg_temp.rad_protokol('BT, Abdomen - Üst, Kontrastlı', 1::smallint, 3::smallint, 15::smallint, 3::smallint, 4::smallint, 1::smallint, 2::smallint,
  'BT-ABD-01', '{"once":60,"ajan":"İyotlu kontrast (350 mgI/ml)","doz":"1,5 ml/kg","enCok":100,"hiz":"3 ml/sn","takip":"40 ml SF","damar":"20G, antekübital","oral":"1 L su + oral kontrast, çekimden 60-30 dk önce","kontrendikasyon":"eGFR < 30, önceki ağır iyotlu kontrast reaksiyonu","ctdi":15,"dlp":700}',
  '[{"sira":1,"ad":"Topogram"},{"sira":2,"ad":"Arteriyel faz","faz":"bolus takip (+15 sn)","kesit":"1,25 mm","notu":"karaciğer lezyonunda"},{"sira":3,"ad":"Portal venöz faz","faz":"70 sn","kesit":"1,25 / 5 mm","rekon":"aksiyel + koronal"}]',
  '[{"sira":1,"ad":"eGFR","kural":"son 90 gün; < 30 ise hekim onayı","kaynak":1,"engel":1},
    {"sira":2,"ad":"Kontrast alerjisi","kural":"öykü varsa premedikasyon","kaynak":2,"engel":1},
    {"sira":3,"ad":"Metformin","kural":"eGFR < 45 ise 48 saat ara","kaynak":3,"engel":0},
    {"sira":4,"ad":"Açlık","kural":"4 saat","kaynak":4,"engel":0}]');

select pg_temp.rad_protokol('Abdomen US, Tüm', 3::smallint, 3::smallint, 20::smallint, 0::smallint, 1::smallint, 3::smallint, 9::smallint,
  'US-ABD-01', '{"endikasyon":"Karın ağrısı, karaciğer / safra kesesi / böbrek değerlendirmesi."}', null,
  '[{"sira":1,"ad":"Açlık","kural":"6-8 saat","kaynak":4,"engel":0},{"sira":2,"ad":"Dolu mesane","kural":"pelvik değerlendirme için","kaynak":4,"engel":0}]');

select pg_temp.rad_protokol('MRG, Diz - Sağ, Kontrastsız', 2::smallint, 4::smallint, 30::smallint, 0::smallint, 1::smallint, 2::smallint, 3::smallint,
  'MR-DIZ-01', '{"once":20,"endikasyon":"Menisküs / bağ yaralanması, travma sonrası ağrı."}',
  '[{"sira":1,"ad":"Lokalizer"},{"sira":2,"ad":"Sagital PD yağ baskılı","kesit":"3 mm"},{"sira":3,"ad":"Koronal PD yağ baskılı","kesit":"3 mm"},{"sira":4,"ad":"Aksiyel PD yağ baskılı","kesit":"3 mm"},{"sira":5,"ad":"Sagital T1","kesit":"3 mm"}]',
  '[{"sira":1,"ad":"MR güvenlik formu","kural":"kalp pili, implant, metal sorgusu","kaynak":4,"engel":1}]');

select pg_temp.rad_protokol('MRG, Diz - Sol, Kontrastsız', 2::smallint, 4::smallint, 30::smallint, 0::smallint, 1::smallint, 2::smallint, 3::smallint,
  'MR-DIZ-01', '{"once":20,"endikasyon":"Menisküs / bağ yaralanması, travma sonrası ağrı."}',
  '[{"sira":1,"ad":"Lokalizer"},{"sira":2,"ad":"Sagital PD yağ baskılı","kesit":"3 mm"},{"sira":3,"ad":"Koronal PD yağ baskılı","kesit":"3 mm"},{"sira":4,"ad":"Aksiyel PD yağ baskılı","kesit":"3 mm"},{"sira":5,"ad":"Sagital T1","kesit":"3 mm"}]',
  '[{"sira":1,"ad":"MR güvenlik formu","kural":"kalp pili, implant, metal sorgusu","kaynak":4,"engel":1}]');

select pg_temp.rad_protokol('MRG, Lomber Vertebra, Kontrastsız', 2::smallint, 5::smallint, 25::smallint, 0::smallint, 1::smallint, 2::smallint, 3::smallint,
  'MR-LOM-01', '{"once":20,"endikasyon":"Bel ağrısı, radikülopati, spinal stenoz şüphesi."}',
  '[{"sira":1,"ad":"Lokalizer"},{"sira":2,"ad":"Sagital T1","kesit":"4 mm"},{"sira":3,"ad":"Sagital T2","kesit":"4 mm"},{"sira":4,"ad":"Sagital STIR","kesit":"4 mm"},{"sira":5,"ad":"Aksiyel T2 (L3-S1)","kesit":"4 mm"}]',
  '[{"sira":1,"ad":"MR güvenlik formu","kural":"kalp pili, implant, metal sorgusu","kaynak":4,"engel":1},
    {"sira":2,"ad":"Klostrofobi","kural":"öykü varsa hekime danış","kaynak":4,"engel":0}]');

select pg_temp.rad_protokol('MRG, Servikal Vertebra, Kontrastsız', 2::smallint, 5::smallint, 25::smallint, 0::smallint, 1::smallint, 2::smallint, 3::smallint,
  'MR-SER-01', '{"once":20,"endikasyon":"Boyun ağrısı, radikülopati, miyelopati şüphesi."}',
  '[{"sira":1,"ad":"Lokalizer"},{"sira":2,"ad":"Sagital T1 / T2 / STIR","kesit":"3 mm"},{"sira":3,"ad":"Aksiyel T2 (C2-T1)","kesit":"3 mm"}]',
  '[{"sira":1,"ad":"MR güvenlik formu","kural":"kalp pili, implant, metal sorgusu","kaynak":4,"engel":1}]');

select pg_temp.rad_protokol('Mammografi (Bilateral Meme)', 5::smallint, 6::smallint, 15::smallint, 0::smallint, 10::smallint, 5::smallint, 1::smallint,
  'MG-01', '{"endikasyon":"Tarama (40 yaş üstü), ele gelen kitle, takip."}',
  '[{"sira":1,"ad":"Sağ CC"},{"sira":2,"ad":"Sol CC"},{"sira":3,"ad":"Sağ MLO"},{"sira":4,"ad":"Sol MLO"}]',
  '[{"sira":1,"ad":"Gebelik / emzirme","kural":"sorgu","kaynak":4,"engel":1},{"sira":2,"ad":"Önceki mamografi","kural":"varsa karşılaştırma için getirilsin","kaynak":4,"engel":0}]');

select pg_temp.rad_protokol('Meme US (Bilateral)', 3::smallint, 6::smallint, 20::smallint, 0::smallint, 1::smallint, 0::smallint, 9::smallint,
  'US-MEM-01', '{"endikasyon":"Dens meme dokusu, ele gelen kitle, mamografi bulgusunun değerlendirilmesi."}', null, null);

select pg_temp.rad_protokol('Alt Ekstremite Perforan Ven Renkli Doppler US, Tek Taraflı', 3::smallint, 7::smallint, 30::smallint, 0::smallint, 9::smallint, 0::smallint, 9::smallint,
  'US-VEN-01', '{"endikasyon":"Bacakta şişlik / ağrı, derin ven trombozu şüphesi, varis."}', null, null);
