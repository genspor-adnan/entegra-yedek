-- =====================================================================
--  937_muayene_bulgu_onerileri_tamamla.sql
--  KALAN BULGU ALANLARINA ÖNERİ (kullanıcı: "şablon ayarlarında tüm
--  bulgulara seçenekler ekle").
--
--  936 desenle yaygın sistemleri doldurmuştu; branşa özel alanlar (göz,
--  psikiyatri, nöroloji, kadın doğum, anestezi...) boş kalmıştı. Burada
--  alan ADINA birebir eşleşen öneri listeleri. Sayısal (tip 2) ve var/yok
--  (tip 4) alanlara da sık değerler önerilir - bulgu kutusu her tipte
--  metin girer. Vücut şeması (tip 5) kendi penceresiyle girilir, atlanır.
--
--  YALNIZ `oneriler` boş VE seçenek listesi olmayan alanlar doldurulur -
--  elle girilmiş liste ezilmez. İdempotent.
-- =====================================================================
\set ON_ERROR_STOP on

with liste(ad, oneriler) as (values
  -- anamnez / sistem sorgusu
  ('Başvuru şikâyeti',            '["Ateş","Öksürük","Karın ağrısı","Baş ağrısı","Göğüs ağrısı","Halsizlik","Bulantı-kusma","İshal","Nefes darlığı","Kontrol"]'::jsonb),
  ('Şikâyet süresi',              '["Bugün başladı","1-3 gün","1 hafta","2-4 hafta","1-3 ay","3 aydan uzun","Yıllardır"]'::jsonb),
  ('Özgeçmiş',                    '["Özellik yok","DM","HT","KAH","KOAH / Astım","Böbrek yetmezliği","Operasyon öyküsü var"]'::jsonb),
  ('Soygeçmiş',                   '["Özellik yok","Ailede DM","Ailede HT","Ailede KAH","Ailede kanser","Ailede erken ölüm"]'::jsonb),
  ('Kullandığı ilaçlar',          '["Yok","Antihipertansif","Oral antidiyabetik","İnsülin","Antikoagülan","Antiagregan","Statin"]'::jsonb),
  ('Ateş / kilo kaybı / halsizlik','["Yok","Ateş (+)","Kilo kaybı (+)","Halsizlik (+)","Gece terlemesi (+)"]'::jsonb),
  ('Bulantı / kusma / dışkılama', '["Yok, dışkılama normal","Bulantı (+)","Kusma (+)","İshal","Kabızlık","Melena","Hematokezya"]'::jsonb),
  ('İdrar yakınması',             '["Yok","Dizüri","Pollaküri","Noktüri","Hematüri","Retansiyon","İnkontinans"]'::jsonb),
  -- genel fizik muayene
  ('Batin',                       '["Rahat, defans-rebound yok, organomegali yok","Hassasiyet (+)","Defans (+)","Rebound (+)","Hepatomegali","Splenomegali","Distansiyon"]'::jsonb),
  ('Genitouriner',                '["Doğal","KVA hassasiyeti yok","KVA hassasiyeti (+)","Suprapubik hassasiyet (+)","Glob vezikale"]'::jsonb),
  ('Genitoüriner',                '["Doğal","KVA hassasiyeti yok","KVA hassasiyeti (+)","Suprapubik hassasiyet (+)","Glob vezikale"]'::jsonb),
  ('Kas - Iskelet',               '["Doğal","Eklem hassasiyeti yok","Eklem şişliği (+)","Hareket kısıtlılığı","Kas güçsüzlüğü","Deformite"]'::jsonb),
  ('Norolojik',                   '["Kaba nörolojik defisit yok","Bilinç açık, oryante, lateralizan bulgu yok","Pupiller izokorik, IR +/+","Kuvvet kaybı (+)","Konfüzyon"]'::jsonb),
  -- acil
  ('Hava yolu',                   '["Açık","Açık, korunuyor","Tehdit altında","Entübe","Hava yolu desteği gerekli"]'::jsonb),
  ('Dolaşım',                     '["Stabil, periferik nabızlar alınıyor","Taşikardik","Hipotansif","Kapiller dolum > 2 sn","Soğuk, nemli cilt"]'::jsonb),
  ('Lokal muayene',               '["Doğal","Hassasiyet (+)","Ödem (+)","Ekimoz","Laserasyon","Deformite","Krepitasyon"]'::jsonb),
  -- nöroloji / ftr
  ('Bilinç / oryantasyon',        '["Bilinç açık, kişi-yer-zaman oryante","Konfüze","Letarjik","Stupor","Koma","Dezoryante"]'::jsonb),
  ('Kranial sinirler',            '["Doğal","Fasiyal asimetri (+)","Göz hareketleri kısıtlı","Pupiller anizokorik","Disfaji","Dizartri"]'::jsonb),
  ('Motor',                       '["Kas gücü tam (5/5)","Sağ hemiparezi","Sol hemiparezi","Paraparezi","Proksimal güçsüzlük","Distal güçsüzlük"]'::jsonb),
  ('Duyu',                        '["Doğal","Hipoestezi (+)","Parestezi (+)","Eldiven-çorap tarzı duyu kaybı","Dermatomal duyu kaybı"]'::jsonb),
  ('Duyu muayenesi',              '["Doğal","Hipoestezi (+)","Parestezi (+)","Dermatomal duyu kaybı"]'::jsonb),
  ('Refleksler',                  '["DTR normoaktif, simetrik","Hiperaktif","Hipoaktif","Alınamıyor","Babinski (+)"]'::jsonb),
  ('Serebellar / koordinasyon',   '["Doğal","Dismetri (+)","Disdiadokokinezi (+)","Ataksik yürüyüş","Romberg (+)","Nistagmus (+)"]'::jsonb),
  ('Postür / yürüyüş',            '["Doğal","Antaljik yürüyüş","Ataksik","Hemiparetik","Kifoz","Skolyoz","Lordoz artmış"]'::jsonb),
  -- psikiyatri
  ('Duygudurum / afekt',          '["Ötimik, afekt uygun","Depresif","Anksiyöz","Disforik","Öforik","Afekt künt","Afekt labil"]'::jsonb),
  ('Düşünce içerik/akış',         '["Doğal, amaca yönelik","Obsesyon (+)","Hezeyan (+)","Ölüm düşünceleri","Düşünce akışı hızlanmış","Düşünce akışı yavaşlamış"]'::jsonb),
  ('Algı',                        '["Varsanı yok","İşitsel varsanı (+)","Görsel varsanı (+)","İllüzyon"]'::jsonb),
  ('İçgörü / yargılama',          '["Tam","Kısmi","Yok"]'::jsonb),
  -- göz
  ('Görme keskinliği',            '["Sağ 1,0 / Sol 1,0","Sağ 0,8 / Sol 0,8","Sağ 0,5 / Sol 0,5","Parmak sayma","El hareketi","Işık hissi","Işık hissi yok"]'::jsonb),
  ('Kapak / konjonktiva',         '["Doğal","Konjonktival hiperemi","Ptozis","Blefarit","Şalazyon","Subkonjonktival hemoraji"]'::jsonb),
  ('Kornea',                      '["Saydam","Ödem","Erozyon","Opasite","Yabancı cisim"]'::jsonb),
  ('Ön kamara',                   '["Derin, sakin","Sığ","Hücre (+)","Hifema","Hipopiyon"]'::jsonb),
  ('Fundus',                      '["Doğal","Diyabetik retinopati","Hipertansif retinopati","Papil ödemi","Makula dejenerasyonu","Değerlendirilemedi"]'::jsonb),
  -- kadın doğum / üroloji / cerrahi
  ('Spekulum',                    '["Doğal","Akıntı (+)","Servikal erozyon","Polip","Kanama (+)"]'::jsonb),
  ('Bimanuel',                    '["Doğal","Uterus büyük","Adneksiyal kitle (+)","Servikal hareket hassasiyeti (+)"]'::jsonb),
  ('Pelvik muayene',              '["Doğal","Akıntı (+)","Hassasiyet (+)","Kitle (+)","Prolapsus"]'::jsonb),
  ('Rektal (prostat)',            '["Doğal boyut, düzgün yüzeyli","Büyümüş, elastik","Nodül (+)","Sert","Hassasiyet (+)"]'::jsonb),
  ('Rektal tuşe',                 '["Doğal","Hemoroid","Fissür","Kitle (+)","Gaita melena","Ampulla boş"]'::jsonb),
  ('Herni muayenesi',             '["Herni yok","İnguinal herni (sağ)","İnguinal herni (sol)","Umbilikal herni","İnsizyonel herni","Redükte edilebilir"]'::jsonb),
  ('İnspeksiyon',                 '["Doğal","Şişlik (+)","Kızarıklık (+)","Deformite","Skar","Asimetri"]'::jsonb),
  ('Etkilenen taraf/bölge',       '["Sağ","Sol","Bilateral","Üst ekstremite","Alt ekstremite","Omurga"]'::jsonb),
  -- endokrin / nefroloji / pediatri
  ('Tiroid',                      '["Doğal, palpe edilmiyor","Diffüz büyük","Nodül (+)","Hassasiyet (+)"]'::jsonb),
  ('Diyabetik ayak',              '["Lezyon yok, nabızlar açık","Nöropati (+)","Ülser (+)","Enfeksiyon bulgusu","Nabız zayıf","Deformite"]'::jsonb),
  ('AV fistül / kateter',         '["Fistül çalışıyor, thrill (+)","Thrill alınamıyor","Kateter yeri temiz","Kateter yerinde akıntı / kızarıklık"]'::jsonb),
  ('Büyüme (persentil)',          '["3-97 persentil arası, uyumlu","< 3 persentil","> 97 persentil","Persentil kayması (+)"]'::jsonb),
  ('Nöromotor gelişim',           '["Yaşına uygun","Gecikme (+)","Motor gelişim geriliği","Konuşma gecikmesi"]'::jsonb),
  -- sayısal (tip 2)
  ('Açlık süresi',                '["6 saat","8 saat","12 saat","Aç değil"]'::jsonb),
  ('Ağız açıklığı',               '["3 parmak ve üzeri","2 parmak","1 parmak"]'::jsonb),
  ('Ağrı (VAS)',                  '["0","1-3 (hafif)","4-6 (orta)","7-10 (şiddetli)"]'::jsonb),
  ('Göğüs ağrısı (VAS)',          '["0","1-3 (hafif)","4-6 (orta)","7-10 (şiddetli)"]'::jsonb),
  ('Bel çevresi',                 '["< 80 cm","80-94 cm","94-102 cm","> 102 cm"]'::jsonb),
  ('Glasgow Koma Skalası',        '["15","14","13","9-12","8 ve altı"]'::jsonb),
  ('Göz içi basıncı',             '["Sağ 15 / Sol 15 mmHg","Normal (10-21 mmHg)","Yüksek (> 21 mmHg)"]'::jsonb),
  ('SpO₂',                        '["%98","%95","%92","%90","< %90"]'::jsonb),
  -- var / yok (tip 4)
  ('Akantozis nigrikans',         '["Yok","Var - boyun","Var - aksiller"]'::jsonb),
  ('Antikoagülan kullanımı',      '["Yok","Varfarin","Yeni oral antikoagülan","Düşük molekül ağırlıklı heparin","Kesildi"]'::jsonb),
  ('Ekzoftalmi',                  '["Yok","Var - bilateral","Var - tek taraflı"]'::jsonb),
  ('Hepatomegali',                '["Yok","Var - kot altı 2 cm","Var - kot altı 4 cm ve üzeri"]'::jsonb),
  ('Hirsutizm',                   '["Yok","Hafif","Orta","Belirgin"]'::jsonb),
  ('Juguler venöz dolgunluk',     '["Yok","Var","45° de belirgin"]'::jsonb),
  ('Kaşıntı',                     '["Yok","Lokalize","Yaygın","Gece artan"]'::jsonb),
  ('Kitle / organomegali',        '["Yok","Hepatomegali","Splenomegali","Batında kitle palpe edildi"]'::jsonb),
  ('Kostovertebral açı hassasiyeti','["Yok","Sağda (+)","Solda (+)","Bilateral (+)"]'::jsonb),
  ('Sarılık (ikter)',             '["Yok","Skleral ikter","Cilt + skleral ikter"]'::jsonb),
  ('Splenomegali',                '["Yok","Var - kot altı 2 cm","Var - belirgin"]'::jsonb),
  ('Travma bulgusu',              '["Yok","Ekimoz","Abrazyon","Laserasyon","Deformite","Hematom"]'::jsonb)
)
update public.muayene_sablon_alan a
   set oneriler = l.oneriler
  from liste l
 where a.ad = l.ad
   and a.oneriler is null
   and (a.secenekler is null or jsonb_array_length(a.secenekler) = 0)
   and a.tip <> 5;

-- Rapor: hâlâ önerisi olmayan alanlar (vücut şeması hariç).
select a.ad, a.tip
  from public.muayene_sablon_alan a
 where a.oneriler is null
   and (a.secenekler is null or jsonb_array_length(a.secenekler) = 0)
   and a.tip <> 5
 order by a.ad;
