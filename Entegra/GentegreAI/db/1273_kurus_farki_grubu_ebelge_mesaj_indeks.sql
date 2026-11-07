-- =============================================================================
--  1273 - KURUŞ FARKI TÜRLERİNİN GRUBU + e_belge_mesaj(e_belge_id) İNDEKSİ  (05.11.2026 refaktör incelemesi)
--
--  · 1269'daki 60 / 62 kuruş farkı türleri `grup = 'kurfarki'` ile açılmıştı; o grup KUR farkı (88 / 98) ve ekranda
--    "Kur Farkı" yazıyor - yuvarlama kapatmaları döviz kur farkıyla aynı başlığa düşüyordu. Kendi grubu: 'kurusfarki'.
--  · 1265 e-belge aktarımı silme adımında e_belge_mesaj, e_belge_id ile birleşir; o kolonda indeks yoktu
--    (ix_e_belge_mesaj_belge (belge_id, id) başka kolon) - her paket tam tarama. İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

update public.kasa_islem_turu set grup = 'kurusfarki' where kod in (60, 62) and grup <> 'kurusfarki';

create index if not exists ix_e_belge_mesaj_ebelge on public.e_belge_mesaj (e_belge_id);

do $$ begin
  raise notice '1273: kurus farki grubu = kurusfarki (%), ix_e_belge_mesaj_ebelge hazir.',
    (select count(*) from public.kasa_islem_turu where grup = 'kurusfarki');
end $$;

commit;
