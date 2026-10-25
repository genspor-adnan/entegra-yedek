-- =============================================================================
--  1183  CARİ "İSKONTO ORANI" ve "PARA BİRİMİ" KALDIRILDI
--
--  Kullanıcı (25.10.2026): "Satış Koşulları'ndan iskonto oranı ve para birimini kaldır" -> "db'den de sil".
--  Cariye özel iskonto kampanyayla verilir. taraf_musteri.iskonto_orani (017) ve doviz_cinsi (1152)
--  düşürülür. Silmeden önce: UNIVERSE / gentegre_ai / gentegre_ai_test'te dolu satır YOK; okuyan
--  görünüm / fonksiyon yok. Yine de dolu satır varsa YEDEKLENİR (taraf_musteri_yedek_1183) ve sonra
--  düşürülür. İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

do $$
declare
  v_isk boolean := exists (select 1 from information_schema.columns
                            where table_schema = 'public' and table_name = 'taraf_musteri' and column_name = 'iskonto_orani');
  v_dov boolean := exists (select 1 from information_schema.columns
                            where table_schema = 'public' and table_name = 'taraf_musteri' and column_name = 'doviz_cinsi');
begin
  if v_isk and v_dov then
    if exists (select 1 from public.taraf_musteri
                where coalesce(iskonto_orani, 0) <> 0 or coalesce(doviz_cinsi, '') <> '') then
      create table if not exists public.taraf_musteri_yedek_1183 as
        select id, iskonto_orani, doviz_cinsi, now() as yedek_an from public.taraf_musteri
         where coalesce(iskonto_orani, 0) <> 0 or coalesce(doviz_cinsi, '') <> '';
      raise notice '1183: dolu satırlar taraf_musteri_yedek_1183 tablosuna yedeklendi';
    end if;
  end if;
  if v_isk then alter table public.taraf_musteri drop column iskonto_orani; end if;
  if v_dov then alter table public.taraf_musteri drop column doviz_cinsi; end if;
end $$;

commit;
