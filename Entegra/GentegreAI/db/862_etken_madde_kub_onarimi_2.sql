-- ============================================================================
--  Gentegre AI — KALAN ATC SINIF ADI KAYITLARININ KÜB'E GÖRE ONARIMI (862)
--  862_etken_madde_kub_onarimi_2.sql
--
--  Kullanıcı: *"kalan aileleri de tek tek araştır"*.
--  861'den sonra 121 satır kalmıştı; bu dosya 86'sını onarır.
--  Her ürün ailesi için KÜB / kullanma talimatı ayrı ayrı okundu.
--
--  ============ ONARILAN AİLELER ======================================
--    LIBENTA            kalsiyum disodyum edetat
--    TRACUTIL           eser element tuzları (demir, çinko, mangan, bakır,
--                       krom, molibden, selenyum, flüor, iyot)
--    PF RİNGER, NEOFLEKS RİNGER   sodyum/potasyum/kalsiyum klorür
--    ISOSOL-P           dekstroz + pediatrik idame elektrolitleri
--    NANOGAM, RONSENGLOB, PENTAGLOBIN  insan normal immünoglobulini
--                       (PENTAGLOBIN IgM/IgA ile zenginleştirilmiş)
--    BRONCHO-VAXOM / MUNAL  liyofilize bakteri lizatı (OM-85)
--    CANTHACUR kantaridin · PODOFILM podofillum reçinesi
--    TANTUM VERDE DUO / PERİMEX PLUS / HEXADAMIN  benzidamin
--                       hidroklorür + klorheksidin glukonat
--    KETOSTERİL, EAS    aminoasit ve ketoasit kombinasyonu
--    FERROZINC, CALCIDINE, MULTIMIX, VITABIOL  KÜB'deki vitamin/mineral
--                       listesi; MENAPHASE, UNICAP, DECAVIT, ANTIOXIDANT,
--                       DAILY-ONE için KÜB'ün kendi üst başlığı
--                       ("multivitamin ve mineral kombinasyonu")
--    FUNGOID            izokonazol nitrat + diflukortolon valerat
--    IECILLINE, BENZAPEN  penisilin G tuzları
--    AMETIK, VOMITIN, VOSELMIT  trimetobenzamid hidroklorür
--    LIBALAKS           gliserol, sodyum sitrat, sorbitol
--    Soğuk algınlığı ürünleri: PARASINUS, DRISTAN, CETAFLU, GRIPAMOL,
--                       TRIATUS, HISTORAN, FENIDIN, GAYABEKSIN, PAROL HOT,
--                       GERALGINE-HOT, PEDITUS, FENOKODIN, BRONKOFLU, ARTU,
--                       METORFAN  - her biri kendi KÜB'ündeki bileşimle
--    HEMORALGINE        çinko oksit, efedrin HCl, klorheksidin HCl
--    ANTIDOT            kafur
--    Aminoasit çözeltileri (PERİFERAMİN, NEFRASİN, NEPHROTECT, AMINOVEN,
--                       GLUKOZ-1100): tam aminoasit listesi KÜB'den
--                       alınamadığı için "aminoasit karışımı" yazıldı -
--                       İngilizce sınıf metninin doğru Türkçe karşılığı.
--
--  ============ HALA ONARILMAYAN 35 SATIR =============================
--    · BIOPERITONAL / BIOPERITONEAL / PERIT.DIA (13) - ürüne özgü KÜB
--      bulunamadı; başka markanın periton diyaliz formülünü kopyalamak
--      derişim farkı yüzünden yanıltıcı olur.
--    · RENDIALIZAT, KONSANTRE/ASIDİK/BAZİK hemodiyaliz çözeltileri (15) -
--      asit/baz konsantre bileşimi üreticiye göre değişiyor.
--    · DORFAN, GERAKON, NEO-JUCODINE, PEREKS, KANSİLAK, PİRALDYNE (7) -
--      KÜB'üne ulaşılamadı.
--
--  ============ GÜVENLİK ==============================================
--  Yedek `ilac_etken_yedek_862`; güncelleme id + eski metin eşleştirir,
--  ikinci çalıştırma 0 satır.
-- ============================================================================
\set ON_ERROR_STOP on
begin;

create table if not exists public.ilac_etken_yedek_862 (
    id           integer primary key,
    etken_madde  character varying(300) not null,
    yedek_tarihi timestamptz not null default now()
);

