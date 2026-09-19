-- ============================================================================
--  Gentegre AI — BOZUK YAZILMIŞ ETKEN MADDE ADLARININ ONARIMI (858)
--  858_etken_madde_yazim_onarimi.sql
--
--  Kullanıcı: *"bozuk yazılmış etken maddeleri de düzelt"*.
--  857'de çeviri sırasında ortaya çıkan yazım hataları bu dosyada VERİDE
--  onarılır (önceki dosyalar yalnız sözlük ekliyordu, veriye dokunmuyordu).
--
--  ============ SADECE İSPATLANABİLİR İKİ HATA SINIFI ================
--    A) BOŞLUK UNUTULMUŞ: iki katalog sözcüğü bitişik yazılmış -
--       "tramadolhidroklorür" → "tramadol hidroklorür".
--    B) AÇIK HARF HATASI: doğru yazım AYNI TABLODA başka satırlarda var -
--       "glimeprid" → "glimepirid" (doğrusu 25 satırda), "sefozolin" →
--       "sefazolin", "rivoraksaban" → "rivaroksaban".
--
--  ============ NEYE DOKUNULMADI ======================================
--    · İNGİLİZCE YAZILMIŞ KAYITLAR ("clarithromycin", "amlodipine"):
--      hata değil, kaynak kataloğun İngilizce satırları.
--    · TÜRKÇE EK almiş biçimler ("polisakkarit" / "polisakkariti"):
--      dil bilgisi, hata değil.
--    · Etken madde yerine MARKA yazılmış kayıtlar ("novaljin",
--      "terramisin"): doğrusu yazım değil, başka bir bilgi - tahmin
--      yürütülmedi, olduğu gibi bırakıldı.
--    · Emin olunmayan kısaltılmış/kesik kayıtlar ("amlodi̇pi̇n bes.").
--
--  ============ GÜVENLİK =============================================
--  · Onarımdan ÖNCE tüm satırlar `ilac_etken_yedek_858` tablosuna
--    kopyalanır (id + eski metin). Geri alma: yedekten UPDATE.
--  · GÜNCELLEME TAM METNİ EŞLEŞTİRİR (regex/LIKE yok): aşağıdaki
--    (eski, yeni) çiftlerinden birine birebir uymayan satır değişmez.
--    Bu yüzden tekrar çalıştırılabilir - ikinci çalışma 0 satır günceller.
--  · `ilac` TİTCK kaynağından aktarılan bir katalogdur; yeni bir aktarım
--    bu satırları eski haline döndürebilir, o zaman dosya yeniden
--    çalıştırılır.
--  · Reçete/MEDULA'ya giden alan `recete_satir.ilac_ad` ve barkoddur;
--    etken madde bilgi amaçlı gösterilir.
-- ============================================================================
\set ON_ERROR_STOP on
begin;

create table if not exists public.ilac_etken_yedek_858 (
    id           integer primary key,
    etken_madde  character varying(300) not null,
    yedek_tarihi timestamptz not null default now()
);

insert into public.ilac_etken_yedek_858 (id, etken_madde)
select i.id, i.etken_madde from public.ilac i
 where i.etken_madde <> ''
on conflict (id) do nothing;


