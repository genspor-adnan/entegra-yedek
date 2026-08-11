-- ============================================================
-- GenDepoUpdate136.sql
-- sp_BelgeNoGetir -> MERKEZI SAYAC (GenDepoUpdate135)
--
-- Mevcut durum: kasa/cek/senet kocanlari (-101/-102/-103) SEQUENCE kullaniyor,
--   yani atomik. Ama fatura/siparis/servis/teklif/uretim emri/dokuman dallari
--   "max(numerik no)+1" ile calisiyor: numara TAHSIS EDILMIYOR, sadece hesaplaniyor.
--   Iki kullanici ayni anda kaydederse AYNI belge numarasini alir.
--
-- Bu guncelleme o dallari sp_Prog_SiradakiNo'ya baglar. ACIK/KAPALI:
--   GENINI BOLUM=-24121 DEGER=1  -> sayac (atomik, tahsisli)
--   GENINI BOLUM=-24121 DEGER=0  -> eski davranis (varsayilan; kurulumda degismez)
--
-- Sayac ILK cagrida ayni WHERE ile MAX'tan tohumlandigi icin acildigi anda
--   ayni numarayi uretir - veri gecisi/geri doldurma GEREKMEZ.
--
-- BOSLUK: rezervasyon acikken alinip kaydedilmeyen numara bosluk birakir.
--   Belgeden vazgecildiginde app sp_Prog_SiradakiNo_Iade cagirir (Utablo.SiradakiNoIade).
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_BelgeNoGetir]
(
    @IslemTur INT,
    @SubeID   INT,
    @Kocanno  INT      = 0,
    @BTarihi  DATETIME = '2000-01-01'
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BELGENO TABLE (KOCANNO INT, BELGESERI NVARCHAR(5), BELGENO NVARCHAR(20));

    DECLARE @AKocanno INT, @ABelgeseri NVARCHAR(5), @ABelgeno NVARCHAR(20), @UstTur INT,
            @Dijitsay INT, @BaslaNo NVARCHAR(25), @BasTarihi DATETIME;
    DECLARE @sqlCommand NVARCHAR(200), @NextValue INT;

    -- Sayac acik mi? (GENINI -24121)
    DECLARE @Sayac BIT = CASE WHEN ISNULL((SELECT TOP 1 DEGER FROM dbo.GENINI WHERE BOLUM = -24121), 0) = 1
                              THEN 1 ELSE 0 END;
    DECLARE @Kapsam NVARCHAR(80), @Kosul NVARCHAR(1000), @Basla BIGINT, @Yeni BIGINT;
    -- Cekirdek OUTPUT parametreli cagrilir: "INSERT ... EXEC" ic ice olamaz.
    DECLARE @SonNo BIGINT, @NoStr NVARCHAR(40);

    SET @Dijitsay = 0;

    SELECT @UstTur = CASE
        WHEN @IslemTur IN (21,22,23,24,25,26,27,28,29,88,130,141,142) THEN -101
        WHEN @IslemTur IN (31,32,33,34,35,36,37,38,98,125,131,137,140) THEN -102
        WHEN @IslemTur IN (40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,
                           132,133,134,135,136,138,139,143,144,145,146,147,148,149) THEN -103
        ELSE @IslemTur END;

    IF @Kocanno IN (0, -99)
        SET @AKocanno = (SELECT TOP 1 KOCANNO FROM KOCANAYARLARI WHERE SUBEID = @SubeID AND TUR = @UstTur);
    ELSE
        SET @AKocanno = @Kocanno;

    ----------------------------------------------------------------- -3333: ID tabanli (degismedi)
    IF @AKocanno = -3333
    BEGIN
        SET @ABelgeseri = '';
        IF @UstTur IN (3, 4, 6, 8, 10, 11, 12, 14, 15, 16, 20, 39, 110, 116, 119, 222)
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM FATBASLIK;
        ELSE IF @UstTur IN (9, 19, 101, 105)
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM SIPARIS;
        ELSE IF @UstTur = 83
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM SERVIS;
        ELSE IF @UstTur IN (80, 81)
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM TEKLIF;
        ELSE IF @UstTur = 250
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM DOKUMAN;
        ELSE
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM KASA;
    END
    ELSE IF @AKocanno <> 0
    BEGIN
        SELECT @ABelgeseri = SERINO, @BaslaNo = BASLANGICNO, @Dijitsay = LEN(BASLANGICNO),
               @BasTarihi = BASLANGICTARIHI
          FROM KOCANAYARLARI
         WHERE SUBEID = @SubeID AND TUR = @UstTur AND KOCANNO = @AKocanno;

        SET @Basla  = ISNULL(TRY_CAST(@BaslaNo AS BIGINT), 1);
        SET @Kapsam = N'T' + CAST(@UstTur AS NVARCHAR(10)) + N'|K' + CAST(@AKocanno AS NVARCHAR(10));
        -- Tarih suzgeci sayaca da GECER: tohumlama eski davranisla ayni MAX'i bulsun.
        DECLARE @TrhLit NVARCHAR(30) = N'''' + CONVERT(NVARCHAR(23), ISNULL(@BasTarihi, '19000101'), 126) + N'''';

        ------------------------------------------------------------- FATBASLIK
        IF @UstTur IN (3, 4, 6, 8, 10, 11, 12, 14, 15, 16, 20, 39, 110, 116, 119, 222)
        BEGIN
            SET @Kosul = N'FATURATARIH >= ' + @TrhLit + N' AND TUR = ' + CAST(@UstTur AS NVARCHAR(10)) +
                         N' AND KOCANNO = ' + CAST(@AKocanno AS NVARCHAR(10)) + N' AND ISNUMERIC(FATURANO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'FATBASLIK', 'FATURANO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), FATURANO)) + 1)
                                          FROM FATBASLIK
                                         WHERE FATURATARIH >= @BasTarihi AND TUR = @UstTur
                                           AND KOCANNO = @AKocanno AND ISNUMERIC(FATURANO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- SIPARIS
        ELSE IF @UstTur IN (9, 19, 101, 105)
        BEGIN
            SET @Kosul = N'SIPARISTARIH >= ' + @TrhLit + N' AND KOCANNO = ' + CAST(@AKocanno AS NVARCHAR(10)) +
                         N' AND ISNUMERIC(SIPARISNO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'SIPARIS', 'SIPARISNO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), SIPARISNO)) + 1)
                                          FROM SIPARIS
                                         WHERE SIPARISTARIH >= @BasTarihi AND KOCANNO = @AKocanno
                                           AND ISNUMERIC(SIPARISNO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- SERVIS
        ELSE IF @UstTur = 83
        BEGIN
            SET @Kosul = N'TARIH >= ' + @TrhLit + N' AND KOCANNO = ' + CAST(@AKocanno AS NVARCHAR(10)) +
                         N' AND ISNUMERIC(SERVISNO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'SERVIS', 'SERVISNO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), SERVISNO)) + 1)
                                          FROM SERVIS
                                         WHERE TARIH >= @BasTarihi AND KOCANNO = @AKocanno
                                           AND ISNUMERIC(SERVISNO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- TEKLIF
        ELSE IF @UstTur IN (80, 81)
        BEGIN
            SET @Kosul = N'TARIH >= ' + @TrhLit + N' AND KOCANNO = ' + CAST(@AKocanno AS NVARCHAR(10)) +
                         N' AND ISNUMERIC(TEKLIFNO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'TEKLIF', 'TEKLIFNO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), TEKLIFNO)) + 1)
                                          FROM TEKLIF
                                         WHERE TARIH >= @BasTarihi AND KOCANNO = @AKocanno
                                           AND ISNUMERIC(TEKLIFNO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- URETIM EMRI
        ELSE IF @UstTur = 166
        BEGIN
            SET @Kosul = N'TALEPTARIHI >= ' + @TrhLit + N' AND ISNUMERIC(EMIRNO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'URETIMEMRI', 'EMIRNO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), EMIRNO)) + 1)
                                          FROM URETIMEMRI
                                         WHERE TALEPTARIHI >= @BasTarihi AND ISNUMERIC(EMIRNO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- DOKUMAN
        ELSE IF @UstTur = 250
        BEGIN
            SET @Kosul = N'EKLEMETARIHI >= ' + @TrhLit + N' AND ISNUMERIC(BELGENO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'DOKUMAN', 'BELGENO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), BELGENO)) + 1)
                                          FROM DOKUMAN
                                         WHERE EKLEMETARIHI >= @BasTarihi AND ISNUMERIC(BELGENO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- KASA/CEK/SENET: SEQUENCE (zaten atomik)
        ELSE IF @UstTur IN (-103, -102, -101)
        BEGIN
            SET @sqlCommand = N'select @NextValue = NEXT VALUE FOR dbo.seq_' + CONVERT(NVARCHAR(20), @AKocanno);
            EXECUTE sp_executesql @sqlCommand, N'@AKocanno int, @NextValue int OUTPUT',
                    @AKocanno = @AKocanno, @NextValue = @NextValue OUTPUT;
            SET @ABelgeno = CONVERT(NVARCHAR(20), @NextValue);
        END
    END

    WHILE LEN(@ABelgeno) < @Dijitsay
        SET @ABelgeno = '0' + @ABelgeno;

    INSERT INTO @BELGENO (KOCANNO, BELGESERI, BELGENO)
    VALUES (@AKocanno, @ABelgeseri, @ABelgeno);

    SELECT * FROM @BELGENO;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_BelgeNoGetir TO gentegre_api;
GO
