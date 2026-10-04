-- ============================================================================
--  Gentegre AI — PERSONEL AVANSI KARTI
--  960_avans_karti.sql
--
--  Kullanıcı: "Avans talepleri listesinde avans kartı için mockup yap" →
--  "mockup uygun, uygula" (Ekranlar/IK/avans_karti.html).
--
--  1. taraf_personel.net_maas: BORDRO MODÜLÜ YOK - kartın "maaşa oranı"
--     paneli için personel kartında elle girilen aylık net ücret. Boşsa
--     panel oran hesaplamaz, yalnız kesinti tutarlarını gösterir.
--  2. referans `ik.avans_maas_orani` (%): bu avans + diğer açık avansların
--     aylık kesintisi net maaşın bu oranını aşarsa kart uyarır. ENGEL DEĞİL.
--  3. kod listesi `ik.avans_gerekce`: gerekçe seçimli (serbest metin de olur).
--  Yalnız dev docker.
-- ============================================================================

alter table public.taraf_personel add column if not exists net_maas numeric(18,2);

insert into public.referans (anahtar, deger, aciklama)
select 'ik.avans_maas_orani', '25',
       'Avans kartinda aylik kesinti toplami net maasin yuzde kacini asarsa uyarilsin (0 = denetim yok).'
 where not exists (select 1 from public.referans where anahtar = 'ik.avans_maas_orani');

insert into public.kod_liste (kod, ad)
select 'ik.avans_gerekce', 'Avans Gerekçesi'
 where not exists (select 1 from public.kod_liste where kod = 'ik.avans_gerekce');

insert into public.kod_deger (liste_id, deger, ad, dil, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, 0, v.deger, 1, 0
  from (values (1, 'Sağlık gideri'), (2, 'Eğitim / okul'), (3, 'Kira / konut'),
               (4, 'Acil ihtiyaç'), (5, 'Düğün / nişan'), (6, 'Taşınma'), (9, 'Diğer')) v(deger, ad)
  join public.kod_liste l on l.kod = 'ik.avans_gerekce'
 where not exists (select 1 from public.kod_deger x where x.liste_id = l.id and x.deger = v.deger and x.dil = 0);
