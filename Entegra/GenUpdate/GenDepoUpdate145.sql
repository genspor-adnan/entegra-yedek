-- ============================================================
-- GenDepoUpdate145.sql
-- KURUM ICI MESAJLASMA - SEMA (kanal modeli)
--
-- Eski yapi (MESAJLOG + MESAJLOGKULLANICI + MESAJLAR) hic kullanilmadi
--   (MESAJLOG'da 2 satir, MESAJLOGKULLANICI bos) ve mesaj BASINA alici satiri
--   uretiyordu: 50 kisilik grupta 1 mesaj = 50 satir. Yerine WhatsApp semantigine
--   oturan KANAL modeli:
--
--     MESAJKANAL      : sohbet (1 = birebir, 2 = grup)
--     MESAJKANALUYE   : uyeler + OKUNDU IMLECI (SONOKUMAID) + sessize alma
--     MESAJ           : mesajlar (kanal basina tek satir, alici fanout YOK)
--
--   Okunmamis sayisi = COUNT(MESAJ.ID > uye.SONOKUMAID) -> mesaj basina okundu
--   satiri gerekmez, grup buyudukce maliyet artmaz.
--
-- ILETIM: TCP/servis YOK. Istemci DB'yi yoklar (2-3 sn, indeksli MAX(ID) seek).
--   Ileride PG'de pg_notify / MSSQL'de Service Broker ya da relay+WebSocket
--   eklenirse SEMA ve SP'ler DEGISMEZ, yalnizca "haber alma" katmani degisir.
--
-- Kullanici kimligi: REHBER.ID (uygulamadaki 'Kullanan' ile ayni).
-- Dosya eki: GENDEPO.DOSYA (FILESTREAM, hash-dedup) - DOSYAID ile referans.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ---- KANAL (sohbet) ------------------------------------------------------
IF OBJECT_ID('dbo.MESAJKANAL') IS NULL
BEGIN
    CREATE TABLE dbo.MESAJKANAL
    (
        ID              INT IDENTITY(1,1) NOT NULL,
        TUR             TINYINT       NOT NULL CONSTRAINT DF_MESAJKANAL_TUR DEFAULT (1),  -- 1 birebir, 2 grup
        ADI             NVARCHAR(100) NULL,          -- grup adi (birebirde NULL)
        OLUSTURAN       INT           NOT NULL,      -- REHBER.ID
        OLUSTURMATARIHI DATETIME      NOT NULL CONSTRAINT DF_MESAJKANAL_TRH DEFAULT (GETDATE()),
        DURUM           TINYINT       NOT NULL CONSTRAINT DF_MESAJKANAL_DRM DEFAULT (1),  -- 1 aktif, 0 kapali
        SONMESAJID      BIGINT        NULL,          -- denormalize: liste ekrani hizli sıralasin
        SONMESAJTARIH   DATETIME      NULL,
        SUBEID          SMALLINT      NULL,
        CONSTRAINT PK_MESAJKANAL PRIMARY KEY CLUSTERED (ID)
    );
    CREATE INDEX IX_MESAJKANAL_SON ON dbo.MESAJKANAL (SONMESAJTARIH DESC) INCLUDE (TUR, ADI, DURUM);
END
GO

-- ---- KANAL UYELERI (+ okundu imleci) -------------------------------------
IF OBJECT_ID('dbo.MESAJKANALUYE') IS NULL
BEGIN
    CREATE TABLE dbo.MESAJKANALUYE
    (
        ID            INT IDENTITY(1,1) NOT NULL,
        KANALID       INT      NOT NULL,
        REHBERID      INT      NOT NULL,     -- kullanici
        ROL           TINYINT  NOT NULL CONSTRAINT DF_MESAJUYE_ROL DEFAULT (0),   -- 1 = grup yoneticisi
        KATILMATARIHI DATETIME NOT NULL CONSTRAINT DF_MESAJUYE_KTL DEFAULT (GETDATE()),
        AYRILMATARIHI DATETIME NULL,         -- NULL = halen uye
        SONOKUMAID    BIGINT   NOT NULL CONSTRAINT DF_MESAJUYE_OKU DEFAULT (0),   -- okundu imleci (MESAJ.ID)
        BILDIRIM      BIT      NOT NULL CONSTRAINT DF_MESAJUYE_BLD DEFAULT (1),   -- 0 = sessize alindi
        BASLANGICID   BIGINT   NOT NULL CONSTRAINT DF_MESAJUYE_BSL DEFAULT (0),   -- uyeden ONCEKI mesajlari gormesin
        CONSTRAINT PK_MESAJKANALUYE PRIMARY KEY CLUSTERED (ID),
        CONSTRAINT UQ_MESAJKANALUYE UNIQUE (KANALID, REHBERID),
        CONSTRAINT FK_MESAJKANALUYE_KANAL FOREIGN KEY (KANALID) REFERENCES dbo.MESAJKANAL (ID)
    );
    -- "benim sohbetlerim" sorgusunun cekirdegi
    CREATE INDEX IX_MESAJKANALUYE_KUL ON dbo.MESAJKANALUYE (REHBERID, AYRILMATARIHI)
        INCLUDE (KANALID, SONOKUMAID, BILDIRIM, BASLANGICID);
END
GO

-- ---- MESAJLAR ------------------------------------------------------------
IF OBJECT_ID('dbo.MESAJ') IS NULL
BEGIN
    CREATE TABLE dbo.MESAJ
    (
        ID          BIGINT IDENTITY(1,1) NOT NULL,
        KANALID     INT           NOT NULL,
        GONDERENID  INT           NOT NULL,   -- REHBER.ID
        TARIH       DATETIME2(0)  NOT NULL CONSTRAINT DF_MESAJ_TRH DEFAULT (SYSDATETIME()),
        METIN       NVARCHAR(MAX) NULL,
        YANITID     BIGINT        NULL,       -- alintilanan mesaj (MESAJ.ID)
        DOSYAID     INT           NULL,       -- GENDEPO.DOSYA referansi
        DOSYAADI    NVARCHAR(200) NULL,
        DOSYABOYUT  BIGINT        NULL,
        SILINDI     BIT           NOT NULL CONSTRAINT DF_MESAJ_SIL DEFAULT (0),
        SILEN       INT           NULL,
        SILMETARIHI DATETIME      NULL,
        CONSTRAINT PK_MESAJ PRIMARY KEY CLUSTERED (ID),
        CONSTRAINT FK_MESAJ_KANAL FOREIGN KEY (KANALID) REFERENCES dbo.MESAJKANAL (ID)
    );
    -- Gecmis okuma + "yeni var mi" yoklamasi: (KANALID, ID) tek indeks yeter.
    CREATE INDEX IX_MESAJ_KANAL ON dbo.MESAJ (KANALID, ID) INCLUDE (GONDERENID, TARIH, SILINDI);
END
GO

-- ---- LOG/UInfo icin tablo adlari ----------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 530)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL) VALUES (530, 'MESAJKANAL', N'Kart', N'Mesajlaşma');
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 531)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL) VALUES (531, 'MESAJKANALUYE', N'Detay', N'Mesajlaşma');
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 532)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL) VALUES (532, 'MESAJ', N'Detay', N'Mesajlaşma');
GO

