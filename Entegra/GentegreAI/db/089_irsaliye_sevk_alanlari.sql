-- ============================================================================
--  Gentegre AI — Irsaliye sevkiyat alanlari (arac / sofor / teslim eden)
--  089_irsaliye_sevk_alanlari.sql
--
--  Ekranlar/satis_irsaliye_listesi.html "ARAC / SOFOR" ve "TESLIM EDEN"
--  kolonlarini istiyor; bunlarin karsiligi `belge` tablosunda yoktu.
--
--  Bu alanlar SUS DEGIL: e-Irsaliye UBL'inde Shipment/Delivery altinda tasiyici
--  arac plakasi ve sofor kimligi ZORUNLU alanlardir (GIB, ROAD tasima). Kagit
--  irsaliyede de matbu form uzerinde yer alir. Serbest metin degil ayri kolonlar
--  olarak tutulur ki XML uretiminde ayiklamaya gerek kalmasin.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.belge add column if not exists arac_plaka     varchar(20) not null default '';
alter table public.belge add column if not exists sofor_ad       varchar(60) not null default '';
alter table public.belge add column if not exists sofor_tckn     varchar(11) not null default '';
alter table public.belge add column if not exists tasiyici_id    integer;
alter table public.belge add column if not exists teslim_eden_id integer;

comment on column public.belge.arac_plaka is
  'Sevkiyat aracinin plakasi. e-Irsaliye UBL: Shipment/ShipmentStage/TransportMeans PlateID.';
comment on column public.belge.sofor_ad is
  'Sofor adi soyadi. e-Irsaliye UBL: DriverPerson.';
comment on column public.belge.sofor_tckn is
  'Sofor TCKN (11 hane). e-Irsaliye UBL: DriverPerson/ID schemeID=TCKN.';
comment on column public.belge.tasiyici_id is
  'Nakliyeyi yapan firma (taraf). Kendi aracimizsa bos.';
comment on column public.belge.teslim_eden_id is
  'Mali fiilen teslim eden personel/kisi (taraf). Satis temsilcisinden (satici_id) FARKLI olabilir.';

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'fk_belge_tasiyici') then
        alter table public.belge add constraint fk_belge_tasiyici
            foreign key (tasiyici_id) references public.taraf(id);
    end if;
    if not exists (select 1 from pg_constraint where conname = 'fk_belge_teslim_eden') then
        alter table public.belge add constraint fk_belge_teslim_eden
            foreign key (teslim_eden_id) references public.taraf(id);
    end if;
end $$;

-- Irsaliye listesi tarih + tur uzerinden suzulur; mevcut ix_belge_kapanma
--   yalniz acik kayitlari kapsiyor, liste TUM irsaliyeleri gosterir.
create index if not exists ix_belge_tur_tarih on public.belge (tur, belge_tarihi desc, id desc);

do $$
declare v integer;
begin
    select count(*) into v from information_schema.columns
     where table_name = 'belge' and column_name in
       ('arac_plaka','sofor_ad','sofor_tckn','tasiyici_id','teslim_eden_id');
    raise notice '089 tamam: sevk alani %/5', v;
end $$;
