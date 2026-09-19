-- ============================================================================
--  Gentegre AI — SON TEMİZLİK: EKSİK ÇEVİRİLER + TÜRKÇE SINIF METNİ (863)
--  863_ilac_son_temizlik.sql
--
--  Kullanıcı: *"ikisini de tek dosyada topla"*. 862 raporunda kalan iki
--  açık nokta bu dosyada birlikte kapatılıyor. Dosya İKİ BÖLÜMDÜR:
--    (A) sözlük eklemesi  - `ceviri` tablosu, veriye dokunmaz
--    (B) veri onarımı     - `ilac.etken_madde`, yedekli
--
--  ============ (A) İNGİLİZCE GÖRÜNÜMDE KALAN TÜRKÇE SÖZCÜKLER =======
--  858-862 onarımları sözlükte olmayan yeni Türkçe sözcükler getirdi
--  ("lizatı", "süksinile", "protein süksinilat"…). Ayrıca veride
--  NOKTASIZ ı ile yazılmış Roma rakamları var: "faktör Vııı" → VIII.
--  Bu bölüm o boşlukları doldurur; anahtar biçimi 856/857 ile aynı
--  (küçük harf + Türkçe harfler ASCII'ye katlanmış).
--  Kendi kendine eşleyen kayıtlar ("infliximab", "tromethamine") bilerek
--  var: veride noktalı İ / noktasız ı ile yazılmışlar, sözlükten geçince
--  ekranda düzgün ASCII yazımla görünüyorlar.
--
--  ============ (B) TÜRKÇE YAZILMIŞ ATC SINIF METNİ ==================
--  860-862 İNGİLİZCE sınıf metinlerini onarmıştı; aynı kusurun TÜRKÇE
--  yazılmışı da varmış ("karbonhidratlar", "elektrolit çözeltisi").
--  Yine YALNIZ İSPATLANABİLİR olanlar onarıldı - bileşim ürün ADINDA
--  yazıyor ve ATC sınıfıyla tutarlı:
--    "% 10 DEKSTROZ SOLUSYONU"        → dekstroz            (B05BA03)
--    "1/6 MOLAR SODYUM LAKTAT"        → sodyum laktat       (B05XA)
--    "I.E. LAKTATLI RINGER"           → Ringer laktat bileşimi (861'de
--        aynı ürünün setli kayıtları zaten bu bileşimle onarılmıştı)
--    "ACE PLUS SELENYUM"              → A, C, E vitaminleri + selenyum
--    ADDAMEL N / ADDAVEN              → eser element karışımı (B05XA31)
--
--  DOKUNULMAYANLAR: ELEVIT/DECAVIT PRONATAL, VİTADYN, ACECAP, ACESCAP,
--  BEHEPTAL, SUPRAVIT, RUBIRON+6, AMİNESS-N, KETOMINO - bunların metni
--  zaten Türkçe ve açıklayıcı ("multivitamin kompleksi"); tam bileşim
--  ürün adından çıkarılamıyor, tahmin yürütülmedi.
--  Ayrıca 862'de bilerek bırakılan 35 satıra (BIOPERITONAL, RENDIALIZAT,
--  DORFAN…) kullanıcı isteğiyle DOKUNULMADI.
--
--  Idempotent: (A) `on conflict do update`, (B) id + eski metin eşleşmesi.
-- ============================================================================
\set ON_ERROR_STOP on
begin;