with d(id, eski, yeni) as (values
    (804, 'other antiemetics', 'trimetobenzamid hidroklorür'),
    (845, 'amino acids', 'aminoasit karışımı'),
    (1048, 'various', 'kafur'),
    (1062, 'multivitamins and trace elements', 'multivitamin ve mineral kombinasyonu'),
    (1283, 'other cold preparations', 'tiyokol, prometazin, sodyum benzoat, efedrin'),
    (1870, 'combinations', 'penisilin g benzatin, penisilin g potasyum, penisilin g prokain'),
    (2364, 'other respiratory system products', 'liyofilize bakteri lizatı (OM-85)'),
    (2365, 'other respiratory system products', 'liyofilize bakteri lizatı (OM-85)'),
    (2372, 'other cold preparations', 'guaifenesin, efedrin hidroklorür'),
    (2481, 'vitamins with minerals', 'd2 vitamini (ergokalsiferol), kalsiyum glukonat, kalsiyum magnezyum inozitohekzafosfat'),
    (2615, 'wart and anti-corn preparations', 'kantaridin'),
    (2616, 'wart and anti-corn preparations', 'kantaridin'),
    (2960, 'other cold preparations', 'parasetamol, fenilefrin hidroklorür, klorfeniramin maleat'),
    (3522, 'vitamins, other combinations', 'multivitamin ve mineral kombinasyonu'),
    (3594, 'multivitamins, minerals', 'multivitamin ve mineral kombinasyonu'),
    (4406, 'other cold preparations', 'parasetamol, fenilefrin hidroklorür, klorfeniramin maleat'),
    (4575, 'amino acids, incl. combinations with polypeptides', 'aminoasit ve ketoasit kombinasyonu'),
    (5432, 'various', 'benzidamin hidroklorür, klorheksidin glukonat'),
    (5433, 'various', 'benzidamin hidroklorür, klorheksidin glukonat'),
    (5471, 'other cold preparations', 'amonyum klorür, difenhidramin hidroklorür, sodyum sitrat'),
    (5472, 'other cold preparations', 'amonyum klorür, difenhidramin hidroklorür, sodyum sitrat'),
    (5543, 'vitamins with minerals', 'demir fumarat, çinko sülfat monohidrat, folik asit, c vitamini'),
    (5544, 'vitamins with minerals', 'demir fumarat, çinko sülfat monohidrat, folik asit, c vitamini'),
    (5988, 'combinations', 'izokonazol nitrat, diflukortolon valerat'),
    (5989, 'combinations', 'izokonazol nitrat, diflukortolon valerat'),
    (6122, 'other cold preparations', 'sodyum benzoat, potasyum sülfogayakolat'),
    (6241, 'other cold preparations', 'parasetamol, klorfeniramin maleat, psödoefedrin hidroklorür'),
    (6406, 'combinations', 'aminoasit karışımı, glukoz'),
    (6407, 'combinations', 'aminoasit karışımı, glukoz'),
    (6477, 'other cold preparations', 'parasetamol, klorfeniramin maleat, psödoefedrin hidroklorür, dekstrometorfan hidrobromür'),
    (6566, 'other preparations, combinations', 'çinko oksit, efedrin hidroklorür, klorheksidin hidroklorür'),
    (6680, 'other cold preparations', 'amonyum klorür, difenhidramin hidroklorür, sodyum sitrat'),
    (6816, 'combinations', 'penisilin g potasyum, penisilin g prokain'),
    (6817, 'combinations', 'penisilin g potasyum, penisilin g prokain'),
    (7221, 'electrolytes with carbohydrates', 'dekstroz, dibazik potasyum fosfat, magnezyum klorür, potasyum klorür, sodyum laktat'),
    (7222, 'electrolytes with carbohydrates', 'dekstroz, dibazik potasyum fosfat, magnezyum klorür, potasyum klorür, sodyum laktat'),
    (7668, 'amino acids, incl. combinations with polypeptides', 'aminoasit ve ketoasit kombinasyonu'),
    (8500, 'combinations', 'gliserol, sodyum sitrat, sorbitol'),
    (8508, 'edetates', 'kalsiyum disodyum edetat'),
    (8509, 'edetates', 'kalsiyum disodyum edetat'),
    (8510, 'edetates', 'kalsiyum disodyum edetat'),
    (8511, 'edetates', 'kalsiyum disodyum edetat'),
    (9179, 'multivitamins and trace elements', 'multivitamin ve mineral kombinasyonu'),
    (9333, 'other cold preparations', 'dekstrometorfan'),
    (9920, 'multivitamins, plain', 'a vitamini, b1 vitamini, b2 vitamini, b6 vitamini, c vitamini, d3 vitamini, e vitamini, d-pantenol, d-biotin, nikotinamid'),
    (10032, 'immunoglobulins, normal human, for intravascular adm.', 'insan normal immünoglobulini'),
    (10033, 'immunoglobulins, normal human, for intravascular adm.', 'insan normal immünoglobulini'),
    (10107, 'amino acids', 'aminoasit karışımı'),
    (10108, 'amino acids', 'aminoasit karışımı'),
    (10264, 'electrolytes', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat'),
    (10265, 'electrolytes', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat'),
    (10266, 'electrolytes', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat'),
    (10267, 'electrolytes', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat'),
    (10304, 'amino acids', 'aminoasit karışımı'),
    (10305, 'amino acids', 'aminoasit karışımı'),
    (11584, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür'),
    (11636, 'other cold preparations', 'parasetamol, klorfeniramin maleat, psödoefedrin hidroklorür'),
    (11637, 'other cold preparations', 'parasetamol, klorfeniramin maleat, psödoefedrin hidroklorür'),
    (11712, 'other cold preparations', 'parasetamol, guaifenesin, prilamin maleat, fenilefrin hidroklorür'),
    (11836, 'combinations', 'aminoasit karışımı'),
    (11837, 'combinations', 'aminoasit karışımı'),
    (11838, 'combinations', 'aminoasit karışımı'),
    (11839, 'combinations', 'aminoasit karışımı'),
    (11845, 'various', 'benzidamin hidroklorür, klorheksidin glukonat'),
    (11846, 'various', 'benzidamin hidroklorür, klorheksidin glukonat'),
    (12150, 'wart and anti-corn preparations', 'podofillum reçinesi'),
    (13339, 'electrolytes', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat'),
    (13340, 'electrolytes', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat'),
    (13341, 'electrolytes', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat'),
    (13342, 'electrolytes', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat'),
    (14624, 'various', 'benzidamin hidroklorür, klorheksidin glukonat'),
    (15474, 'electrolytes in combination with other drugs', 'demir (II) klorür tetrahidrat, çinko klorür, mangan (II) klorür tetrahidrat, bakır (II) klorür dihidrat, krom (III) klorür hekzahidrat, sodyum molibdat dihidrat, sodyum selenit pentahidrat, sodyum florür, potasyum iyodür'),
    (15552, 'other cold preparations', 'dekstrometorfan hidrobromür, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (15912, 'multivitamins and trace elements', 'multivitamin ve mineral kombinasyonu'),
    (16175, 'other respiratory system products', 'liyofilize bakteri lizatı (OM-85)'),
    (16176, 'other respiratory system products', 'liyofilize bakteri lizatı (OM-85)'),
    (16453, 'multivitamins, plain', 'a vitamini, b1 vitamini, b2 vitamini, b3 vitamini, b5 vitamini, b6 vitamini, c vitamini, d3 vitamini'),
    (16541, 'other antiemetics', 'trimetobenzamid hidroklorür'),
    (16542, 'other antiemetics', 'trimetobenzamid hidroklorür'),
    (16559, 'other antiemetics', 'trimetobenzamid hidroklorür'),
    (20732, 'vitamins with minerals', 'demir fumarat, çinko sülfat monohidrat, folik asit, c vitamini'),
    (20822, 'amino acids, incl. combinations with polypeptides', 'aminoasit ve ketoasit kombinasyonu'),
    (13510, 'immunoglobulins, normal human, for intravascular adm.', 'insan normal immünoglobulini'),
    (10034, 'immunoglobulins, normal human, for intravascular adm.', 'insan normal immünoglobulini'),
    (5485, 'combinations', 'kodein, etilmorfin'),
    (11771, 'immunoglobulins, normal human, for intravascular adm.', 'insan normal immünoglobulini (IgM ve IgA ile zenginleştirilmiş)')
)
, y as (
    insert into public.ilac_etken_yedek_862 (id, etken_madde)
    select i.id, i.etken_madde from public.ilac i join d on d.id = i.id
     where i.etken_madde = d.eski
    on conflict (id) do nothing
    returning 1
)
update public.ilac i set etken_madde = d.yeni, guncelleme = now()
  from d where i.id = d.id and i.etken_madde = d.eski;

do $$
declare v_yedek integer;
begin
    select count(*) into v_yedek from public.ilac_etken_yedek_862;
    raise notice '862 tamam: KUB ile onarilan % satir.', v_yedek;
end $$;

commit;
