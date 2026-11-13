-- 1336 - Depolu belgede DEPOSU BOŞ satırlar başlıktan doldurulur (1335'in devamı).
--
-- Kullanıcı 13.11.2026: "depo bilgisi satırlarda tutuluyor mu" → evet (belge_satir.giris_depo_id / cikis_depo_id,
--   kayıtta başlıktan kopyalanır; okuma coalesce(satır, başlık)). "ekle, satırları da başlıktan doldursun".
--
-- Kuraldan (11.11.2026) önce yazılmış satırlarda depo boş kalmış olabilir (UNIVERSE 10290'ın satırı). Okuma yolu
--   başlığa düştüğü için stok hesabı doğruydu; bu göç veriyi tam tutarlı yapar: satırın boş depo alanı, başlığın
--   AYNI alanı doluysa ondan doldurulur. Dolu satır alanına DOKUNULMAZ (satır kendi deposunu taşıyabilir).
--   Başlığı da boş olan belge (1335'in atladığı iki depolu belgeler) burada da boş kalır.
--
-- KAPSAM: 1335 ile aynı depolu tür kümesi (BelgeTuru.DepoZorunlu). Yedek: public.yedek_1336_belge_satir_depo.
\set ON_ERROR_STOP on
begin;

create table if not exists public.yedek_1336_belge_satir_depo (
    satir_id          integer primary key,
    belge_id          integer not null,
    yeni_giris_depo   integer,
    yeni_cikis_depo   integer,
    tarih             timestamptz not null default now()
);
comment on table public.yedek_1336_belge_satir_depo is
  '1336: başlıktan doldurulan satır depoları (eski değer null idi). Geri almak: listedeki satırların alanlarını null yap.';

do $$
declare
    v_sayi integer;
begin
    create temp table zz_1336 on commit drop as
    select s.id as satir_id, s.belge_id,
           case when s.giris_depo_id is null and b.giris_depo_id is not null then b.giris_depo_id end as yeni_giris,
           case when s.cikis_depo_id is null and b.cikis_depo_id is not null then b.cikis_depo_id end as yeni_cikis
      from public.belge_satir s
      join public.belge b on b.id = s.belge_id
     where b.tur not in (13, 17, 18, 19)
       and (b.tur in (4, 14, 15, 16, 17, 29, 105, 119, 121, 123, 133)
            or b.tur in (9, 10, 11, 12, 109, 20, 122)
            or b.tur in (3, 4))
       and ((s.giris_depo_id is null and b.giris_depo_id is not null)
            or (s.cikis_depo_id is null and b.cikis_depo_id is not null));

    insert into public.yedek_1336_belge_satir_depo (satir_id, belge_id, yeni_giris_depo, yeni_cikis_depo)
    select satir_id, belge_id, yeni_giris, yeni_cikis from zz_1336
    on conflict (satir_id) do nothing;

    update public.belge_satir s
       set giris_depo_id = coalesce(s.giris_depo_id, z.yeni_giris),
           cikis_depo_id = coalesce(s.cikis_depo_id, z.yeni_cikis)
      from zz_1336 z
     where z.satir_id = s.id;
    get diagnostics v_sayi = row_count;

    raise notice '1336: % satırın deposu başlıktan dolduruldu (yedek: yedek_1336_belge_satir_depo)', v_sayi;
end $$;

commit;
