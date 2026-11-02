\set ON_ERROR_STOP on
-- ============================================================================
--  1214 — Kısa yaş metni: tek kural, tek yer
--
--  Kullanıcı 31.10.2026: "hasta 2 yaş altı olursa 1y3a gibi göster, 1 yaş altı
--  olursa 3a5g gibi göster", "yaşta 0 varsa gösterme".
--
--    2 yaş ve üstü   45y
--    1 - 2 yaş       1y3a   (ay 0 ise 1y)
--    1 yaş altı      3a5g   (ay 0 ise 5g, gün 0 ise 3a; doğduğu gün 0g)
--
--  Liste kataloğundaki "yasMetni" kolonu ve uçların görüntü yaşı bunu çağırır;
--  istemcideki karşılığı web/src/bilesenler/bicim.ts yasMetni (aynı kural).
--  Tam sayı "yas" alanları (65+, 16 altı gibi kararlar) değişmez.
-- ============================================================================
begin;

create or replace function public.fn_yas_kisa(p_dogum date, p_tarih date default current_date)
returns text
language sql stable parallel safe
as $$
    select case
        when p_dogum is null or p_dogum > p_tarih then ''
        when a.y >= 2 then a.y || 'y'
        when a.y = 1  then '1y' || case when a.m > 0 then a.m || 'a' else '' end
        when a.m = 0 and a.g = 0 then '0g'
        else case when a.m > 0 then a.m || 'a' else '' end
          || case when a.g > 0 then a.g || 'g' else '' end
    end
    from (select extract(year from x)::int as y, extract(month from x)::int as m, extract(day from x)::int as g
            from age(p_tarih, p_dogum) x) a;
$$;

comment on function public.fn_yas_kisa(date, date) is
    'Kısa yaş: 2+ yaş "45y", 1-2 yaş "1y3a", 1 yaş altı "3a5g"; sıfır parçalar yazılmaz (1214).';

commit;