-- ---------- (A) SOZLUK ----------------------------------------------------
insert into public.ceviri (kapsam, anahtar, dil, metin) values
    ('ilac', 'akarlari', 1, 'mites'),
    ('ilac', 'akarlarinda', 1, 'mites'),
    ('ilac', 'alumniyum', 1, 'aluminium'),
    ('ilac', 'bakteri', 1, 'bacterial'),
    ('ilac', 'cink', 1, 'zinc'),
    ('ilac', 'diger', 1, 'other'),
    ('ilac', 'dihidrokloru', 1, 'dihydrochloride'),
    ('ilac', 'edilmis', 1, 'obtained'),
    ('ilac', 'elde edilmis', 1, 'obtained from'),
    ('ilac', 'element', 1, 'element'),
    ('ilac', 'elementler', 1, 'elements'),
    ('ilac', 'eser', 1, 'trace'),
    ('ilac', 'etilmorfin', 1, 'ethylmorphine'),
    ('ilac', 'hidroklortitazid', 1, 'hydrochlorothiazide'),
    ('ilac', 'ii', 1, 'II'),
    ('ilac', 'iii', 1, 'III'),
    ('ilac', 'ilaclarla', 1, 'with drugs'),
    ('ilac', 'immunglobulin', 1, 'immunoglobulin'),
    ('ilac', 'infliximab', 1, 'infliximab'),
    ('ilac', 'iu', 1, 'IU'),
    ('ilac', 'iv', 1, 'IV'),
    ('ilac', 'ix', 1, 'IX'),
    ('ilac', 'iyodur-131', 1, 'iodide-131'),
    ('ilac', 'kantaridin', 1, 'cantharidin'),
    ('ilac', 'karsi', 1, 'against'),
    ('ilac', 'karsin', 1, 'against'),
    ('ilac', 'klorurdihidrat', 1, 'chloride dihydrate'),
    ('ilac', 'levulinat', 1, 'levulinate'),
    ('ilac', 'lizat', 1, 'lysate'),
    ('ilac', 'lizati', 1, 'lysate'),
    ('ilac', 'multivitamin', 1, 'multivitamin'),
    ('ilac', 'podofillum', 1, 'podophyllum'),
    ('ilac', 'prilamin', 1, 'pyrilamine'),
    ('ilac', 'proteinsuksinilat', 1, 'protein succinylate'),
    ('ilac', 'recine', 1, 'resin'),
    ('ilac', 'recinesi', 1, 'resin'),
    ('ilac', 'seklinde', 1, 'as'),
    ('ilac', 'suksinile', 1, 'succinylated'),
    ('ilac', 'sus-', 1, 'strain-'),
    ('ilac', 'sus-a', 1, 'strain A'),
    ('ilac', 'tavsanlardan', 1, 'from rabbits'),
    ('ilac', 'tiyokol', 1, 'thiocol'),
    ('ilac', 'tromethamine', 1, 'tromethamine'),
    ('ilac', 'venomlarina', 1, 'venoms'),
    ('ilac', 'venomu', 1, 'venom'),
    ('ilac', 'vii', 1, 'VII'),
    ('ilac', 'viia', 1, 'VIIa'),
    ('ilac', 'viii', 1, 'VIII'),
    ('ilac', 'yabanil', 1, 'wild'),
    ('ilac', 'zenginlestirilmis', 1, 'enriched')
on conflict (kapsam, anahtar, dil) do update set metin = excluded.metin,
    degistirme_tarihi = now();

-- ---------- (B) VERI ------------------------------------------------------
create table if not exists public.ilac_etken_yedek_863 (
    id           integer primary key,
    etken_madde  character varying(300) not null,
    yedek_tarihi timestamptz not null default now()
);

with d(id, eski, yeni) as (values
    (10, 'karbonhidratlar', 'dekstroz'),
    (51, 'karbonhidratlar', 'dekstroz'),
    (130, 'karbonhidratlar', 'dekstroz'),
    (133, 'karbonhidratlar', 'dekstroz'),
    (134, 'karbonhidratlar', 'dekstroz'),
    (228, 'elektrolit çözeltisi', 'sodyum laktat'),
    (229, 'elektrolit çözeltisi', 'sodyum laktat'),
    (230, 'elektrolit çözeltisi', 'sodyum laktat'),
    (231, 'elektrolit çözeltisi', 'sodyum laktat'),
    (271, 'vitamin kombinasyonu', 'a vitamini, c vitamini, e vitamini, selenyum'),
    (347, 'diğer ilaçlarla kombine elektrolitler', 'eser element karışımı'),
    (348, 'diğer ilaçlarla kombine elektrolitler', 'eser element karışımı'),
    (6762, 'elektrolitler', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat, sodyum laktat'),
    (6763, 'elektrolitler', 'sodyum klorür, potasyum klorür, kalsiyum klorür dihidrat, sodyum laktat')
)
, y as (
    insert into public.ilac_etken_yedek_863 (id, etken_madde)
    select i.id, i.etken_madde from public.ilac i join d on d.id = i.id
     where i.etken_madde = d.eski
    on conflict (id) do nothing
    returning 1
)
update public.ilac i set etken_madde = d.yeni, guncelleme = now()
  from d where i.id = d.id and i.etken_madde = d.eski;

do $$
declare v_soz integer; v_veri integer;
begin
    select count(*) into v_soz from public.ceviri where dil = 1 and kapsam = 'ilac';
    select count(*) into v_veri from public.ilac_etken_yedek_863;
    raise notice '863 tamam: ilac sozlugu % anahtar, onarilan veri satiri %.', v_soz, v_veri;
end $$;

commit;
