-- ============================================================================
--  Gentegre AI — TEKLIF REVIZE NO
--  220_teklif_revize_no.sql
--
--  Teklif kartinda Teklif No hucresi ikiye bolundu (kullanici): sagda
--  REVIZE NO - serbest kullanici editi, varsayilan bos. Ayrica Siparis
--  sekmesi ve donusum yalniz KABUL (3) durumunda; Revize durumu kaldirildi.
-- ============================================================================

alter table public.belge
    add column if not exists revize_no varchar(20) not null default '';

comment on column public.belge.revize_no is
  'Teklif revize numarasi (220, yalniz tur 18) - serbest metin, kullanici girer.';

do $$ begin
    raise notice '220 tamam: belge.revize_no kolonu.';
end $$;
