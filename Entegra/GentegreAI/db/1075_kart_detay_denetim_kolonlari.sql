-- =============================================================================
--  1075  KARTIN YAZDIĞI DENETİM / ŞUBE KOLONLARI EKSİK TABLOLAR
--
--  Kullanıcı (13.10.2026): "katalog tutarlılık testlerini kur" (dokuman/17).
--  Yeni test KatalogSemaTestleri.Her_kartin_ve_detayin_yazdigi_kolonlar_tabloda_var
--  ilk koşuda 21 tablo buldu: generic kart (KartDeposu) kart / detay satırı
--  eklerken `ekleyen`, düzeltirken `degistiren`, detay satırına oturum şubesini
--  `sube_id`'ye yazar. Bu tablolarda kolon yoktu - o satırı ekleyen / düzelten
--  ilk kullanıcı "column ... does not exist" ile 500 alırdı. hata_log'da aynı
--  sınıftan 12 vaka var (taraf_hasta, stok_barkod, muayene_bulgu, lab_istem_test,
--  kalite_gosterge_deger...), her biri ayrı ayrı sonradan düzeltilmişti.
--
--  Yalnız EKSİK kolon eklenir (add column if not exists); mevcut veri değişmez.
--    ekleyen / degistiren : integer not null default 0 (kartın yazdığı kullanıcı)
--    degistirme_tarihi    : timestamptz (degistiren ile birlikte)
--    sube_id              : integer not null default 0 (detay satırı oturum şubesi;
--                           eski satırlar 0 - şubesiz)
--  İdempotent.
-- =============================================================================

begin;

do $$
declare
  r record;
begin
  for r in
    select * from (values
      ('acil_cagri',             array['degistiren']),
      ('acil_bildirim',          array['degistiren']),
      ('ameliyat_islem',         array['ekleyen', 'degistiren', 'sube_id']),
      ('ameliyat_ekip',          array['ekleyen', 'degistiren', 'sube_id']),
      ('ameliyat_kontrol',       array['sube_id']),
      ('ameliyat_sarf',          array['degistiren', 'sube_id']),
      ('ameliyat_sayim',         array['ekleyen', 'degistiren', 'sube_id']),
      ('ameliyat_komplikasyon',  array['degistiren', 'sube_id']),
      ('cagri_ilgili',           array['degistiren']),
      ('ftr_kabin',              array['sube_id']),
      ('taraf_acil_kisi',        array['sube_id']),
      ('lab_akilci_kural',       array['ekleyen', 'degistiren']),
      ('lab_besiyeri_numune',    array['ekleyen', 'degistiren']),
      ('lab_organizma_direnc',   array['degistiren']),
      ('lab_organizma_panel',    array['degistiren']),
      ('lab_refleks_kural',      array['degistiren']),
      ('taraf_prim_rol',         array['degistiren']),
      ('personel_masraf_satir',  array['degistiren']),
      ('sigorta_kod_esleme',     array['ekleyen', 'degistiren']),
      ('steril_dongu_indikator', array['degistiren'])
    ) as v(tablo, kolonlar)
  loop
    if to_regclass('public.' || r.tablo) is null then
      raise notice '1075: tablo yok, atlandı: %', r.tablo;
      continue;
    end if;
    if 'ekleyen' = any(r.kolonlar) then
      execute format('alter table public.%I add column if not exists ekleyen integer not null default 0', r.tablo);
      execute format('alter table public.%I add column if not exists ekleme_tarihi timestamptz not null default now()', r.tablo);
    end if;
    if 'degistiren' = any(r.kolonlar) then
      execute format('alter table public.%I add column if not exists degistiren integer not null default 0', r.tablo);
      execute format('alter table public.%I add column if not exists degistirme_tarihi timestamptz', r.tablo);
    end if;
    if 'sube_id' = any(r.kolonlar) then
      execute format('alter table public.%I add column if not exists sube_id integer not null default 0', r.tablo);
    end if;
  end loop;
end $$;

commit;
