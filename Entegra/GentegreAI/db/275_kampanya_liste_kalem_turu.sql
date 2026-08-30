-- 275: KAMPANYA "LİSTE" SATIRI KALEM TÜRÜNÜ YOK SAYIYORDU (272 hatası).
--
-- Satırın `kalem_turu` alanı kuralın hangi tarafa baktığını söyler:
--   0 Farketmez · 1 Stok · 2 Hizmet.
-- Ürün (tip 3) ve kategori (tip 2) dallarında kontrol ediliyordu ama LİSTE
-- (tip 1) dalında koşul yalnız `ks.tip = 1` idi: "tüm listeye %25, yalnız
-- STOK kalemlerine" diye tanımlanmış bir satır hizmet kalemine de iniyordu.
--
-- Öncelik sırası DEĞİŞMEDİ (kullanıcı): ürün > kategori (ağaçta en yakın) >
-- liste; eşleşme yoksa fiyat listesi fiyatı kalır.

create or replace function public.fn_kampanya_fiyat(
    p_kampanya_id integer,
    p_stok_id     integer,
    p_hizmet_id   integer,
    p_baz_fiyat   numeric,
    p_tarih       date default current_date)
returns table (fiyat numeric, satir_id integer, tip smallint,
               iskonto_tipi smallint, iskonto numeric)
language plpgsql stable as $$
declare
  v_kategori integer;
begin
  if p_kampanya_id is null then
    return query select p_baz_fiyat, null::integer, null::smallint, null::smallint, null::numeric;
    return;
  end if;

  -- Kalemin kategorisi (stok ya da hizmet - ikisi de ortak ağaçta, 269).
  select case when p_stok_id is not null
              then (select s.kategori from public.stok s where s.id = p_stok_id)
              else (select h.kategori from public.hizmet h where h.id = p_hizmet_id) end
    into v_kategori;

  return query
  with recursive atalar as (
      -- Kalemin kategorisi: derinlik 0 (en yakın), üstüne çıktıkça artar.
      select k.id, k.ust_id, 0 as uzaklik
        from public.kategori k
       where k.id = v_kategori
      union all
      select u.id, u.ust_id, a.uzaklik + 1
        from public.kategori u
        join atalar a on a.ust_id = u.id
       where a.uzaklik < 20
  ),
  aday as (
      select ks.id, ks.tip, ks.iskonto_tipi, ks.iskonto,
             case ks.tip
               when 3 then 3          -- ürün: en dar kapsam
               when 2 then 2
               else 1
             end as oncelik,
             case when ks.tip = 2
                  then coalesce((select a.uzaklik from atalar a where a.id = ks.iskonto_yeri_id), 99)
                  else 0 end as uzaklik
        from public.kampanya_satir ks
       where ks.kampanya_id = p_kampanya_id
         and ks.durum = 1
         -- Satirin kendi tarihi YOK: gecerlilik araligi KAMPANYADA (268),
         --   fn_taraf_kampanya orada zaten kontrol ediyor.
         -- Kalem türü HER DALDA geçerli: "yalnız stok" satırı hizmete inmez.
         and (ks.kalem_turu = 0
           or (ks.kalem_turu = 1 and p_stok_id   is not null)
           or (ks.kalem_turu = 2 and p_hizmet_id is not null))
         and (
              -- ÜRÜN: id tutmalı (taraf ayrımı yukarıdaki kalem_turu ile).
              (ks.tip = 3
               and ks.iskonto_yeri_id = coalesce(p_stok_id, p_hizmet_id))
              -- KATEGORİ: kalemin kategorisi ya da bir üst kategorisi.
           or (ks.tip = 2
               and exists (select 1 from atalar a where a.id = ks.iskonto_yeri_id))
              -- LİSTE: kampanyanın tamamı.
           or ks.tip = 1
         )
  ),
  kazanan as (
      select * from aday order by oncelik desc, uzaklik asc, id limit 1
  )
  select case
           when k.id is null then p_baz_fiyat
           when k.iskonto_tipi = 2 then k.iskonto                       -- sabit fiyat
           else round(coalesce(p_baz_fiyat, 0)
                      * (1 - coalesce(k.iskonto, 0) / 100.0), 6)        -- yüzde
         end,
         k.id, k.tip, k.iskonto_tipi, k.iskonto
    from (select 1) x
    left join kazanan k on true;
end $$;

comment on function public.fn_kampanya_fiyat(integer, integer, integer, numeric, date) is
  'Kampanyanın kaleme uyguladığı fiyat (272/275): ürün > kategori (ağaçta en yakın) > liste; her dalda kalem türü (stok/hizmet) süzülür.';
