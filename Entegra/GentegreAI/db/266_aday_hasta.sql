-- 266: ADAY HASTA (kullanıcı: "randevudan kurum bilgisini sil, db'den de sil;
-- taraf_hasta durumları Aktif/Pasif/Aday/Vefat; sade bir Aday Hasta kartı,
-- kurum_id'yi taraf_hasta'ya ekle; randevu verirken hasta yoksa Yeni ile aday
-- kartı açılsın, başvuruya dönüşünce aday aktif olsun").
--
-- 1) randevu.kurum_id GERİ ALINIYOR (265): ödeyen kurum randevuda değil,
--    hastanın kendisinde durur - randevu ekranı sadeleşiyor.
-- 2) taraf_hasta.kurum_id: hastanın (tek) kurumu. Çok poliçeli izleme
--    taraf_hasta_kurum'da (248) duruyor; aday kartı gibi hızlı girişlerde
--    tek alan yeterli.
-- 3) Hasta durumu artık dört değerli: 1 Aktif / 0 Pasif / 2 Aday / 3 Vefat.
--    taraf.durum kolonu ORTAK - 0/1 kullanan diğer kartlar etkilenmez, hasta
--    kartı ek iki değeri gösterir.

alter table public.randevu drop column if exists kurum_id;

alter table public.taraf_hasta add column if not exists kurum_id integer
  references public.taraf(id);
comment on column public.taraf_hasta.kurum_id is
  'Hastanın ödeyen kurumu (266). Çok poliçeli izleme taraf_hasta_kurum''da.';

create index if not exists ix_taraf_hasta_kurum_id on public.taraf_hasta (kurum_id)
  where kurum_id is not null;

-- Aday hasta lookup'ta da seçilebilmeli (randevu ADAYA da verilir).
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
                else '' end
        -- Aday oldugu ekranda gorunsun: randevu verilebilir ama kaydi eksiktir.
        || case when t.durum = 2 then ' · ADAY' else '' end)::varchar(200) as ad,
       case when t.durum in (1, 2) then 1 else 0 end as aktif
  from public.taraf t
  left join public.taraf_hasta h on h.id = t.id
 where t.hasta = 1;
