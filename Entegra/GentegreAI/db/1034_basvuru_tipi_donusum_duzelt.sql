-- 1034: BASVURUDAN DOGAN BELGEDE TIPI 30 (kullanici 11.10.2026: fatura kartinda
--   "Fatura Tipi: Tanımsız (30)"). Donusum basvurunun tipini (30 = basvuru,
--   yalniz tur 19'da anlamli) hedefe kopyaliyordu. Kod duzeltildi
--   (BelgeDeposu.Donusum); burada mevcut kayitlar.
--
-- YALNIZ KANITLANMIS YANLIS satirlar: tur <> 19 ve tipi = 30. 30 hicbir
--   fatura / fis / tahakkuk tipi degil (belge.fatura_tipi listesinde yok),
--   dogru deger normal satis (1). Once yedeklenir; tekrar calistirilinca
--   degisecek satir kalmaz.

create table if not exists public._yedek_belge_tipi_1034 as
select id, tur, tipi, now() as yedek_tarihi
  from public.belge where tur <> 19 and tipi = 30;

insert into public._yedek_belge_tipi_1034 (id, tur, tipi, yedek_tarihi)
select b.id, b.tur, b.tipi, now()
  from public.belge b
 where b.tur <> 19 and b.tipi = 30
   and not exists (select 1 from public._yedek_belge_tipi_1034 y where y.id = b.id);

do $$
declare n integer;
begin
    update public.belge set tipi = 1 where tur <> 19 and tipi = 30;
    get diagnostics n = row_count;
    raise notice '1034: % belgenin tipi 30 -> 1 duzeltildi.', n;
end $$;
