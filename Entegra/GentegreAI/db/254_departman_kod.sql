-- 254: DEPARTMAN KODU (kullanıcı: "departmana kod ekle").
--
-- Diğer ana veri kartlarıyla aynı desen (cari.kod, stok.kod): kısa, aranabilir
-- kod + uzun ad. Boş bırakılabilir - eski kayıtlarda kod yok, zorunlu yapmak
-- 41 departmanı elle kodlamayı gerektirirdi.

alter table public.departman add column if not exists kod varchar(20) not null default '';
comment on column public.departman.kod is 'Departman/bölüm kodu (254) - kısa, aranabilir.';

-- Kod dolu olanlarda tekil olsun; boşlar serbest (kısmi benzersiz indeks).
create unique index if not exists ux_departman_kod
  on public.departman (lower(kod)) where kod <> '';

-- Lookup'lar kodu da göstersin (cari/kategori lookup deseni: "KOD - Ad").
-- "ad" kolonunun tipi varchar(100)'den text'e döndüğü için görünümler önce
--   düşürülür ("cannot change data type of view column").
drop view if exists public.v_departman_lookup;
create view public.v_departman_lookup as
select d.id,
       case when d.kod = '' then d.ad else d.kod || ' - ' || d.ad end as ad,
       d.aktif
  from public.departman d;

drop view if exists public.v_randevu_bolum_lookup;
create view public.v_randevu_bolum_lookup as
select d.id,
       case when d.kod = '' then d.ad else d.kod || ' - ' || d.ad end as ad,
       d.aktif
  from public.departman d
 where d.randevu_verilebilir = 1;
