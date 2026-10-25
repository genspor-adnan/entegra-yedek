-- =============================================================================
--  1181  CARİ "ÖDEME ŞEKLİ" KALDIRILDI
--
--  Kullanıcı (25.10.2026): "Satış Koşulları'nda ödeme şeklini kaldır, db'den de sil".
--  taraf_musteri.odeme_sekli (1152) kartın Satış Koşulları kutusundan kalktı; kolon da düşürülür.
--  Silmeden önce: UNIVERSE / gentegre_ai / gentegre_ai_test'te dolu (≠ 0) satır YOK; kolonu okuyan görünüm /
--  fonksiyon yok (taraf_tedarikci'de bu kolon hiç oluşmadı - 1162'nin "create table if not exists"i atlandı).
--  Yine de dolu satır varsa YEDEKLENİR (taraf_musteri_odeme_sekli_yedek_1181) ve sonra düşürülür.
--  İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

do $$
begin
  if exists (select 1 from information_schema.columns
              where table_schema = 'public' and table_name = 'taraf_musteri' and column_name = 'odeme_sekli') then
    if exists (select 1 from public.taraf_musteri where coalesce(odeme_sekli, 0) <> 0) then
      create table if not exists public.taraf_musteri_odeme_sekli_yedek_1181 as
        select id, odeme_sekli, now() as yedek_an from public.taraf_musteri where coalesce(odeme_sekli, 0) <> 0;
      raise notice '1181: dolu odeme_sekli satırları taraf_musteri_odeme_sekli_yedek_1181 tablosuna yedeklendi';
    end if;
    alter table public.taraf_musteri drop column odeme_sekli;
  end if;
end $$;

commit;
