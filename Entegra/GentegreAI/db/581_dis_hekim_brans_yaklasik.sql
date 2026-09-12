-- =====================================================================
--  581_dis_hekim_brans_yaklasik.sql
--  580'de "Uzman Hekim"e düşen dış hekimlere gerçek branşları verilir.
--
--  580 yalnız ÖN EK eşleşmesi arıyordu; SKRS'de bölüm ile branş adı bazen
--  ortadan ayrılıyor ya da bölüm adında yazım hatası var:
--    "Endokrin ve Metabolizma…"  / "Endokrinoloji ve Metabolizma…"
--    "Fiziksel tıp ve Rehabiltasyon" / "Fiziksel Tıp ve Rehabilitasyon"
--    "Gastroentereolji"          / "Gastroenteroloji"
--    "Patoloji"                  / "Tıbbi Patoloji"   (ön ek değil, içerir)
--
--  Ölçüt: (1) branş adı bölüm adını İÇERİYOR, ya da (2) ortak ön ek en az
--  8 harf. Eşleşenlerden en KISA ad seçilir (en genel dal). Bulunamazsa
--  satır olduğu gibi kalır ("Uzman Hekim").
--
--  Yalnız branşı "Uzman Hekim" olan DIŞ hekimlere dokunur; elle seçilmiş
--  bir branşı ezmez. Tekrar çalıştırılabilir.
-- =====================================================================

update public.taraf t
   set gorev_id = k.yeni_gorev
  from (
        select t2.id,
               (select g.id
                  from public.personel_gorev g
                 where coalesce(g.kod,'') <> ''
                   and (public.fn_ara_metin(g.ad) like '%' || public.fn_ara_metin(d.ad) || '%'
                        or left(public.fn_ara_metin(g.ad), 8) = left(public.fn_ara_metin(d.ad), 8))
                 order by length(g.ad)
                 limit 1) as yeni_gorev
          from public.taraf t2
          join public.taraf_personel p on p.id = t2.id and p.dis_hekim = 1
          join public.departman d on d.id = t2.departman
          join public.personel_gorev g0 on g0.id = t2.gorev_id
         where public.fn_ara_metin(g0.ad) = 'uzman hekim'
       ) k
 where t.id = k.id and k.yeni_gorev is not null;
