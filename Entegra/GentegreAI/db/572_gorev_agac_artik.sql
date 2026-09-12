-- =====================================================================
--  572_gorev_agac_artik.sql
--  570'in üç artığı doğru dala taşınır.
--
--  "Diğer Görevler" dalında kalanlar gözden geçirildi:
--    Dahiliye Uzmanı -> Sağlık Personeli  ("^uzman" deseni başa bağlıydı,
--                                          "… Uzmanı" biçimini kaçırdı)
--    IT Destek       -> Teknik / Destek   ("bilgi işlem" yazılmamış)
--    Müdür           -> Yönetim           (tek kelimelik kadro adı)
--
--  "Diğer Görevler" dalı DURUYOR: sonradan eklenen, hiçbir kurala uymayan
--  görev sessizce kaybolmasın diye.
-- =====================================================================

update public.personel_gorev g
   set ust_id = (select u.id from public.personel_gorev u
                  where u.ad = x.hedef and u.ust_id is null
                    and coalesce(u.kod, '') = '' limit 1)
  from (values
    ('Dahiliye Uzmanı', 'Sağlık Personeli'),
    ('IT Destek',       'Teknik / Destek'),
    ('Müdür',           'Yönetim')
  ) as x(gorev, hedef)
 where public.fn_ara_metin(g.ad) = public.fn_ara_metin(x.gorev)
   and coalesce(g.kod, '') = '';
