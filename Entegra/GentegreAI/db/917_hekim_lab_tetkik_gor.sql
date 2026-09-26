-- =====================================================================
--  917_hekim_lab_tetkik_gor.sql
--  DOKTOR LAB İSTEMİ İÇİN TETKİK KATALOĞU OKUMA (kullanıcı: "doktor rol
--  yetkisinde lab ve radyoloji istem olmalı").
--
--  Lab istem ekranındaki tetkik/panel seçici `lab-tetkik` ve `lab-panel`
--  listelerini çeker; her ikisi de YetkiKodu = 'lab.tetkik' (katalog GÖR)
--  ister. Uzman Doktor rolünde bu yetki yoktu → seçici "Bu işlem için
--  yetkiniz yok" ile açılmıyor ve doktor lab istemi yapamıyordu (lab.ekle
--  ve muayene.degistir vardı; eksik olan tek şey katalog GÖR idi).
--
--  Bu betik HEKİM rollerine (tur/işaret 'hekim' ya da 'Uzman Doktor')
--  'lab.tetkik' GÖR (yalnız okuma; ekle/değiştir/sil = 0) verir. Tetkik
--  tanımını YÖNETMEZ, yalnız istemde seçmek için OKUR.
-- =====================================================================
\set ON_ERROR_STOP on

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 0, 0, 0, 0
  from public.rol r
  cross join public.yetki y
 where y.kod = 'lab.tetkik'
   and r.kod in ('hekim')
   and not exists (select 1 from public.rol_yetki x where x.rol_id = r.id and x.yetki_id = y.id);

-- Zaten satırı olan ama GÖR kapalı olan hekim rollerini de aç.
update public.rol_yetki ry
   set gor = 1
  from public.rol r, public.yetki y
 where ry.rol_id = r.id and ry.yetki_id = y.id
   and y.kod = 'lab.tetkik' and r.kod in ('hekim') and coalesce(ry.gor, 0) = 0;

update public.rol set yetki_surumu = yetki_surumu + 1 where kod in ('hekim');

do $$
begin
    raise notice '917 tamam: hekim rolüne lab.tetkik GÖR (%.satır)',
        (select count(*) from public.rol_yetki ry
           join public.rol r on r.id = ry.rol_id
           join public.yetki y on y.id = ry.yetki_id
          where y.kod = 'lab.tetkik' and r.kod = 'hekim' and ry.gor = 1);
end $$;
