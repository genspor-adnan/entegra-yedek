-- 256: departman.aktif -> departman.durum (kullanıcı: "departman ve görevde
-- field adı durum olacak, aktif değil").
--
-- Görev tablosu (255) zaten `durum` kullanıyor; departman 251'de `aktif` olarak
-- açılmıştı. İkisi aynı anlamda olduğu için tek ada indiriliyor - taraf.durum,
-- fiyat_listesi.durum ile de aynı ad.

do $$
begin
  if exists (select 1 from information_schema.columns
              where table_schema = 'public' and table_name = 'departman'
                and column_name = 'aktif')
     and not exists (select 1 from information_schema.columns
                      where table_schema = 'public' and table_name = 'departman'
                        and column_name = 'durum') then
    alter table public.departman rename column aktif to durum;
  end if;
end $$;

comment on column public.departman.durum is '1 Aktif / 0 Pasif (256).';

-- Lookup sözleşmesi (id, ad, aktif) DEĞİŞMEZ - kart altyapısı `aktif` kolonunu
--   okuyor; tablo kolonu `durum`, görünümde takma adla sunulur.
drop view if exists public.v_departman_lookup;
create view public.v_departman_lookup as
select d.id,
       case when d.kod = '' then d.ad else d.kod || ' - ' || d.ad end as ad,
       d.durum as aktif
  from public.departman d;

drop view if exists public.v_randevu_bolum_lookup;
create view public.v_randevu_bolum_lookup as
select d.id,
       case when d.kod = '' then d.ad else d.kod || ' - ' || d.ad end as ad,
       d.durum as aktif
  from public.departman d
 where d.randevu_verilebilir = 1;