-- 300 KARAKTERDE KESILMIS 4 KAYIT ONARILMADI: `etken_madde` varchar(300)
-- ve bu satirlar aktarimda zaten kesilmis (metin yarida bitiyor). Bosluk
-- eklemek siniri asiyordu; kolonu genisletmek aktarim tarafini da
-- ilgilendirdigi icin bu dosyada YAPILMADI, satirlar oldugu gibi kaldi.
with d(eski, yeni) as (values
    ('budesonid ve formetorol fumarat', 'budesonid ve formoterol fumarat'),
    ('nistadin', 'nistatin'),
    ('prokain penisilin, potasyum penislin', 'prokain penisilin, potasyum penisilin'),
    ('gingko biloba', 'ginkgo biloba'),
    ('betametazon dıpropıyonat+kalsıpotrıyol monohidrat', 'betametazon dipropiyonat+kalsipotriyol monohidrat'),
    ('spirinolakton / hidroklorotiyazid', 'spironolakton / hidroklorotiyazid'),
    ('tenoksikam, tiyokloşikozit', 'tenoksikam, tiyokolşikosid'),
    ('amoksisilin/klavulonik asit', 'amoksisilin/klavulanik asit'),
    ('budesonid/formeterol fumarat dihidrat', 'budesonid/formoterol fumarat dihidrat'),
    ('sodyum klorürkalsiyum klorür 2.h2omagnezyum klorür 6.h2opotasyum klorür', 'sodyum klorür, kalsiyum klorür 2.h2o, magnezyum klorür 6.h2o, potasyum klorür'),
    ('estramustin sodyum fosfatmonohidrat', 'estramustin sodyum fosfat monohidrat'),
    ('tirofiban hidroklorü monohidrat', 'tirofiban hidroklorür monohidrat'),
    ('tadafil', 'tadalafil'),
    ('siprofloksasin hidraklorür', 'siprofloksasin hidroklorür'),
    ('spirinolakton', 'spironolakton'),
    ('rasemik potasyum aspartathemihidrat,rasemik magnezyumaspartat tetrahidrat', 'rasemik potasyum aspartat hemihidrat,rasemik magnezyum aspartat tetrahidrat'),
    ('L-izolösin, L-lösin, L-lizin monohidrat, Lmetiyonin, L-fenilalanin, L-treonin, Ltriptofan, L-valin, L-histidin, L-malik asit', 'L-izolösin, L-lösin, L-lizin monohidrat, L-metiyonin, L-fenilalanin, L-treonin, L-triptofan, L-valin, L-histidin, L-malik asit'),
    ('parasetamol/hiyasin-n-butilbromür', 'parasetamol/hiyosin-n-butilbromür'),
    ('travoprost+tımolol maleat', 'travoprost+timolol maleat'),
    ('panroprazol sodyum seskihidrat', 'pantoprazol sodyum seskihidrat'),
    ('atomeksin hidroklorür', 'atomoksetin hidroklorür'),
    ('isosorbitdinitrat', 'izosorbid dinitrat'),
    ('difenhidraminhidroklorür ve çinko oksit', 'difenhidramin hidroklorür ve çinko oksit'),
    ('tiyokolşikosit', 'tiyokolşikosid'),
    ('tiyokolşikozit + diklofenak potasyum', 'tiyokolşikosid + diklofenak potasyum'),
    ('olmesartan medoksamil', 'olmesartan medoksomil'),
    ('travoprost, tımolol maleat', 'travoprost, timolol maleat'),
    ('levamizolhidroklorür', 'levamizol hidroklorür'),
    ('ibandronikasit sodyum monohidrat', 'ibandronik asit sodyum monohidrat'),
    ('glisin, kalsiyum klorür, l-alanin, l-arjinin, l-fenilalanin, l-histidin, l-isolösin, l-lizin, l-lösin, lmethiyonin, l-prolin, l-treonin, l-triptofan, l-valin, magnezyum klorür, serin, sodyum klorür, sodyum laktat, tirozin', 'glisin, kalsiyum klorür, l-alanin, l-arjinin, l-fenilalanin, l-histidin, l-isolösin, l-lizin, l-lösin, l-metiyonin, l-prolin, l-treonin, l-triptofan, l-valin, magnezyum klorür, serin, sodyum klorür, sodyum laktat, tirozin'),
    ('sefpodoksim proksetil ve kalvulanik asit', 'sefpodoksim proksetil ve klavulanik asit'),
    ('levatirasetam', 'levetirasetam'),
    ('sefozolin', 'sefazolin'),
    ('flurbiprofen, tiyokolşikozid', 'flurbiprofen, tiyokolşikosid'),
    ('alanin, arjinin, glisin, histidin, izolösin, lösin, lizin hcl, methiyonin, fenilalanin, prolin, serin, treonin, triptofan, tirozin, valin, sodyum klorür, kalsiyum klorür dihidrat, magnezyum klorür hekzahidrat, sodyum (s)-laktat çözeltisi', 'alanin, arjinin, glisin, histidin, izolösin, lösin, lizin hcl, metiyonin, fenilalanin, prolin, serin, treonin, triptofan, tirozin, valin, sodyum klorür, kalsiyum klorür dihidrat, magnezyum klorür hekzahidrat, sodyum (s)-laktat çözeltisi'),
    ('çinkosülfat heptahidrat', 'çinko sülfat heptahidrat'),
    ('l-izolüsın, l-lösin, lıizin, l-metiyonin, l-fenilalanin, l-treonin, l-triptofan, l-valin, l-histidin, l-arginıin l-prolin, l-serin, glisin, sistein', 'l-izolösin, l-lösin, l-lizin, l-metiyonin, l-fenilalanin, l-treonin, l-triptofan, l-valin, l-histidin, l-arginin l-prolin, l-serin, glisin, sistein'),
    ('tramadolhidroklorür', 'tramadol hidroklorür'),
    ('levofloksasin hermihidrat', 'levofloksasin hemihidrat'),
    ('olmesartan nedoksomil + amlodipin besilat', 'olmesartan medoksomil + amlodipin besilat'),
    ('glimeprid', 'glimepirid'),
    ('tiamin hidroklorür+pridoksin hidroklorür+siyanokobalamin', 'tiamin hidroklorür+piridoksin hidroklorür+siyanokobalamin'),
    ('betametazondipropionat,betametazon sodyumfosfat', 'betametazon dipropionat,betametazon sodyum fosfat'),
    ('levosetrizin dihidroklorür', 'levosetirizin dihidroklorür'),
    ('demir(ii)-glisin, sülfatkompleksi, folik asit, b12 vitamin', 'demir(ii)-glisin, sülfat kompleksi, folik asit, b12 vitamin'),
    ('ezetimip ve atorvastatin kalsiyum', 'ezetimib ve atorvastatin kalsiyum'),
    ('rafine zeytinyağı,rafine soya yağı,l-alanin,l-arjinin, glisin, l-histidin,l-izölösin, l-lösin,l-lizin, l-metiyonin,l-fenilalanin, l-prolin, l-serin, l-treonin, l-triptofan, l-treozin, l-valin, sodyum asetat 3h2o, sodyum gliserofosfat 5h20, potasyum klorür, mağnezyum klorür 6h2o, glukoz(17.6 g glıkoz', 'rafine zeytinyağı,rafine soya yağı,l-alanin,l-arjinin, glisin, l-histidin,l-izolösin, l-lösin,l-lizin, l-metiyonin,l-fenilalanin, l-prolin, l-serin, l-treonin, l-triptofan, l-tirozin, l-valin, sodyum asetat 3h2o, sodyum gliserofosfat 5h20, potasyum klorür, magnezyum klorür 6h2o, glukoz(17.6 g glıkoz'),
    ('magnesyum hidroksit', 'magnezyum hidroksit'),
    ('alümniyum hidroksit, çinkooksit, borik asit, peru balsam', 'alümniyum hidroksit, çinko oksit, borik asit, peru balsam'),
    ('karvedillol', 'karvedilol'),
    ('montelukast sodyum,levosetrizin dihidroklorür', 'montelukast sodyum,levosetirizin dihidroklorür'),
    ('dekstoz monohidrat', 'dekstroz monohidrat'),
    ('metenamin & metenamin anhidrometilensitrat', 'metenamin & metenamin anhidrometilen sitrat'),
    ('Vitamin A Palmitat, Vitamin D3 (Kolekalsiferol), Vitamin B1 (Tiamin hidroklorür), Vitamin B2 (Riboflavin sodyum fosfat),Vitamin B3 (Niasinamit/Nikotinamid), Vitamin B5 (D-pantenol/Dexpantenol), Vitamin B 6 (Pridoksin hidroklorür),Vitamin C (Askorbik asit)', 'Vitamin A Palmitat, Vitamin D3 (Kolekalsiferol), Vitamin B1 (Tiamin hidroklorür), Vitamin B2 (Riboflavin sodyum fosfat),Vitamin B3 (Niasinamit/Nikotinamid), Vitamin B5 (D-pantenol/Dexpantenol), Vitamin B 6 (Piridoksin hidroklorür),Vitamin C (Askorbik asit)'),
    ('formetorol fumarat dihidrat + beklometazon dipropiyonat', 'formoterol fumarat dihidrat + beklometazon dipropiyonat'),
    ('tiotropium bromür anhidrus, formeterol fumarat dihidrat', 'tiotropium bromür anhidrus, formoterol fumarat dihidrat'),
    ('parasetamol, klorfeniraminmaleat, fenilefrin hcl, oksolamin sitrat', 'parasetamol, klorfeniramin maleat, fenilefrin hcl, oksolamin sitrat'),
    ('İbuprofen, Psödoefedrin hidroklorürt, Klorfeniramin maleat', 'İbuprofen, Psödoefedrin hidroklorür, Klorfeniramin maleat'),
    ('sefiksim trihidrat ve klavulonikasit', 'sefiksim trihidrat ve klavulanik asit'),
    ('atomoksetinhidroklorür', 'atomoksetin hidroklorür'),
    ('Sitagligtin fosfat monohidrat', 'Sitagliptin fosfat monohidrat'),
    ('sodyum laktat, sodyum klorür, potasyum korür, kalsiyum klorür dihidrat', 'sodyum laktat, sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat'),
    ('mometaszon fumarat', 'mometazon fumarat'),
    ('pridoksin hcl, tiamin hcl', 'piridoksin hcl, tiamin hcl'),
    ('ondansetron hidroklorürdihidrat', 'ondansetron hidroklorür dihidrat'),
    ('sulpride', 'sulpiride'),
    ('deksketoprofen tometamol + tiyokolşikosid', 'deksketoprofen trometamol + tiyokolşikosid'),
    ('Vortioksetin hidrokloür', 'Vortioksetin hidroklorür'),
    ('gliseriltrinitrat', 'gliseril trinitrat'),
    ('pridoksin hcl', 'piridoksin hcl'),
    ('deksketoprofen trometamol+tiyokolşikozit', 'deksketoprofen trometamol+tiyokolşikosid'),
    ('ketokanazol', 'ketokonazol'),
    ('florourasil', 'fluorourasil'),
    ('tiotroniium bromür anhidrus', 'tiotropium bromür anhidrus'),
    ('seftolozan sükfat, tazobaktam sodyum', 'seftolozan sülfat, tazobaktam sodyum'),
    ('rosuvastatinkalsiyum, asetilsalisilik asit', 'rosuvastatin kalsiyum, asetilsalisilik asit'),
    ('çinko sülfatheptahidret', 'çinko sülfat heptahidrat'),
    ('sefuroksim soyum', 'sefuroksim sodyum'),
    ('pantaprazol sodyum', 'pantoprazol sodyum'),
    ('memantin hcl ve ginko biloba kuru ekstresi', 'memantin hcl ve ginkgo biloba kuru ekstresi'),
    ('gümüş süfadiazin', 'gümüş sülfadiazin'),
    ('asetilsalisalik asit ve askorbik asit', 'asetilsalisilik asit ve askorbik asit'),
    ('deksketoprofen tometamol', 'deksketoprofen trometamol'),
    ('rivoraksaban', 'rivaroksaban'),
    ('diflukotolon valerat', 'diflukortolon valerat'),
    ('sodyum aljinatpotasyum bikarbonat', 'sodyum aljinat potasyum bikarbonat'),
    ('sefaklor monohidrat ve kalvulanik asit', 'sefaklor monohidrat ve klavulanik asit'),
    ('spironolakton/furasemid', 'spironolakton/furosemid'),
    ('tiyokolşikozit', 'tiyokolşikosid'),
    ('tetrasiklinhidroklorür', 'tetrasiklin hidroklorür'),
    ('benzoilperoksit', 'benzoil peroksit'),
    ('dekstroz anhidrat + sodyum laktat + potasyum klorür + magnezyum klorür hekzahidrat + dibazik potasyum fosfat + sodum bisülfit', 'dekstroz anhidrat + sodyum laktat + potasyum klorür + magnezyum klorür hekzahidrat + dibazik potasyum fosfat + sodyum bisülfit'),
    ('levosetrizin dihidroklorür ve montelukast sodyum', 'levosetirizin dihidroklorür ve montelukast sodyum'),
    ('sefpodoksim ve kalvulanik asit', 'sefpodoksim ve klavulanik asit'),
    ('nandrolondekanoat', 'nandrolon dekanoat'),
    ('nimesulid/tiyokolşikozit', 'nimesulid/tiyokolşikosid'),
    ('alanin,arjinin,aspartik asit, glutamik asit, glisin, histidin, izolösin, lösin, lizinasetat, metiyonin, fenilalanin, prolin, serin, treonin, triptofan, tirozin, valin, glukoz monohidrat, rafine z.yaği, rafine soya fasülyesi yaği', 'alanin,arjinin,aspartik asit, glutamik asit, glisin, histidin, izolösin, lösin, lizin asetat, metiyonin, fenilalanin, prolin, serin, treonin, triptofan, tirozin, valin, glukoz monohidrat, rafine z.yaği, rafine soya fasülyesi yaği'),
    ('metaprolol süksinat', 'metoprolol süksinat')
)
update public.ilac i set etken_madde = d.yeni, guncelleme = now()
  from d where i.etken_madde = d.eski;

do $$
declare v_yedek integer; v_deg integer;
begin
    select count(*) into v_yedek from public.ilac_etken_yedek_858;
    -- Onarilmis sayisi: yedekteki eski metinden FARKLI olan satirlar.
    select count(*) into v_deg
      from public.ilac i join public.ilac_etken_yedek_858 y on y.id = i.id
     where i.etken_madde <> y.etken_madde;
    raise notice '858 tamam: yedek % satir, onarilan % satir.', v_yedek, v_deg;
end $$;

commit;
