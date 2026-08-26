-- ============================================================================
--  Konsolide GenUpdate 66-169 — PostgreSQL portu
--  01_Eksik_User_Tablolari_PG.sql
--
--  PG semasinda kullanici-alan (_USER) tablolarinin cogu YOKTU; yalnizca
--  FATBASLIK_USER ve FATURA_USER vardi. Silme/kaydetme fonksiyonlari bu
--  tablolara statik DELETE/INSERT yaziyor -> PG'de calisma aninda
--  "relation does not exist" hatasi. MSSQL (BILIM) semasindan uretildi.
--
--  Not: ID kolonu IDENTITY DEGIL - ana kartin ID'siyle ayni deger yazilir.
-- ============================================================================
\set ON_ERROR_STOP on

CREATE TABLE IF NOT EXISTS public.DEMIRBAS_USER (
    ID                           integer NOT NULL,
    EKLEYEN                      integer,
    EKLEMETARIHI                 timestamp,
    DEGISTIREN                   integer,
    DEGISTIRMETARIHI             timestamp,
    DEMTEST                      varchar(100),
    CONSTRAINT pk_demirbas_user PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS public.DOKUMAN_USER (
    ID                           integer NOT NULL,
    EKLEYEN                      integer,
    EKLEMETARIHI                 timestamp,
    DEGISTIREN                   integer,
    DEGISTIRMETARIHI             timestamp,
    CONSTRAINT pk_dokuman_user PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS public.REHBER_USER (
    ID                           integer NOT NULL,
    EKLEYEN                      integer,
    EKLEMETARIHI                 timestamp,
    DEGISTIREN                   integer,
    DEGISTIRMETARIHI             timestamp,
    KDR_Disi                     varchar(30),
    IKTEST                       varchar(100),
    CARITEST                     varchar(100),
    CONSTRAINT pk_rehber_user PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS public.SERVIS_USER (
    ID                           integer NOT NULL,
    EKLEYEN                      integer,
    EKLEMETARIHI                 timestamp,
    DEGISTIREN                   integer,
    DEGISTIRMETARIHI             timestamp,
    SERVISTEST                   varchar(100),
    CONSTRAINT pk_servis_user PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS public.SERVISHAREKET_USER (
    ID                           integer NOT NULL,
    EKLEYEN                      integer,
    EKLEMETARIHI                 timestamp,
    DEGISTIREN                   integer,
    DEGISTIRMETARIHI             timestamp,
    CONSTRAINT pk_servishareket_user PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS public.SIPARIS_USER (
    ID                           integer NOT NULL,
    EKLEYEN                      integer,
    EKLEMETARIHI                 timestamp,
    DEGISTIREN                   integer,
    DEGISTIRMETARIHI             timestamp,
    AlpApkAktar                  varchar(30),
    ST_FIRMA                     varchar(500),
    SIPARIS                      varchar(100),
    CONSTRAINT pk_siparis_user PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS public.STOKLAR_USER (
    ID                           integer NOT NULL,
    EKLEYEN                      integer,
    EKLEMETARIHI                 timestamp,
    DEGISTIREN                   integer,
    DEGISTIRMETARIHI             timestamp,
    SUTKODU                      varchar(50),
    BRANSKODU                    varchar(50),
    GMDN                         varchar(50),
    GMDNADI                      varchar(150),
    MEDIKALSINIF                 smallint,
    ITHALIMAL                    smallint,
    MENSEIULKE                   smallint,
    UTSREF                       varchar(50),
    FTN                          varchar(50),
    DIGERURUNADI                 varchar(150),
    IHALESIRANO                  varchar(50),
    SMKODU                       varchar(20),
    DMOKODU                      varchar(20),
    TEditYABANCI_URUN_AD         varchar(200),
    UE_Gosterme                  varchar(30),
    FATURA_STOK_KODU             varchar(30),
    CONSTRAINT pk_stoklar_user PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS public.TEKLIF_USER (
    ID                           integer NOT NULL,
    EKLEYEN                      integer,
    EKLEMETARIHI                 timestamp,
    DEGISTIREN                   integer,
    DEGISTIRMETARIHI             timestamp,
    TEKLIFTEST                   varchar(100),
    CONSTRAINT pk_teklif_user PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS public.URETIMEMRI_USER (
    ID                           integer NOT NULL,
    EKLEYEN                      integer,
    EKLEMETARIHI                 timestamp,
    DEGISTIREN                   integer,
    DEGISTIRMETARIHI             timestamp,
    LOTNO                        varchar(30),
    SIPARIS_NO                   varchar(25),
    GIRDILOTNO                   varchar(30),
    SIRANO                       integer,
    OlcuAletiKodu1               varchar(30),
    OlcuAletiKodu2               varchar(30),
    UrunMiktari1                 integer,
    OlcuAletiKodu3               varchar(30),
    OlcuAletiKodu4               varchar(30),
    UrunMiktari2                 integer,
    UrunMiktari3                 integer,
    UrunMiktari4                 integer,
    Durum1                       varchar(30),
    Durum2                       varchar(30),
    Durum3                       varchar(30),
    Durum4                       varchar(30),
    KaliteKontrolOnay            varchar(30),
    UretilenSaglamAdt            integer,
    UretilenIskartAdt            integer,
    UretilenTopAdt               integer,
    OperatorOnay                 varchar(30),
    Durum5                       varchar(30),
    OlcuAletiKodu5               varchar(30),
    UrunMiktari5                 integer,
    KKOlcuAletiKodu1             varchar(30),
    KKOlcuAletiKodu2             varchar(30),
    KKOlcuAletiKodu3             varchar(30),
    KKUrunMiktari1               varchar(30),
    KKUrunMiktari2               varchar(30),
    KKUrunMiktari3               varchar(30),
    KKDurum1                     varchar(30),
    KKDurum2                     varchar(30),
    KKDurum3                     varchar(30),
    KKSaglam                     varchar(30),
    KKIskarta                    varchar(30),
    KKToplam                     varchar(30),
    KKontrolEden                 varchar(30),
    KKontrolSorumlusu            varchar(30),
    URT                          timestamp,
    SKT                          timestamp,
    CONSTRAINT pk_uretimemri_user PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS public.URETIMOPERASONPERSONEL_USER (
    ID                           integer NOT NULL,
    EKLEYEN                      integer,
    EKLEMETARIHI                 timestamp,
    DEGISTIREN                   integer,
    DEGISTIRMETARIHI             timestamp,
    ADET                         double precision,
    BIRIM                        integer,
    LOTU                         varchar(30),
    OlcuAletiKodu1               varchar(30),
    OlcuAletiKodu2               varchar(30),
    UrunMiktari1                 integer,
    OlcuAletiKodu3               varchar(30),
    OlcuAletiKodu4               varchar(30),
    UrunMiktari2                 integer,
    UrunMiktari3                 integer,
    UrunMiktari4                 integer,
    Durum1                       varchar(30),
    Durum2                       varchar(30),
    Durum3                       varchar(30),
    Durum4                       varchar(30),
    KaliteKontrolOnay            varchar(30),
    UretilenSaglamAdt            integer,
    UretilenIskartAdt            integer,
    UretilenTopAdt               integer,
    OperatorOnay                 varchar(30),
    Durum5                       varchar(30),
    OlcuAletiKodu5               varchar(30),
    UrunMiktari5                 integer,
    KKOlcuAletiKodu1             varchar(30),
    KKOlcuAletiKodu2             varchar(30),
    KKOlcuAletiKodu3             varchar(30),
    KKUrunMiktari1               varchar(30),
    KKUrunMiktari2               varchar(30),
    KKUrunMiktari3               varchar(30),
    KKDurum1                     varchar(30),
    KKDurum2                     varchar(30),
    KKDurum3                     varchar(30),
    KKSaglam                     varchar(30),
    KKIskarta                    varchar(30),
    KKToplam                     varchar(30),
    KKontrolEden                 varchar(30),
    KKontrolSorumlusu            varchar(30),
    ISKARTA                      varchar(30),
    CONSTRAINT pk_uretimoperasonpersonel_user PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS public.URETIMOPERASYONPERSONEL_USER (
    ID                           integer NOT NULL,
    EKLEYEN                      integer,
    EKLEMETARIHI                 timestamp,
    DEGISTIREN                   integer,
    DEGISTIRMETARIHI             timestamp,
    CONSTRAINT pk_uretimoperasyonpersonel_user PRIMARY KEY (ID)
);
