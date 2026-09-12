-- =====================================================================
--  580_dis_hekim_brans_tamamla.sql
--  579'da branşı boş kalan dış hekimlerin branşı doldurulur.
--
--  579 branşı bölüm adıyla TAM eşleşerek arıyordu; SKRS'de iki listenin
--  adları küçük farklarla ayrılıyor ("Deri ve Zührevi Hastalıklar" bölümü /
--  "Deri ve Zührevi Hastalıkları" branşı, "Acil" / "Acil Tıp",
--  "Patoloji" / "Tıbbi Patoloji"), bu yüzden 20 hekimin 8'i branşsız kaldı.
--
--  Sıra: (1) tam ad eşleşmesi, (2) biri ötekinin ön eki olan ad -- eşleşen
--  en KISA branş (en genel dal; "Gastroenteroloji", "Gastroenteroloji
--  Yoğun Bakım" değil), (3) hiçbiri yoksa "Uzman Hekim" (574'teki kural).
--
--  Yalnız branşı BOŞ dış hekimlere dokunur - elle seçilmiş bir branşı
--  ezmez. Tekrar çalıştırılabilir.
-- =====================================================================

update public.taraf t
   set gorev_id = k.gorev_id
  from (
        select t2.id,
               coalesce(
                   (select g.id from public.personel_gorev g
                     where coalesce(g.kod,'') <> ''
                       and (public.fn_ara_metin(g.ad) like public.fn_ara_metin(d.ad) || '%'
                         or public.fn_ara_metin(d.ad) like public.fn_ara_metin(g.ad) || '%')
                     order by length(g.ad)
                     limit 1),
                   (select g.id from public.personel_gorev g
                     where public.fn_ara_metin(g.ad) = 'uzman hekim' limit 1)
               ) as gorev_id
          from public.taraf t2
          join public.taraf_personel p on p.id = t2.id and p.dis_hekim = 1
          join public.departman d on d.id = t2.departman
         where coalesce(t2.gorev_id, 0) = 0
       ) k
 where t.id = k.id and k.gorev_id is not null;
