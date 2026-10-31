\set ON_ERROR_STOP on
-- ============================================================================
--  1212 — K78: çift degistirme_tarihi tetikleri ve yedek tablodaki tetik
--
--  Kod inceleme 30.10.2026 K78: numara_sablonu, ebelge_seri ve taraf_kullanici
--  üzerinde aynı fn_degistirme_tarihi() iki ayrı adla (tr_* / trg_*) bağlıydı -
--  her UPDATE'te iki kez çalışıyordu. Biri kalır. stok_barkod_yedek_145 yedek
--  tablosunda unutulan tetik düşer (yedek tablo dokunulmaz, sadece tetik).
-- ============================================================================
begin;

drop trigger if exists trg_numara_sablonu_degistirme   on public.numara_sablonu;    -- tr_numara_sablonu_degistirme kalır
drop trigger if exists trg_ebelge_seri_degistirme      on public.ebelge_seri;       -- tr_ebelge_seri_degistirme kalır
drop trigger if exists trg_taraf_kullanici_degistirme  on public.taraf_kullanici;   -- trg_kullanici_degistirme kalır

do $$
begin
    if to_regclass('public.stok_barkod_yedek_145') is not null then
        execute 'drop trigger if exists trg_stok_barkod_yedek_145_degistirme on public.stok_barkod_yedek_145';
    end if;
end $$;

commit;
