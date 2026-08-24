-- ============================================================================
--  Gentegre AI — STOK ÜTS / MEDIKAL BILGILERI
--  119_stok_uts.sql
--
--  Stok kartindaki "ÜTS Bilgileri" sekmesi (Ekranlar/stok_karti.html; Delphi
--  karsiligi UStokWizard.TabSheetUTS) yer tutucuydu - alanlarin tablosu yoktu.
--
--  Alanlar eski sistemde STOKLAR_USER tablosundadir (stok kartinin "kullanici
--  alanlari" uzantisi). ÜTS ile ilgili olanlar buraya alinir; ayni tablodaki
--  TEditYABANCI_URUN_AD / UE_Gosterme / FATURA_STOK_KODU ÜTS DEGIL (sonuncusu
--  zaten stok.fatura_stok_adi olarak kartta var) - tasinmadi.
--
--  1:1 UZANTI: stok_id hem birincil anahtar hem yabanci anahtar. Ayri tablo
--  cunku alanlar yalniz medikal urunlerde dolu; stok tablosunu 13 bos kolonla
--  genisletmenin anlami yok (taraf_musteri / kredi ile ayni desen).
--
--  MENSEI ULKE public.ulke'ye baglanir. Kart secim listeleri "id, ad, aktif"
--  bekledigi icin gorunum acilir (ulke tablosunda aktif kolonu yok).
--
--  Gocmus veri: BILIM'de 4.315 STOKLAR_USER satirindan yalnizca IKISINDE ÜTS
--  alani dolu - onlar da asagida tohumlanir.
-- ============================================================================
\set ON_ERROR_STOP on

create table if not exists public.stok_uts (
    stok_id           integer primary key references public.stok(id) on delete cascade,
    sut_kodu          varchar(50)  not null default '',
    brans_kodu        varchar(100) not null default '',
    uts_ref           varchar(100) not null default '',   -- katalog no
    ftn               varchar(100) not null default '',
    gmdn              varchar(100) not null default '',
    gmdn_adi          varchar(300) not null default '',
    diger_urun_adi    varchar(300) not null default '',
    medikal_sinif     smallint     not null default 0,
    ithal_imal        smallint     not null default 0,     -- 0 İthal · 1 İmal
    mensei_ulke       smallint,
    ihale_sira_no     varchar(100) not null default '',
    dmo_kodu          varchar(40)  not null default '',
    sm_kodu           varchar(40)  not null default '',
    ekleyen           integer      not null default 0,
    ekleme_tarihi     timestamp    not null default now()::timestamp,
    degistiren        integer      not null default 0,
    degistirme_tarihi timestamp
);

comment on table public.stok_uts is
  'Stokun ÜTS / medikal bilgileri (119). Eski STOKLAR_USER''in ÜTS alanlari; 1:1 uzanti.';
comment on column public.stok_uts.uts_ref is
  'ÜTS REF (katalog no). GTIN ile birlikte ÜTS bildiriminde urun eslestirmesinde kullanilir.';
comment on column public.stok_uts.ithal_imal is '0 İthal · 1 İmal';

do $$
begin
    if not exists (select 1 from pg_trigger where tgname = 'trg_stok_uts_degistirme') then
        create trigger trg_stok_uts_degistirme before update on public.stok_uts
            for each row execute function public.fn_degistirme_tarihi();
    end if;
    if not exists (select 1 from pg_constraint where conname = 'fk_stok_uts_ulke') then
        alter table public.stok_uts add constraint fk_stok_uts_ulke
            foreign key (mensei_ulke) references public.ulke(id);
    end if;
end $$;

create index if not exists ix_stok_uts_ref on public.stok_uts (uts_ref) where uts_ref <> '';

-- ------------------------------------------------------------- kod listeleri --
insert into public.kod_liste (kod, ad) values
    ('stok.medikal_sinif', 'Medikal Sınıf'),
    ('stok.ithal_imal', 'İthal / İmal')
on conflict (kod) do nothing;

insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
select kl.id, d.deger, d.ad, d.sira, 1
  from public.kod_liste kl
  join (values ('stok.medikal_sinif', 1, 'Sınıf I',   10),
               ('stok.medikal_sinif', 2, 'Sınıf IIa', 20),
               ('stok.medikal_sinif', 3, 'Sınıf IIb', 30),
               ('stok.medikal_sinif', 4, 'Sınıf III', 40),
               ('stok.ithal_imal',    0, 'İthal',     10),
               ('stok.ithal_imal',    1, 'İmal',      20)
       ) as d(liste, deger, ad, sira) on d.liste = kl.kod
 where not exists (select 1 from public.kod_deger k
                    where k.liste_id = kl.id and k.deger = d.deger);

-- Menseı ulke secimi: kart alanlari "id, ad, aktif" bekler.
create or replace view public.v_ulke_lookup as
select id, ad, 1 as aktif from public.ulke;

comment on view public.v_ulke_lookup is 'Ulke secim listesi (119).';

-- ------------------------------------------------------------------- tohum ---
-- BILIM.STOKLAR_USER'da ÜTS alani DOLU olan iki kayit. Stok yoksa atlanir.
insert into public.stok_uts (stok_id, sut_kodu, medikal_sinif, ithal_imal,
                             mensei_ulke, dmo_kodu, sm_kodu)
select v.stok_id, v.sut_kodu, v.medikal_sinif, v.ithal_imal,
       (select u.id from public.ulke u where u.id = v.mensei_ulke), v.dmo_kodu, v.sm_kodu
  from (values (54, '',          1, 0, 101, 'ttyyyy', '1122'),
               (86, '123456789', 1, 0, null, '',      '')
       ) as v(stok_id, sut_kodu, medikal_sinif, ithal_imal, mensei_ulke, dmo_kodu, sm_kodu)
 where exists (select 1 from public.stok s where s.id = v.stok_id)
on conflict (stok_id) do nothing;

do $$
declare v_satir integer; v_ulke integer;
begin
    select count(*) into v_satir from public.stok_uts;
    select count(*) into v_ulke from public.ulke;
    raise notice '119 tamam: stok_uts % satir, ulke listesi % kayit', v_satir, v_ulke;
end $$;
