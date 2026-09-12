-- =====================================================================
--  582_dis_hekim_brans_duzeltme.sql
--  581'in iki yanlış eşleşmesi düzeltilir.
--
--  581 eşleşenler içinden EN KISA adı seçiyordu; bu iki dalda en kısa ad
--  yan dal oldu:
--    Endokrin ve Metabolizma Hastalıkları -> "Endokrinoloji Yoğun Bakım"
--        (doğrusu "Endokrinoloji ve Metabolizma Hastalıkları")
--    Patoloji                             -> "Sitopatoloji"
--        (doğrusu "Tıbbi Patoloji")
--  Yoğun bakım / sito- yan dallardır, bölümün ana branşı değil.
--
--  Yalnız o iki yanlış değeri taşıyan DIŞ hekim satırına dokunur.
-- =====================================================================

update public.taraf t
   set gorev_id = g.id
  from public.personel_gorev g, public.taraf_personel p, public.departman d
 where p.id = t.id and p.dis_hekim = 1 and d.id = t.departman
   and public.fn_ara_metin(d.ad) = 'endokrin ve metabolizma hastaliklari'
   and public.fn_ara_metin(g.ad) = 'endokrinoloji ve metabolizma hastaliklari'
   and t.gorev_id <> g.id;

update public.taraf t
   set gorev_id = g.id
  from public.personel_gorev g, public.taraf_personel p, public.departman d
 where p.id = t.id and p.dis_hekim = 1 and d.id = t.departman
   and public.fn_ara_metin(d.ad) = 'patoloji'
   and public.fn_ara_metin(g.ad) = 'tibbi patoloji'
   and t.gorev_id <> g.id;
