-- ============================================================
-- GenDepoUpdate110.sql
-- sp_Prog_Izleme_Aday_Json: cagiran YONTEMI dogrudan verebilir
--
-- Izleme ekrani hangi listeye ihtiyaci oldugunu BILIR (tasima / depo / kendi)
--   ama donusum TURUNU bilmez - elinde yalnizca kaynak satir vardir. Ekrani
--   SP'ye baglamak icin (plan A8 okuma tarafi) yontemin disaridan verilebilmesi
--   gerekiyor; verilirse rota matrisine bakilmaz.
--
-- Davranis degismedi: yontem gonderilmezse eski karar zinciri isler.
-- ============================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Izleme_Aday_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Mod         NVARCHAR(20) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.mod'), N'donusum'));
    DECLARE @StokId      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.stokId')      AS INT);
    DECLARE @IzlemTur    INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.izlemTur')    AS INT);
    DECLARE @DepoId      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.depoId')      AS INT);
    DECLARE @DonusumTuru INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.donusumTuru') AS INT);
    DECLARE @HedefBaslik INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.baslikId')  AS INT);
    DECLARE @HedefSatir  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.satirId')   AS INT);
    DECLARE @KaynakBaslik INT= TRY_CAST(JSON_VALUE(@Kosullar, '$.kaynak.baslikId') AS INT);
    DECLARE @KaynakSatir INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.kaynak.satirId')  AS INT);

    IF @StokId IS NULL OR @StokId <= 0 THROW 51001, N'stokId zorunlu.', 1;
    IF @Mod NOT IN (N'donusum', N'cikis', N'giris')
        THROW 51001, N'mod "donusum", "cikis" ya da "giris" olmali. (Sayim ayri akistir.)', 1;

    -- ---------- Yontem secimi ----------
    DECLARE @Yontem NVARCHAR(10);

    -- CAGIRAN DOGRUDAN SOYLEYEBILIR: izleme ekrani hangi listeye ihtiyaci
    --   oldugunu bilir ama donusum TURUNU bilmez (elinde yalniz kaynak satir
    --   vardir). "yontem" verildiginde rota matrisine bakilmaz.
    DECLARE @YontemDis NVARCHAR(10) = LOWER(NULLIF(JSON_VALUE(@Kosullar, '$.yontem'), N''));
    IF @YontemDis IS NOT NULL AND @YontemDis NOT IN (N'tasima', N'depo', N'kendi')
        THROW 51001, N'yontem "tasima", "depo" ya da "kendi" olmali.', 1;

    IF @YontemDis IS NOT NULL
        SET @Yontem = @YontemDis
    ELSE IF @Mod = N'donusum'
    BEGIN
        IF @DonusumTuru IS NULL THROW 51001, N'mod=donusum icin donusumTuru zorunlu.', 1;
        IF @KaynakSatir IS NULL OR @KaynakSatir <= 0
            THROW 51001, N'mod=donusum icin kaynak.satirId zorunlu.', 1;

        DECLARE @KaynakDetay NVARCHAR(20);
        SELECT @KaynakDetay = KaynakDetayTablo
        FROM dbo.fn_Prog_BelgeDonusum_Rota() WHERE DonusumTuru = @DonusumTuru;

        IF @KaynakDetay IS NULL
        BEGIN
            DECLARE @m NVARCHAR(200) = N'Bilinmeyen donusum turu: ' + CAST(@DonusumTuru AS nvarchar(10));
            THROW 51200, @m, 1;
        END
        -- Kaynak FATURA -> tasinacak kayit VAR; SIPARISDETAY -> depodan secilir
        SET @Yontem = CASE WHEN @KaynakDetay = 'FATURA' THEN N'tasima' ELSE N'depo' END;
    END
    ELSE IF @Mod = N'cikis'
        SET @Yontem = N'depo'
    ELSE
        SET @Yontem = N'kendi';

    IF @Yontem = N'depo' AND (@DepoId IS NULL OR @DepoId <= 0)
        THROW 51001, N'Depodan secim icin gecerli depoId zorunlu.', 1;

    -- ---------- H2: bu satirin halihazirdaki secimi ----------
    DECLARE @Secili TABLE (SERILOTID INT PRIMARY KEY, Adet DECIMAL(18,6), IzlemId INT);
    IF ISNULL(@HedefSatir, 0) > 0
        INSERT @Secili (SERILOTID, Adet, IzlemId)
        SELECT SI.SERILOTID, SUM(ISNULL(SI.ADET, 0)), MIN(SI.ID)
        FROM dbo.STOKIZLEME SI
        WHERE SI.BASLIKID = @HedefBaslik AND SI.SATIRID = @HedefSatir
          AND ISNULL(SI.SERILOTID, 0) > 0
        GROUP BY SI.SERILOTID;

    -- ============================================================
    IF @Yontem = N'tasima'
    BEGIN
        -- Kaynak belge satirindan tasinabilir seri/lot
        SELECT SERILOTID   = SI.SERILOTID,
               SERINO      = SSL.SERINO,
               LOTNO       = SSL.LOTNO,
               SKT         = SSL.SKT,
               URT         = SSL.URT,
               MEVCUT      = CAST(ABS(ISNULL(SI.KALAN, 0)) AS decimal(18,6)),
               SECILI      = CAST(CASE WHEN S.SERILOTID IS NULL THEN 0 ELSE 1 END AS bit),
               SECILENADET = CAST(ISNULL(ABS(S.Adet), 0) AS decimal(18,6)),
               KAYNAKIZLEMID = SI.ID
        FROM dbo.STOKIZLEME SI
             INNER JOIN dbo.STOKSERILOT SSL ON SSL.ID = SI.SERILOTID
             LEFT JOIN @Secili S ON S.SERILOTID = SI.SERILOTID
        WHERE SI.SATIRID = @KaynakSatir
          AND SI.BASLIKID = ISNULL(NULLIF(@KaynakBaslik, 0), SI.BASLIKID)
          -- Tukenmis kayit gizlenir; ISTISNA: hedefte zaten secili olan kalir
          AND (ABS(ISNULL(SI.KALAN, 0)) > 0.0001 OR S.SERILOTID IS NOT NULL)
        ORDER BY SSL.SKT, SSL.LOTNO, SSL.SERINO;
    END
    ELSE IF @Yontem = N'depo'
    BEGIN
        -- Depodaki bakiyeden secim.
        --   MEVCUT = STOKDURUMIZLEME.KALAN EKSI bu satirin KENDI hareketi
        --   (eski SQLCikan'in iki dalli hesabinin karsiligi: bakiye + kendi
        --    etkisinin geri alinmasi. Boylece satir yeniden acildiginda
        --    kullanici kendi sectigini "hala secilebilir" gorur.)
        SELECT SERILOTID   = SDI.SERILOTID,
               SERINO      = SSL.SERINO,
               LOTNO       = SSL.LOTNO,
               SKT         = SSL.SKT,
               URT         = SSL.URT,
               MEVCUT      = CAST(ISNULL(SDI.KALAN, 0) - ISNULL(K.Kendi, 0) AS decimal(18,6)),
               SECILI      = CAST(CASE WHEN S.SERILOTID IS NULL THEN 0 ELSE 1 END AS bit),
               SECILENADET = CAST(ISNULL(ABS(S.Adet), 0) AS decimal(18,6)),
               KAYNAKIZLEMID = CAST(NULL AS INT)
        FROM dbo.STOKDURUMIZLEME SDI
             INNER JOIN dbo.STOKSERILOT SSL ON SSL.ID = SDI.SERILOTID
             LEFT JOIN @Secili S ON S.SERILOTID = SDI.SERILOTID
             OUTER APPLY (
                 SELECT Kendi = SUM(ISNULL(D.ADET, 0))
                 FROM dbo.STOKIZLEMEDEPO D
                      INNER JOIN dbo.STOKIZLEME SI2 ON SI2.ID = D.IZLEMID
                 WHERE SI2.SATIRID = @HedefSatir
                   AND SI2.SERILOTID = SDI.SERILOTID
                   AND D.DEPOID = @DepoId
             ) K
        WHERE SDI.STOKID = @StokId
          AND SDI.DEPOID = @DepoId
          AND (ISNULL(SDI.KALAN, 0) - ISNULL(K.Kendi, 0) > 0.0001 OR S.SERILOTID IS NOT NULL)
        ORDER BY SSL.SKT, SSL.LOTNO, SSL.SERINO;
    END
    ELSE
    BEGIN
        -- GIRIS: bu belge satirinin KENDI kayitlari. Kullanici yeni seri/lot
        --   girer; mevcutlar isaretli gelir (eski SQLGiren'in karsiligi).
        --   Giriste "depodaki bakiye" kavrami YOK - stok bu belgeyle olusuyor.
        SELECT SERILOTID   = SI.SERILOTID,
               SERINO      = SSL.SERINO,
               LOTNO       = SSL.LOTNO,
               SKT         = SSL.SKT,
               URT         = SSL.URT,
               MEVCUT      = CAST(SUM(ISNULL(SI.ADET, 0)) AS decimal(18,6)),
               SECILI      = CAST(1 AS bit),
               SECILENADET = CAST(SUM(ISNULL(SI.ADET, 0)) AS decimal(18,6)),
               KAYNAKIZLEMID = MIN(SI.ID)
        FROM dbo.STOKIZLEME SI
             INNER JOIN dbo.STOKSERILOT SSL ON SSL.ID = SI.SERILOTID
        WHERE SI.BASLIKID = @HedefBaslik AND SI.SATIRID = @HedefSatir
          AND (@IzlemTur IS NULL OR SI.IZLEMTUR = @IzlemTur)
        GROUP BY SI.SERILOTID, SSL.SERINO, SSL.LOTNO, SSL.SKT, SSL.URT
        ORDER BY SSL.SKT, SSL.LOTNO, SSL.SERINO;
    END
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Izleme_Aday_Json TO gentegre_api;
GO
