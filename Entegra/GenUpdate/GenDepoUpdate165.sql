-- ============================================================
-- GenDepoUpdate165.sql
-- MESAJLASMA: "Sohbeti Temizle" iki kapsam
--
--   Kapsam = 'ben'    (VARSAYILAN): sohbet YALNIZ BENDEN temizlenir. Mesajlar
--                     digerlerinde durur; bende gorunmez (MESAJGIZLI).
--                     Her uye kendi tarafi icin yapabilir.
--   Kapsam = 'herkes': mesajlar TUM uyelerden silinir (kalici). Yalniz GRUP
--                     YONETICISI - bilgi panosundaki "Sohbeti Herkesten Temizle".
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Kanal_Temizle_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KanalId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId') AS INT);
    DECLARE @KulId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);
    DECLARE @Kapsam  NVARCHAR(10) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.Kapsam'), N'ben'));

    IF @KulId <= 0 THROW 51001, N'Oturum.KulId zorunlu.', 1;
    IF ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId zorunlu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                    WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL)
        THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;

    DECLARE @Adet INT = 0;

    IF @Kapsam = N'herkes'
    BEGIN
        -- Kalici silme: yalniz GRUP yoneticisi (birebirde iki taraf da ROL=1 oldugu
        --   icin TUR = 2 sarti sart - bkz. GenDepoUpdate161)
        IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE U
                            INNER JOIN dbo.MESAJKANAL K ON K.ID = U.KANALID AND K.TUR = 2
                        WHERE U.KANALID = @KanalId AND U.REHBERID = @KulId
                          AND U.AYRILMATARIHI IS NULL AND U.ROL = 1)
            THROW 51200, N'Sohbeti herkesten yalnızca grup yöneticisi temizleyebilir.', 1;

        BEGIN TRAN;
            SELECT @Adet = COUNT(*) FROM dbo.MESAJ WHERE KANALID = @KanalId;

            DELETE G FROM dbo.MESAJGIZLI G
             INNER JOIN dbo.MESAJ M ON M.ID = G.MESAJID
             WHERE M.KANALID = @KanalId;

            -- Ekler GENDEPO.DOSYA'da hash-dedup tutulur; burada yalniz mesaj satirlari.
            DELETE FROM dbo.MESAJ WHERE KANALID = @KanalId;

            UPDATE dbo.MESAJKANAL SET SONMESAJID = NULL, SONMESAJTARIH = NULL WHERE ID = @KanalId;
            UPDATE dbo.MESAJKANALUYE SET SONOKUMAID = 0, BASLANGICID = 0 WHERE KANALID = @KanalId;
        COMMIT;
    END
    ELSE
    BEGIN
        -- YALNIZ BENDEN: kanaldaki tum mesajlari bu kullaniciya gizle
        INSERT INTO dbo.MESAJGIZLI (MESAJID, REHBERID)
        SELECT M.ID, @KulId
          FROM dbo.MESAJ M
         WHERE M.KANALID = @KanalId
           AND NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI G
                            WHERE G.MESAJID = M.ID AND G.REHBERID = @KulId);
        SET @Adet = @@ROWCOUNT;

        -- Okundu imlecini de sona al: gizlenen mesajlar rozet uretmesin
        UPDATE U
           SET SONOKUMAID = ISNULL((SELECT MAX(M2.ID) FROM dbo.MESAJ M2
                                     WHERE M2.KANALID = @KanalId), U.SONOKUMAID)
          FROM dbo.MESAJKANALUYE U
         WHERE U.KANALID = @KanalId AND U.REHBERID = @KulId AND U.AYRILMATARIHI IS NULL;
    END

    SELECT Sonuc = 1, KanalId = @KanalId, Kapsam = @Kapsam, SilinenMesaj = @Adet
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Api_Mesaj_Kanal_Temizle_Json TO gentegre_api;
GO
