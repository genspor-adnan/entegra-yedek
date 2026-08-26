-- ============================================================================
--  Gentegre AI — SEVKIYAT BILGILERI AYRI TABLOYA (belge_sevkiyat)
--  177_belge_sevkiyat.sql
--
--  Kullanici: "belge_sevkiyat tablosu olustur, 1'e 1 ID'si belge.id'ye esit ve
--  sevkiyat alanlarini belgeden buraya tasi."
--
--  NEDEN: sevkiyat alanlari (plaka, sofor, tasiyici, teslim eden/alan, teslim
--  sekli) YALNIZ irsaliyede doluyor; `belge` tablosunun her satirinda bos
--  duruyorlardi. e-Irsaliye tarafi buyudukce (dorse plakasi, sevk adresi,
--  cikis/varis saati, tasima sekli, kap bilgisi) bu alanlar artacak - hepsini
--  ana tabloya eklemek 60+ kolonluk `belge`yi daha da sisirirdi.
--
--  1:1 UZANTI (`taraf_musteri` / `kredi` deseni): id = belge.id, ayri sequence
--  YOK. Satir yalnizca sevkiyat bilgisi GIRILDIGINDE acilir; irsaliye olmayan
--  belgede hic satir olmaz. Silme CASCADE - belge silinince sevkiyati da gider.
--
--  TASINMAYANLAR ve sebepleri:
--    cikis_depo_id / giris_depo_id -> STOK hareketinin kaynagi, sevkiyat degil;
--        belge yazicisi her turde kullaniyor.
--    irsaliye_no / irsaliye_tarihi -> faturanin KAYNAK irsaliye referansi
--        (despatchDocumentReference); irsaliyenin kendi sevk bilgisi degil.
--    belge_tarihi -> sevk tarihi olarak da kullaniliyor ama belgenin tarihi.
-- ============================================================================
\set ON_ERROR_STOP on

create table if not exists public.belge_sevkiyat (
    -- ID = belge.id: ayri anahtar yok, bag birebir.
    id                integer primary key references public.belge(id) on delete cascade,
    -- 0 belirtilmemis / 1 alici adresine / 2 alici kendi araciyla / 3 kargo-nakliye /
    --   4 depoda teslim / 5 yurt disi sevk (kod listesi: belge.teslim_sekli)
    teslim_sekli      smallint     not null default 0,
    -- e-Irsaliye UBL: Shipment/ShipmentStage/TransportMeans PlateID
    arac_plaka        varchar(20)  not null default '',
    -- e-Irsaliye UBL: DriverPerson (ad+soyad ZORUNLU) / ID schemeID=TCKN
    sofor_ad          varchar(100) not null default '',
    sofor_tckn        varchar(11)  not null default '',
    -- Nakliyeyi yapan firma. Kendi aracimizsa bos (UBL: carrierParty).
    tasiyici_id       integer      null references public.taraf(id),
    -- Mali fiilen teslim eden personel/kisi; satis temsilcisinden farkli olabilir.
    teslim_eden_id    integer      null references public.taraf(id),
    -- Mali teslim alan personel; stok transferinde zorunlu (100).
    teslim_alan_id    bigint       null,
    ekleyen           integer      not null default 0,
    ekleme_tarihi     timestamp    not null default now()::timestamp,
    degistiren        integer      not null default 0,
    degistirme_tarihi timestamp
);

comment on table public.belge_sevkiyat is
  'Belgenin SEVKIYAT bilgileri - 1:1 uzanti, id = belge.id. Yalniz irsaliyede dolar (177).';

create index if not exists ix_belge_sevkiyat_tasiyici on public.belge_sevkiyat(tasiyici_id)
    where tasiyici_id is not null;

-- ------------------------------------------------------------------ goc ----
-- Yalniz DOLU olan satirlar tasinir: bos sevkiyatli belgeye kayit acmak,
--   tablonun "sevkiyat bilgisi var mi" anlamini bozardi.
do $$
declare v_adet integer;
begin
    if not exists (select 1 from information_schema.columns
                    where table_name = 'belge' and column_name = 'arac_plaka') then
        raise notice '177: kolonlar zaten tasinmis, goc atlandi.';
        return;
    end if;

    insert into public.belge_sevkiyat (id, teslim_sekli, arac_plaka, sofor_ad, sofor_tckn,
                                       tasiyici_id, teslim_eden_id, teslim_alan_id,
                                       ekleyen, ekleme_tarihi)
    select b.id, coalesce(b.teslim_sekli, 0), coalesce(b.arac_plaka, ''),
           coalesce(b.sofor_ad, ''), coalesce(b.sofor_tckn, ''),
           nullif(b.tasiyici_id, 0), nullif(b.teslim_eden_id, 0), nullif(b.teslim_alan_id, 0),
           b.ekleyen, b.ekleme_tarihi
      from public.belge b
     where coalesce(b.teslim_sekli, 0) <> 0
        or coalesce(btrim(b.arac_plaka), '') <> ''
        or coalesce(btrim(b.sofor_ad), '') <> ''
        or coalesce(btrim(b.sofor_tckn), '') <> ''
        or coalesce(b.tasiyici_id, 0) <> 0
        or coalesce(b.teslim_eden_id, 0) <> 0
        or coalesce(b.teslim_alan_id, 0) <> 0
    on conflict (id) do nothing;

    get diagnostics v_adet = row_count;
    raise notice '177: % belgenin sevkiyat bilgisi tasindi.', v_adet;

    alter table public.belge
        drop column teslim_sekli,
        drop column arac_plaka,
        drop column sofor_ad,
        drop column sofor_tckn,
        drop column tasiyici_id,
        drop column teslim_eden_id,
        drop column teslim_alan_id;
end $$;

-- --------------------------------------------------------------- gorunum ----
-- Okuyan taraf JOIN yazmasin diye: sevkiyati olmayan belgede de satir doner
--   (bos degerlerle), boylece "left join + coalesce" her yerde tekrarlanmaz.
create or replace view public.v_belge_sevkiyat as
    select b.id                                     as belge_id,
           coalesce(s.teslim_sekli, 0)              as teslim_sekli,
           coalesce(s.arac_plaka, '')               as arac_plaka,
           coalesce(s.sofor_ad, '')                 as sofor_ad,
           coalesce(s.sofor_tckn, '')               as sofor_tckn,
           s.tasiyici_id,
           s.teslim_eden_id,
           s.teslim_alan_id,
           (s.id is not null)                       as sevkiyat_var
      from public.belge b
      left join public.belge_sevkiyat s on s.id = b.id;

comment on view public.v_belge_sevkiyat is
  'Belge + sevkiyat: kaydi olmayan belgede bos degerler doner (177).';

do $$
begin
    raise notice '177 tamam: belge_sevkiyat (1:1) + v_belge_sevkiyat.';
end $$;
