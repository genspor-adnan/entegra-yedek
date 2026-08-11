-- ============================================================
-- GenDepoUpdate161.sql
-- MESAJLASMA: "Herkesten Sil" ve "Sohbeti Temizle" YONETICI ayricaligi
--             yalnizca GRUPLARDA gecerli olsun
--
-- ACIK: birebir kanal acilirken IKI taraf da ROL = 1 yaziliyor
--   (GenDepoUpdate146, 'birebir' dali). Dolayisiyla "yonetici" kontrolu
--   birebirde HER IKI tarafi da yetkili sayiyordu; karsidan gelen mesaj
--   herkesten silinebiliyordu.
--
-- KURAL (netlestirildi):
--   Herkesten Sil : mesaji GONDEREN her zaman; ayrica GRUP (TUR=2) yoneticisi.
--                   Birebirde karsi tarafin mesaji herkesten SILINEMEZ.
--   Sil (kendinden): her uye, her mesaj icin (MESAJGIZLI).
--   Sohbeti Temizle: yalnizca GRUP yoneticisi.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Sil_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId   INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);
    DECLARE @MesajId BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.MesajId') AS BIGINT);
    DECLARE @Kapsam  NVARCHAR(10) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.Kapsam'), N'ben'));
    IF @KulId <= 0 OR ISNULL(@MesajId, 0) <= 0 THROW 51001, N'MesajId ve Oturum.KulId zorunlu.', 1;

    DECLARE @KanalId INT, @Gonderen INT, @Tur TINYINT;
    SELECT @KanalId = M.KANALID, @Gonderen = M.GONDERENID, @Tur = K.TUR
      FROM dbo.MESAJ M INNER JOIN dbo.MESAJKANAL K ON K.ID = M.KANALID
     WHERE M.ID = @MesajId;
    IF @KanalId IS NULL THROW 51002, N'Mesaj bulunamadı.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                    WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL)
        THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;

    IF @Kapsam = N'herkes'
    BEGIN
        -- Gonderen her zaman; yonetici ayricaligi YALNIZ GRUPTA (TUR = 2)
        IF @Gonderen <> @KulId
           AND NOT (@Tur = 2 AND EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                                          WHERE KANALID = @KanalId AND REHBERID = @KulId
                                            AND ROL = 1 AND AYRILMATARIHI IS NULL))
            THROW 51200, N'Bu mesajı yalnızca gönderen (grupta yönetici) herkesten silebilir.', 1;

        UPDATE dbo.MESAJ SET SILINDI = 1, SILEN = @KulId, SILMETARIHI = GETDATE()
         WHERE ID = @MesajId AND SILINDI = 0;
    END
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI WHERE MESAJID = @MesajId AND REHBERID = @KulId)
            INSERT INTO dbo.MESAJGIZLI (MESAJID, REHBERID) VALUES (@MesajId, @KulId);
    END

    SELECT Sonuc = 1, MesajId = @MesajId, KanalId = @KanalId, Kapsam = @Kapsam
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- Sohbeti temizleme de yalniz GRUP yoneticisine -----------------------
CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Kanal_Temizle_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KanalId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId') AS INT);
    DECLARE @KulId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);

    IF @KulId <= 0 THROW 51001, N'Oturum.KulId zorunlu.', 1;
    IF ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId zorunlu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE U
                        INNER JOIN dbo.MESAJKANAL K ON K.ID = U.KANALID AND K.TUR = 2
                    WHERE U.KANALID = @KanalId AND U.REHBERID = @KulId
                      AND U.AYRILMATARIHI IS NULL AND U.ROL = 1)
        THROW 51200, N'Sohbeti yalnızca grup yöneticisi temizleyebilir.', 1;

    DECLARE @Adet INT;
    BEGIN TRAN;
        SELECT @Adet = COUNT(*) FROM dbo.MESAJ WHERE KANALID = @KanalId;

        -- Kisiye ozel gizleme kayitlari da gitsin (FK)
        DELETE G FROM dbo.MESAJGIZLI G
         INNER JOIN dbo.MESAJ M ON M.ID = G.MESAJID
         WHERE M.KANALID = @KanalId;

        DELETE FROM dbo.MESAJ WHERE KANALID = @KanalId;

        UPDATE dbo.MESAJKANAL SET SONMESAJID = NULL, SONMESAJTARIH = NULL WHERE ID = @KanalId;
        UPDATE dbo.MESAJKANALUYE SET SONOKUMAID = 0, BASLANGICID = 0 WHERE KANALID = @KanalId;
    COMMIT;

    SELECT Sonuc = 1, KanalId = @KanalId, SilinenMesaj = @Adet
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_Api_Mesaj_Sil_Json             TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Mesaj_Kanal_Temizle_Json   TO gentegre_api;
END
GO
