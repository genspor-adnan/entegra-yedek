-- =============================================================================
--  1259  REÇETE BİLEŞENİ "KRİTİK" İŞARETİ (mockup urun_agaci_karti_v2.html, denetimli bileşen satırı)
--
--  Kritik bileşen: kalite / lot takibi zorunlu hammadde (ISO 13485 izlenebilirlik). Denetimli seviyede satırda
--  işaretlenir; emir ön kontrolünde lot ataması bu satırlar için aranır. Basit / standart gizler.
-- =============================================================================
\set ON_ERROR_STOP on

alter table public.urun_agaci_satir
    add column if not exists kritik smallint not null default 0;

comment on column public.urun_agaci_satir.kritik is 'Kritik bileşen (1): lot / kalite takibi zorunlu (1259, denetimli seviye).';

do $$ begin raise notice '1259 tamam: urun_agaci_satir.kritik'; end $$;
