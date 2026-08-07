-- ============================================================
-- GenDepoUpdate77.sql
-- API: sp_Api_Belge_EkAlan_Json -- kullanici tanimli EK ALANLAR (tanim + deger)
--
-- YERINE GECER: TM_FatBaslikEkalanlar (@TIP='Listele' dali).
--
-- ESKI DAVRANIS VE NEDEN DEGISTI
--   TM'deki 'Listele' dali FATBASLIK'in TUM kolonlarini once bos string olarak
--   secip, ardindan gercek satiri UNION ALL ile ekliyordu ("baslik satiri +
--   veri satiri" numarasi). Sonuc: kolon sayisi tabloya bagli, kolon sirasi
--   alfabetik, tabloya kolon eklenince istemcide her sey kayiyor. Ustelik
--   @EMIRNO dinamik SQL'e BIRLESTIRILEREK giriyordu (enjeksiyon yuzeyi).
--   Burada sonuc SABIT SEKILLI: alan tanimlari bir kume, degerler tek satirlik
--   JSON. Dinamik SQL yalniz kolon ADLARI icin ve QUOTENAME ile kaciriliyor;
--   kullanici verisi parametreyle baglaniyor.
--
--   Guncelleme (TM'nin 'Guncelle' dali) BURADA YOK: ek alan yazimi belge
--   kaydetmenin parcasidir (F grubu, sp_Api_Belge_Kaydet_Json).
--
-- EK ALAN TANIMI: ALANLAR tablosu (EKRANADI + TABLO + ALANADI + TUR).
--   TUR 1/3/4/7 = veri girisi olan alan turleri (TM ile ayni kume).
--
-- GIRDI : {"Ekran":"FaturaWizardDlg","Tablo":"FATBASLIK","KayitId":5567}
--   Tablo yalnizca beyaz listeden: FATBASLIK / FATURA / SIPARIS / SIPARISDETAY
-- CIKTI :
--   1. sonuc kumesi - alan tanimlari:
--      ID, ALANADI, CAPTION, TUR, SQL, DEGER, KONUM, TAG, GENISLIK, YUKSEKLIK, SIRA
--   2. sonuc kumesi - tek satir: {"Sonuc":1,"KayitId":..,"Degerler":{"ALAN":"deger",...}}
--      Deger bicimi SQL tarafi standardi: ISO tarih, nokta ondalik, True/False.
-- HATA : 51001 girdi, 51002 tablo/kolon yok
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_EkAlan_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Ekran   VARCHAR(50)  = NULLIF(JSON_VALUE(@Kosullar, '$.Ekran'), '');
    DECLARE @Tablo   NVARCHAR(50) = NULLIF(JSON_VALUE(@Kosullar, '$.Tablo'), N'');
    DECLARE @KayitId BIGINT       = TRY_CAST(JSON_VALUE(@Kosullar, '$.KayitId') AS BIGINT);

    IF @Ekran IS NULL OR @Tablo IS NULL OR @KayitId IS NULL
        THROW 51001, N'Ekran, Tablo ve KayitId zorunlu.', 1;
    -- Tablo BEYAZ LISTE (ham ad dinamik SQL'e gidecegi icin)
    IF @Tablo NOT IN (N'FATBASLIK', N'FATURA', N'SIPARIS', N'SIPARISDETAY')
        THROW 51001, N'Tablo beyaz listede degil.', 1;
    IF OBJECT_ID(@Tablo, 'U') IS NULL
        THROW 51002, N'Tablo bulunamadi.', 1;

    -- ---- 1. sonuc kumesi: alan tanimlari ----
    SELECT A.ID, A.ALANADI, A.CAPTION, A.TUR, A.[SQL], A.DEGER, A.KONUM, A.TAG,
           GENISLIK = A.WIDTH, YUKSEKLIK = A.HEIGHT,
           SIRA = ROW_NUMBER() OVER (ORDER BY A.[TOP], A.[LEFT], A.ID)
    FROM ALANLAR A
    WHERE A.EKRANADI = @Ekran AND A.TABLO = @Tablo AND A.TUR IN (1, 3, 4, 7)
      AND EXISTS (SELECT 1 FROM sys.columns C
                   WHERE C.object_id = OBJECT_ID(@Tablo) AND C.name = A.ALANADI)
    ORDER BY A.[TOP], A.[LEFT], A.ID;

    -- ---- 2. sonuc kumesi: degerler (tek satir JSON) ----
    --   Kolon adlari QUOTENAME ile kacirilir; KayitId PARAMETREYLE baglanir.
    -- DIKKAT: "SELECT @v = @v + ..." birikimli atama JOIN + ORDER BY ile
    --   BELIRSIZDIR (SQL Server garanti vermez; testte yalniz SON satir geldi).
    --   Ifade FOR XML PATH ile deterministik kuruluyor.
    DECLARE @Parca NVARCHAR(MAX) =
    (
        SELECT N' + CASE WHEN ' + QUOTENAME(C.name) + N' IS NULL THEN N'''' ELSE ' +
               N'N'',"' + STRING_ESCAPE(C.name, 'json') + N'":"'' + STRING_ESCAPE(' +
               CASE
                 WHEN T.name = 'date' THEN N'CONVERT(nvarchar(10), ' + QUOTENAME(C.name) + N', 23)'
                 WHEN T.name IN ('datetime','datetime2','smalldatetime','datetimeoffset')
                                      THEN N'CONVERT(nvarchar(19), ' + QUOTENAME(C.name) + N', 120)'
                 WHEN T.name = 'time' THEN N'CONVERT(nvarchar(8), ' + QUOTENAME(C.name) + N', 108)'
                 WHEN T.name IN ('float','real') THEN N'CONVERT(nvarchar(50), ' + QUOTENAME(C.name) + N')'
                 WHEN T.name IN ('money','smallmoney','decimal','numeric')
                                      THEN N'CONVERT(nvarchar(50), CAST(' + QUOTENAME(C.name) + N' AS decimal(38,6)))'
                 WHEN T.name = 'bit'  THEN N'CASE WHEN ' + QUOTENAME(C.name) + N' = 1 THEN N''True'' ELSE N''False'' END'
                 ELSE N'CAST(' + QUOTENAME(C.name) + N' AS nvarchar(max))'
               END +
               N', ''json'') + N''"'' END'
        FROM ALANLAR A
            INNER JOIN sys.columns C ON C.object_id = OBJECT_ID(@Tablo) AND C.name = A.ALANADI
            INNER JOIN sys.types   T ON T.user_type_id = C.user_type_id
        WHERE A.EKRANADI = @Ekran AND A.TABLO = @Tablo AND A.TUR IN (1, 3, 4, 7)
          AND T.name NOT IN ('varbinary','binary','image','text','ntext','xml',
                             'geography','geometry','hierarchyid','sql_variant','timestamp')
          AND C.generated_always_type = 0 AND C.is_hidden = 0
        ORDER BY A.[TOP], A.[LEFT], A.ID
        FOR XML PATH(''), TYPE
    ).value('.', 'nvarchar(max)');
    SET @Parca = STUFF(ISNULL(@Parca, N''), 1, 3, N'');   -- bastaki ' + ' at

    IF @Parca = N''
    BEGIN
        SELECT (SELECT 1 AS Sonuc, @KayitId AS KayitId, N'{}' AS Degerler
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
        RETURN;
    END

    DECLARE @sql NVARCHAR(MAX) = N'
SELECT (SELECT 1 AS Sonuc, @pId AS KayitId,
               JSON_QUERY(N''{'' + ISNULL(STUFF(' + @Parca + N', 1, 1, N''''), N'''') + N''}'') AS Degerler
        FROM ' + QUOTENAME(@Tablo) + N' WHERE [ID] = @pId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;';
    EXEC sp_executesql @sql, N'@pId bigint', @pId = @KayitId;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NULL
    EXEC('CREATE ROLE gentegre_api');
GO
GRANT EXECUTE ON dbo.sp_Api_Belge_EkAlan_Json TO gentegre_api;
GO
