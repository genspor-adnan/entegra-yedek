-- ============================================================
-- GenDepoUpdate97.sql
-- IZLEME EKRANI - ADIM A3: sp_Prog_Izleme_Dogrula_Json
--
-- Seri/lot SECIMININ dogrulanmasi. TEK KAYNAK: hem izleme ekrani hem belge
--   donusumu bunu cagirir.
--
-- NEDEN: bu kontroller bugun IKI YERDE:
--   1) UIzleme.pas  - KaydetTusClick/CikisMiktarKontrolEt (cikacak miktar
--      depoda var mi) ve TabIzlemBeforePost (lot-SKT tutarsizligi, 124 satir)
--   2) sp_Prog_BelgeDonusum_Dogrula - donusum icin AYNI kontrollerin ikinci
--      kopyasi (secilen adet = satir adedi, secilen lotta yeterli kalan)
--   Bu SP gelince (2) kaldirilir, (1) ekran tasinirken kalkar.
--
-- GIRDI
--   {"mod":"donusum","donusumTuru":411,
--    "stokId":726,"izlemTur":2,"depoId":1,"gerekliAdet":5,
--    "belge" :{"baslikId":114090,"satirId":3557600},
--    "kaynak":{"baslikId":113994,"satirId":3557439},
--    "secim" :[{"serilotId":42622,"adet":3},{"serilotId":42623,"adet":2}],
--    "yeni"  :[{"seriNo":"A1","lotNo":"L9","skt":"2027-01-01","urt":"2026-01-01","adet":0}]}
--
-- CIKTI: SORUN SATIRLARI (bos kume = gecerli)
--   KOD, SERILOTID, MESAJ
--   Kodlar: SECIM_YOK, ADET_UYUMSUZ, ADET_GECERSIZ, MUKERRER_LOT,
--           LOT_KALAN_YETERSIZ, LOT_TARIH_UYUSMAZ
--
-- SP HICBIR SEY YAZMAZ.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Izleme_Dogrula_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Mod         NVARCHAR(20) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.mod'), N'donusum'));
    DECLARE @DonusumTuru INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.donusumTuru') AS INT);
    DECLARE @StokId      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.stokId')      AS INT);
    DECLARE @IzlemTur    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.izlemTur') AS INT), 0);
    DECLARE @DepoId      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.depoId')      AS INT);
    DECLARE @Gerekli     DECIMAL(18,6) = TRY_CAST(JSON_VALUE(@Kosullar, '$.gerekliAdet') AS DECIMAL(18,6));
    DECLARE @HedefBaslik INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.baslikId')  AS INT);
    DECLARE @HedefSatir  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.satirId')   AS INT);
    DECLARE @KaynakSatir INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.kaynak.satirId')  AS INT);

    DECLARE @Sorun TABLE (Sira INT IDENTITY, KOD NVARCHAR(30), SERILOTID INT NULL,
                          MESAJ NVARCHAR(400));

    -- ---------- Girdiler ----------
    DECLARE @Secim TABLE (SERILOTID INT, Adet DECIMAL(18,6));
    INSERT @Secim (SERILOTID, Adet)
    SELECT J.SerilotId, J.Adet
    FROM OPENJSON(@Kosullar, '$.secim')
         WITH (SerilotId INT '$.serilotId', Adet DECIMAL(18,6) '$.adet') J;

    DECLARE @Yeni TABLE (SeriNo NVARCHAR(64), LotNo NVARCHAR(50),
                         Skt DATETIME, Urt DATETIME, Adet DECIMAL(18,6));
    INSERT @Yeni (SeriNo, LotNo, Skt, Urt, Adet)
    SELECT J.SeriNo, J.LotNo, J.Skt, J.Urt, J.Adet
    FROM OPENJSON(@Kosullar, '$.yeni')
         WITH (SeriNo NVARCHAR(64) '$.seriNo', LotNo NVARCHAR(50) '$.lotNo',
               Skt DATETIME '$.skt', Urt DATETIME '$.urt', Adet DECIMAL(18,6) '$.adet') J;

    -- ---------- 1) Izlemli satirda secim zorunlu ----------
    IF @IzlemTur > 0 AND NOT EXISTS (SELECT 1 FROM @Secim) AND NOT EXISTS (SELECT 1 FROM @Yeni)
        INSERT @Sorun (KOD, SERILOTID, MESAJ)
        SELECT N'SECIM_YOK', NULL,
               N'"' + ISNULL((SELECT STOKADI FROM dbo.STOKLAR WHERE ID = @StokId), N'?')
             + N'" izlemeli bir urun; seri/lot secimi yapilmali.';

    -- ---------- 2) Gecersiz adet ----------
    INSERT @Sorun (KOD, SERILOTID, MESAJ)
    SELECT N'ADET_GECERSIZ', S.SERILOTID,
           N'Seri/lot icin gecersiz adet: ' + CAST(CAST(S.Adet AS decimal(18,3)) AS nvarchar(30))
    FROM @Secim S WHERE ISNULL(S.Adet, 0) <= 0;

    -- ---------- 3) Ayni seri/lot birden fazla kez ----------
    INSERT @Sorun (KOD, SERILOTID, MESAJ)
    SELECT N'MUKERRER_LOT', S.SERILOTID,
           N'Ayni seri/lot birden fazla kez gonderildi.'
    FROM @Secim S GROUP BY S.SERILOTID HAVING COUNT(*) > 1;

    -- ---------- 4) Secilen toplam = gerekli adet ----------
    IF @Gerekli IS NOT NULL AND @Gerekli > 0
    BEGIN
        DECLARE @Toplam DECIMAL(18,6) =
            ISNULL((SELECT SUM(Adet) FROM @Secim), 0) + ISNULL((SELECT SUM(Adet) FROM @Yeni), 0);
        IF ABS(@Toplam - @Gerekli) > 0.0001
            INSERT @Sorun (KOD, SERILOTID, MESAJ)
            SELECT N'ADET_UYUMSUZ', NULL,
                   N'Secilen seri/lot toplami (' + CAST(CAST(@Toplam AS decimal(18,3)) AS nvarchar(30))
                 + N') satir adediyle (' + CAST(CAST(@Gerekli AS decimal(18,3)) AS nvarchar(30))
                 + N') ayni degil.';
    END

    -- ---------- 5) Secilen lotta yeterli kalan var mi ----------
    --   Kaynak turune gore olculur; aday listesiyle AYNI hesap:
    --     kaynak FATURA      -> kaynak STOKIZLEME.KALAN
    --     kaynak SIPARISDETAY-> depodaki bakiye EKSI bu satirin kendi hareketi
    DECLARE @KaynakDetay NVARCHAR(20);
    IF @DonusumTuru IS NOT NULL
        SELECT @KaynakDetay = KaynakDetayTablo
        FROM dbo.fn_Prog_BelgeDonusum_Rota() WHERE DonusumTuru = @DonusumTuru;

    IF @KaynakDetay = 'FATURA' AND ISNULL(@KaynakSatir, 0) > 0
        INSERT @Sorun (KOD, SERILOTID, MESAJ)
        SELECT N'LOT_KALAN_YETERSIZ', S.SERILOTID,
               N'Kaynak belgede bu seri/lot icin yeterli kalan yok (mevcut: '
             + CAST(CAST(ISNULL(K.Kalan, 0) AS decimal(18,3)) AS nvarchar(30))
             + N', istenen: ' + CAST(CAST(S.Adet AS decimal(18,3)) AS nvarchar(30)) + N').'
        FROM @Secim S
             OUTER APPLY (SELECT Kalan = SUM(ABS(ISNULL(SI.KALAN, 0)))
                          FROM dbo.STOKIZLEME SI
                          WHERE SI.SATIRID = @KaynakSatir AND SI.SERILOTID = S.SERILOTID) K
        WHERE ISNULL(K.Kalan, 0) + 0.0001 < S.Adet;

    IF ISNULL(@KaynakDetay, 'SIPARISDETAY') = 'SIPARISDETAY' AND ISNULL(@DepoId, 0) > 0
        INSERT @Sorun (KOD, SERILOTID, MESAJ)
        SELECT N'LOT_KALAN_YETERSIZ', S.SERILOTID,
               N'Depoda bu seri/lot icin yeterli kalan yok (mevcut: '
             + CAST(CAST(ISNULL(D.Mevcut, 0) AS decimal(18,3)) AS nvarchar(30))
             + N', istenen: ' + CAST(CAST(S.Adet AS decimal(18,3)) AS nvarchar(30)) + N').'
        FROM @Secim S
             OUTER APPLY (
                 SELECT Mevcut = ISNULL(SDI.KALAN, 0) - ISNULL(K2.Kendi, 0)
                 FROM dbo.STOKDURUMIZLEME SDI
                      OUTER APPLY (SELECT Kendi = SUM(ISNULL(DD.ADET, 0))
                                   FROM dbo.STOKIZLEMEDEPO DD
                                        INNER JOIN dbo.STOKIZLEME SI2 ON SI2.ID = DD.IZLEMID
                                   WHERE SI2.SATIRID = @HedefSatir
                                     AND SI2.SERILOTID = S.SERILOTID
                                     AND DD.DEPOID = @DepoId) K2
                 WHERE SDI.STOKID = @StokId AND SDI.DEPOID = @DepoId
                   AND SDI.SERILOTID = S.SERILOTID) D
        WHERE ISNULL(D.Mevcut, 0) + 0.0001 < S.Adet;

    -- ---------- 6) Yeni lot: ayni lot no farkli tarihlerle var mi ----------
    --   Eski TabIzlemBeforePost kurali (124 satir) - orada kullaniciya soruluyordu;
    --   burada UYARI olarak bildiriliyor, karar cagiranin.
    INSERT @Sorun (KOD, SERILOTID, MESAJ)
    SELECT N'LOT_TARIH_UYUSMAZ', SSL.ID,
           N'"' + Y.LotNo + N'" lot numarasi daha once farkli tarihlerle girilmis (SKT: '
         + ISNULL(CONVERT(nvarchar(10), SSL.SKT, 104), N'-') + N', URT: '
         + ISNULL(CONVERT(nvarchar(10), SSL.URT, 104), N'-') + N').'
    FROM @Yeni Y
         INNER JOIN dbo.STOKSERILOT SSL ON SSL.STOKID = @StokId AND SSL.LOTNO = Y.LotNo
    WHERE ISNULL(Y.LotNo, N'') <> N''
      AND (ISNULL(SSL.SKT, '1990-01-01') <> ISNULL(Y.Skt, '1990-01-01')
        OR ISNULL(SSL.URT, '1990-01-01') <> ISNULL(Y.Urt, '1990-01-01'));

    SELECT KOD, SERILOTID, MESAJ FROM @Sorun ORDER BY Sira;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Izleme_Dogrula_Json TO gentegre_api;
GO
