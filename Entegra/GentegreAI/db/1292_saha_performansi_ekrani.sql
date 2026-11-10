-- =============================================================================
--  1292  SAHA PERFORMANSI EKRANI  (mockup Ekranlar/Radyoloji/temsilci_ziyaret.html §6; kullanıcı 10.11.2026:
--        "yönetimin de temsilcilerin ve doktorların performansını görmeleri gerekiyor" - adım d)
--  Yalnız yetki + rehber: rakamlar uçta (SahaPerformansUclari) gönderim / ziyaret / talep / hakediş tablolarından okunur.
--  dis_doktor.liste olan roller aynı hakla; temsilci kendi satırını Ziyaret Planı özetinde görür.
-- =============================================================================
\set ON_ERROR_STOP on

insert into public.yetki (kod, ad, grup, tur, urun_modu, sira, aktif)
select 'dis_doktor.performans', 'Saha Performansı (Temsilci / Doktor)', 'Kurumlar & Sigorta', 0, 2, 526, 1
 where not exists (select 1 from public.yetki y where y.kod = 'dis_doktor.performans');
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select ry.rol_id, yn.id, ry.gor, 0, 0, 0
  from public.yetki ye join public.rol_yetki ry on ry.yetki_id = ye.id
  join public.yetki yn on yn.kod = 'dis_doktor.performans'
 where ye.kod = 'dis_doktor.liste'
on conflict (rol_id, yetki_id) do nothing;
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select 1, y.id, 1, 1, 1, 1 from public.yetki y
 where y.kod = 'dis_doktor.performans'
   and not exists (select 1 from public.rol_yetki r where r.rol_id = 1 and r.yetki_id = y.id);
update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
                where ry.rol_id = r.id and y.kod = 'dis_doktor.performans');

insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, anahtar, aciklama)
select 'saha-performans', '/saha-performans', 'Saha Performansı', 'Kurumlar & Sigorta › Saha Performansı',
       'Kurumlar & Sigorta', 'Saha Performansı', 'dis_doktor.performans', 2,
       'saha performans temsilci doktor gönderim ziyaret talep prim şube',
       'Dönem × şube: temsilci başına hekim, ziyaret, plan uyumu, gönderim ve değişim, yeni / kaybedilen hekim, açık talep, prim; doktor başına gönderim trendi; şube kırılımı; talep türleri.'
 where not exists (select 1 from public.ai_rehber_ekran r where r.kaynak = 'saha-performans');

do $$ begin raise notice '1292 tamam: dis_doktor.performans.'; end $$;
