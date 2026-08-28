-- ============================================================================
--  Gentegre AI — ÜTS YETKİLERİ
--  224_uts_yetki.sql
--
--  Yeni kaynak yetki tablosuna girmezse hiçbir rol onu göremez (203 deseni).
--  uts.bildir / uts.iptal aksiyon yetkileri (tur = 1): bildirim GÖNDERMEK ve
--  İPTAL ETMEK resmi işlemdir - görme yetkisi olan herkes yapamamalı.
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.yetki (kod, ad, grup, tur, sira) values
    ('uts',        'ÜTS (Ürün Takip Sistemi)',   'stok', 0, 26),
    ('uts.bildir', 'ÜTS bildirimi gönder',       'stok', 1, 132),
    ('uts.iptal',  'ÜTS bildirimini iptal et',   'stok', 1, 133)
on conflict (kod) do nothing;

-- Yönetici: tam yetki.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 1, 1, 1
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and y.kod in ('uts', 'uts.bildir', 'uts.iptal')
on conflict (rol_id, yetki_id) do update
   set gor = 1, ekle = 1, degistir = 1, sil = 1;

-- Salt okuyucu: listeleri görür, bildirim gönderemez/iptal edemez.
insert into public.rol_yetki (rol_id, yetki_id, gor)
select r.id, y.id, 1
  from public.rol r cross join public.yetki y
 where r.kod = 'salt_okur' and y.kod = 'uts'
on conflict (rol_id, yetki_id) do nothing;

do $$
declare v integer;
begin
    select count(*) into v from public.yetki where kod like 'uts%';
    raise notice '224 tamam: % yetki (uts, uts.bildir, uts.iptal).', v;
end $$;
