-- ============================================================================
--  Gentegre AI — ADAY MÜŞTERİ
--  122_aday_musteri.sql
--
--  Satis firsati (121) henuz musteri OLMAYAN bir firmayla da acilir. Bugune
--  kadar boyle bir kayit acmak icin onu "musteri" isaretlemek gerekiyordu:
--  musteri listesi hic alisveris yapmamis firmalarla doluyor, cari bakiye
--  raporlari anlamsizlasiyordu.
--
--  AYRI TABLO ACMIYORUZ (kullanici karari): aday da bir TARAF'tir. Ayri tablo
--  olsaydi anlasma saglanınca butun kayit (adres, ilgili kisi, gorev, firsat
--  gecmisi) yeni bir id'ye TASINACAKTI - firsat ve gorevlerin bagi kirilirdi.
--  Rol bayragi eklenir; donusum tek alan degisimidir, gecmis oldugu yerde kalir.
--
--  taraf.aday = 1 -> "Aday Müşteriler" listesinde gorunur.
--  Anlasma saglaninca musteri = 1, aday = 0: kayit normal Musteri Listesi'ne
--  gecer, id'si ve butun gecmisi AYNI kalir.
--
--  OTOMATIK DONUSUM: firsat "Kazanıldı"ya (durum 2) gecince aday musteriye
--  cevrilir - tetikle, cunku bunu ekrana birakmak "kazandik ama hala aday"
--  kayitlari uretir. Elle donusturme de mumkun (Aday listesindeki aksiyon).
--
--  TERIM NOTU: karsit terim "kesin musteri" DEGIL sadece "Müşteri" - CRM
--  dilinde aday/potansiyel (prospect) karsisinda musteri (customer) durur.
--  Ekranda "Aday Müşteriler" ve "Müşteri Listesi" olarak ayrilir.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.taraf add column if not exists aday smallint not null default 0;

comment on column public.taraf.aday is
  'Aday (potansiyel) musteri (122). Anlasma saglaninca musteri = 1, aday = 0 yapilir; kayit ve gecmisi ayni kalir.';

create index if not exists ix_taraf_aday on public.taraf (aday) where aday = 1;

-- Cari secim listeleri ADAYLARI da gostermeli: firsat ve gorev bir adayla da
--   acilir; aksi halde kullanici adayi secmek icin once musteri isaretlemek
--   zorunda kalir (bu gocun cozdugu sorunun ta kendisi).
create or replace view public.v_cari_lookup as
select id, unvan as ad, case when durum = 1 then 1 else 0 end as aktif
  from public.taraf
 where musteri = 1 or tedarikci = 1 or aday = 1;

comment on view public.v_cari_lookup is
  'Cari secim listesi: musteri, tedarikci ve ADAY (122).';

-- ------------------------------------------------------- otomatik donusum ---
create or replace function public.fn_firsat_kazanildi_musteri() returns trigger
language plpgsql as $$
begin
    -- Firsat KAZANILDI (durum 2) ve karsisindaki taraf henuz adaysa: musteri olur.
    if new.durum = 2 and coalesce(old.durum, 0) <> 2 and new.taraf_id is not null then
        update public.taraf
           set musteri = 1, aday = 0
         where id = new.taraf_id and aday = 1;
    end if;
    return new;
end $$;

comment on function public.fn_firsat_kazanildi_musteri() is
  'Firsat kazanilinca adayi musteriye cevirir (122).';

do $$
begin
    if not exists (select 1 from pg_trigger where tgname = 'trg_firsat_kazanildi') then
        create trigger trg_firsat_kazanildi after update on public.firsat
            for each row execute function public.fn_firsat_kazanildi_musteri();
    end if;
end $$;

do $$
declare v_aday integer; v_musteri integer;
begin
    select count(*) into v_aday from public.taraf where aday = 1;
    select count(*) into v_musteri from public.taraf where musteri = 1;
    raise notice '122 tamam: % aday, % musteri', v_aday, v_musteri;
end $$;
