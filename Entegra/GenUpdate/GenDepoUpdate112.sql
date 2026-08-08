-- ============================================================
-- GenDepoUpdate112.sql
-- sp_Prog_BelgeDonusum_IzlemeAktar -> KANONIK SP'YE DEVREDIYOR
--
-- BORC KAPATMA: seri/lot tasima islemi IKI YERDE yaziliydi
--   sp_Prog_BelgeDonusum_IzlemeAktar  (donusum zinciri, #temp'ten okur)
--   sp_Prog_Izleme_Aktar_Json         (ekran yolu, JSON'dan okur)
-- Ikisi de ayni seyi yapiyordu: STOKIZLEME + STOKIZLEMEDEPO yazma, yon
--   kurali, depo secimi, kismi adet. Bu oturumda ayni hatayi (depo yeterlilik
--   kontrolunun giriste de uygulanmasi) IKI DEFA duzeltmek gerekti - tam da
--   tekrarin bedeli.
--
-- Artik IzlemeAktar YALNIZCA ADAPTORDUR:
--   1) #DonusumIzlemeSecim'deki yeni seri/lot kartlarini acar (temp tabloya
--      ozgu is; islemin kendi transaction'inda)
--   2) her (kaynak satir -> hedef satir) cifti icin secim JSON'u kurar ve
--      sp_Prog_Izleme_Aktar_Json'u cagirir
-- Yazma mantigi TEK YERDE kaldi.
--
-- YeniIzlemeId kolonu artik doldurulmuyor: hicbir yerden OKUNMUYORDU
--   (yalnizca yaziliyordu). Kolon semada duruyor, kimse bakmiyor.
--
-- Inner SP'nin sonuc kumesi CAGIRANA SIZMASIN diye @SonucDondur yok;
--   Aktar_Json tek satirlik JSON dondurur ve bu SP onu bir tabloya alir.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_IzlemeAktar
    @DonusumTuru INT,
    @HedefBaslikID INT,
    @KullaniciID INT,
    @Aktarilan   INT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Aktarilan = 0;

    IF NOT EXISTS (SELECT 1 FROM #DonusumIzlemeSecim) RETURN;

    DECLARE @HedefTur INT, @GirDepo INT, @CikDepo INT;
    SELECT @HedefTur = TUR, @GirDepo = GIRISDEPO, @CikDepo = CIKISDEPO
    FROM FATBASLIK WHERE ID = @HedefBaslikID;

    DECLARE @DepoId INT = CASE WHEN @HedefTur IN (4, 14, 15, 16, 99, 119)
                               THEN @CikDepo ELSE @GirDepo END;

    -- Depo hareketi yapilacak mi? Rota matrisi soyler:
    --   siparis -> irsaliye/fatura : 1 (stok ILK KEZ burada cikar/girer)
    --   irsaliye -> fatura         : 0 (stok zaten irsaliyeyle hareket etti;
    --                                   satir K-B karariyla ADET=0 ile acilir)
    DECLARE @StokDegis BIT =
        ISNULL((SELECT StokDurumDegis FROM dbo.fn_Prog_BelgeDonusum_Rota()
                WHERE DonusumTuru = @DonusumTuru), 0);

    -- ---------- 1) Yeni seri/lot kartlari ----------
    --   GIRIS donusumlerinde lot tedarikciden gelir, kart HENUZ YOKTUR.
    --   Kart BURADA acilir - cagiranin transaction'i icinde, boylece donusum
    --   geri sararsa kart da geri sarar.
    UPDATE I SET I.SerilotId = SSL.ID
      FROM #DonusumIzlemeSecim I
           INNER JOIN dbo.STOKSERILOT SSL ON SSL.STOKID = I.UrunId
                  AND ISNULL(SSL.SERINO, N'') COLLATE DATABASE_DEFAULT = ISNULL(I.SeriNo, N'') COLLATE DATABASE_DEFAULT
                  AND ISNULL(SSL.LOTNO,  N'') COLLATE DATABASE_DEFAULT = ISNULL(I.LotNo,  N'') COLLATE DATABASE_DEFAULT
     WHERE ISNULL(I.SerilotId, 0) = 0 AND ISNULL(I.StokIzlemeId, 0) = 0;

    INSERT INTO dbo.STOKSERILOT (STOKID, SERINO, LOTNO, URT, SKT)
    SELECT DISTINCT I.UrunId, ISNULL(I.SeriNo, N''), ISNULL(I.LotNo, N''),
           ISNULL(I.Urt, '1990-01-01'), ISNULL(I.Skt, '1990-01-01')
    FROM #DonusumIzlemeSecim I
    WHERE ISNULL(I.SerilotId, 0) = 0 AND ISNULL(I.StokIzlemeId, 0) = 0
      AND ISNULL(I.UrunId, 0) > 0
      AND (ISNULL(I.SeriNo, N'') <> N'' OR ISNULL(I.LotNo, N'') <> N'');

    UPDATE I SET I.SerilotId = SSL.ID
      FROM #DonusumIzlemeSecim I
           INNER JOIN dbo.STOKSERILOT SSL ON SSL.STOKID = I.UrunId
                  AND ISNULL(SSL.SERINO, N'') COLLATE DATABASE_DEFAULT = ISNULL(I.SeriNo, N'') COLLATE DATABASE_DEFAULT
                  AND ISNULL(SSL.LOTNO,  N'') COLLATE DATABASE_DEFAULT = ISNULL(I.LotNo,  N'') COLLATE DATABASE_DEFAULT
     WHERE ISNULL(I.SerilotId, 0) = 0 AND ISNULL(I.StokIzlemeId, 0) = 0;

    IF EXISTS (SELECT 1 FROM #DonusumIzlemeSecim
               WHERE ISNULL(SerilotId, 0) = 0 AND ISNULL(StokIzlemeId, 0) = 0)
        THROW 51200, N'Seri/lot karti olusturulamadi (seri no ve lot no bos olamaz).', 1;

    -- ---------- 2) Her satir cifti icin kanonik SP ----------
    DECLARE @KaynakSatir INT, @HedefSatir INT, @Json NVARCHAR(MAX), @Secim NVARCHAR(MAX);
    DECLARE @Sonuc TABLE (Sonuc NVARCHAR(MAX));

    DECLARE cp CURSOR LOCAL FAST_FORWARD FOR
        SELECT I.SatirId, E.HedefSatirId
        FROM #DonusumIzlemeSecim I
             INNER JOIN #DonusumSatirEsleme E ON E.KaynakSatirId = I.SatirId
        GROUP BY I.SatirId, E.HedefSatirId;
    OPEN cp; FETCH NEXT FROM cp INTO @KaynakSatir, @HedefSatir;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Kaynakta izlem kaydi VARSA tasima (kaynakIzlemId), yoksa depodan
        --   secim (serilotId). Aktar_Json ikisini de tanir.
        SET @Secim =
            ISNULL((SELECT kaynakIzlemId = ISNULL(I.StokIzlemeId, 0),
                           serilotId     = ISNULL(I.SerilotId, 0),
                           adet          = I.Adet
                    FROM #DonusumIzlemeSecim I
                    WHERE I.SatirId = @KaynakSatir
                    FOR JSON PATH), N'[]');

        DECLARE @Tasima BIT = CASE WHEN EXISTS (
            SELECT 1 FROM #DonusumIzlemeSecim I
            WHERE I.SatirId = @KaynakSatir AND ISNULL(I.StokIzlemeId, 0) > 0)
            THEN 1 ELSE 0 END;

        SET @Json =
            N'{' +
            CASE WHEN @Tasima = 1
                 THEN N'"kaynak":{"satirId":' + CAST(@KaynakSatir AS nvarchar(12)) + N'},'
                 ELSE N'' END +
            N'"hedef":{"tur":' + CAST(@HedefTur AS nvarchar(10)) +
            N',"baslikId":' + CAST(@HedefBaslikID AS nvarchar(12)) +
            N',"satirId":'  + CAST(@HedefSatir AS nvarchar(12)) + N'},' +
            N'"depoId":' + CAST(ISNULL(@DepoId, 0) AS nvarchar(12)) + N',' +
            N'"stokHareketi":' + CASE WHEN @StokDegis = 1 THEN N'true' ELSE N'false' END + N',' +
            N'"kullaniciId":' + CAST(@KullaniciID AS nvarchar(12)) + N',' +
            N'"secim":' + @Secim + N'}';

        DELETE @Sonuc;
        INSERT @Sonuc (Sonuc)
        EXEC dbo.sp_Prog_Izleme_Aktar_Json @Kosullar = @Json;

        SET @Aktarilan = @Aktarilan +
            ISNULL((SELECT TRY_CAST(JSON_VALUE(Sonuc, '$.Aktarilan') AS INT) FROM @Sonuc), 0);

        FETCH NEXT FROM cp INTO @KaynakSatir, @HedefSatir;
    END
    CLOSE cp; DEALLOCATE cp;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_BelgeDonusum_IzlemeAktar TO gentegre_api;
GO
