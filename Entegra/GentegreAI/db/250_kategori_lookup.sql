-- 250: kategori lookup + kurum lookup düzeltmesi (249'un devamı).
--
-- Sözleşme satırında "şu KATEGORİDEN %20 indirim" seçilebilmesi için kategori
-- lookup'ı gerekiyor. Diğer lookup görünümleriyle aynı sözleşme: (id, ad, aktif).

create or replace view public.v_kategori_lookup as
select k.id,
       case when k.kod = '' then k.ad else k.kod || ' - ' || k.ad end as ad,
       k.aktif
  from public.kategori k;

-- v_kurum_lookup (249) diğer lookup'larla aynı sözleşmeye çekildi: kart
--   alanları (id, ad, aktif) bekliyor; tur/durum kolonları kart tarafında
--   kullanılmıyordu, pasif kurum da listede çıkmamalı.
-- 249'daki görünümde tur/durum kolonları vardı; "cannot drop columns from
--   view" hatası vermesin diye önce düşürülür.
drop view if exists public.v_kurum_lookup;
create view public.v_kurum_lookup as
select t.id,
       case when t.kod = '' then t.unvan else t.kod || ' - ' || t.unvan end as ad,
       case when t.durum = 1 and k.durum = 1 then 1 else 0 end as aktif
  from public.taraf t
  join public.taraf_kurum k on k.id = t.id
 where t.kurum = 1;
