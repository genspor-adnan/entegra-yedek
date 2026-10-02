-- =====================================================================
--  936_muayene_bulgu_onerileri.sql
--  BULGU KUTUSUNA ÖNERİ LİSTESİ (kullanıcı: "bulgulara combo ekle, uygun
--  seçenekler de olsun").
--
--  Şablon alanına `oneriler` (jsonb metin dizisi) eklenir. Bulgu kutusu
--  açılır liste olur: öneriden SEÇİLİR ya da SERBEST yazılır - öneri bir
--  kısıt değildir (tip 3 "seçenekli" alanın `secenekler`inden farkı bu;
--  ekran ikisini birlikte kullanır: coalesce(oneriler, secenekler)).
--
--  Tohum: var olan şablonlardaki serbest metin (tip 1) alanlara, alan
--  ADINA göre yaygın muayene bulguları. YALNIZ `oneriler` boş olan alanlar
--  doldurulur - elle girilmiş liste ezilmez. Ad birden çok desene uyarsa
--  öncelik sırası küçük olan kazanır ("genel deri" > "genel").
--  İdempotent: tekrar çalışınca dolu alanlara dokunmaz.
-- =====================================================================
\set ON_ERROR_STOP on

alter table public.muayene_sablon_alan
  add column if not exists oneriler jsonb;

comment on column public.muayene_sablon_alan.oneriler is
  'Bulgu kutusunun öneri listesi (metin dizisi). Kısıt değil - hekim serbest de yazar.';

with desen(oncelik, kalip, oneriler) as (values
  (10, '%genel deri%',      '["Doğal","Döküntü yok","Makülopapüler döküntü","Peteşi / purpura","Ürtiker","Sarılık","Solukluk","Siyanoz"]'::jsonb),
  (11, '%cilt%',            '["Doğal","Döküntü yok","Makülopapüler döküntü","Peteşi / purpura","Ürtiker","Sarılık","Solukluk","Siyanoz"]'::jsonb),
  (12, '%deri%',            '["Doğal","Döküntü yok","Makülopapüler döküntü","Peteşi / purpura","Ürtiker","Sarılık","Solukluk"]'::jsonb),
  (20, '%genel görünüm%',   '["Genel durum iyi, bilinç açık, koopere","Genel durum orta","Genel durum kötü","Soluk, terli","Ajite","Letarjik","Dehidrate görünümde"]'::jsonb),
  (21, '%genel durum%',     '["İyi","Orta","Kötü","Bilinç açık, koopere, oryante","Letarjik","Ajite"]'::jsonb),
  (30, '%baş-boyun%',       '["Doğal, LAP yok","Servikal LAP (+)","Tiroid büyük","Ense sertliği (+)","Boyun hareketleri kısıtlı"]'::jsonb),
  (31, '%boyun%',           '["LAP yok, tiroid doğal","Servikal LAP (+)","Tiroid büyük","Ense sertliği (+)","JVD (+)"]'::jsonb),
  (40, '%solunum%',         '["Bilateral eşit, ral-ronküs yok","Bazallerde ince raller","Ronküs (+)","Wheezing (+)","Solunum sesleri azalmış","Ekspiryum uzun","Takipneik"]'::jsonb),
  (41, '%akciğer%',         '["Bilateral eşit, ral-ronküs yok","Bazallerde ince raller","Ronküs (+)","Wheezing (+)","Solunum sesleri azalmış"]'::jsonb),
  (50, '%kardiyovask%',     '["S1 S2 ritmik, üfürüm yok","Taşikardik","Bradikardik","Aritmik","Sistolik üfürüm (+)","Diyastolik üfürüm (+)","Periferik nabızlar alınıyor"]'::jsonb),
  (51, '%kalp%',            '["S1 S2 ritmik, üfürüm yok","Taşikardik","Bradikardik","Aritmik","Üfürüm (+)"]'::jsonb),
  (60, '%batın%',           '["Rahat, defans-rebound yok, organomegali yok","Hassasiyet (+)","Defans (+)","Rebound (+)","Hepatomegali","Splenomegali","Distansiyon","Barsak sesleri azalmış"]'::jsonb),
  (61, '%karın%',           '["Rahat, hassasiyet yok","Hassasiyet (+)","Defans (+)","Distansiyon"]'::jsonb),
  (70, '%ekstremite%',      '["Ödem yok, nabızlar açık","Pretibial ödem (+)","Siyanoz yok","Çomak parmak","Varis","Eklem hassasiyeti (+)"]'::jsonb),
  (80, '%nörolojik%',       '["Kaba nörolojik defisit yok","Bilinç açık, oryante, lateralizan bulgu yok","Pupiller izokorik, IR +/+","Ense sertliği yok","Kuvvet kaybı (+)","Konfüzyon"]'::jsonb),
  (90, '%ödem%',            '["Yok","Bilateral pretibial ödem","Sağ alt ekstremitede","Sol alt ekstremitede","Jeneralize ödem","Periorbital ödem"]'::jsonb),
  (100, '%öksürük%',        '["Yok","Kuru öksürük","Prodüktif, beyaz balgam","Pürülan balgam","Hemoptizi"]'::jsonb),
  (110, '%dispne%',         '["Yok","Eforla","İstirahatte","Ortopne","Paroksismal noktürnal dispne"]'::jsonb),
  (120, '%kaşıntı%',        '["Yok","Lokalize","Yaygın","Gece artan"]'::jsonb),
  (130, '%ağrı%',           '["Yok","Hafif (VAS 1-3)","Orta (VAS 4-6)","Şiddetli (VAS 7-10)"]'::jsonb),
  (140, '%kulak%',          '["Dış kulak yolu açık, zar intakt","Zar hiperemik","Zar bombe","Buşon","Akıntı (+)"]'::jsonb),
  (150, '%burun%',          '["Septum orta hatta, mukoza doğal","Septum deviasyonu","Konka hipertrofisi","Mukoza hiperemik","Akıntı (+)"]'::jsonb),
  (160, '%orofarenks%',     '["Hiperemi yok, tonsiller doğal","Farenks hiperemik","Tonsiller hipertrofik","Tonsillerde eksüda","Postnazal akıntı"]'::jsonb),
  (161, '%boğaz%',          '["Hiperemi yok, tonsiller doğal","Farenks hiperemik","Tonsiller hipertrofik","Tonsillerde eksüda"]'::jsonb),
  (170, '%göz%',            '["Doğal","Pupiller izokorik, IR +/+","Konjonktiva hiperemik","Sklera ikterik","Konjonktiva soluk"]'::jsonb),
  (180, '%palpasyon%',      '["Hassasiyet yok","Lokal hassasiyet (+)","Kitle palpe edilmedi","Kitle palpe edildi"]'::jsonb),
  (190, '%hareket açıklığı%','["Tam ve ağrısız","Ağrılı, tam","Kısıtlı","Ağrılı ve kısıtlı"]'::jsonb),
  (200, '%nörovasküler%',   '["Distal nabız-duyu-motor açık","Distal nabız zayıf","Duyu kaybı (+)","Motor kayıp (+)"]'::jsonb),
  (210, '%lokalizasyon%',   '["Yüz","Gövde","Üst ekstremite","Alt ekstremite","Yaygın"]'::jsonb),
  (220, '%genital%',        '["Doğal","Lezyon (+)","Akıntı (+)"]'::jsonb),
  (230, '%meme%',           '["Doğal, kitle yok","Kitle palpe edildi","Meme başı akıntısı","Cilt değişikliği"]'::jsonb),
  (240, '%lenf%',           '["LAP yok","Servikal LAP","Aksiller LAP","İnguinal LAP","Jeneralize LAP"]'::jsonb)
),
eslesen as (
  select distinct on (a.id) a.id, d.oneriler
    from public.muayene_sablon_alan a
    join desen d on lower(a.ad) like d.kalip
   where a.oneriler is null
     and a.tip = 1
   order by a.id, d.oncelik
)
update public.muayene_sablon_alan a
   set oneriler = e.oneriler
  from eslesen e
 where a.id = e.id;

-- Rapor: kaç alana öneri girdi, hangileri öneri almadı (bilgi).
select count(*) filter (where oneriler is not null) as onerili_alan,
       count(*) filter (where oneriler is null and tip = 1) as onerisiz_metin_alan
  from public.muayene_sablon_alan;
