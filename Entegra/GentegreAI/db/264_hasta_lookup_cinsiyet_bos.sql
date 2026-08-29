-- 264: cinsiyeti girilmemiş hastada "?" (kullanıcı: "cinsiyeti olmayan
-- hastalarda ikon yerine soru işareti koy").
--
-- 263'te cinsiyet boşsa hiç yazılmıyordu ve "MERVE DEMİR — 34" gibi eksik
-- görünüyordu; artık eksiklik GÖRÜNÜR: "MERVE DEMİR — ? 34" - kayıt kabul
-- kartı açıp cinsiyeti tamamlayabilsin.

drop view if exists public.v_hasta_lookup;
create view public.v_hasta_lookup as
select t.id,
       (coalesce(nullif(trim(t.unvan), ''), trim(t.ad || ' ' || t.soyad))
        || case h.cinsiyet when 1 then ' — ♂ E' when 2 then ' — ♀ K' else ' — ?' end
        || case when h.dogum_tarihi is not null
                then ' ' || extract(year from age(h.dogum_tarihi))::int::text
                else '' end
        || case when coalesce(nullif(t.cep_tel, ''), nullif(t.telefon, ''), '') <> ''
                then ' · ☎ ' || coalesce(nullif(t.cep_tel, ''), t.telefon)
                else '' end)::varchar(200) as ad,
       case when t.durum = 1 then 1 else 0 end as aktif
  from public.taraf t
  left join public.taraf_hasta h on h.id = t.id
 where t.hasta = 1;
