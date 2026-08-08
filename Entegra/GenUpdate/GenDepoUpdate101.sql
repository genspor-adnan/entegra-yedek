-- ============================================================
-- GenDepoUpdate101.sql
-- sp_Prog_Belge_KaynakDurum_Json - HEDEF belgeden KAYNAK belgelerin durumu
--
-- NEDEN
--   Donusumle olusan bir belge SONRADAN DUZENLENINCE kaynagin kalani degisiyor
--   ama DURUM'u yeniden hesaplanmiyordu. Tespit (08.08.2026): siparis 23205'ten
--   15 adet faturaya donusmus, fatura 10'a dusurulmus -> kalan 5 oldugu halde
--   siparis DURUM 9 (kapali) kalmis. Tamamen donusmus sanilan siparis aslinda
--   acik, listede "kapali" gorunuyor, kimse donusturmeye calismiyor.
--
--   Donusum ANINDA hesap zaten yapiliyor (UBelgeDonusum, A4). Eksik olan
--   DUZENLEME ve SILME.
--
-- GIRDI - iki kullanim
--   {"belgeId":114096}
--       Hedef belgenin satirlarindaki YERI/YERID baglarindan kaynaklar bulunur.
--       Duzenleme sonrasi kullanim (satirlar hala duruyor).
--   {"kaynaklar":[{"kaynak":"belge","baslikId":114094}, ...]}
--       Kaynaklar dogrudan verilir. SILME icin: hedef silindikten sonra bag
--       kalmaz, cagiran silmeden ONCE kaynaklari toplayip boyle gonderir.
--   Ikisi birlikte de gonderilebilir (birlesir).
--
-- CIKTI {"Sonuc":1,"Guncellenen":n,"Kaynaklar":[{...}]}
--
-- Hesabi KENDI YAPMAZ: sp_Api_Belge_Durum_Yaz_Ic cagirir (tek kaynak).
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Belge_KaynakDurum_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BelgeId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belgeId') AS INT);
    -- listele=1: HESAPLAMAZ, yalniz kaynak listesini dondurur. SILME yolunda
    --   kullanilir: hedef silinince YERI/YERID bagi kaybolur, bu yuzden cagiran
    --   silmeden ONCE listeyi alir, silme sonrasi "kaynaklar" ile geri gonderir.
    DECLARE @Listele BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.listele') AS BIT), 0);

    DECLARE @K TABLE (Kaynak NVARCHAR(10), BaslikId INT, PRIMARY KEY (Kaynak, BaslikId));

    -- ---------- 1) Hedef belgenin satirlarindaki baglardan ----------
    IF ISNULL(@BelgeId, 0) > 0
        INSERT @K (Kaynak, BaslikId)
        SELECT DISTINCT
               CASE WHEN R.KaynakDetayTablo = 'SIPARISDETAY' THEN N'siparis' ELSE N'belge' END,
               CASE WHEN R.KaynakDetayTablo = 'SIPARISDETAY' THEN SD.SIPARISID ELSE FK.FATBASID END
        FROM dbo.FATURA F
             INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R ON R.DonusumTuru = F.YERI
             LEFT JOIN dbo.SIPARISDETAY SD ON R.KaynakDetayTablo = 'SIPARISDETAY' AND SD.ID = F.YERID
             LEFT JOIN dbo.FATURA      FK ON R.KaynakDetayTablo = 'FATURA'       AND FK.ID = F.YERID
        WHERE F.FATBASID = @BelgeId
          AND ISNULL(F.YERID, 0) > 0
          AND ISNULL(CASE WHEN R.KaynakDetayTablo = 'SIPARISDETAY' THEN SD.SIPARISID ELSE FK.FATBASID END, 0) > 0;

    -- ---------- 2) Cagiranin dogrudan verdikleri (silme yolu) ----------
    INSERT @K (Kaynak, BaslikId)
    SELECT DISTINCT LOWER(J.Kaynak), J.BaslikId
    FROM OPENJSON(@Kosullar, '$.kaynaklar')
         WITH (Kaynak NVARCHAR(10) '$.kaynak', BaslikId INT '$.baslikId') J
    WHERE ISNULL(J.BaslikId, 0) > 0
      AND LOWER(ISNULL(J.Kaynak, N'')) IN (N'siparis', N'belge')
      AND NOT EXISTS (SELECT 1 FROM @K K2
                      WHERE K2.Kaynak = LOWER(J.Kaynak) AND K2.BaslikId = J.BaslikId);

    IF @Listele = 1
    BEGIN
        SELECT (SELECT 1 AS Sonuc,
                       ISNULL((SELECT Kaynak AS kaynak, BaslikId AS baslikId
                               FROM @K FOR JSON PATH), N'[]') AS Kaynaklar
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
        RETURN;
    END

    -- ---------- 3) Her kaynak icin yeniden hesapla ----------
    DECLARE @Sonuc TABLE (Kaynak NVARCHAR(10), BaslikId INT, Durum INT,
                          OncekiDurum INT, Yazildi BIT);

    DECLARE @Kay NVARCHAR(10), @Bid INT;
    DECLARE @Tur INT, @Durum INT, @Onceki INT, @Satir INT, @Tam INT, @Kis INT,
            @Acik INT, @Neden NVARCHAR(60), @Yazildi BIT;

    DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT Kaynak, BaslikId FROM @K;
    OPEN c; FETCH NEXT FROM c INTO @Kay, @Bid;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_Api_Belge_Durum_Yaz_Ic @BelgeId = @Bid, @Kaynak = @Kay, @Yaz = 1,
             @Tur = @Tur OUTPUT, @Durum = @Durum OUTPUT, @OncekiDurum = @Onceki OUTPUT,
             @Satir = @Satir OUTPUT, @Tamamlanan = @Tam OUTPUT, @Kismi = @Kis OUTPUT,
             @Acik = @Acik OUTPUT, @Neden = @Neden OUTPUT, @Yazildi = @Yazildi OUTPUT;

        INSERT @Sonuc (Kaynak, BaslikId, Durum, OncekiDurum, Yazildi)
        VALUES (@Kay, @Bid, @Durum, @Onceki, @Yazildi);

        FETCH NEXT FROM c INTO @Kay, @Bid;
    END
    CLOSE c; DEALLOCATE c;

    SELECT (SELECT 1 AS Sonuc,
                   (SELECT COUNT(*) FROM @Sonuc WHERE Yazildi = 1) AS Guncellenen,
                   (SELECT Kaynak, BaslikId, Durum, OncekiDurum, Yazildi
                    FROM @Sonuc FOR JSON PATH) AS Kaynaklar
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Belge_KaynakDurum_Json TO gentegre_api;
GO
