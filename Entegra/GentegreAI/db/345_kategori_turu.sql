-- 345: KATEGORİYE TÜR (stok / hizmet / ortak).
--
-- Kullanıcı: "kategorileri de 2 gride böl - solda stok, sağda hizmet
-- kategorileri olsun."
--
-- 270'te kategori ağacı stok ve hizmet için ORTAK açılmıştı; ayrım yalnız
-- KULLANIMDAN (kaç stok / kaç hizmet o kategoriyi seçmiş) çıkarılabiliyordu.
-- Bu, henüz kullanılmamış kategoriyi hiçbir tarafa koyamıyor ve "bu kategori
-- hizmetler içindir" bilgisini kaydedilemez bırakıyordu.
--
-- TÜR: 1 Stok · 2 Hizmet · 3 Ortak (ikisinde de görünür).
-- Göç mevcut satırları GERÇEK KULLANIMA göre işaretler - bayrağa değil veriye
-- bakar (hizmet/masraf ayrımında da aynı yol izlenmişti):
--   * yalnız stokta kullanılıyorsa 1, yalnız hizmette 2,
--   * ikisinde de ya da hiçbirinde kullanılmıyorsa 3 (ortak) - kullanılmamış
--     kategoriyi tek tarafa hapsetmek, kullanıcının onu öteki listede
--     bulamamasına yol açardı.
\set ON_ERROR_STOP on

alter table public.kategori
    add column if not exists tur smallint not null default 3;

comment on column public.kategori.tur is
  'Kategori turu (345): 1 stok, 2 hizmet, 3 ortak (iki listede de gorunur).';

update public.kategori k
   set tur = case
               when s.adet > 0 and h.adet = 0 then 1
               when h.adet > 0 and s.adet = 0 then 2
               else 3
             end
  from (select k2.id,
               (select count(*) from public.stok s2 where s2.kategori = k2.id) as adet
          from public.kategori k2) s,
       (select k3.id,
               (select count(*) from public.hizmet h2 where h2.kategori = k3.id) as adet
          from public.kategori k3) h
 where s.id = k.id and h.id = k.id;

create index if not exists ix_kategori_tur on public.kategori (tur);

do $$
declare r record;
begin
    for r in select tur, count(*) adet from public.kategori group by tur order by tur loop
        raise notice '345: tur % -> % kategori', r.tur, r.adet;
    end loop;
    raise notice '345 tamam: kategori.tur (1 stok / 2 hizmet / 3 ortak).';
end $$;
