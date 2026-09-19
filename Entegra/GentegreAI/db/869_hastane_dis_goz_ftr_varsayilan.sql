-- 869: HASTANE tipinde Diş / Göz / FTR modülleri VARSAYILAN AÇIK (kullanıcı:
-- "kliniklerde diş göz ftr yok" → "hastane tipinde varsayılan 1 yap").
-- Daha önce 2 (opsiyonel) idi: hastane kurulumunda menünün Klinikler bölgesinde
-- Diş / Göz / FTR grupları görünmüyordu. Kurum profilinde açıkça kapatılmış
-- (moduller {"dis": 0}) kurumlara dokunulmaz; anahtarı hiç olmayan hastane
-- profillerine açık yazılır.
update public.kurum_tipi_modul set varsayilan = 1
 where kurum_tipi = 'hastane' and modul in ('dis', 'goz', 'ftr') and varsayilan <> 1;

update public.kurum_profil
   set moduller = coalesce(moduller, '{}'::jsonb)
                  || case when coalesce(moduller, '{}'::jsonb) ? 'dis' then '{}'::jsonb else '{"dis": 1}'::jsonb end
                  || case when coalesce(moduller, '{}'::jsonb) ? 'goz' then '{}'::jsonb else '{"goz": 1}'::jsonb end
                  || case when coalesce(moduller, '{}'::jsonb) ? 'ftr' then '{}'::jsonb else '{"ftr": 1}'::jsonb end
 where kurum_tipi = 'hastane';
