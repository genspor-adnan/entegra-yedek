-- ============================================================
-- GenDepoUpdate115.sql
-- sp_Prog_UretimFisi_Olustur_Json - uretim fisi artik KANONIK KAYDET ile
--
-- Utablo.UretimFisiOlustur elle INSERT yaziyordu: FATBASLIK'a bir Query7.Open
--   (INSERT ... select scope_identity), FATURA'ya ayri bir INSERT...SELECT.
--   Belge uretiminin tek kapisi sp_Api_Belge_Kaydet_Json olmali; ikinci bir
--   yazma yolu, alan kurallari degistikce geride kalir.
--
-- FIYATLAR SIFIR (kullanici karari, 08.08.2026): eski akis STOKFIYAT'tan
--   MALIYETSON/MALIYETORT cekip birim fiyat/tutar olarak yaziyordu. Artik
--   0 yaziliyor; maliyet uretim sonunda ayrica hesaplaniyor.
--
-- GIRDI
--   {"tarih":"2026-08-08","yeri":134,"yerId":114120,"receteId":348,
--    "girisDepo":2,"cikisDepo":2,"miktar":1,"subeId":0,"kullaniciId":5}
-- CIKTI {"Sonuc":1,"BelgeId":n,"BelgeNo":"...","SatirSayisi":n}
--   Recete bulunamazsa {"Sonuc":0,...} - THROW YOK, cagiran atlayabilsin.
--
-- KAYDET'IN BILMEDIGI BASLIK ALANLARI (ANAKAYITID, AKTIVITEID kullanimi,
--   STOKISK, SAYFA, LOKASYON, ISYERI) uretim fisine ozgu kodlamalardir;
--   Kaydet'e alan eklemek yerine burada, ayni islemde UPDATE ile yaziliyor.
--   Eski akistaki anlamlar AYNEN korundu:
--     ANAKAYITID = recete ID
--     AKTIVITEID = recetenin urun (STOKID) kimligi
--     STOKISK    = uretim miktari
--     SAYFA      = urunun ana birimi
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_UretimFisi_Olustur_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Tarih     DATETIME = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.tarih') AS DATETIME), GETDATE());
    DECLARE @Yeri      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.yeri')      AS INT);
    DECLARE @YerId     INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.yerId')     AS INT);
    DECLARE @ReceteId  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.receteId')  AS INT);
    DECLARE @GirisDepo INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.girisDepo') AS INT), 0);
    DECLARE @CikisDepo INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.cikisDepo') AS INT), 0);
    DECLARE @Miktar    DECIMAL(18,6) = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.miktar') AS DECIMAL(18,6)), 1);
    DECLARE @SubeId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.subeId') AS INT), 0);
    DECLARE @KulId     INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.kullaniciId') AS INT), 0);
    DECLARE @Kur       NVARCHAR(10) = ISNULL(JSON_VALUE(@Kosullar, '$.kur'), N'TL');

    IF ISNULL(@ReceteId, 0) <= 0
    BEGIN
        SELECT (SELECT 0 AS Sonuc, 0 AS BelgeId, N'Recete belirtilmedi.' AS Mesaj
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
        RETURN;
    END

    -- ---------- Recete ----------
    DECLARE @Kod NVARCHAR(50), @Ad NVARCHAR(255), @StokId INT, @Birim INT;
    SELECT @Kod = UR.KOD, @Ad = UR.AD, @StokId = UR.STOKID,
           @Birim = ISNULL((SELECT S.ANABIRIM FROM STOKLAR S WHERE S.ID = UR.STOKID), 0)
    FROM URETIMRECETE UR WHERE UR.ID = @ReceteId;

    IF @StokId IS NULL
    BEGIN
        SELECT (SELECT 0 AS Sonuc, 0 AS BelgeId, N'Recete bulunamadi.' AS Mesaj
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM URETIMRECETEDETAY WHERE URETIMRECETEID = @ReceteId)
    BEGIN
        SELECT (SELECT 0 AS Sonuc, 0 AS BelgeId, N'Recetenin detay satirlari yok.' AS Mesaj
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
        RETURN;
    END

    -- ---------- Belge no ----------
    -- Kolon sirasi sp_BelgeNoGetir'in DONDURDUGU sirayla ayni olmali
    --   (INSERT ... EXEC ada gore degil KONUMA gore eslesir).
    DECLARE @BN TABLE (KocanNo NVARCHAR(50), BelgeSeri NVARCHAR(50), BelgeNo NVARCHAR(50));
    DECLARE @BelgeNo NVARCHAR(50), @BelgeSeri NVARCHAR(50), @KocanNo INT = 0;
    INSERT @BN EXEC dbo.sp_BelgeNoGetir @IslemTur = 6, @SubeID = -1,
                                        @Kocanno = @KocanNo, @BTarihi = @Tarih;
    SELECT TOP 1 @BelgeNo = BelgeNo, @BelgeSeri = BelgeSeri FROM @BN;

    -- ---------- Kaydet JSON ----------
    --   FIYATLAR 0: birim fiyat / tutar / doviz alanlari sifir gonderiliyor.
    DECLARE @Baslik NVARCHAR(MAX) =
        (SELECT 6 AS Tur, 1 AS Tipi, 0 AS RehberId,
                @Tarih AS Tarih, @Tarih AS FaturaTarih,
                @BelgeNo AS FaturaNo, @BelgeSeri AS FaturaSeri,
                @GirisDepo AS GirisDepo, @CikisDepo AS CikisDepo,
                N'Muaf' AS KdvDurum, @Kur AS Kur, @Kur AS RaporDoviz,
                @SubeId AS SubeId,
                LEFT(ISNULL(@Kod, N'') + N' - ' + ISNULL(@Ad, N''), 200) AS Aciklama
         FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

    DECLARE @Satirlar NVARCHAR(MAX) =
        (SELECT ROW_NUMBER() OVER (ORDER BY URD.ID)        AS Sira,
                URD.URUNID                                  AS UrunId,
                ISNULL(URD.TUR, 1)                          AS Tur,
                CAST(ISNULL(URD.ADET, 0)   * @Miktar AS decimal(18,6)) AS Adet,
                CAST(ISNULL(URD.MIKTAR, 0) * @Miktar AS decimal(18,6)) AS Miktar,
                ISNULL(URD.BIRIM, 0)                        AS Birim,
                CAST(0 AS decimal(18,6))                    AS BirimFiyat,
                CAST(0 AS decimal(18,6))                    AS Tutar,
                CAST(0 AS decimal(18,6))                    AS DovizBirimFiyat,
                CAST(0 AS decimal(18,6))                    AS DovizTutari,
                ISNULL(S.KDV, 0)                            AS Kdv,
                URD.ACIKLAMA                                AS Aciklama,
                URD.MASRAFID                                AS MasrafId,
                ISNULL(S.IZLEME, 0)                         AS Izleme,
                1                                           AS StokDurumDegis,
                139                                         AS Yeri,   -- TabNo_URETIMRECETEDETAY
                URD.ID                                      AS YerId
         FROM URETIMRECETEDETAY URD
              LEFT JOIN STOKLAR S ON S.ID = URD.URUNID
         WHERE URD.URETIMRECETEID = @ReceteId
         ORDER BY URD.ID
         FOR JSON PATH);

    DECLARE @Json NVARCHAR(MAX) =
        N'{"Baslik":' + @Baslik + N',"Satirlar":' + @Satirlar +
        N',"SatirModu":"delta","Oturum":{"KulId":' + CAST(@KulId AS nvarchar(12)) + N'}}';

    DECLARE @BelgeId INT;
    EXEC dbo.sp_Api_Belge_Kaydet_Json @Kosullar = @Json, @BelgeIdOut = @BelgeId OUTPUT,
         @SonucDondur = 0;

    IF ISNULL(@BelgeId, 0) = 0
        THROW 51200, N'Uretim fisi olusturulamadi.', 1;

    -- ---------- Uretim fisine OZGU baslik alanlari ----------
    --   Kaydet bunlari bilmez; anlamlari eski akistan AYNEN devralindi.
    UPDATE FATBASLIK
       SET YERI       = @Yeri,
           YERID      = @YerId,
           ANAKAYITID = @ReceteId,     -- hangi receteden uretildi
           AKTIVITEID = @StokId,       -- recetenin urunu
           STOKISK    = @Miktar,       -- uretim miktari
           SAYFA      = @Birim,        -- urunun ana birimi
           LOKASYON   = 0, ISYERI = 0
     WHERE ID = @BelgeId;

    SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId, @BelgeNo AS BelgeNo,
                   (SELECT COUNT(*) FROM FATURA WHERE FATBASID = @BelgeId) AS SatirSayisi
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_UretimFisi_Olustur_Json TO gentegre_api;
GO
