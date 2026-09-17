-- ============================================================================
--  Gentegre AI — ESKİ DOKÜMAN AKIŞ TANIMI TABLOLARI DÜŞÜYOR
--  760_dokuman_akis_tablolari_dusuyor.sql
--
--  Kullanıcı: "dokuman_akis tablolarını da düşür."
--
--  758 doküman onayını omurgaya taşırken akış TANIMINI da `onay_akis` /
--  `onay_akis_adim`a kopyalamış, `dokuman.akis_id` ve
--  `dokuman_kategori.akis_id` kolonlarını yeni id'lere çevirmiş ama eski
--  tabloları yerinde bırakmıştı. 759 yürüyen süreç tablolarını düşürmüştü;
--  bu dosya tanım tablolarını düşürüyor.
--
--  ============ ÜÇ KANIT ARANIR ========================================
--  Tablo silmek geri alınamaz. Dosya durmadan önce üç şeyi doğruluyor:
--
--    1) her `dokuman_akis` satırının omurgada karşılığı var mı
--       (`onay_akis.kod = 'dokuman.<eski id>'`),
--    2) her `dokuman_akis_adim` satırının bir `onay_akis_adim` karşılığı
--       var mı (aynı sırada),
--    3) `dokuman` ve `dokuman_kategori`nin `akis_id`leri artık GERÇEKTEN
--       `onay_akis`i gösteriyor mu.
--
--  Üçüncüsü en önemlisi: 758'in kolon güncellemesi eksik kalmış olsaydı,
--  tabloyu düşürmek o dokümanları var olmayan bir akışa bağlı bırakır ve
--  bir daha onaya gönderilemezlerdi. Eksik varsa dosya HATA VEREREK DURUR.
--
--  ============ KOLONLARA DOKUNULMUYOR =================================
--  `dokuman.akis_id` / `dokuman_kategori.akis_id`e FK KONULMUYOR. Omurgada
--  akış silinebilir (aktif = 0 yapılır ama silinebilir de) ve FK, kurumun
--  kullanmadığı bir akışı silmesini engellerdi; bağ zaten 758'den beri
--  `onay_akis` üzerinden okunuyor ve okuma yolu (`v_dokuman_akis_lookup`)
--  geçersiz id'yi boş gösterir.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare
  v_eksik_akis  int;
  v_eksik_adim  int;
  v_yetim_dok   int;
  v_yetim_kat   int;
begin
    select count(*) into v_eksik_akis
      from public.dokuman_akis a
     where not exists (select 1 from public.onay_akis k
                        where k.kod = 'dokuman.' || a.id::text);

    select count(*) into v_eksik_adim
      from public.dokuman_akis_adim d
      join public.onay_akis k on k.kod = 'dokuman.' || d.akis_id::text
     where not exists (select 1 from public.onay_akis_adim x
                        where x.akis_id = k.id and x.sira = d.sira);

    -- AKIŞA BAĞLI KAYITLAR omurgayı göstermeli.
    select count(*) into v_yetim_dok
      from public.dokuman d
     where d.akis_id is not null
       and not exists (select 1 from public.onay_akis k where k.id = d.akis_id);

    select count(*) into v_yetim_kat
      from public.dokuman_kategori t
     where t.akis_id is not null
       and not exists (select 1 from public.onay_akis k where k.id = t.akis_id);

    if v_eksik_akis > 0 or v_eksik_adim > 0 or v_yetim_dok > 0 or v_yetim_kat > 0 then
        raise exception
          'GOC EKSIK - tablolar DUSURULMEDI. Omurgada karsiligi olmayan: '
          '% akis, % adim. Gecersiz akis_id tasiyan: % dokuman, % kategori. '
          'Once 758 gocu uygulanmali.',
          v_eksik_akis, v_eksik_adim, v_yetim_dok, v_yetim_kat
          using errcode = 'GK422';
    end if;

    raise notice '760: goc dogrulandi, akis tanimi tablolari dusurulebilir.';
end $$;

-- `dokuman_akis_adim` `dokuman_akis`ın çocuğu (FK); birlikte gider.
drop table if exists public.dokuman_akis_adim;
drop table if exists public.dokuman_akis;

comment on column public.dokuman.akis_id is
  '758/760: onay_akis.id. Eski dokuman_akis tablosu 760''ta dusuruldu.';
comment on column public.dokuman_kategori.akis_id is
  '758/760: onay_akis.id. Yeni dokumanin akisi buradan kopyalanir.';

do $$
declare v_kalan int;
begin
    select count(*) into v_kalan from information_schema.tables
     where table_schema = 'public'
       and table_name in ('dokuman_akis', 'dokuman_akis_adim');
    raise notice '760 tamam: dokuman akis tanimi tablolari dusuruldu (kalan %).',
                 v_kalan;
end $$;
