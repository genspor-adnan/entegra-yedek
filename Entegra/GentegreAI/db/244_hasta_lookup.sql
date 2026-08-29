-- 244: Randevu kartında hasta seçimi için lookup görünümü (243'ün eki).
-- v_personel_lookup ile aynı sözleşme: id, ad, aktif.

create or replace view public.v_hasta_lookup as
select t.id,
       (coalesce(nullif(trim(t.unvan), ''), trim(t.ad || ' ' || t.soyad)))::varchar(120) as ad,
       case when t.durum = 1 then 1 else 0 end as aktif
  from public.taraf t
 where t.hasta = 1;
