-- ============================================================================
--  Gentegre AI — FIYAT LISTESI YETKILERI VE LOG KODLARI
--  203_satis_listesi_yetki.sql
--
--  Yeni bir kaynak yetki tablosuna girmezse hicbir rol onu goremez (yetki
--  cozucu bilinmeyen kodda "yok" der) - liste ekranda hic acilmaz.
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.yetki (kod, ad, grup, tur, sira) values
    ('satis_listesi',      'Satis fiyat listesi',  'stok', 0, 24),
    -- Listeyi URETMEK ayri bir izin: binlerce satir yazar, taban degisince
    --   fiyatlar toptan degisir. Gorme/duzeltme yetkisi olan herkes
    --   calistirabilmemeli.
    ('satis_listesi.uret', 'Fiyat listesini uret', 'stok', 1, 131)
on conflict (kod) do nothing;

-- Yonetici: yeni yetkiler de acik (020'deki cross join yalniz o an var olanlari
--   kapsamisti - sonradan eklenen her yetki icin tekrarlanir).
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 1, 1, 1
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and y.kod in ('satis_listesi', 'satis_listesi.uret')
on conflict (rol_id, yetki_id) do update
   set gor = 1, ekle = 1, degistir = 1, sil = 1;

-- Salt okuyucu: listeyi gorur, uretemez (uret tur = 1).
insert into public.rol_yetki (rol_id, yetki_id, gor)
select r.id, y.id, 1
  from public.rol r cross join public.yetki y
 where r.kod = 'salt_okur' and y.kod = 'satis_listesi'
on conflict (rol_id, yetki_id) do nothing;

do $$
declare v integer;
begin
    select count(*) into v from public.yetki where kod like 'satis_listesi%';
    raise notice '203 tamam: % yetki (satis_listesi, satis_listesi.uret).', v;
end $$;
