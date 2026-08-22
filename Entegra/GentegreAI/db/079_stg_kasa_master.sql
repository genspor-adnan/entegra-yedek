-- ============================================================================
--  Gentegre AI — Kasa alt sistemi / goc hazirligi
--  079_stg_kasa_master.sql  —  MSSQL kasa/banka/pos/kredi master tablolari icin
--                              stg (staging) semasi
--
--  goc_al.ps1 PG'deki stg kolonlarina BAKARAK MSSQL'den yalniz o kolonlari
--    ceker (bkz. goc_al.ps1 "pgCols"). Bu yuzden burada TAM tablo degil,
--    goc icin GEREKLI kolonlar tanimlanir - gereksiz legacy kolon tasinmaz.
--
--  Kullanim sirasi:
--     1) bu dosya          -> stg tablolari
--     2) goc_al.ps1 -Tablolar KASALAR,BANKAHESAPLAR,POS,KREDIKARTI,KREDILER,SRMMERKEZI,PROJELER,PARA_KUPON
--     3) 080_goc_kasa.sql  -> stg -> public + mali_hareket.hesap_id remap + FK
-- ============================================================================
\set ON_ERROR_STOP on

create schema if not exists stg;

-- ---------------------------------------------------------------- KASALAR ----
drop table if exists stg.kasalar;
create table stg.kasalar (
    id                integer,
    kasakodu          varchar(30),
    kasaadi           varchar(150),
    kur               varchar(10),
    durum             smallint,
    kasatur           smallint,
    subeid            integer,
    rehberid          integer,
    hesapaciklama     varchar(300),
    bakiye            numeric(19,4)
);

-- --------------------------------------------------------- BANKAHESAPLAR ----
drop table if exists stg.bankahesaplar;
create table stg.bankahesaplar (
    id                integer,
    hesapkodu         varchar(30),
    hesapadi          varchar(150),
    hesapno           varchar(50),
    iban              varchar(50),
    kur               varchar(10),
    durum             smallint,
    subeid            integer,
    bankasubelerid    integer,
    hesapaciklama     varchar(300),
    bakiye            numeric(19,4)
);

-- -------------------------------------------------------------------- POS ----
drop table if exists stg.pos;
create table stg.pos (
    id                     integer,
    kodu                   varchar(30),
    adi                    varchar(150),
    kur                    varchar(10),
    durum                  smallint,
    subeid                 integer,
    bankahesapid           integer,
    komisyonmasrafmerkezi  integer,
    masrafcikis            smallint,
    hesap_kesim_tarihi     smallint,
    odeme_gun_sayisi       smallint,
    genellimit             numeric(19,4)
);

-- ------------------------------------------------------------- KREDIKARTI ----
drop table if exists stg.kredikarti;
create table stg.kredikarti (
    id                     integer,
    kodu                   varchar(30),
    adi                    varchar(150),
    kur                    varchar(10),
    durum                  smallint,
    subeid                 integer,
    bankahesapid           integer,
    odeme_bankahesapid     integer,
    hesap_kesim_tarihi     smallint,
    odeme_gun_sayisi       smallint,
    genellimit             numeric(19,4)
);

-- --------------------------------------------------------------- KREDILER ----
drop table if exists stg.krediler;
create table stg.krediler (
    id                     integer,
    kredikodu              varchar(30),
    adi                    varchar(150),
    genelkreditipi         smallint,
    kur                    varchar(10),
    durum                  smallint,
    subeid                 integer,
    bankaticarihesapid     integer,
    rehberid               integer,
    projeid                integer,
    tutari                 numeric(19,4),
    faizorani              double precision,
    bsmv                   double precision,
    kkdf                   double precision,
    kreditaksit            smallint,
    alinistarihi           timestamp,
    faizmasrafid           integer,
    masrafid               integer
);

-- ------------------------------------------------------------- SRMMERKEZI ----
drop table if exists stg.srmmerkezi;
create table stg.srmmerkezi (
    id                integer,
    merkezkodu        varchar(30),
    merkezadi         varchar(150),
    gelirmi           smallint
);

-- --------------------------------------------------------------- PROJELER ----
drop table if exists stg.projeler;
create table stg.projeler (
    id                integer,
    projekodu         varchar(100),
    projeadi          varchar(400),
    konusu            varchar(400),
    rehberid          integer,
    prj_sorumlusu_id  integer,
    baslamatarihi     timestamp,
    bitistarihi       timestamp,
    durum             smallint,
    satisfiyati       numeric(19,4),
    satiskur          varchar(20),
    subeid            integer
);

-- ------------------------------------------------------------- PARA_KUPON ----
drop table if exists stg.para_kupon;
create table stg.para_kupon (
    id                integer,
    tur               smallint,
    adi               varchar(150),
    tutar             integer,
    kur               varchar(10),
    durum             smallint
);

do $$
declare v integer;
begin
    select count(*) into v from information_schema.tables
     where table_schema = 'stg'
       and table_name in ('kasalar','bankahesaplar','pos','kredikarti','krediler','srmmerkezi','projeler','para_kupon');
    raise notice '079 tamam: % / 8 stg tablosu hazir - simdi goc_al.ps1 calistirilmali', v;
end $$;
