-- 1363 - Hasta Fişi çevrimi: kurumsuz başvurunun pay 0 tahakkukları (kod inceleme 17.11.2026).
--   1360 eski hasta tahakkuklarını yalnız satırları hasta kovasında (pay 1 / 4) olanlarla çevirdi. Sunucu kuralı
--   (BelgeDeposu.DonusturAsync) ise ödeyen kurumu olmayan başvuruda pay 0'ı da hasta payı sayar - o yoldan kesilmiş
--   eski 17'ler "Kurum Tahakkuku" görünüp kurum takibinde kalıyordu. Ölçüt artık sunucuyla aynı:
--     başvurudan (kaynak_tur 30), başvurunun hastasına kesilmiş 17; satırları pay 1 / 4, ya da başvurunun ödeyen
--     kurumu yoksa pay 0 da.
--   Belge + mali hareket 128 olur; yedek 1360'ın tablosuna eklenir (yedek.hasta_fisi_1360). Tekrar çalıştırılabilir.

create schema if not exists yedek;
create table if not exists yedek.hasta_fisi_1360 (belge_id integer primary key, belge_no varchar(40),
       taraf_id integer, genel_toplam numeric, eski_tur smallint, yedek_zamani timestamptz default now());

do $$
declare v_sayi integer;
begin
  create temp table _hf2 on commit drop as
  select b.id
    from public.belge b
    join public.belge k on k.id = b.kaynak_id
    join public.belge_basvuru bb on bb.id = k.id
   where b.tur = 17 and b.kaynak_tur = 30 and b.taraf_id = k.taraf_id
     and exists (select 1 from public.belge_satir s where s.belge_id = b.id)
     and not exists (select 1 from public.belge_satir s
                      where s.belge_id = b.id
                        and not (coalesce(s.pay, 0) in (1, 4) or (coalesce(s.pay, 0) = 0 and bb.odeyen_kurum_id is null)));

  insert into yedek.hasta_fisi_1360 (belge_id, belge_no, taraf_id, genel_toplam, eski_tur)
  select b.id, b.belge_no, b.taraf_id, b.genel_toplam, b.tur from public.belge b join _hf2 on _hf2.id = b.id
  on conflict (belge_id) do nothing;

  update public.belge b set tur = 128 from _hf2 where _hf2.id = b.id;
  get diagnostics v_sayi = row_count;
  update public.mali_hareket m set tur = 128 from _hf2 where _hf2.id = m.belge_id and m.tur = 17;
  raise notice '1363: % kurumsuz başvuru tahakkuku Hasta Fişi (128) oldu', v_sayi;
end $$;
