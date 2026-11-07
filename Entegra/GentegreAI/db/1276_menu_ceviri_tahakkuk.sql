-- =============================================================================
--  1276 - TAHAKKUK LİSTESİ MENÜ ADLARI TÜRLÜ  (07.11.2026)
--
--  · Satış / Alış gruplarındaki "Tahakkuk Listesi" menü adı türüyle: "Satış Tahakkuk Listesi" / "Alış Tahakkuk Listesi"
--    (kullanıcı). Yeni adların EN / DE çevirileri sözlüğe; eski ad çevirileri dokunulmaz. İdempotent.
-- =============================================================================

insert into public.ceviri (kapsam, anahtar, dil, metin)
select v.kapsam, v.tr, v.dil, v.karsilik
  from (values
    ('menu', 'Satış Tahakkuk Listesi', 1::smallint, 'Sales Accrual List'),
    ('menu', 'Satış Tahakkuk Listesi', 2,           'Verkaufsabgrenzungen'),
    ('menu', 'Alış Tahakkuk Listesi',  1,           'Purchase Accrual List'),
    ('menu', 'Alış Tahakkuk Listesi',  2,           'Einkaufsabgrenzungen')
  ) as v(kapsam, tr, dil, karsilik)
 where not exists (select 1 from public.ceviri c
                    where c.kapsam = v.kapsam and c.anahtar = v.tr and c.dil = v.dil);

do $kontrol$
begin
    raise notice '1276 tamam: tahakkuk menü adları - % çeviri',
        (select count(*) from public.ceviri where kapsam = 'menu' and anahtar in ('Satış Tahakkuk Listesi', 'Alış Tahakkuk Listesi'));
end $kontrol$;
