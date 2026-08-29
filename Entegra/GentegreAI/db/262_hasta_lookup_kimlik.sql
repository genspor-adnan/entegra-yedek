-- 262: HASTA LOOKUP'ında TC + telefon (Ekranlar/randevu_karti.html: hasta
-- alanı "AYŞE YILMAZ — TC 12*******34 · ☎ +90 532 111 22 33" gösteriyor).
--
-- TC MASKELİ: listelerdeki kuralla aynı (ilk 3 + son 2 açık) - randevu ekranı
-- kayıt kabul masasında açık duruyor, tam kimlik numarası ekranda durmasın.

-- Kolon tipi genisledigi icin gorunum once dusurulur ("cannot change data
--   type of view column").
drop view if exists public.v_hasta_lookup;
create view public.v_hasta_lookup as
select t.id,
       (coalesce(nullif(trim(t.unvan), ''), trim(t.ad || ' ' || t.soyad))
        || case when length(coalesce(t.vkno, '')) = 11
                then ' — TC ' || left(t.vkno, 3) || '******' || right(t.vkno, 2)
                else '' end
        || case when coalesce(nullif(t.cep_tel, ''), nullif(t.telefon, ''), '') <> ''
                then ' · ☎ ' || coalesce(nullif(t.cep_tel, ''), t.telefon)
                else '' end)::varchar(200) as ad,
       case when t.durum = 1 then 1 else 0 end as aktif
  from public.taraf t
 where t.hasta = 1;
