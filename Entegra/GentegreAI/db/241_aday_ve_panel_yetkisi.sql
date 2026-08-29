-- 241: İki yeni yetki (kullanıcı istekleri).
--
-- 1) 'aday' — Aday Müşteriler artık 'cari' yetkisini paylaşmıyor. Aynı yetki
--    kodu hem CRM › Aday Müşteriler hem Cari › Müşteri/Tedarikçi/Kişi
--    listelerinde kullanılıyordu; "satıcı rolü sadece CRM görsün" dendiğinde
--    cari listeleri de açılıyordu.
-- 2) 'panel' — Ana Sayfa da yetkiye bağlı ve matriste EN BAŞTA görünsün.
--
-- Yönetici rolüne ikisi de tam verilir. 'satici' rolü (varsa) CRM-only
-- kalsın diye: cari kaldırılır, aday + panel eklenir.

insert into public.yetki (kod, ad, grup, tur, sira, aktif)
select 'panel', 'Ana Sayfa', 'genel', 0, 1, 1
 where not exists (select 1 from public.yetki where kod = 'panel');

insert into public.yetki (kod, ad, grup, tur, sira, aktif)
select 'aday', 'Aday Müşteriler', 'kart', 0, 11, 1
 where not exists (select 1 from public.yetki where kod = 'aday');

-- Yönetici: her ikisi de tam yetki.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r
  cross join public.yetki y
 where r.kod = 'yonetici' and y.kod in ('panel', 'aday')
   and not exists (select 1 from public.rol_yetki x
                    where x.rol_id = r.id and x.yetki_id = y.id);

-- Rol Atanmamış havuzu: yalnız Ana Sayfa (giriş yapınca boş ekran görmesin).
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 0, 0, 0, 0
  from public.rol r
  cross join public.yetki y
 where r.kod = 'atanmamis' and y.kod = 'panel'
   and not exists (select 1 from public.rol_yetki x
                    where x.rol_id = r.id and x.yetki_id = y.id);

-- satici rolü: CRM-only. cari kalkar; aday ve panel gelir.
update public.rol_yetki ry
   set gor = 0, ekle = 0, degistir = 0, sil = 0
  from public.rol r, public.yetki y
 where ry.rol_id = r.id and ry.yetki_id = y.id
   and r.kod = 'satici' and y.kod = 'cari';

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id,
       1, case when y.kod = 'aday' then 1 else 0 end,
       case when y.kod = 'aday' then 1 else 0 end,
       case when y.kod = 'aday' then 1 else 0 end, 0
  from public.rol r
  cross join public.yetki y
 where r.kod = 'satici' and y.kod in ('aday', 'panel')
   and not exists (select 1 from public.rol_yetki x
                    where x.rol_id = r.id and x.yetki_id = y.id);
