-- =====================================================================
-- 479 - NUMUNE LOOKUP'I (istem kartı tetkik satırı)
--
-- İstem kartındaki tetkik satırı "bu tetkik hangi tüpten çalışılacak"
-- sorusunu cevaplamalı (mockup lab_hasta_istem_karti.html: her tetkiğin
-- karşısında barkod var). Bunun için numune seçici gerekiyordu.
--
-- AD = barkod + tüp rengi: teknisyen rafta rengi arar, listede yalnız numara
-- görmek seçimi zorlaştırırdı. `ust_id` istemdir - kart yalnız KENDİ isteminin
-- tüplerini gösterir, başka hastanın tüpü seçilemez.
-- =====================================================================

create or replace view public.v_lab_numune_lookup as
select n.id,
       n.barkod
         || ' · ' || case n.tup_tipi when 2 then 'Mor (EDTA)'
                                     when 3 then 'Mavi (sitrat)'
                                     when 4 then 'Gri (florür)'
                                     when 5 then 'Yeşil (heparin)'
                                     when 6 then 'İdrar kabı'
                                     when 9 then 'Diğer'
                                     else 'Sarı (jelli)' end as ad,
       n.istem_id as ust_id,
       case when n.ret = 1 then 0 else 1 end::smallint as aktif
  from public.lab_numune n;

comment on view public.v_lab_numune_lookup is
  'İstem kartında tetkiğin bağlanacağı tüp (479): barkod + tüp rengi, istem başına süzülür.';

do $$
begin
    raise notice '479 tamam: v_lab_numune_lookup';
end $$;
