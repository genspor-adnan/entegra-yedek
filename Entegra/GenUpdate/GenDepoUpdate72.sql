-- ============================================================
-- GenDepoUpdate72.sql
-- API: sp_Api_Belge_Sil_Json  -- belge (FATBASLIK + FATURA + izleme + ekler) silme
--
-- KANONIK KAYNAK: TTablo.FaturaSil (Utablo.pas:5178). Sira ve kapsam birebir.
--
-- YERINE GECER: TM_FATBASLIKGuncelle'nin "@FATBASLIKNO = 'Sil'" dali. O dal
--   yalnizca "DELETE FROM FATURA" + "DELETE FROM FATBASLIK" yapiyordu:
--   on-kontrol yok, ISLEMLOG yok (Geri Al calismaz), stok izleme/kasa/imaj
--   temizligi yok, transaction yok. Ayni belge Delphi'den ve mobilden FARKLI
--   sonucla siliniyordu; bu SP ikisini esitler.
--
-- BUGUNE GORE EK KAZANIM: Delphi tarafi bu isi ayri bir baglantida ve
--   TRANSACTION'SIZ yapiyor (YeniGeciciBaglantiOlustur); ortada hata olursa
--   belge yarim silinmis kaliyor. Burada hepsi TEK transaction.
--
-- AKIS
--   1) On-kontrol : sp_Prog_Fatura_Silinebilir_Mi (e-belge / kullanim / izleme /
--      UTS / donusum). SILINEBILIR=0 -> hicbir sey yazilmadan THROW 51200.
--   2) Loglama (SILMEDEN ONCE; Geri Al'in calismasi buna bagli) - FaturaSil sirasi:
--      kart FATBASLIK -> satirlar FATURA -> FATURA_USER -> STOKIZLEME ->
--      STOKIZLEMEDEPO -> FATBASLIK_USER
--   3) Silme (FK sirasi): [uretim fisi ise artik kullanilmayan STOKSERILOT] ->
--      STOKIZLEME -> STOKLOKASYON -> FATURA -> REHBERBILGI(detay sablonu) ->
--      IMAJ(YERI=31) -> KASA(TUR 61,71) -> FATBASLIK
--      Gider pusulasi (TUR=8) satirlari icin kaynak faturanin IADEADET'i geri alinir.
--
-- TabNo eslemesi (PrjConst): kart TUR'e gore 104/105/106/107/134/144/214/209/219/
--   28/29/30; detay 330/145/131/130/133/132.
--
-- GIRDI : {"BelgeId":5567,"KilitKaldirildi":false,
--          "Oturum":{"KulId":5,"SubeId":-1,"Ip":"","Istasyon":""}}
-- CIKTI : {"Sonuc":1,"BelgeId":..,"Tur":..,"SilinenSatir":n,"Loglanan":n}
-- HATA  : 51001 BelgeId eksik, 51002 belge bulunamadi,
--         51200 silinemez (NEDEN mesajda: EBELGE/KULLANIM/IZLEME/UTS/DONUSUM)
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Sil_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @BelgeId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeId') AS INT);
    DECLARE @Kilit   BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KilitKaldirildi') AS BIT), 0);
    DECLARE @KulId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), 0);
    DECLARE @Ip      VARCHAR(45) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Ip'), ''), 45);
    DECLARE @Ist     VARCHAR(64) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Istasyon'), ''), 64);

    IF @BelgeId IS NULL OR @BelgeId <= 0
        THROW 51001, N'BelgeId zorunlu.', 1;

    DECLARE @Tur INT = (SELECT TUR FROM FATBASLIK WHERE ID = @BelgeId);
    IF @Tur IS NULL
        THROW 51002, N'Belge bulunamadi.', 1;

    -- ---- 1) On-kontrol ----
    DECLARE @K TABLE (SILINEBILIR INT, NEDEN varchar(50) COLLATE DATABASE_DEFAULT,
                      BELGEAD varchar(100) COLLATE DATABASE_DEFAULT, BELGETARIH datetime,
                      BELGENO varchar(50) COLLATE DATABASE_DEFAULT);
    INSERT @K EXEC dbo.sp_Prog_Fatura_Silinebilir_Mi @FatBasID = @BelgeId, @SatirID = 0, @KilitKaldirildi = @Kilit;

    DECLARE @Neden varchar(50) = (SELECT TOP 1 NEDEN FROM @K WHERE ISNULL(SILINEBILIR, 1) = 0);
    IF @Neden IS NOT NULL
    BEGIN
        DECLARE @m NVARCHAR(200) = N'Belge silinemez: ' + @Neden;
        THROW 51200, @m, 1;
    END

    -- ---- TabNo eslemesi (TTablo.FaturaSil ile ayni) ----
    DECLARE @TabKart INT =
        CASE WHEN @Tur IN (3,12)     THEN 106   -- giris fisi
             WHEN @Tur IN (4,16)     THEN 107   -- cikis fisi
             WHEN @Tur = 20          THEN 134   -- stok transfer
             WHEN @Tur = 6           THEN 144   -- uretim fisi
             WHEN @Tur = 10          THEN 104   -- gelen irsaliye
             WHEN @Tur = 14          THEN 105   -- giden irsaliye
             WHEN @Tur IN (8,110)    THEN 214   -- gider pusulasi
             WHEN @Tur = 109         THEN 209   -- gelen konsinye
             WHEN @Tur = 119         THEN 219   -- giden konsinye
             WHEN @Tur IN (9,11,13)  THEN 28    -- gelen fatura/siparis
             WHEN @Tur IN (19,15,17) THEN 29    -- giden fatura/siparis
             ELSE 30 END;
    DECLARE @TabDetay INT =
        CASE WHEN @Tur IN (3,12,4,16,20)      THEN 330   -- FATURA (fis/transfer detay)
             WHEN @Tur = 6                    THEN 145   -- uretim fisi detay
             WHEN @Tur = 9                    THEN 131   -- alis siparis detay
             WHEN @Tur IN (10,11,13,8,109)    THEN 130   -- gelen fat/fis/irs detay
             WHEN @Tur = 19                   THEN 133   -- satis siparis detay
             WHEN @Tur IN (14,15,17,110,119)  THEN 132   -- giden fat/fis/irs detay
             ELSE 130 END;
    -- REHBERBILGI (detay sablonu) YERI - TTablo.FaturaDetaySablonTipiBul
    DECLARE @SablonYeri INT =
        CASE WHEN @Tur = 9                THEN 131
             WHEN @Tur IN (3,10,11,12)    THEN 130
             WHEN @Tur IN (4,14,15,16)    THEN 132
             WHEN @Tur = 19               THEN 133
             ELSE 0 END;

    DECLARE @Loglanan INT = 0, @n INT = 0, @SilinenSatir INT = 0;
    DECLARE @sBelge varchar(20) = CAST(@BelgeId AS varchar(20));

    BEGIN TRY
        BEGIN TRAN;

        -- ---- 2) LOGLAMA (silmeden ONCE) ----
        -- kart
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK', @KayitId = @BelgeId, @TabNo = @TabKart,
             @UstTabNo = @TabKart, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @Yazilan = @n OUTPUT;                       SET @Loglanan = @Loglanan + @n;
        -- satirlar (FATURA) ve satir ek alanlari (FATURA_USER; FK cascade ile gider)
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATURA', @Kosul = N'FATBASID = @pB', @TabNo = @TabDetay,
             @UstTabNo = @TabKart, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @KosulPar = @BelgeId, @Yazilan = @n OUTPUT;   SET @Loglanan = @Loglanan + @n;
        IF OBJECT_ID('dbo.FATURA_USER', 'U') IS NOT NULL
        BEGIN
            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATURA_USER',
                 @Kosul = N'ID IN (SELECT ID FROM FATURA WHERE FATBASID = @pB)', @TabNo = 503,
                 @UstTabNo = @TabKart, @UstId = @BelgeId,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @KosulPar = @BelgeId, @Yazilan = @n OUTPUT; SET @Loglanan = @Loglanan + @n;
        END
        -- STOKIZLEME, sonra STOKIZLEMEDEPO (restore sirasi FK icin boyle)
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'STOKIZLEME', @Kosul = N'BASLIKID = @pB', @TabNo = 367,
             @UstTabNo = @TabKart, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @KosulPar = @BelgeId, @Yazilan = @n OUTPUT;   SET @Loglanan = @Loglanan + @n;
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'STOKIZLEMEDEPO',
             @Kosul = N'IZLEMID IN (SELECT ID FROM STOKIZLEME WHERE BASLIKID = @pB)', @TabNo = 375,
             @UstTabNo = @TabKart, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @KosulPar = @BelgeId, @Yazilan = @n OUTPUT;   SET @Loglanan = @Loglanan + @n;
        -- kart ek alanlari
        IF OBJECT_ID('dbo.FATBASLIK_USER', 'U') IS NOT NULL
        BEGIN
            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK_USER', @KayitId = @BelgeId, @TabNo = 502,
                 @UstTabNo = @TabKart, @UstId = @BelgeId,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @Yazilan = @n OUTPUT;                     SET @Loglanan = @Loglanan + @n;
        END

        -- ---- 3) SILME ----
        -- Uretim fisi: baska yerde kullanilmayan seri/lot ana kayitlarini da temizle
        IF @Tur = 6
            DELETE SL FROM FATURA F
                INNER JOIN STOKIZLEME SI ON SI.BASLIKID = F.FATBASID AND SI.SATIRID = F.ID AND SI.BELGETUR = 6
                INNER JOIN STOKSERILOT SL ON SL.STOKID = SI.STOKID AND SL.ID = SI.SERILOTID
             WHERE F.FATBASID = @BelgeId
               AND NOT EXISTS (SELECT 1 FROM STOKIZLEME SI1
                                WHERE SI1.STOKID = SI.STOKID AND SI1.SERILOTID = SL.ID AND SI1.ID <> SI.ID);

        DELETE FROM STOKIZLEME   WHERE BASLIKID = @BelgeId;
        DELETE FROM STOKLOKASYON WHERE BASLIKID = @BelgeId;

        -- Gider pusulasi: silinen satirin iade miktarini kaynak faturaya geri ver
        IF @Tur = 8
            UPDATE T SET IADEADET = ISNULL(T.IADEADET, 0) - X.Adet
            FROM FATURA T
            INNER JOIN (SELECT F.IADEFATURAID AS Id, SUM(ISNULL(F.ADET, 0)) AS Adet
                          FROM FATURA F
                         WHERE F.FATBASID = @BelgeId AND ISNULL(F.IADEFATURAID, 0) > 0
                         GROUP BY F.IADEFATURAID) X ON X.Id = T.ID;

        DELETE FROM FATURA WHERE FATBASID = @BelgeId;
        SET @SilinenSatir = @@ROWCOUNT;

        IF @SablonYeri > 0
            DELETE FROM REHBERBILGI WHERE YERI = @SablonYeri AND YER_ID = @BelgeId;
        DELETE FROM IMAJ WHERE YERI = 31 AND YER_ID = @BelgeId;
        DELETE FROM KASA WHERE TUR IN (61, 71) AND FATURAID = @BelgeId;
        DELETE FROM FATBASLIK WHERE ID = @BelgeId;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH

    SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId, @Tur AS Tur,
                   @SilinenSatir AS SilinenSatir, @Loglanan AS Loglanan
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NULL
    EXEC('CREATE ROLE gentegre_api');
GO
GRANT EXECUTE ON dbo.sp_Api_Belge_Sil_Json TO gentegre_api;
GO