-- ---- Birebir kanal tekilligi ---------------------------------------------
--   Iki kullanici arasinda TEK birebir kanal olmali. Uyelik iki satirda
--   tutuldugu icin kisit tabloda ifade edilemiyor -> yardimci fonksiyon,
--   kanal acan SP once bunu sorar (yarista ikinci kanal olusursa liste
--   ekrani ikisini de gosterir; SP UPDLOCK ile acar, bkz. 146).
CREATE OR ALTER FUNCTION dbo.fn_Prog_Mesaj_BirebirKanal(@Kul1 INT, @Kul2 INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT TOP 1 K.ID
            FROM dbo.MESAJKANAL K
            WHERE K.TUR = 1 AND K.DURUM = 1
              AND EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE U
                           WHERE U.KANALID = K.ID AND U.REHBERID = @Kul1 AND U.AYRILMATARIHI IS NULL)
              AND EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE U
                           WHERE U.KANALID = K.ID AND U.REHBERID = @Kul2 AND U.AYRILMATARIHI IS NULL)
              AND (SELECT COUNT(*) FROM dbo.MESAJKANALUYE U
                    WHERE U.KANALID = K.ID AND U.AYRILMATARIHI IS NULL) = 2
            ORDER BY K.ID);
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT SELECT, INSERT, UPDATE ON dbo.MESAJKANAL     TO gentegre_api;
    GRANT SELECT, INSERT, UPDATE ON dbo.MESAJKANALUYE  TO gentegre_api;
    GRANT SELECT, INSERT, UPDATE ON dbo.MESAJ          TO gentegre_api;
    GRANT EXECUTE ON dbo.fn_Prog_Mesaj_BirebirKanal    TO gentegre_api;
END
GO
