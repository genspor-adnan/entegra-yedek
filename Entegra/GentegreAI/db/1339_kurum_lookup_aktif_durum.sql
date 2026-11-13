-- 1339 - v_kurum_lookup.aktif = kurum aktif mi (sözleşme şartı kalktı).
--
-- Kod incelemesi 14.11.2026 (1338 sonrası): v_kurum_lookup "aktif" sütunu 940'tan beri "geçerli kurum_sozlesme var"
-- anlamındaydı; kart kod sözlüğü yalnız aktif = 1 satırları aldığı için dış hekim kartındaki Kurum alanı (1338:
-- sözleşmesiz hastane de seçilebilir) sözleşmesiz kurumu listeleyemiyor, seçilmişse adını boş gösteriyordu.
-- Sözleşme şartı artık v_anlasmali_kurum_lookup'ta (1338, ödeyen kurum seçimi); bu görünüm BÜTÜN kurumları verir,
-- aktif = kurum kaydı aktif (taraf.durum = 1).
\set ON_ERROR_STOP on
begin;

create or replace view public.v_kurum_lookup as
 select t.id,
        case when t.kod::text = '' then public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)::text
             else (t.kod::text || ' - ') || public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)::text
        end as ad,
        case when t.durum = 1 then 1 else 0 end as aktif
   from public.taraf t
   join public.taraf_kurum k on k.id = t.id
  where t.kurum = 1;
comment on view public.v_kurum_lookup is
  '1339: bütün kurumlar (kurum rolü); aktif = kurum kaydı aktif. Ödeyen (sözleşmeli) seçimi v_anlasmali_kurum_lookup.';

commit;
