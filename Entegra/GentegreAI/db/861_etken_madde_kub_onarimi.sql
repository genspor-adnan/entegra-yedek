-- ============================================================================
--  Gentegre AI — ATC SINIF ADI YAZAN KAYITLARIN KÜB'E GÖRE ONARIMI (861)
--  861_etken_madde_kub_onarimi.sql
--
--  Kullanıcı: *"kalan 252 satırı da KÜB'lere göre onar"*.
--  860 bunların 84'ünü katalog içi kanıtla onarmış, kalanı için
--  "doğrusu ürünün kendi formülünden gelmeli" denmişti. Bu dosya o
--  bilgiyi ÜRÜNLERİN KISA ÜRÜN BİLGİSİ'nden (KÜB/KT) alarak uygular.
--
--  ============ KAYNAK ================================================
--  Her ürün ailesi için KÜB / kullanma talimatı "kalitatif ve kantitatif
--  bileşim" bölümü okundu (TİTCK arşivi ve KÜB yayınlayan kaynaklar).
--  Sadece ETKİN MADDE ADLARI yazıldı; DERİŞİM/MİKTAR yazılmadı - alan
--  ad listesi tutar, derişim ürün adında zaten var ("%1,5 GLUKOZ").
--
--    BALANCE, CAPD (periton diyaliz)   kalsiyum klorür dihidrat, sodyum
--        klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat,
--        glukoz monohidrat
--    MULTIBIC (hemofiltrasyon)         + sodyum hidrojen karbonat, anhidr
--        glukoz; "POTASYUMSUZ" olanda potasyum klorür YOK
--    Laktatlı Ringer (NEOFLEKS, I.E)   sodyum klorür, potasyum klorür,
--        kalsiyum klorür dihidrat, sodyum laktat ( %5 dekstrozlu olanda
--        ayrıca dekstroz monohidrat)
--    NEOFLEKS dengeli elektrolit       + sodyum asetat trihidrat, sodyum
--        sitrat dihidrat, magnezyum klorür
--    IZOMIX 1/3 - 1/4                  dekstroz monohidrat, sodyum klorür
--    TYLOL HOT / HOT D / PEDİATRİK,
--    GRIBEX HOT / HOT D / PEDİATRİK    parasetamol, psödoefedrin
--        hidroklorür, klorfeniramin maleat  (TYLOL COLD şurupta AYRICA
--        dekstrometorfan hidrobromür - şurubun KÜB'ü dört madde yazıyor)
--    KABIVEN / SMOF KABIVEN / AMINOMIX aminoasit karışımı + glukoz +
--        elektrolitler (+ SMOF'ta dörtlü lipid: soya, MCT, zeytinyağı,
--        balık yağı). 15-18 aminoasidin tamamı alana sığmadığı için
--        KÜB'ün kullandığı üst başlık yazıldı.
--    FRESELAMIN                        KÜB'deki 15 aminoasit tek tek
--    INTRALIPID / SMOFLIPID / OMEGAVEN lipid kaynakları
--    VITALIPID / SOLUVIT               yağda / suda çözünen vitaminler
--    GELOFUSINE / HAEMACCEL            süksinile jelatin / poligelin
--    MAFLOR                            Bifidobacterium animalis ssp.
--                                      lactis B94
--
--  ============ ONARILMAYAN 121 SATIR =================================
--  KÜB'üne bu ortamdan ulaşılamayan ya da bileşimi ürüne göre değişen
--  aileler olduğu gibi bırakıldı: BIOPERITONAL/PERIT.DIA, RENDIALIZAT ve
--  diğer hemodiyaliz konsantreleri, ISOBAL/PF/ISOSOL-P, NEFRASİN /
--  NEPHROTECT / PERİFERAMİN / AMINOVEN / GLUKOZ-1100, KETOSTERİL / EAS,
--  LIBENTA, KREON / MULTANZIM / PANKREON, BRONCHO-VAXOM / BRONCHO-MUNAL,
--  NANOGAM / PENTAGLOBIN / RONSENGLOB, TANTUM / PERİMEX / HEXADAMIN /
--  PİRALDYNE, CANTHACUR / PODOFILM, vitamin-mineral karışımları,
--  JEVITY / SIMILAC / PREKUNIL, BENZAPEN / IECILLINE, FUNGOID, KANSİLAK /
--  LIBALAKS, ANTIDOT, AMETIK / VOMITIN / VOSELMIT, FENOKODIN, BRONKOFLU
--  ve tek satırlık soğuk algınlığı ürünleri. Bunlar için tahmin
--  yürütülmedi.
--
--  ============ GÜVENLİK ==============================================
--  · Etkilenen satırlar `ilac_etken_yedek_861` tablosuna kopyalanır.
--  · Güncelleme hem ID hem ESKİ METNİ eşleştirir; ikinci çalıştırma
--    0 satır günceller. `ilac` TİTCK'ten aktarılan katalogdur; yeni
--    aktarım satırları eski haline döndürürse dosya yeniden çalıştırılır.
-- ============================================================================
\set ON_ERROR_STOP on
begin;

create table if not exists public.ilac_etken_yedek_861 (
    id           integer primary key,
    etken_madde  character varying(300) not null,
    yedek_tarihi timestamptz not null default now()
);

with d(id, eski, yeni) as (values
    (837, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler'),
    (838, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler'),
    (839, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler'),
    (840, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler'),
    (841, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler'),
    (842, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler'),
    (1698, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1699, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1700, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1701, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1702, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1703, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1704, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1705, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1706, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1707, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1708, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1709, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1710, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1711, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1712, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1713, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1714, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1715, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1716, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1717, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1718, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1719, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1720, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1721, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1722, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1723, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1724, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1725, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (1726, 'hypertonic solutions', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2618, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2619, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2620, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2621, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2622, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2623, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2624, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2625, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2626, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2627, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2628, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2629, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2630, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2631, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2632, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2633, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2634, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2635, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2636, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (2637, 'peritoneal dialytics', 'kalsiyum klorür dihidrat, sodyum klorür, sodyum (S)-laktat, magnezyum klorür hekzahidrat, glukoz monohidrat'),
    (5918, 'amino acids', 'l-izolösin, l-lösin, l-lizin, l-metiyonin, l-fenilalanin, l-treonin, l-triptofan, l-valin, l-alanin, l-arjinin, l-histidin, l-prolin, l-serin, glisin, l-sistein'),
    (5919, 'amino acids', 'l-izolösin, l-lösin, l-lizin, l-metiyonin, l-fenilalanin, l-treonin, l-triptofan, l-valin, l-alanin, l-arjinin, l-histidin, l-prolin, l-serin, glisin, l-sistein'),
    (5920, 'amino acids', 'l-izolösin, l-lösin, l-lizin, l-metiyonin, l-fenilalanin, l-treonin, l-triptofan, l-valin, l-alanin, l-arjinin, l-histidin, l-prolin, l-serin, glisin, l-sistein'),
    (5921, 'amino acids', 'l-izolösin, l-lösin, l-lizin, l-metiyonin, l-fenilalanin, l-treonin, l-triptofan, l-valin, l-alanin, l-arjinin, l-histidin, l-prolin, l-serin, glisin, l-sistein'),
    (5922, 'amino acids', 'l-izolösin, l-lösin, l-lizin, l-metiyonin, l-fenilalanin, l-treonin, l-triptofan, l-valin, l-alanin, l-arjinin, l-histidin, l-prolin, l-serin, glisin, l-sistein'),
    (5923, 'amino acids', 'l-izolösin, l-lösin, l-lizin, l-metiyonin, l-fenilalanin, l-treonin, l-triptofan, l-valin, l-alanin, l-arjinin, l-histidin, l-prolin, l-serin, glisin, l-sistein'),
    (6135, 'gelatin agents', 'süksinile jelatin, sodyum klorür'),
    (6136, 'gelatin agents', 'süksinile jelatin, sodyum klorür'),
    (6460, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (6461, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (6462, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (6463, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (6464, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (6465, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (6466, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (6467, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (6468, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (6524, 'gelatin agents', 'poligelin'),
    (6760, 'electrolytes', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat, sodyum laktat'),
    (6761, 'electrolytes', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat, sodyum laktat'),
    (7067, 'fat emulsions', 'rafine soya yağı'),
    (7068, 'fat emulsions', 'rafine soya yağı'),
    (7069, 'fat emulsions', 'rafine soya yağı'),
    (7070, 'fat emulsions', 'rafine soya yağı'),
    (7256, 'electrolytes with carbohydrates', 'dekstroz monohidrat, sodyum klorür'),
    (7257, 'electrolytes with carbohydrates', 'dekstroz monohidrat, sodyum klorür'),
    (7262, 'electrolytes with carbohydrates', 'dekstroz monohidrat, sodyum klorür'),
    (7263, 'electrolytes with carbohydrates', 'dekstroz monohidrat, sodyum klorür'),
    (7370, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler, rafine soya yağı'),
    (7371, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler, rafine soya yağı'),
    (7372, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler, rafine soya yağı'),
    (7373, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler, rafine soya yağı'),
    (7374, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler, rafine soya yağı'),
    (7375, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler, rafine soya yağı'),
    (7376, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler, rafine soya yağı'),
    (8885, 'lactic acid producing organisms', 'bifidobacterium animalis ssp. lactis b94'),
    (8886, 'lactic acid producing organisms', 'bifidobacterium animalis ssp. lactis b94'),
    (8887, 'lactic acid producing organisms', 'bifidobacterium animalis ssp. lactis b94'),
    (8888, 'lactic acid producing organisms', 'bifidobacterium animalis ssp. lactis b94'),
    (9897, 'hemofiltrates', 'kalsiyum klorür dihidrat, magnezyum klorür hekzahidrat, anhidr glukoz, sodyum klorür, sodyum hidrojen karbonat, potasyum klorür'),
    (9898, 'hemofiltrates', 'kalsiyum klorür dihidrat, magnezyum klorür hekzahidrat, anhidr glukoz, sodyum klorür, sodyum hidrojen karbonat, potasyum klorür'),
    (9899, 'hemofiltrates', 'kalsiyum klorür dihidrat, magnezyum klorür hekzahidrat, anhidr glukoz, sodyum klorür, sodyum hidrojen karbonat, potasyum klorür'),
    (9900, 'hemofiltrates', 'kalsiyum klorür dihidrat, magnezyum klorür hekzahidrat, anhidr glukoz, sodyum klorür, sodyum hidrojen karbonat, potasyum klorür'),
    (9901, 'hemofiltrates', 'kalsiyum klorür dihidrat, magnezyum klorür hekzahidrat, anhidr glukoz, sodyum klorür, sodyum hidrojen karbonat, potasyum klorür'),
    (9902, 'hemofiltrates', 'kalsiyum klorür dihidrat, magnezyum klorür hekzahidrat, anhidr glukoz, sodyum klorür, sodyum hidrojen karbonat, potasyum klorür'),
    (9903, 'hemofiltrates', 'kalsiyum klorür dihidrat, magnezyum klorür hekzahidrat, anhidr glukoz, sodyum klorür, sodyum hidrojen karbonat'),
    (9904, 'hemofiltrates', 'kalsiyum klorür dihidrat, magnezyum klorür hekzahidrat, anhidr glukoz, sodyum klorür, sodyum hidrojen karbonat'),
    (10228, 'electrolytes with carbohydrates', 'dekstroz monohidrat, sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat, sodyum laktat'),
    (10229, 'electrolytes with carbohydrates', 'dekstroz monohidrat, sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat, sodyum laktat'),
    (10230, 'electrolytes with carbohydrates', 'dekstroz monohidrat, sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat, sodyum laktat'),
    (10231, 'electrolytes with carbohydrates', 'dekstroz monohidrat, sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat, sodyum laktat'),
    (10258, 'electrolytes', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat, sodyum laktat'),
    (10259, 'electrolytes', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat, sodyum laktat'),
    (10260, 'electrolytes', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat, sodyum laktat'),
    (10261, 'electrolytes', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat, sodyum laktat'),
    (10262, 'electrolytes', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat, sodyum laktat'),
    (10263, 'electrolytes', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat, sodyum laktat'),
    (11098, 'fat emulsions', 'balık yağı (omega-3 asitleri)'),
    (14440, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler, rafine soya yağı, orta zincirli trigliseritler, zeytinyağı, balık yağı'),
    (14441, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler, rafine soya yağı, orta zincirli trigliseritler, zeytinyağı, balık yağı'),
    (14442, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler, rafine soya yağı, orta zincirli trigliseritler, zeytinyağı, balık yağı'),
    (14443, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler, rafine soya yağı, orta zincirli trigliseritler, zeytinyağı, balık yağı'),
    (14444, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler, rafine soya yağı, orta zincirli trigliseritler, zeytinyağı, balık yağı'),
    (14445, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler, rafine soya yağı, orta zincirli trigliseritler, zeytinyağı, balık yağı'),
    (14446, 'combinations', 'aminoasit karışımı, glukoz, elektrolitler, rafine soya yağı, orta zincirli trigliseritler, zeytinyağı, balık yağı'),
    (14447, 'fat emulsions', 'rafine soya yağı, orta zincirli trigliseritler, zeytinyağı, balık yağı'),
    (14448, 'fat emulsions', 'rafine soya yağı, orta zincirli trigliseritler, zeytinyağı, balık yağı'),
    (14488, 'vitamins', 'tiamin, riboflavin, nikotinamid, piridoksin, sodyum pantotenat, sodyum askorbat, biotin, folik asit, siyanokobalamin'),
    (15773, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat, dekstrometorfan hidrobromür'),
    (15778, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (15779, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (15780, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (15782, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (15783, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (15784, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (15785, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (15786, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (15787, 'other cold preparations', 'parasetamol, psödoefedrin hidroklorür, klorfeniramin maleat'),
    (16459, 'vitamins', 'a vitamini, d2 vitamini, e vitamini, k1 vitamini'),
    (16460, 'vitamins', 'a vitamini, d2 vitamini, e vitamini, k1 vitamini')
)
, y as (
    insert into public.ilac_etken_yedek_861 (id, etken_madde)
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
    select count(*) into v_yedek from public.ilac_etken_yedek_861;
    raise notice '861 tamam: KUB ile onarilan % satir.', v_yedek;
end $$;

commit;
