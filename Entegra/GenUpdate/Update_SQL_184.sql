-- ============================================================
-- Update_SQL_184.sql   (MSSQL)
-- sp_Prog_Belge_KaynakDurum_Json JSON path uyumluluk duzeltmesi
--
-- Bazi musteri SQL Server kurulumlarinda OPENJSON WITH kolon path
-- sozdizimi "Incorrect syntax near '$.kaynak'" hatasi veriyor.
-- Kaynaklar dizisi once OPENJSON ile satirlara ayrilir, alanlar her
-- satirin JSON value degerinden JSON_VALUE ile okunur.
-- ============================================================

IF OBJECT_ID(N'dbo.sp_Prog_Belge_KaynakDurum_Json', N'P') IS NULL
BEGIN
    PRINT 'sp_Prog_Belge_KaynakDurum_Json bulunamadi; Update_SQL_184 atlandi.';
END
ELSE
BEGIN
    EXEC(N'
ALTER PROCEDURE dbo.sp_Prog_Belge_KaynakDurum_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BelgeId INT = TRY_CAST(JSON_VALUE(@Kosullar, ''$.belgeId'') AS INT);
    -- listele=1: HESAPLAMAZ, yalniz kaynak listesini dondurur. SILME yolunda
    --   kullanilir: hedef silinince YERI/YERID bagi kaybolur, bu yuzden cagiran
    --   silmeden ONCE listeyi alir, silme sonrasi "kaynaklar" ile geri gonderir.
    DECLARE @Listele BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, ''$.listele'') AS BIT), 0);
    DECLARE @Kaynaklar NVARCHAR(MAX) = JSON_QUERY(@Kosullar, ''$.kaynaklar'');

    DECLARE @K TABLE (Kaynak NVARCHAR(10), BaslikId INT, PRIMARY KEY (Kaynak, BaslikId));

    -- ---------- 1) Hedef belgenin satirlarindaki baglardan ----------
    IF ISNULL(@BelgeId, 0) > 0
        INSERT @K (Kaynak, BaslikId)
        SELECT DISTINCT
               CASE WHEN R.KaynakDetayTablo = ''SIPARISDETAY'' THEN N''siparis'' ELSE N''belge'' END,
               CASE WHEN R.KaynakDetayTablo = ''SIPARISDETAY'' THEN SD.SIPARISID ELSE FK.FATBASID END
        FROM dbo.FATURA F
             INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R ON R.DonusumTuru = F.YERI
             LEFT JOIN dbo.SIPARISDETAY SD ON R.KaynakDetayTablo = ''SIPARISDETAY'' AND SD.ID = F.YERID
             LEFT JOIN dbo.FATURA      FK ON R.KaynakDetayTablo = ''FATURA''       AND FK.ID = F.YERID
        WHERE F.FATBASID = @BelgeId
          AND ISNULL(F.YERID, 0) > 0
          AND ISNULL(CASE WHEN R.KaynakDetayTablo = ''SIPARISDETAY'' THEN SD.SIPARISID ELSE FK.FATBASID END, 0) > 0;

    -- ---------- 2) Cagiranin dogrudan verdikleri (silme yolu) ----------
    IF ISJSON(@Kaynaklar) = 1
        INSERT @K (Kaynak, BaslikId)
        SELECT DISTINCT LOWER(JSON_VALUE(J.value, ''$.kaynak'')),
                        TRY_CAST(JSON_VALUE(J.value, ''$.baslikId'') AS INT)
        FROM OPENJSON(@Kaynaklar) J
        WHERE ISNULL(TRY_CAST(JSON_VALUE(J.value, ''$.baslikId'') AS INT), 0) > 0
          AND LOWER(ISNULL(JSON_VALUE(J.value, ''$.kaynak''), N'''')) IN (N''siparis'', N''belge'')
          AND NOT EXISTS (SELECT 1 FROM @K K2
                          WHERE K2.Kaynak = LOWER(JSON_VALUE(J.value, ''$.kaynak''))
                            AND K2.BaslikId = TRY_CAST(JSON_VALUE(J.value, ''$.baslikId'') AS INT));

    IF @Listele = 1
    BEGIN
        SELECT (SELECT 1 AS Sonuc,
                       ISNULL((SELECT Kaynak AS kaynak, BaslikId AS baslikId
                               FROM @K FOR JSON PATH), N''[]'') AS Kaynaklar
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
');

    IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
        GRANT EXECUTE ON dbo.sp_Prog_Belge_KaynakDurum_Json TO gentegre_api;
END
GO
