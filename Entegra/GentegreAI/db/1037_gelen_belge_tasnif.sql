-- 1037: GELEN e-BELGE TASNİFİ - Delphi gibi sekmeler (kullanici 11.10.2026: "delphi
--   gibi sekmeli olsun"). Delphi'de gelen belge Alis Faturalari ekraninda uc ana
--   sekmede: Sistem (aktarilmis, EFATURADURUM -2/-12) | Gelen Kutusu (-1/-11) |
--   Kullanim Disi (-3/-13). Burada e_belge (yon 2) uzerinde:
--     tasnif 1 Gelen Kutusu · 2 Sistem (alis faturasina aktarildi) · 3 Kullanim Disi
--   Aktarilmis kayitlar (belge_id dolu) Sistem'e alinir. Idempotent.
begin;

alter table public.e_belge add column if not exists tasnif smallint not null default 1;
comment on column public.e_belge.tasnif is
  'Gelen belge tasnifi (1037): 1 Gelen Kutusu, 2 Sistem (aktarıldı), 3 Kullanım Dışı.';

update public.e_belge set tasnif = 2
 where yon = 2 and coalesce(belge_id, 0) > 0 and tasnif <> 2;

create index if not exists ix_e_belge_gelen_tasnif on public.e_belge (tasnif, belge_tarihi) where yon = 2;

commit;
