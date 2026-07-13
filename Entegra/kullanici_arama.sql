-- ============================================================
-- KULLANICI_ARAMA — kullanici bazli Son/Sik Aranan (generic, MODUL bazli)
--   KULLANICI_REHBER'in genellestirilmis hali. Tum listeler (Cari/Stok/Demirbas...)
--   tek tablodan: MODUL = MODUL.MODULID (app sabiti: MODUL_Cari=22, MODUL_Stok=27,
--   MODUL_Demirbas=28, MODUL_Teklif=29, MODUL_IK=34...), KAYITID = kayit ID.
--   Son Aranan = DEGISTIRMETARIHI desc, Sik Aranan = SAY desc.
-- ============================================================
IF OBJECT_ID('dbo.KULLANICI_ARAMA') IS NULL
BEGIN
    CREATE TABLE dbo.KULLANICI_ARAMA (
        ID               INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_KULLANICI_ARAMA PRIMARY KEY,
        KULID            INT           NOT NULL,   -- kullanici
        MODUL            INT           NOT NULL,   -- modul/varlik tipi (TabNo: Cari, Stok, Demirbas...)
        KAYITID          INT           NOT NULL,   -- kayit ID (REHBERID/STOKID/DEMIRBASID...)
        SAY              INT           NOT NULL CONSTRAINT DF_KULLANICI_ARAMA_SAY DEFAULT 1,
        DEGISTIRMETARIHI SMALLDATETIME NOT NULL CONSTRAINT DF_KULLANICI_ARAMA_TRH DEFAULT GETDATE()
    );
    -- upsert + hizli son/sik sorgu icin
    CREATE UNIQUE INDEX UX_KULLANICI_ARAMA ON dbo.KULLANICI_ARAMA (KULID, MODUL, KAYITID);
    CREATE INDEX IX_KULLANICI_ARAMA_SON ON dbo.KULLANICI_ARAMA (KULID, MODUL, DEGISTIRMETARIHI DESC);
    CREATE INDEX IX_KULLANICI_ARAMA_SIK ON dbo.KULLANICI_ARAMA (KULID, MODUL, SAY DESC);
END;
GO
