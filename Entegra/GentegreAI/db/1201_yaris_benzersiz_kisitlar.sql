-- ============================================================================
--  1201 — YARIŞ KOŞULLARINA KARŞI BENZERSİZ KISITLAR
--
--  Kod inceleme raporu 30.10.2026 (dokuman/KOD_INCELEME_RAPORU_2026-10-30.md):
--    K13  oku-sonra-yaz + koşulsuz UPDATE → eşzamanlı iki istekte çift işlem
--    K57  üretim maliyet kapanışı aynı emre iki kez yazılabiliyor (uretim_maliyet)
--    K58  satınalma kabul tutanağı aynı belgeye iki kez açılabiliyor
--         (satinalma_kabul); steril döngü sayacı "oku + 1 yaz" olduğu için aynı
--         cihazda aynı sayaç numarasıyla iki döngü açılabiliyor (steril_dongu)
--
--  Uçlar artık satır kilidi (`for update`) + koşullu UPDATE + etkilenen satır
--  kontrolüyle yazıyor (UretimUclari, SatinalmaUclari.Siparis, SterilUclari.Islem);
--  bu indeksler SON SİGORTA: kaçan ikinci kayıt 23505 → 422 ile döner (VeriHatasi).
--
--  MEVCUT VERİ: çakışan satır varsa hiçbir satır silinmez / değiştirilmez.
--  İndeks o tabloda yalnız YENİ kayıtlara (id > göç anındaki en büyük id)
--  kısmi olarak uygulanır ve WARNING ile bildirilir; çakışanlar betiğin
--  sonundaki rapor sorgularıyla listelenir - temizlik ayrı bir karardır.
--  Yeniden çalıştırılabilir: indeks varsa dokunulmaz.
-- ============================================================================
\set ON_ERROR_STOP on
begin;

-- ---------------------------------------------------------------- satinalma_kabul
do $$
declare cak int; sinir bigint;
begin
    if to_regclass('public.ux_satinalma_kabul_belge') is not null then
        raise notice '1201: ux_satinalma_kabul_belge zaten var, atlandı';
        return;
    end if;
    select count(*) into cak
      from (select belge_id from public.satinalma_kabul group by belge_id having count(*) > 1) x;
    if cak = 0 then
        create unique index ux_satinalma_kabul_belge on public.satinalma_kabul (belge_id);
    else
        select coalesce(max(id), 0) into sinir from public.satinalma_kabul;
        raise warning '1201: satinalma_kabul - % belgede birden çok tutanak var; ux_satinalma_kabul_belge yalnız id > % olan yeni kayıtlara uygulandı (rapor sorgusu betiğin sonunda)', cak, sinir;
        execute format('create unique index ux_satinalma_kabul_belge on public.satinalma_kabul (belge_id) where id > %s', sinir);
    end if;
end $$;

comment on index public.ux_satinalma_kabul_belge is
  '1201 (K58): bir belgenin tek kabul tutanağı olur; eşzamanlı ikinci açılış 23505 ile düşer.';

-- --------------------------------------------------------------------- steril_dongu
do $$
declare cak int; sinir bigint;
begin
    if to_regclass('public.ux_steril_dongu_cihaz_sayac') is not null then
        raise notice '1201: ux_steril_dongu_cihaz_sayac zaten var, atlandı';
        return;
    end if;
    select count(*) into cak
      from (select cihaz_id, sayac_no from public.steril_dongu group by cihaz_id, sayac_no having count(*) > 1) x;
    if cak = 0 then
        create unique index ux_steril_dongu_cihaz_sayac on public.steril_dongu (cihaz_id, sayac_no);
    else
        select coalesce(max(id), 0) into sinir from public.steril_dongu;
        raise warning '1201: steril_dongu - % cihaz/sayaç çiftinde birden çok döngü var; ux_steril_dongu_cihaz_sayac yalnız id > % olan yeni kayıtlara uygulandı', cak, sinir;
        execute format('create unique index ux_steril_dongu_cihaz_sayac on public.steril_dongu (cihaz_id, sayac_no) where id > %s', sinir);
    end if;
end $$;

comment on index public.ux_steril_dongu_cihaz_sayac is
  '1201 (K58): cihaz başına döngü sayacı tekil; sayaç artık update … returning ile DB''de artar.';

-- ------------------------------------------------------------------- uretim_maliyet
do $$
declare cak int; sinir bigint;
begin
    if to_regclass('public.ux_uretim_maliyet_emir') is not null then
        raise notice '1201: ux_uretim_maliyet_emir zaten var, atlandı';
        return;
    end if;
    select count(*) into cak
      from (select emir_id from public.uretim_maliyet group by emir_id having count(*) > 1) x;
    if cak = 0 then
        create unique index ux_uretim_maliyet_emir on public.uretim_maliyet (emir_id);
    else
        select coalesce(max(id), 0) into sinir from public.uretim_maliyet;
        raise warning '1201: uretim_maliyet - % emirde birden çok kapanış var; ux_uretim_maliyet_emir yalnız id > % olan yeni kayıtlara uygulandı', cak, sinir;
        execute format('create unique index ux_uretim_maliyet_emir on public.uretim_maliyet (emir_id) where id > %s', sinir);
    end if;
end $$;

comment on index public.ux_uretim_maliyet_emir is
  '1201 (K57): bir emrin tek maliyet kapanışı olur; ikinci kapanış mamul giriş fiyatını yeniden ezerdi.';

commit;

-- ============================================================================
--  RAPOR (veri değiştirmez): göç sırasında WARNING görüldüyse çakışan satırlar.
--  Hangisinin kalacağına kullanıcı karar verir; temizlik ayrı bir göçtür.
-- ============================================================================
select 'satinalma_kabul' as tablo, belge_id::text as anahtar, count(*) as adet, string_agg(id::text, ', ' order by id) as idler
  from public.satinalma_kabul group by belge_id having count(*) > 1
union all
select 'steril_dongu', cihaz_id || '/' || sayac_no, count(*), string_agg(id::text, ', ' order by id)
  from public.steril_dongu group by cihaz_id, sayac_no having count(*) > 1
union all
select 'uretim_maliyet', emir_id::text, count(*), string_agg(id::text, ', ' order by id)
  from public.uretim_maliyet group by emir_id having count(*) > 1
order by 1, 2;
