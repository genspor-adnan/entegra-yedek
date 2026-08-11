-- ============================================================
-- GenDepoUpdate156.sql
-- MESAJLASMA: tek emojilik mesaj "Boş mesaj gönderilemez" hatasi veriyordu
--
-- TESHIS: sp_Api_Mesaj_Gonder_Json'daki bosluk kontrolu
--     IF ISNULL(@Metin, N'') = N''
--   karsilastirma yapiyor. SQL Server karsilastirmalari COLLATION agirliklarina
--   gore calisir; SC (supplementary character) destegi olmayan collation'larda
--   surrogate cift ile yazilan emoji'lerin agirligi yoktur, dolayisiyla
--     N'😀' = N''  -->  TRUE
--   olur ve mesaj bos sayilip reddedilir. (LEN(@Metin) = 2 dondugu halde!)
--
-- COZUM: DATALENGTH ile bayt uzunlugu kontrolu - collation'dan bagimsiz.
--
-- NOT: Ayni tuzak kullanici metni ustunde "= N''" kullanan her yerde gecerli.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Gonder_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KanalId    INT    = TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId') AS INT);
    DECLARE @Metin      NVARCHAR(MAX) = JSON_VALUE(@Kosullar, '$.Metin');
    DECLARE @YanitId    BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.YanitId') AS BIGINT);
    DECLARE @DosyaId    INT    = TRY_CAST(JSON_VALUE(@Kosullar, '$.DosyaId') AS INT);
    DECLARE @DosyaAdi   NVARCHAR(200) = JSON_VALUE(@Kosullar, '$.DosyaAdi');
    DECLARE @DosyaBoyut BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.DosyaBoyut') AS BIGINT);
    DECLARE @KulId      INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);

    IF @KulId <= 0 OR ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId ve Oturum.KulId zorunlu.', 1;
    -- BOSLUK KONTROLU DATALENGTH ILE: "= N''" karsilastirmasi COLLATION agirligina
    --   bakar; SC olmayan collation'da (Turkish_CI_AS) emoji gibi ek-duzlem
    --   karakterlerin agirligi YOKTUR -> N'<emoji>' = N'' TRUE doner ve tek
    --   emojilik mesaj "bos" sayilip reddedilirdi. DATALENGTH collation'dan
    --   bagimsizdir (bayt sayar).
    IF DATALENGTH(ISNULL(@Metin, N'')) = 0 AND @DosyaId IS NULL
        THROW 51001, N'Boş mesaj gönderilemez.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                    WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL)
        THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;

    DECLARE @Id BIGINT, @Trh DATETIME2(0) = SYSDATETIME();

    BEGIN TRAN;
    INSERT INTO dbo.MESAJ (KANALID, GONDERENID, TARIH, METIN, YANITID, DOSYAID, DOSYAADI, DOSYABOYUT)
    VALUES (@KanalId, @KulId, @Trh, @Metin, @YanitId, @DosyaId, @DosyaAdi, @DosyaBoyut);
    SET @Id = SCOPE_IDENTITY();

    -- Liste ekrani icin denormalize alanlar
    UPDATE dbo.MESAJKANAL SET SONMESAJID = @Id, SONMESAJTARIH = @Trh WHERE ID = @KanalId;
    -- Gonderen kendi mesajini okumus sayilir
    UPDATE dbo.MESAJKANALUYE SET SONOKUMAID = @Id
     WHERE KANALID = @KanalId AND REHBERID = @KulId AND SONOKUMAID < @Id;
    COMMIT;

    SELECT Sonuc = 1, MesajId = @Id, KanalId = @KanalId,
           Tarih = CONVERT(NVARCHAR(19), @Trh, 126)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Api_Mesaj_Gonder_Json TO gentegre_api;
GO
