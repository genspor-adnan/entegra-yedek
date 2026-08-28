-- ============================================================================
--  Gentegre AI — BELGEDE ÜTS BİLDİRİM DURUMU
--  230_belge_uts_durum.sql
--
--  Kullanıcı: "belgede bildirim durum kaydı tutulmalı" - verme bildirimi
--  fatura seçim listesinden yapılır; hangi faturanın bildirildiği belge
--  üzerinde görünür. 0 Bildirilmedi / 1 Kısmi / 2 Bildirildi. Hesap: belgenin
--  seri/lot izlem satırlarından kaçının BAŞARILI (durum 1) ÜTS bildirimi var.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.belge
    add column if not exists uts_durum smallint not null default 0;

comment on column public.belge.uts_durum is
  'ÜTS bildirim durumu (230): 0 bildirilmedi, 1 kısmi, 2 tüm seri/lot '
  'satırları başarıyla bildirildi. uts_bildirim üzerinden hesaplanır.';

create index if not exists ix_belge_uts_durum on public.belge (uts_durum)
    where uts_durum > 0;

do $$ begin
    raise notice '230 tamam: belge.uts_durum.';
end $$;
