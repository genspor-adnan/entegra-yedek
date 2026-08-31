-- 307: Hekim unvan listesinde Op.Dr.'yi Dr.'nin ALTINA al (kullanici).
--
-- 306'da Op.Dr. sonradan eklendigi icin listenin SONUNDA duruyordu; en cok
-- kullanilan iki unvan (Dr. ve Op.Dr.) yan yana olsun - combo acildiginda
-- asagi kaydirmadan secilebilsin.
--
-- Kod DEGERLERI degismez (kayitli hekimlerin unvani metin olarak
-- taraf.unvan'da duruyor, deger degil ad kullaniliyor) - yalniz SIRA.

update public.kod_deger d
   set sira = v.sira
  from public.kod_liste l,
       (values ('Dr.', 1), ('Op.Dr.', 2), ('Uzm.Dr.', 3), ('Doç.Dr.', 4),
               ('Prof.Dr.', 5), ('Dt.', 6), ('Dr.Dt.', 7)) as v(ad, sira)
 where d.liste_id = l.id and l.kod = 'hekim.unvan' and d.ad = v.ad;
