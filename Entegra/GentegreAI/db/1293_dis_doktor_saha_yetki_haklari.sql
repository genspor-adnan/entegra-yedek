-- =============================================================================
--  1293  DIŞ DOKTOR SAHA EKRANLARI: İŞLEM HAKLARI  (kullanıcı 10.11.2026: "Dış Doktor Ziyaretleri listesinde
--        ekle/düzenle/sil buton deseni yok")
--
--  1289 / 1290 yeni ekran yetkilerini (dis_doktor.ziyaret, .talep, .vade, .plan) dis_doktor.liste'den kopyalamıştı;
--  liste kodu yalnız GÖR taşır (1115 liste / kart ayrımı) - ekle / değiştir / sil 0 kaldı, Crud düğmeleri gizlendi.
--  Yönetici satırı da zaten var olduğundan "rol 1 tam hak" eklemesi atlanmıştı. Bu ekranlarda liste ve kart AYNI kodu
--  taşır: haklar KART kodu dis_doktor'dan (gör / ekle / değiştir / sil) alınır; rol 1 tam. Performans gör kalır.
--  İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

update public.rol_yetki ry
   set ekle = greatest(ry.ekle, k.ekle), degistir = greatest(ry.degistir, k.degistir), sil = greatest(ry.sil, k.sil)
  from public.yetki y, public.yetki yk, public.rol_yetki k
 where ry.yetki_id = y.id and y.kod in ('dis_doktor.ziyaret', 'dis_doktor.talep', 'dis_doktor.vade', 'dis_doktor.plan')
   and yk.kod = 'dis_doktor' and k.yetki_id = yk.id and k.rol_id = ry.rol_id;

update public.rol_yetki ry set gor = 1, ekle = 1, degistir = 1, sil = 1
  from public.yetki y
 where ry.yetki_id = y.id and ry.rol_id = 1
   and y.kod in ('dis_doktor.ziyaret', 'dis_doktor.talep', 'dis_doktor.vade', 'dis_doktor.plan');

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
                where ry.rol_id = r.id and y.kod in ('dis_doktor.ziyaret', 'dis_doktor.talep', 'dis_doktor.vade', 'dis_doktor.plan'));

do $$ begin raise notice '1293 tamam: dis_doktor.ziyaret / talep / vade / plan haklari dis_doktor kart kodundan.'; end $$;
