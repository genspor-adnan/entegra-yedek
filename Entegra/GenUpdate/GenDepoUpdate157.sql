-- ============================================================
-- GenDepoUpdate157.sql
-- COLLATION TUZAGI: kosullardaki bosluk kontrolu emoji'yi BOS sayiyordu
--
-- SQL Server karsilastirmasi collation AGIRLIGINA bakar. SC (supplementary
--   character) destegi olmayan collation'da - or. Turkish_CI_AS - surrogate
--   cift ile yazilan emoji'nin agirligi YOKTUR:
--       N'<emoji>' = N''   -->   TRUE      (LEN() 2 dedigi halde!)
--   Sonuc: yalniz emoji iceren girdi "bos" sanilip reddediliyordu.
--   GenDepoUpdate156 bunu mesaj gonderiminde duzeltmisti; bu dosya AYNI DESENI
--   diger yazma uclarinda (sp_Api_*) ve mesajlasma nesnelerinde temizler.
--
-- COZUM: DATALENGTH (bayt sayar, collation'dan bagimsiz).
-- KAPSAM: yalniz KOSUL icindeki kontroller (IF / AND / OR / WHEN).
--   ATAMALAR (SET/SELECT @x = N'') ve KOLON karsilastirmalari ELLENMEDI -
--   onlar veri filtresi/ilk deger, davranislari degismemeli.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ---- dbo.sp_Api_Belge_Durum_Yaz_Ic ----

-- ---- dbo.sp_Api_Belge_Durum_Yaz_Ic  (3 yer) ----

-- ---- 2) DURUM HESABI ----------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Durum_Yaz_Ic
    @BelgeId     INT,
    @Kaynak      NVARCHAR(10) = N'siparis',
    @Yaz         BIT = 1,
    @Tur         INT OUTPUT,
    @Durum       INT OUTPUT,
    @OncekiDurum INT OUTPUT,
    @Satir       INT OUTPUT,
    @Tamamlanan  INT OUTPUT,
    @Kismi       INT OUTPUT,
    @Acik        INT OUTPUT,
    @Neden       NVARCHAR(60) OUTPUT,
    @Yazildi     BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Neden = N''; SET @Yazildi = 0;
    SET @Satir = 0; SET @Tamamlanan = 0; SET @Kismi = 0; SET @Acik = 0;

    IF @Kaynak = N'siparis'
        SELECT @Tur = TUR, @OncekiDurum = ISNULL(DURUM, 0) FROM SIPARIS   WHERE ID = @BelgeId;
    ELSE
        SELECT @Tur = TUR, @OncekiDurum = ISNULL(DURUM, 0) FROM FATBASLIK WHERE ID = @BelgeId;

    IF @Tur IS NULL THROW 51002, N'Kayit bulunamadi.', 1;
    SET @Durum = @OncekiDurum;

    -- Yeniden hesaplanabilir durumlar: Taslak(0) / Kismi(1) / Onay(2) / Tamamlandi(9)
    --   IPTAL(6) ve diger ozel durumlar KORUNUR (otomatik degismez).
    IF @OncekiDurum NOT IN (0, 1, 2, 9)
        SET @Neden = N'durum korumali (' + CAST(@OncekiDurum AS nvarchar(10)) + N')';

    -- Bu belge turunden CIKAN donusum kodlari: ROTA MATRISINDEN (elle liste YOK)
    DECLARE @Yeri TABLE (K INT PRIMARY KEY);
    IF DATALENGTH(@Neden) = 0
    BEGIN
        INSERT @Yeri (K)
        SELECT DISTINCT R.DonusumTuru
        FROM dbo.fn_Prog_BelgeDonusum_Rota() R
        WHERE R.KaynakTur = @Tur
          AND R.KaynakDetayTablo = CASE WHEN @Kaynak = N'siparis' THEN 'SIPARISDETAY' ELSE 'FATURA' END
          AND R.KalanHedefTablo = 'FATURA';

        IF NOT EXISTS (SELECT 1 FROM @Yeri)
            SET @Neden = CASE WHEN @Kaynak = N'siparis' THEN N'siparis turu kapsam disi'
                              ELSE N'belge turu kapsam disi' END;
    END

    IF DATALENGTH(@Neden) = 0
    BEGIN
        DECLARE @S TABLE (SatirId INT PRIMARY KEY, Adet DECIMAL(18,6), Cikan DECIMAL(18,6));
        IF @Kaynak = N'siparis'
            INSERT @S SELECT SD.ID, ISNULL(SD.ADET,0),
                   ISNULL((SELECT SUM(ISNULL(F.ADET,0)) FROM FATURA F
                           WHERE F.YERID = SD.ID AND F.YERI IN (SELECT K FROM @Yeri)), 0)
            FROM SIPARISDETAY SD WHERE SD.SIPARISID = @BelgeId AND ISNULL(SD.ADET,0) > 0;
        ELSE
            INSERT @S SELECT FD.ID, ISNULL(FD.ADET,0),
                   ISNULL((SELECT SUM(ISNULL(F.ADET,0)) FROM FATURA F
                           WHERE F.YERID = FD.ID AND F.YERI IN (SELECT K FROM @Yeri)), 0)
            FROM FATURA FD WHERE FD.FATBASID = @BelgeId AND ISNULL(FD.ADET,0) > 0;

        SELECT @Satir      = COUNT(*),
               @Tamamlanan = ISNULL(SUM(CASE WHEN Adet - Cikan <= 0 THEN 1 ELSE 0 END), 0),
               @Acik       = ISNULL(SUM(CASE WHEN Cikan <= 0 THEN 1 ELSE 0 END), 0),
               @Kismi      = ISNULL(SUM(CASE WHEN Cikan > 0 AND Adet - Cikan > 0 THEN 1 ELSE 0 END), 0)
        FROM @S;

        IF @Satir = 0                SET @Neden = N'adetli satir yok';
        ELSE IF @Satir = @Tamamlanan SET @Durum = 9;                       -- Tamamlandi
        -- Hic donusum yoksa: ONAY(2) korunur, digerlerinde TASLAK(0)
        ELSE IF @Acik = @Satir       SET @Durum = CASE WHEN @OncekiDurum = 2 THEN 2 ELSE 0 END;
        ELSE                         SET @Durum = 1;                       -- Kismi
    END

    IF @Yaz = 1 AND DATALENGTH(@Neden) = 0 AND @Durum <> @OncekiDurum
    BEGIN
        IF @Kaynak = N'siparis' UPDATE SIPARIS   SET DURUM = @Durum WHERE ID = @BelgeId;
        ELSE                    UPDATE FATBASLIK SET DURUM = @Durum WHERE ID = @BelgeId;
        SET @Yazildi = 1;
    END
END
GO

-- ---- dbo.sp_Api_Belge_DurumHesapla_Json ----

-- ---- dbo.sp_Api_Belge_DurumHesapla_Json  (1 yer) ----

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_DurumHesapla_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @BelgeId INT          = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeId') AS INT);
    DECLARE @Kaynak  NVARCHAR(10) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.Kaynak'), N'siparis'));
    DECLARE @Yaz     BIT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Yaz') AS BIT), 1);
    IF @BelgeId IS NULL OR @BelgeId <= 0 THROW 51001, N'BelgeId zorunlu.', 1;
    IF @Kaynak NOT IN (N'siparis', N'belge') THROW 51001, N'Kaynak "siparis" ya da "belge" olmali.', 1;

    DECLARE @Tur INT, @Durum INT, @Onceki INT, @Satir INT, @Tam INT, @Kis INT, @Acik INT,
            @Neden NVARCHAR(60), @Yazildi BIT;
    EXEC dbo.sp_Api_Belge_Durum_Yaz_Ic @BelgeId = @BelgeId, @Kaynak = @Kaynak, @Yaz = @Yaz,
         @Tur = @Tur OUTPUT, @Durum = @Durum OUTPUT, @OncekiDurum = @Onceki OUTPUT,
         @Satir = @Satir OUTPUT, @Tamamlanan = @Tam OUTPUT, @Kismi = @Kis OUTPUT,
         @Acik = @Acik OUTPUT, @Neden = @Neden OUTPUT, @Yazildi = @Yazildi OUTPUT;

    SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId, @Kaynak AS Kaynak, @Tur AS Tur,
                   CASE WHEN DATALENGTH(@Neden) = 0 THEN N'ici' ELSE N'disi' END AS Kapsam,
                   @Neden AS Neden, @Durum AS Durum, @Onceki AS OncekiDurum, @Yazildi AS Yazildi,
                   @Satir AS Satir, @Tam AS Tamamlanan, @Kis AS Kismi, @Acik AS Acik
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ---- dbo.sp_Api_Belge_EkAlan_Json ----

-- ---- dbo.sp_Api_Belge_EkAlan_Json  (1 yer) ----

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

    IF DATALENGTH(@Parca) = 0
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

-- ---- dbo.sp_Api_Belge_Toplam_Yaz_Ic ----

-- ---- dbo.sp_Api_Belge_Toplam_Yaz_Ic  (1 yer) ----

-- ============================================================
-- Toplam: hesap + yazma (sonuc kumesi DONDURMEZ)
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Toplam_Yaz_Ic
    @BelgeId  INT,
    @Yaz      BIT = 1,
    @Zorla    BIT = 0,
    @Matrah   MONEY OUTPUT,
    @Kdv      MONEY OUTPUT,
    @Toplam   MONEY OUTPUT,
    @Doviz    MONEY OUTPUT,
    @Maliyet  MONEY OUTPUT,
    @EkVergi  MONEY OUTPUT,
    @Neden    NVARCHAR(60) OUTPUT,
    @Yazildi  BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Neden = N''; SET @Yazildi = 0;

    DECLARE @Tur INT, @Tipi INT, @RaporDoviz NVARCHAR(10), @FaturaDovizi NVARCHAR(10), @EFatDurum INT;
    SELECT @Tur          = TUR,
           @Tipi         = ISNULL(TIPI, 0),
           @EkVergi      = ISNULL(EKVERGI, 0),
           @RaporDoviz   = ISNULL(RAPORDOVIZ, N'TL'),
           @FaturaDovizi = ISNULL(FATURADOVIZI, N'TL'),
           @EFatDurum    = ISNULL(EFATURADURUM, 0)
    FROM FATBASLIK WHERE ID = @BelgeId;

    IF @Tur IS NULL THROW 51002, N'Belge bulunamadi.', 1;

    -- Kapsam: gelen e-belge ve uretim fisinde formul gecersiz (bkz. GenDepoUpdate68)
    IF @EFatDurum <> 0 SET @Neden = N'gelen e-belge';
    ELSE IF @Tur = 6   SET @Neden = N'uretim fisi';

    SELECT @Matrah = CAST(MAX(CASE WHEN TUR = 4 THEN DEGER END) AS MONEY)
    FROM dbo.fn_Api_Belge_DipToplam(@BelgeId);
    IF @Matrah IS NULL
        SELECT @Matrah = CAST(SUM(DEGER) AS MONEY)
        FROM dbo.fn_Api_Belge_DipToplam(@BelgeId) WHERE TUR = 1;

    SELECT @Toplam = CAST(SUM(DEGER) AS MONEY),
           @Doviz  = CAST(SUM(DOVIZTUTARI) AS MONEY)
    FROM dbo.fn_Api_Belge_DipToplam(@BelgeId) WHERE TUR = 20;

    SET @Matrah = ISNULL(@Matrah, 0);
    SET @Toplam = ISNULL(@Toplam, 0);

    IF @Tipi IN (4, 7, 8)
    BEGIN
        SELECT @Kdv = CAST(SUM(DEGER) AS MONEY) FROM dbo.fn_Api_Belge_DipToplam(@BelgeId) WHERE TUR = 15;
        SET @Kdv    = ISNULL(@Kdv, 0);
        SET @Matrah = @Matrah - ABS(@EkVergi);
    END
    ELSE
        SET @Kdv = @Toplam - @Matrah;

    IF @RaporDoviz = N'TL' AND @FaturaDovizi = N'TL' SET @Doviz = @Toplam;
    SET @Doviz = ISNULL(@Doviz, @Toplam);

    SELECT @Maliyet = CAST(ISNULL(ROUND(SUM(F.MIKTAR * ISNULL(SOM.BIRIMMALIYET, 0.0)), 2), 0.0) AS MONEY)
    FROM FATURA F LEFT OUTER JOIN STOK_ORT_MALIYET SOM ON F.ID = SOM.FATURAID
    WHERE F.FATBASID = @BelgeId;
    SET @Maliyet = ISNULL(@Maliyet, 0);

    IF @Yaz = 1 AND (DATALENGTH(@Neden) = 0 OR @Zorla = 1)
    BEGIN
        UPDATE FATBASLIK
           SET FATURA_MATRAHI = @Matrah, KDV_TUTARI = @Kdv, FATURA_TUTARI = @Toplam,
               DOVIZ_TUTARI = @Doviz, FATURA_MALIYETI_ORT = @Maliyet
         WHERE ID = @BelgeId;
        SET @Yazildi = 1;
    END
END
GO

-- ---- dbo.sp_Api_Belge_ToplamHesapla_Json ----

-- ---- dbo.sp_Api_Belge_ToplamHesapla_Json  (2 yer) ----

-- ---- dbo.sp_Api_Belge_ToplamHesapla_Json  (1 yer) ----


-- ============================================================
-- sp_Api_Belge_ToplamHesapla_Json
-- GIRDI : {"BelgeId":5567,"Yaz":1,"Zorla":0}
--         Yaz=0   -> yalniz hesapla, yazma
--         Zorla=1 -> kapsam disi belgede de YAZ (asagiya bak)
--
-- KAPSAM: Dip toplam formulu satirin BIRIMFIYAT*ADET degerinden hesaplar,
--   TUTAR kolonunu kullanmaz. Iki belge sinifinda bu gecersizdir:
--     1) GELEN e-Belge (EFATURADURUM <> 0): toplamlar tedarikcinin UBL'inden
--        gelir; satir BIRIMFIYAT/ADET eksik ya da farkli olcekte olabilir.
--        Ornek olcum (BILIM, 400 belge): 303 gelen e-belgenin 38'inde yeniden
--        hesap tutmadi.
--     2) URETIM FISI (TUR=6): birim fiyat yoktur, TUTAR maliyetten gelir;
--        yeniden hesap 0 uretir.
--   Bu belgelerde hesap YAPILIR ama YAZILMAZ; JSON'da Kapsam='disi' ve Neden
--   doner. Yazmak icin acikca Zorla=1 gerekir.
-- CIKTI : {"Sonuc":1,"BelgeId":..,"Matrah":..,"Kdv":..,"Toplam":..,
--          "Doviz":..,"Maliyet":..,"EkVergi":..}
-- HATA  : 51001 BelgeId eksik/gecersiz, 51002 belge bulunamadi
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_ToplamHesapla_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @BelgeId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeId') AS INT);
    DECLARE @Yaz     BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Yaz') AS BIT), 1);
    DECLARE @Zorla   BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Zorla') AS BIT), 0);

    IF @BelgeId IS NULL OR @BelgeId <= 0
        THROW 51001, N'BelgeId zorunlu.', 1;

    DECLARE @Tur INT, @Tipi INT, @EkVergi MONEY, @RaporDoviz NVARCHAR(10), @FaturaDovizi NVARCHAR(10);
    DECLARE @EFatDurum INT, @Neden NVARCHAR(60) = N'';
    SELECT @EFatDurum = ISNULL(EFATURADURUM, 0) FROM FATBASLIK WHERE ID = @BelgeId;
    SELECT @Tur          = TUR,
           @Tipi         = ISNULL(TIPI, 0),
           @EkVergi      = ISNULL(EKVERGI, 0),
           @RaporDoviz   = ISNULL(RAPORDOVIZ, N'TL'),
           @FaturaDovizi = ISNULL(FATURADOVIZI, N'TL')
    FROM FATBASLIK WHERE ID = @BelgeId;

    IF @Tur IS NULL
        THROW 51002, N'Belge bulunamadi.', 1;

    -- Kapsam kontrolu (yukaridaki KAPSAM notu)
    IF @EFatDurum <> 0 SET @Neden = N'gelen e-belge';
    ELSE IF @Tur = 6   SET @Neden = N'uretim fisi';

    DECLARE @Matrah MONEY, @Kdv MONEY, @Toplam MONEY, @Doviz MONEY, @Maliyet MONEY;

    -- Matrah: once "Ara Toplam" (TUR=4: Toplam + OTV - Iskonto), yoksa "Toplam" (TUR=1).
    --   KDV Dahil belgede TVF zaten brutu ayirip NET matrah uretir (karar 2).
    SELECT @Matrah = CAST(MAX(CASE WHEN TUR = 4 THEN DEGER END) AS MONEY)
    FROM dbo.fn_Api_Belge_DipToplam(@BelgeId);
    IF @Matrah IS NULL
        SELECT @Matrah = CAST(SUM(DEGER) AS MONEY)
        FROM dbo.fn_Api_Belge_DipToplam(@BelgeId) WHERE TUR = 1;

    -- Genel Toplam (TUR=20). EKVERGI/stopaj bu toplama TVF icinde TUR=8/9
    --   satirlariyla ZATEN dahildir - burada TEKRAR eklenmez.
    SELECT @Toplam = CAST(SUM(DEGER) AS MONEY),
           @Doviz  = CAST(SUM(DOVIZTUTARI) AS MONEY)
    FROM dbo.fn_Api_Belge_DipToplam(@BelgeId) WHERE TUR = 20;

    SET @Matrah = ISNULL(@Matrah, 0);
    SET @Toplam = ISNULL(@Toplam, 0);

    -- KDV: stopajli belgelerde (TIPI 4/7/8 - serbest meslek makbuzu vb.) KDV
    --   dogrudan "KDV Toplam" satirindan alinir ve matrahtan stopaj dusulur
    --   (UFaturaWizard.FaturaTutarHesapla ile ayni kural); digerlerinde
    --   KDV = Genel Toplam - Matrah.
    IF @Tipi IN (4, 7, 8)
    BEGIN
        SELECT @Kdv = CAST(SUM(DEGER) AS MONEY)
        FROM dbo.fn_Api_Belge_DipToplam(@BelgeId) WHERE TUR = 15;
        SET @Kdv    = ISNULL(@Kdv, 0);
        SET @Matrah = @Matrah - ABS(@EkVergi);
    END
    ELSE
        SET @Kdv = @Toplam - @Matrah;

    -- Karar 4: TL belgede DOVIZ_TUTARI = TL toplam.
    IF @RaporDoviz = N'TL' AND @FaturaDovizi = N'TL'
        SET @Doviz = @Toplam;
    SET @Doviz = ISNULL(@Doviz, @Toplam);

    -- Ortalama maliyet: stok hareketi miktari (MIKTAR) uzerinden.
    SELECT @Maliyet = CAST(ISNULL(ROUND(SUM(F.MIKTAR * ISNULL(SOM.BIRIMMALIYET, 0.0)), 2), 0.0) AS MONEY)
    FROM FATURA F
        LEFT OUTER JOIN STOK_ORT_MALIYET SOM ON F.ID = SOM.FATURAID
    WHERE F.FATBASID = @BelgeId;
    SET @Maliyet = ISNULL(@Maliyet, 0);

    IF @Yaz = 1 AND (DATALENGTH(@Neden) = 0 OR @Zorla = 1)
        UPDATE FATBASLIK
           SET FATURA_MATRAHI      = @Matrah,
               KDV_TUTARI          = @Kdv,
               FATURA_TUTARI       = @Toplam,
               DOVIZ_TUTARI        = @Doviz,
               FATURA_MALIYETI_ORT = @Maliyet
         WHERE ID = @BelgeId;

    SELECT (SELECT 1        AS Sonuc,
                   @BelgeId AS BelgeId,
                   CASE WHEN DATALENGTH(@Neden) = 0 THEN N'ici' ELSE N'disi' END AS Kapsam,
                   @Neden   AS Neden,
                   CASE WHEN @Yaz = 1 AND (DATALENGTH(@Neden) = 0 OR @Zorla = 1) THEN 1 ELSE 0 END AS Yazildi,
                   @Matrah  AS Matrah,
                   @Kdv     AS Kdv,
                   @Toplam  AS Toplam,
                   @Doviz   AS Doviz,
                   @Maliyet AS Maliyet,
                   @EkVergi AS EkVergi
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ---- dbo.sp_Api_Log_Yaz_Ic ----

-- ---- dbo.sp_Api_Log_Yaz_Ic  (1 yer) ----

CREATE OR ALTER PROCEDURE dbo.sp_Api_Log_Yaz_Ic
    @Tablo    sysname,
    @Kosul    NVARCHAR(MAX) = NULL,
    -- @Kosul icinde kullanilabilecek TEK parametre: @pB (ust kayit/belge ID'si).
    --   Boylece kosul metni sabit kalir, deger parametreyle baglanir (birlestirme yok).
    @KosulPar BIGINT        = NULL,
    @KayitId  BIGINT        = NULL,
    @TabNo    INT,
    @UstTabNo INT           = 0,
    @UstId    BIGINT        = 0,
    @KulId    INT           = 0,
    @SubeId   INT           = 0,
    @Ip       VARCHAR(45)   = NULL,
    @Istasyon VARCHAR(64)   = NULL,
    @RehberId BIGINT        = 0,
    @StokId   BIGINT        = 0,
    -- 0 = liSil (varsayilan), 1 = liEkle, 2 = liDegistir (ULog.TLogIslem ile ayni)
    @IslemTipi TINYINT      = 0,
    @Yazilan  INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Yazilan = 0;

    DECLARE @oid INT = OBJECT_ID(@Tablo);
    IF @oid IS NULL
        THROW 51002, N'Tablo bulunamadi.', 1;

    DECLARE @LogTablo sysname;
    DECLARE @Yil INT = YEAR(GETDATE());
    EXEC dbo.sp_Api_Log_YilTablosu @Yil = @Yil, @Tablo = @LogTablo OUTPUT;

    -- ---- BILGI JSON ifadesi: kolon basina  ,"AD":"deger"  (NULL/bos ve blob HARIC) ----
    -- DIKKAT: "SELECT @v = @v + ..." birikimli atama JOIN + ORDER BY ile
    --   BELIRSIZDIR (SQL Server garanti vermez). Ifade FOR XML PATH ile kurulur.
    DECLARE @Parca NVARCHAR(MAX) =
    (
        SELECT N' + CASE WHEN ' + QUOTENAME(c.name) + N' IS NULL THEN N'''' ELSE ' +
               N'N'',"' + STRING_ESCAPE(c.name, 'json') + N'":"'' + STRING_ESCAPE(' +
               CASE
                 WHEN t.name = 'date'                    THEN N'CONVERT(nvarchar(10), ' + QUOTENAME(c.name) + N', 23)'
                 WHEN t.name IN ('datetime','datetime2','smalldatetime','datetimeoffset')
                                                         THEN N'CONVERT(nvarchar(19), ' + QUOTENAME(c.name) + N', 120)'
                 WHEN t.name = 'time'                    THEN N'CONVERT(nvarchar(8),  ' + QUOTENAME(c.name) + N', 108)'
                 WHEN t.name IN ('float','real')         THEN N'CONVERT(nvarchar(50), ' + QUOTENAME(c.name) + N')'
                 WHEN t.name IN ('money','smallmoney','decimal','numeric')
                                                         THEN N'CONVERT(nvarchar(50), CAST(' + QUOTENAME(c.name) + N' AS decimal(38,6)))'
                 WHEN t.name = 'bit'                     THEN N'CASE WHEN ' + QUOTENAME(c.name) + N' = 1 THEN N''True'' ELSE N''False'' END'
                 WHEN t.name = 'uniqueidentifier'        THEN N'CONVERT(nvarchar(36), ' + QUOTENAME(c.name) + N')'
                 ELSE N'CAST(' + QUOTENAME(c.name) + N' AS nvarchar(max))'
               END +
               N', ''json'') + N''"'' END'
        FROM sys.columns c
            JOIN sys.types t ON t.user_type_id = c.user_type_id
        WHERE c.object_id = @oid
          AND t.name NOT IN ('varbinary','binary','image','text','ntext','xml',
                             'geography','geometry','hierarchyid','sql_variant','timestamp')
          AND c.generated_always_type = 0
          AND c.is_hidden = 0
        ORDER BY c.column_id
        FOR XML PATH(''), TYPE
    ).value('.', 'nvarchar(max)');
    SET @Parca = STUFF(ISNULL(@Parca, N''), 1, 3, N'');   -- bastaki ' + ' at

    IF DATALENGTH(@Parca) = 0 RETURN;

    DECLARE @IdVar BIT = CASE WHEN EXISTS (SELECT 1 FROM sys.columns WHERE object_id = @oid AND name = 'ID')
                              THEN 1 ELSE 0 END;

    -- Satirin KENDI varlik kolonlari (ULog.LogVarlikIDleri ile ayni oncelik).
    --   Bunlar olmadan UInfo silme satirinda cari/stok KOD-AD cozulemiyordu.
--   Tablo iki kolonu da tasiyabilir (FATURA'da hem STOKID hem URUNID var) ve
--   biri NULL olabilir -> ULog gibi SIRAYLA denenir, ilk dolu olan alinir.
--   NOT: COALESCE tek argumanla SOZDIZIMI HATASI verir -> kolon sayisi 1 ise
--   sarmalanmaz, 0 ise NULL yazilir.
    DECLARE @RehIfade NVARCHAR(400), @StkIfade NVARCHAR(400);
    DECLARE @RehLst NVARCHAR(400) =
        (SELECT STRING_AGG(N'NULLIF(CAST(' + QUOTENAME(x.name) + N' AS bigint), 0)', N', ')
                  WITHIN GROUP (ORDER BY x.sira)
           FROM (SELECT c.name, sira = CASE c.name WHEN 'REHBERID' THEN 0 ELSE 1 END
                   FROM sys.columns c
                  WHERE c.object_id = @oid AND c.name IN ('REHBERID','CARIID')) x);
    DECLARE @StkLst NVARCHAR(400) =
        (SELECT STRING_AGG(N'NULLIF(CAST(' + QUOTENAME(x.name) + N' AS bigint), 0)', N', ')
                  WITHIN GROUP (ORDER BY x.sira)
           FROM (SELECT c.name, sira = CASE c.name WHEN 'STOKID' THEN 0 ELSE 1 END
                   FROM sys.columns c
                  WHERE c.object_id = @oid AND c.name IN ('STOKID','URUNID')) x);
    -- Kolon SAYISI ile karar ver: uretilen ifade zaten virgul iceriyor
    --   (NULLIF(..., 0)), o yuzden virgul saymak YANLIS olur.
    DECLARE @RehAdet INT = (SELECT COUNT(*) FROM sys.columns c
                             WHERE c.object_id = @oid AND c.name IN ('REHBERID','CARIID'));
    DECLARE @StkAdet INT = (SELECT COUNT(*) FROM sys.columns c
                             WHERE c.object_id = @oid AND c.name IN ('STOKID','URUNID'));
    SET @RehIfade = CASE WHEN @RehAdet = 0 THEN N'NULL'
                         WHEN @RehAdet = 1 THEN @RehLst
                         ELSE N'COALESCE(' + @RehLst + N')' END;
    SET @StkIfade = CASE WHEN @StkAdet = 0 THEN N'NULL'
                         WHEN @StkAdet = 1 THEN @StkLst
                         ELSE N'COALESCE(' + @StkLst + N')' END;
    DECLARE @KayitIfade NVARCHAR(100) = CASE WHEN @IdVar = 1 THEN N'CAST([ID] AS bigint)' ELSE N'CAST(0 AS bigint)' END;

    DECLARE @Where NVARCHAR(MAX) =
        CASE WHEN NULLIF(LTRIM(RTRIM(ISNULL(@Kosul, N''))), N'') IS NOT NULL THEN @Kosul
             WHEN @IdVar = 1 AND @KayitId IS NOT NULL THEN N'[ID] = @pKayit'
             ELSE N'1=0' END;

    -- REHBERID / STOKID turetimi (ULog.LogYaz kurali)
    DECLARE @UstT INT = CASE WHEN ISNULL(@UstTabNo, 0) = 0 THEN @TabNo ELSE @UstTabNo END;
    DECLARE @Reh BIGINT = NULLIF(ISNULL(@RehberId, 0), 0);
    DECLARE @Stk BIGINT = NULLIF(ISNULL(@StokId, 0), 0);
    DECLARE @RehKendi BIT = 0, @StkKendi BIT = 0;
    IF @Reh IS NULL
    BEGIN
        IF @TabNo IN (71, 73, 74) SET @RehKendi = 1;            -- kartin kendisi -> KAYITID
        ELSE IF @UstT IN (71, 73, 74) SET @Reh = NULLIF(@UstId, 0);
    END
    IF @Stk IS NULL
    BEGIN
        IF @TabNo = 88 SET @StkKendi = 1;
        ELSE IF @UstT = 88 SET @Stk = NULLIF(@UstId, 0);
    END

    DECLARE @sql NVARCHAR(MAX) = N'
INSERT INTO ' + @LogTablo + N' (IP,ISTASYON,KULLANICIID,SUBEID,ISLEMTIPI,ALTISLEMTIPI,
        USTTABLOID,USTKAYITID,TABLOID,KAYITID,REHBERID,STOKID,BILGI)
SELECT @pIp, @pIst, @pKul, @pSub, @pTip, @pTip,
       @pUstT,
       CASE WHEN ISNULL(@pUstId,0) = 0 THEN ' + @KayitIfade + N' ELSE @pUstId END,
       @pTabNo, ' + @KayitIfade + N',
       NULLIF(CASE WHEN @pRehKendi = 1 THEN ' + @KayitIfade + N'
                   ELSE COALESCE(@pReh, ' + @RehIfade + N') END, 0),
       NULLIF(CASE WHEN @pStkKendi = 1 THEN ' + @KayitIfade + N'
                   ELSE COALESCE(@pStk, ' + @StkIfade + N') END, 0),
       COMPRESS(CAST(N''{'' + ISNULL(STUFF(' + @Parca + N', 1, 1, N''''), N'''') + N''}'' AS nvarchar(max)))
FROM ' + QUOTENAME(OBJECT_SCHEMA_NAME(@oid)) + N'.' + QUOTENAME(OBJECT_NAME(@oid)) + N'
WHERE ' + @Where + N';
SET @pN = @@ROWCOUNT;';

    EXEC sp_executesql @sql,
        N'@pIp varchar(45), @pIst varchar(64), @pKul int, @pSub int, @pUstT int, @pUstId bigint,
          @pTabNo int, @pReh bigint, @pStk bigint, @pRehKendi bit, @pStkKendi bit,
          @pKayit bigint, @pB bigint, @pTip tinyint, @pN int OUTPUT',
        @pIp = @Ip, @pIst = @Istasyon, @pKul = @KulId, @pSub = @SubeId,
        @pUstT = @UstT, @pUstId = @UstId, @pTabNo = @TabNo,
        @pReh = @Reh, @pStk = @Stk, @pRehKendi = @RehKendi, @pStkKendi = @StkKendi,
        @pKayit = @KayitId, @pB = @KosulPar, @pTip = @IslemTipi, @pN = @Yazilan OUTPUT;
END
GO

-- ---- dbo.sp_Api_Mesaj_Kanal_Kaydet_Json ----

-- ---- dbo.sp_Api_Mesaj_Kanal_Kaydet_Json  (2 yer) ----

-- ============================================================
-- 1) KANAL: ac / olustur / uye yonet
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Kanal_Kaydet_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Islem   NVARCHAR(20) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.Islem'), N'birebir'));
    DECLARE @KanalId INT  = TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId') AS INT);
    DECLARE @KarsiId INT  = TRY_CAST(JSON_VALUE(@Kosullar, '$.KarsiId') AS INT);
    DECLARE @Adi     NVARCHAR(100) = JSON_VALUE(@Kosullar, '$.Adi');
    DECLARE @Bildirim BIT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Bildirim') AS BIT);
    DECLARE @Gecmis  BIT  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.EskiMesajlar') AS BIT), 0); -- yeni uye eski mesajlari gorsun mu
    DECLARE @KulId   INT  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId  INT  = TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT);

    IF @KulId <= 0 THROW 51001, N'Oturum.KulId zorunlu.', 1;

    DECLARE @Uyeler TABLE (RehberId INT PRIMARY KEY);
    INSERT @Uyeler (RehberId)
    SELECT DISTINCT TRY_CAST(value AS INT) FROM OPENJSON(@Kosullar, '$.Uyeler')
    WHERE TRY_CAST(value AS INT) IS NOT NULL AND TRY_CAST(value AS INT) <> @KulId;

    DECLARE @Yeni BIT = 0, @SonId BIGINT;

    ------------------------------------------------------------------ BIREBIR
    IF @Islem = N'birebir'
    BEGIN
        IF ISNULL(@KarsiId, 0) <= 0 THROW 51001, N'KarsiId zorunlu.', 1;
        IF @KarsiId = @KulId        THROW 51200, N'Kendinizle sohbet açamazsınız.', 1;
        IF NOT EXISTS (SELECT 1 FROM dbo.REHBER WHERE ID = @KarsiId)
            THROW 51002, N'Kişi bulunamadı.', 1;

        BEGIN TRAN;
        -- Yaris korumasi: ayni ikili icin ikinci kanal acilmasin.
        SELECT TOP 1 @KanalId = ID FROM dbo.MESAJKANAL WITH (UPDLOCK, HOLDLOCK)
         WHERE ID = dbo.fn_Prog_Mesaj_BirebirKanal(@KulId, @KarsiId);

        IF @KanalId IS NULL
        BEGIN
            INSERT INTO dbo.MESAJKANAL (TUR, ADI, OLUSTURAN, DURUM, SUBEID)
            VALUES (1, NULL, @KulId, 1, @SubeId);
            SET @KanalId = CAST(SCOPE_IDENTITY() AS INT);
            SET @Yeni = 1;

            INSERT INTO dbo.MESAJKANALUYE (KANALID, REHBERID, ROL)
            VALUES (@KanalId, @KulId, 1), (@KanalId, @KarsiId, 1);
        END
        COMMIT;
    END

    ------------------------------------------------------------------ GRUP
    ELSE IF @Islem = N'grup'
    BEGIN
        IF DATALENGTH(ISNULL(@Adi, N'')) = 0 THROW 51001, N'Grup adı zorunlu.', 1;

        BEGIN TRAN;
        INSERT INTO dbo.MESAJKANAL (TUR, ADI, OLUSTURAN, DURUM, SUBEID)
        VALUES (2, @Adi, @KulId, 1, @SubeId);
        SET @KanalId = CAST(SCOPE_IDENTITY() AS INT);
        SET @Yeni = 1;

        INSERT INTO dbo.MESAJKANALUYE (KANALID, REHBERID, ROL) VALUES (@KanalId, @KulId, 1);
        INSERT INTO dbo.MESAJKANALUYE (KANALID, REHBERID, ROL)
        SELECT @KanalId, U.RehberId, 0 FROM @Uyeler U
        WHERE EXISTS (SELECT 1 FROM dbo.REHBER R WHERE R.ID = U.RehberId);
        COMMIT;
    END

    ------------------------------------------------------------------ UYE EKLE
    ELSE IF @Islem = N'uyeekle'
    BEGIN
        IF ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId zorunlu.', 1;
        IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                        WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL)
            THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;
        IF (SELECT TUR FROM dbo.MESAJKANAL WHERE ID = @KanalId) <> 2
            THROW 51200, N'Yalnızca gruplara üye eklenebilir.', 1;

        SET @SonId = ISNULL((SELECT MAX(ID) FROM dbo.MESAJ WHERE KANALID = @KanalId), 0);

        BEGIN TRAN;
        -- Daha once ayrilmis uye geri geliyorsa satiri canlandir.
        UPDATE U SET AYRILMATARIHI = NULL, KATILMATARIHI = GETDATE(),
                     BASLANGICID = CASE WHEN @Gecmis = 1 THEN 0 ELSE @SonId END
          FROM dbo.MESAJKANALUYE U INNER JOIN @Uyeler Y ON Y.RehberId = U.REHBERID
         WHERE U.KANALID = @KanalId AND U.AYRILMATARIHI IS NOT NULL;

        INSERT INTO dbo.MESAJKANALUYE (KANALID, REHBERID, ROL, BASLANGICID, SONOKUMAID)
        SELECT @KanalId, Y.RehberId, 0,
               CASE WHEN @Gecmis = 1 THEN 0 ELSE @SonId END,
               CASE WHEN @Gecmis = 1 THEN 0 ELSE @SonId END
          FROM @Uyeler Y
         WHERE EXISTS (SELECT 1 FROM dbo.REHBER R WHERE R.ID = Y.RehberId)
           AND NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE U
                            WHERE U.KANALID = @KanalId AND U.REHBERID = Y.RehberId);
        COMMIT;
    END

    ------------------------------------------------------------------ UYE CIKAR
    ELSE IF @Islem = N'uyecikar'
    BEGIN
        IF ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId zorunlu.', 1;
        -- Kendisi cikabilir; baskasini yalnizca yonetici cikarabilir.
        IF EXISTS (SELECT 1 FROM @Uyeler WHERE RehberId <> @KulId)
           AND NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                            WHERE KANALID = @KanalId AND REHBERID = @KulId
                              AND ROL = 1 AND AYRILMATARIHI IS NULL)
            THROW 51200, N'Üye çıkarmak için grup yöneticisi olmalısınız.', 1;

        UPDATE dbo.MESAJKANALUYE SET AYRILMATARIHI = GETDATE()
         WHERE KANALID = @KanalId AND AYRILMATARIHI IS NULL
           AND REHBERID IN (SELECT RehberId FROM @Uyeler
                            UNION ALL SELECT @KulId WHERE NOT EXISTS (SELECT 1 FROM @Uyeler));
    END

    ------------------------------------------------------------------ AD DEGISTIR
    ELSE IF @Islem = N'addegistir'
    BEGIN
        IF ISNULL(@KanalId, 0) <= 0 OR DATALENGTH(ISNULL(@Adi, N'')) = 0 THROW 51001, N'KanalId ve Adi zorunlu.', 1;
        IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                        WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL)
            THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;
        UPDATE dbo.MESAJKANAL SET ADI = @Adi WHERE ID = @KanalId AND TUR = 2;
    END

    ------------------------------------------------------------------ SESSIZE AL / AC
    ELSE IF @Islem = N'sessize'
    BEGIN
        IF ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId zorunlu.', 1;
        UPDATE dbo.MESAJKANALUYE SET BILDIRIM = ISNULL(@Bildirim, 0)
         WHERE KANALID = @KanalId AND REHBERID = @KulId;
    END
    ELSE
        THROW 51001, N'Bilinmeyen Islem.', 1;

    -- bit -> JSON true/false olur; istemci sayi bekliyor (FireDAC/JSON tuzagi) -> CAST
    SELECT Sonuc = 1, KanalId = @KanalId, Yeni = CAST(@Yeni AS INT)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- dbo.sp_Api_POS_Tahsilat_Json ----

-- ---- dbo.sp_Api_POS_Tahsilat_Json  (2 yer) ----

-- ============================================================
-- 1) TAHSILAT: tum odeme satirlari TEK transaction
--   {"RehId":..,"FatTur":..,"YerId":..,"FaturaId":..,"MasrafId":..,"Kur":"TL",
--    "Perakende":0/1,"KasaTakipTabNo":..,"GirisKaynak":..,
--    "Satirlar":[{"Tur":21,"HesapId":5,"MusteriHesapId":0,"Tutar":100.0,"HesapTuru":"K"}],
--    "Oturum":{"KulId":..,"SubeId":..}}
--   Perakende=1 -> KASA yerine SATISKASA (hizli satis kaydi, ID uretmez -> '0')
-- CIKTI: {"Sonuc":1,"Idler":"12,13","Adet":2}
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_POS_Tahsilat_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @RehId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.RehId')    AS INT), 0);
    DECLARE @FatTur   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.FatTur')   AS INT), 0);
    DECLARE @YerId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.YerId')    AS INT), 0);
    DECLARE @FaturaId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.FaturaId') AS INT), 0);
    DECLARE @MasrafId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.MasrafId') AS INT), 0);
    DECLARE @Kur      NVARCHAR(5) = ISNULL(JSON_VALUE(@Kosullar, '$.Kur'), N'TL');
    DECLARE @Perakende BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Perakende') AS BIT), 0);
    DECLARE @KasaTakip INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KasaTakipTabNo') AS INT), 0);
    DECLARE @GirisKay  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.GirisKaynak')    AS INT), 0);
    DECLARE @KulId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), 0);
    DECLARE @Simdi    DATETIME = GETDATE();

    DECLARE @Satir TABLE (Sira INT IDENTITY(1,1), Tur INT, HesapId INT, MusteriHesapId INT,
                          Tutar MONEY, HesapTuru CHAR(1));
    INSERT @Satir (Tur, HesapId, MusteriHesapId, Tutar, HesapTuru)
    SELECT ISNULL(Tur, 0), ISNULL(HesapId, 0), ISNULL(MusteriHesapId, 0),
           ISNULL(Tutar, 0), ISNULL(LEFT(HesapTuru, 1), 'K')
    FROM OPENJSON(@Kosullar, '$.Satirlar')
    WITH (Tur INT '$.Tur', HesapId INT '$.HesapId', MusteriHesapId INT '$.MusteriHesapId',
          Tutar MONEY '$.Tutar', HesapTuru NVARCHAR(2) '$.HesapTuru')
    WHERE ISNULL(Tutar, 0) >= 0.01;

    IF NOT EXISTS (SELECT 1 FROM @Satir)
    BEGIN
        SELECT Sonuc = 1, Idler = N'', Adet = 0 FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
        RETURN;
    END

    DECLARE @Yeni TABLE (ID BIGINT);
    DECLARE @Idler NVARCHAR(MAX) = N'', @Adet INT = 0;
    DECLARE @i INT = 1, @Son INT = (SELECT MAX(Sira) FROM @Satir);
    DECLARE @Tur INT, @HesapId INT, @MHesapId INT, @Tutar MONEY, @HTur CHAR(1);
    DECLARE @BN TABLE (KOCANNO INT, BELGESERI NVARCHAR(5), BELGENO NVARCHAR(20));
    DECLARE @BelgeNo NVARCHAR(30);

    BEGIN TRAN;

    WHILE @i <= @Son
    BEGIN
        SELECT @Tur = Tur, @HesapId = HesapId, @MHesapId = MusteriHesapId,
               @Tutar = Tutar, @HTur = HesapTuru
          FROM @Satir WHERE Sira = @i;

        IF @Tur IS NULL BEGIN SET @i += 1; CONTINUE; END

        IF @Perakende = 1
        BEGIN
            INSERT INTO dbo.SATISKASA (TUR, TARIH, REHBERID, HESAPID, TUTAR, FATURAID, EKLEYEN, SUBEID, AKTAR)
            VALUES (@Tur, @Simdi, @RehId, @HesapId, @Tutar, 0, @KulId, @SubeId, 0);
            SET @Idler = @Idler + CASE WHEN DATALENGTH(@Idler) = 0 THEN N'' ELSE N',' END + N'0';
        END
        ELSE
        BEGIN
            -- Makbuz no: kocan SEQUENCE'i (sp_BelgeNoGetir). NOT: bu SP "INSERT ... EXEC"
            --   kullandigi icin sp_Api_POS_Tahsilat_Json'un kendisi INSERT-EXEC ile cagrilamaz.
            DELETE @BN;
            INSERT @BN EXEC dbo.sp_BelgeNoGetir @IslemTur = @Tur, @SubeID = @SubeId;
            SELECT TOP 1 @BelgeNo = ISNULL(BELGESERI, N'') + ISNULL(BELGENO, N'') FROM @BN;

            DELETE @Yeni;
            INSERT INTO dbo.KASA (TUR, PLANTARIHI, ISLEMTARIHI, BELGENO, REHBERID, HESAPID,
                                  BORC, ALACAK, KUR, DOVIZ_TUTARI, DOVIZ_KURU, HESAPTURU,
                                  MASRAFID, FATURAID, MUSTERIHESAPID,
                                  EKLEYEN, SUBEID, YERI, YERID, GIRISKAYNAK)
            OUTPUT inserted.ID INTO @Yeni (ID)
            VALUES (@Tur, @Simdi, @Simdi, @BelgeNo, @RehId, @HesapId,
                    0, @Tutar, @Kur, @Tutar, @Kur, @HTur,
                    CASE WHEN @FatTur > 0 THEN NULLIF(@MasrafId, 0) END,
                    CASE WHEN @FatTur > 0 THEN NULLIF(@FaturaId, 0) END,
                    CASE WHEN @Tur = 25 THEN NULLIF(@MHesapId, 0) END,
                    @KulId, @SubeId, @KasaTakip, @YerId, @GirisKay);

            SET @Idler = @Idler + CASE WHEN DATALENGTH(@Idler) = 0 THEN N'' ELSE N',' END +
                         CAST((SELECT TOP 1 ID FROM @Yeni) AS NVARCHAR(20));
        END

        SET @Adet += 1;
        SET @i += 1;
    END

    COMMIT;

    SELECT Sonuc = 1, Idler = @Idler, Adet = @Adet FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- dbo.sp_Api_Rehber_Kaydet_Ic ----

-- ---- dbo.sp_Api_Rehber_Kaydet_Ic  (2 yer) ----

-- ============================================================
-- REHBER (cari / IK) ORTAK KAYDET CEKIRDEGI
--   @TabNo: 71 cari, 73 IK  (log ve modul ayrimi icin)
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Rehber_Kaydet_Ic
    @Kosullar   NVARCHAR(MAX),
    @TabNo      INT,
    @KayitIdOut INT = NULL OUTPUT,
    @SonucDondur BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Mod NVARCHAR(10) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.SatirModu'), N'delta'));
    IF @Mod NOT IN (N'delta', N'tam') THROW 51001, N'SatirModu "delta" ya da "tam" olmali.', 1;

    DECLARE @KulId  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);
    DECLARE @Id     INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.ID') AS INT);
    DECLARE @Yeni   BIT = CASE WHEN ISNULL(@Id, 0) = 0 THEN 1 ELSE 0 END;
    DECLARE @Simdi  DATETIME = GETDATE();

    IF @Yeni = 0 AND NOT EXISTS (SELECT 1 FROM dbo.REHBER WHERE ID = @Id)
        THROW 51002, N'Kart bulunamadı.', 1;

    DECLARE @Kod   NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Kart.Kod');
    DECLARE @Firma NVARCHAR(200) = JSON_VALUE(@Kosullar, '$.Kart.Firma');
    DECLARE @Grup  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Grup') AS INT);

    IF @Yeni = 1 AND DATALENGTH(ISNULL(@Firma, N'')) = 0
        THROW 51001, N'Yeni kartta Kart.Firma zorunlu.', 1;
    IF @Kod IS NOT NULL AND DATALENGTH(@Kod) > 0
       AND EXISTS (SELECT 1 FROM dbo.REHBER WHERE KOD = @Kod AND ID <> ISNULL(@Id, 0))
        THROW 51200, N'Bu cari kodu zaten kullanılıyor.', 1;

    DECLARE @Loglanan INT = 0, @n INT;

    BEGIN TRAN;

    IF @Yeni = 1
    BEGIN
        INSERT INTO dbo.REHBER
            (KOD, FIRMA, STATU, GRUP, KATEGORI, SINIF, DURUM, TEMSILCI, NOTLAR, OZELKOD,
             YETKIKODU, OZEL, BOLGE, MUHKODU, BAGID, SEKTOR, ALTBOLGE, PERYOT, ALTSEKTOR,
             POSTA, EPOSTA, TEMAS, EFATURA, KONUM, GIRISKAYNAK, EKLEYEN, EKLEMETARIHI, SUBEID)
        VALUES
            (@Kod, @Firma,
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Statu') AS INT),
             @Grup,
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Kategori') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Sinif') AS INT),
             ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Durum') AS INT), 1),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Temsilci') AS INT),
             JSON_VALUE(@Kosullar, '$.Kart.Notlar'),
             JSON_VALUE(@Kosullar, '$.Kart.OzelKod'),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.YetkiKodu') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Ozel') AS BIT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Bolge') AS INT),
             JSON_VALUE(@Kosullar, '$.Kart.MuhKodu'),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.BagId') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Sektor') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.AltBolge') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Peryot') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.AltSektor') AS INT),
             JSON_VALUE(@Kosullar, '$.Kart.Posta'),
             JSON_VALUE(@Kosullar, '$.Kart.Eposta'),
             JSON_VALUE(@Kosullar, '$.Kart.Temas'),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.EFatura') AS BIT),
             JSON_VALUE(@Kosullar, '$.Kart.Konum'),
             ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.GirisKaynak') AS INT), 0),
             @KulId, @Simdi, @SubeId);

        SET @Id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.REHBER SET
            KOD       = ISNULL(@Kod, KOD),
            FIRMA     = ISNULL(@Firma, FIRMA),
            STATU     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Statu') AS INT), STATU),
            GRUP      = ISNULL(@Grup, GRUP),
            KATEGORI  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Kategori') AS INT), KATEGORI),
            SINIF     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Sinif') AS INT), SINIF),
            DURUM     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Durum') AS INT), DURUM),
            TEMSILCI  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Temsilci') AS INT), TEMSILCI),
            NOTLAR    = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Notlar'), NOTLAR),
            OZELKOD   = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.OzelKod'), OZELKOD),
            YETKIKODU = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.YetkiKodu') AS INT), YETKIKODU),
            OZEL      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Ozel') AS BIT), OZEL),
            BOLGE     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Bolge') AS INT), BOLGE),
            MUHKODU   = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.MuhKodu'), MUHKODU),
            BAGID     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.BagId') AS INT), BAGID),
            SEKTOR    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Sektor') AS INT), SEKTOR),
            ALTBOLGE  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.AltBolge') AS INT), ALTBOLGE),
            PERYOT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Peryot') AS INT), PERYOT),
            ALTSEKTOR = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.AltSektor') AS INT), ALTSEKTOR),
            POSTA     = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Posta'), POSTA),
            EPOSTA    = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Eposta'), EPOSTA),
            TEMAS     = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Temas'), TEMAS),
            EFATURA   = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.EFatura') AS BIT), EFATURA),
            KONUM     = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Konum'), KONUM),
            DEGISTIREN = @KulId,
            DEGISTIRMETARIHI = @Simdi
        WHERE ID = @Id;
    END

    ------------------------------------------------------------------ ILETISIMLER (+ bilgileri)
    IF JSON_QUERY(@Kosullar, '$.Iletisimler') IS NOT NULL
    BEGIN
        DECLARE @I TABLE (Sira INT IDENTITY(1,1), SatirId INT, Sil BIT, Ad NVARCHAR(200),
                          Varsayilan BIT, Aktif BIT, Bilgiler NVARCHAR(MAX), YeniId INT NULL);
        INSERT @I (SatirId, Sil, Ad, Varsayilan, Aktif, Bilgiler)
        SELECT ISNULL(ID,0), ISNULL(Sil,0), Ad, ISNULL(Varsayilan,0), ISNULL(Aktif,1), Bilgiler
        FROM OPENJSON(@Kosullar, '$.Iletisimler')
        WITH (ID INT, Sil BIT, Ad NVARCHAR(200), Varsayilan BIT, Aktif BIT,
              Bilgiler NVARCHAR(MAX) AS JSON);

        -- silinenler: once alt bilgileri
        DELETE FROM dbo.REHBERBILGI
         WHERE YERI = 1 AND YER_ID IN (SELECT SatirId FROM @I WHERE Sil = 1 AND SatirId > 0);
        DELETE RI FROM dbo.REHBERILETISIM RI INNER JOIN @I I ON I.SatirId = RI.ID WHERE I.Sil = 1;

        IF @Mod = N'tam'
        BEGIN
            DELETE FROM dbo.REHBERBILGI
             WHERE YERI = 1 AND YER_ID IN (SELECT ID FROM dbo.REHBERILETISIM
                                            WHERE REHBERID = @Id
                                              AND ID NOT IN (SELECT SatirId FROM @I WHERE SatirId > 0));
            DELETE FROM dbo.REHBERILETISIM
             WHERE REHBERID = @Id AND ID NOT IN (SELECT SatirId FROM @I WHERE SatirId > 0);
        END

        UPDATE RI SET AD = I.Ad, VARSAYILAN = I.Varsayilan, AKTIF = I.Aktif,
                      DEGISTIREN = @KulId, DEGISTIRMETARIHI = @Simdi
          FROM dbo.REHBERILETISIM RI INNER JOIN @I I ON I.SatirId = RI.ID
         WHERE I.Sil = 0;

        -- yeni iletisimler tek tek (alt bilgileri yeni ID'ye baglanacak)
        DECLARE @k INT = 1, @Son INT = (SELECT ISNULL(MAX(Sira), 0) FROM @I);
        DECLARE @IlId INT, @Bilgi NVARCHAR(MAX), @SatirId INT, @Sil BIT;
        WHILE @k <= @Son
        BEGIN
            SELECT @SatirId = SatirId, @Sil = Sil, @Bilgi = Bilgiler FROM @I WHERE Sira = @k;

            IF @Sil = 0
            BEGIN
                IF @SatirId = 0
                BEGIN
                    INSERT INTO dbo.REHBERILETISIM (REHBERID, AD, VARSAYILAN, AKTIF, EKLEYEN, EKLEMETARIHI, SUBEID)
                    SELECT @Id, Ad, Varsayilan, Aktif, @KulId, @Simdi, @SubeId FROM @I WHERE Sira = @k;
                    SET @IlId = SCOPE_IDENTITY();
                    UPDATE @I SET YeniId = @IlId WHERE Sira = @k;
                END
                ELSE
                    SET @IlId = @SatirId;

                IF @Bilgi IS NOT NULL
                BEGIN
                    -- iletisim altindaki bilgi satirlari (telefon/mail vb.): YERI=1
                    DELETE FROM dbo.REHBERBILGI
                     WHERE YERI = 1 AND YER_ID = @IlId
                       AND ID IN (SELECT ID FROM OPENJSON(@Bilgi) WITH (ID INT, Sil BIT) WHERE Sil = 1);

                    IF @Mod = N'tam'
                        DELETE FROM dbo.REHBERBILGI
                         WHERE YERI = 1 AND YER_ID = @IlId
                           AND ID NOT IN (SELECT ISNULL(ID,0) FROM OPENJSON(@Bilgi) WITH (ID INT));

                    UPDATE RB SET MODUL = J.Modul, SIRA = J.Sira, ETIKET = J.Etiket, BILGI = J.Bilgi,
                                  DEGISTIREN = @KulId, DEGISTIRMETARIHI = @Simdi
                      FROM dbo.REHBERBILGI RB
                           INNER JOIN OPENJSON(@Bilgi)
                                WITH (ID INT, Sil BIT, Modul INT, Sira INT,
                                      Etiket NVARCHAR(100), Bilgi NVARCHAR(250)) J ON J.ID = RB.ID
                     WHERE ISNULL(J.Sil, 0) = 0;

                    INSERT INTO dbo.REHBERBILGI (MODUL, YERI, YER_ID, SIRA, ETIKET, BILGI, EKLEYEN, EKLEMETARIHI, SUBEID)
                    SELECT J.Modul, 1, @IlId, J.Sira, J.Etiket, J.Bilgi, @KulId, @Simdi, @SubeId
                      FROM OPENJSON(@Bilgi)
                           WITH (ID INT, Sil BIT, Modul INT, Sira INT,
                                 Etiket NVARCHAR(100), Bilgi NVARCHAR(250)) J
                     WHERE ISNULL(J.ID, 0) = 0 AND ISNULL(J.Sil, 0) = 0;
                END
            END

            SET @k += 1;
        END
    END

    ------------------------------------------------------------------ IK: PERSONEL HAREKETLERI
    IF @TabNo = 73 AND JSON_QUERY(@Kosullar, '$.Hareketler') IS NOT NULL
    BEGIN
        DECLARE @H TABLE (SatirId INT, Sil BIT, Tarih DATETIME, Tur INT,
                          Aciklama NVARCHAR(250), RolId INT, MeslekId INT);
        INSERT @H SELECT ISNULL(ID,0), ISNULL(Sil,0), Tarih, Tur, Aciklama, RolId, MeslekId
        FROM OPENJSON(@Kosullar, '$.Hareketler')
        WITH (ID INT, Sil BIT, Tarih DATETIME, Tur INT, Aciklama NVARCHAR(250), RolId INT, MeslekId INT);

        DELETE PH FROM dbo.PERS_HAREKET PH INNER JOIN @H H ON H.SatirId = PH.ID WHERE H.Sil = 1;
        IF @Mod = N'tam'
            DELETE FROM dbo.PERS_HAREKET
             WHERE REHBERID = @Id AND ID NOT IN (SELECT SatirId FROM @H WHERE SatirId > 0);

        UPDATE PH SET TARIH = H.Tarih, TUR = H.Tur, ACIKLAMA = H.Aciklama,
                      ROLID = H.RolId, MESLEKID = H.MeslekId
          FROM dbo.PERS_HAREKET PH INNER JOIN @H H ON H.SatirId = PH.ID
         WHERE H.Sil = 0;

        INSERT INTO dbo.PERS_HAREKET (REHBERID, TARIH, TUR, ACIKLAMA, ROLID, MESLEKID)
        SELECT @Id, H.Tarih, H.Tur, H.Aciklama, H.RolId, H.MeslekId
          FROM @H H WHERE H.SatirId = 0 AND H.Sil = 0;
    END

    ------------------------------------------------------------------ LOG
    DECLARE @Tip TINYINT = CASE WHEN @Yeni = 1 THEN 1 ELSE 2 END;
    EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'REHBER', @Kosul = N'ID=@pB', @KosulPar = @Id,
         @TabNo = @TabNo, @UstTabNo = @TabNo, @UstId = @Id, @KulId = @KulId, @SubeId = @SubeId,
         @RehberId = @Id, @IslemTipi = @Tip, @Yazilan = @n OUTPUT;
    SET @Loglanan += ISNULL(@n, 0);

    COMMIT;

    SET @KayitIdOut = @Id;
    IF @SonucDondur = 1
        SELECT Sonuc = 1, KayitId = @Id, Yeni = @Yeni, Loglanan = @Loglanan
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- dbo.sp_Api_Rehber_Klonla_Ic ----

-- ---- dbo.sp_Api_Rehber_Klonla_Ic  (2 yer) ----

-- ---- REHBER (cari/IK) klon cekirdegi -------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Api_Rehber_Klonla_Ic
    @Kosullar NVARCHAR(MAX), @TabNo INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KaynakId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KaynakId') AS INT);
    DECLARE @KulId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);
    DECLARE @YeniKod  NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Kod');
    DECLARE @YeniAd   NVARCHAR(200) = JSON_VALUE(@Kosullar, '$.Firma');

    IF @KaynakId IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.REHBER WHERE ID = @KaynakId)
        THROW 51002, N'Kaynak kart bulunamadı.', 1;

    IF DATALENGTH(ISNULL(@YeniKod, N'')) = 0
    BEGIN
        DECLARE @Kok NVARCHAR(50) = ISNULL((SELECT KOD FROM dbo.REHBER WHERE ID = @KaynakId), N'');
        IF DATALENGTH(@Kok) > 0
        BEGIN
            DECLARE @i INT = 1;
            SET @YeniKod = LEFT(@Kok, 45) + N'_K1';     -- kural: <KAYNAKKOD>_K1
            WHILE EXISTS (SELECT 1 FROM dbo.REHBER WHERE KOD = @YeniKod) AND @i < 100
            BEGIN
                SET @i += 1;
                SET @YeniKod = LEFT(@Kok, 45) + N'_K' + CAST(@i AS NVARCHAR(3));
            END
        END
    END

    DECLARE @Kart NVARCHAR(MAX) =
    (
        SELECT Kod = @YeniKod,
               Firma = ISNULL(@YeniAd, LEFT(R.FIRMA, 180) + N' (KOPYA)'),
               Statu = R.STATU, Grup = R.GRUP, Kategori = R.KATEGORI, Sinif = R.SINIF,
               Durum = R.DURUM, Temsilci = R.TEMSILCI, Notlar = R.NOTLAR, OzelKod = R.OZELKOD,
               YetkiKodu = R.YETKIKODU, Ozel = R.OZEL, Bolge = R.BOLGE, MuhKodu = R.MUHKODU,
               BagId = R.BAGID, Sektor = R.SEKTOR, AltBolge = R.ALTBOLGE, Peryot = R.PERYOT,
               AltSektor = R.ALTSEKTOR, Posta = R.POSTA, Eposta = R.EPOSTA, Temas = R.TEMAS,
               EFatura = R.EFATURA, Konum = R.KONUM
        FROM dbo.REHBER R WHERE R.ID = @KaynakId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    );

    -- Iletisimler + her iletisimin bilgi satirlari (ic ice)
    DECLARE @Ilet NVARCHAR(MAX) = ISNULL((
        SELECT Ad = RI.AD, Varsayilan = RI.VARSAYILAN, Aktif = RI.AKTIF,
               Bilgiler = JSON_QUERY(ISNULL((
                   SELECT Modul = RB.MODUL, Sira = RB.SIRA, Etiket = RB.ETIKET, Bilgi = RB.BILGI
                   FROM dbo.REHBERBILGI RB
                   WHERE RB.YERI = 1 AND RB.YER_ID = RI.ID
                   FOR JSON PATH), N'[]'))
        FROM dbo.REHBERILETISIM RI
        WHERE RI.REHBERID = @KaynakId
        FOR JSON PATH), N'[]');

    DECLARE @J NVARCHAR(MAX) =
        N'{"SatirModu":"tam","Kart":' + @Kart + N',"Iletisimler":' + @Ilet +
        N',"Oturum":{"KulId":' + CAST(@KulId AS NVARCHAR(20)) +
        N',"SubeId":' + CAST(@SubeId AS NVARCHAR(20)) + N'}}';

    DECLARE @YeniId INT;
    EXEC dbo.sp_Api_Rehber_Kaydet_Ic @Kosullar = @J, @TabNo = @TabNo,
         @KayitIdOut = @YeniId OUTPUT, @SonucDondur = 0;

    IF ISNULL(@YeniId, 0) = 0 THROW 51202, N'Klon kart oluşturulamadı.', 1;

    EXEC dbo.sp_Api_Log_Kaynak_Isaretle @TabNo = @TabNo, @KayitId = @YeniId,
         @AltTip = 3, @KaynakId = @KaynakId, @KaynakTabNo = @TabNo;

    SELECT Sonuc = 1, KaynakId = @KaynakId, KayitId = @YeniId,
           Kod = (SELECT KOD FROM dbo.REHBER WHERE ID = @YeniId)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- dbo.sp_Api_Stok_Kaydet_Json ----

-- ---- dbo.sp_Api_Stok_Kaydet_Json  (1 yer) ----

-- ---- dbo.sp_Api_Stok_Kaydet_Json  (1 yer) ----

-- ============================================================
-- STOK KAYDET
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Stok_Kaydet_Json
    @Kosullar   NVARCHAR(MAX),
    @KayitIdOut INT = NULL OUTPUT,
    @SonucDondur BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Mod NVARCHAR(10) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.SatirModu'), N'delta'));
    IF @Mod NOT IN (N'delta', N'tam') THROW 51001, N'SatirModu "delta" ya da "tam" olmali.', 1;

    DECLARE @KulId  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);
    DECLARE @Id     INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.ID') AS INT);
    DECLARE @Yeni   BIT = CASE WHEN ISNULL(@Id, 0) = 0 THEN 1 ELSE 0 END;
    DECLARE @Simdi  DATETIME = GETDATE();

    IF @Yeni = 0 AND NOT EXISTS (SELECT 1 FROM dbo.STOKLAR WHERE ID = @Id)
        THROW 51002, N'Stok kartı bulunamadı.', 1;

    -- ---- Kart alanlari (gonderilmeyen alan = DOKUNMA) ----
    DECLARE @Kod NVARCHAR(50) = JSON_VALUE(@Kosullar, '$.Kart.Kod');
    DECLARE @Ad  NVARCHAR(200) = JSON_VALUE(@Kosullar, '$.Kart.StokAdi');

    IF @Yeni = 1 AND (DATALENGTH(ISNULL(@Kod, N'')) = 0 OR DATALENGTH(ISNULL(@Ad, N'')) = 0)
        THROW 51001, N'Yeni stokta Kart.Kod ve Kart.StokAdi zorunlu.', 1;
    IF @Kod IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.STOKLAR WHERE KOD = @Kod AND ID <> ISNULL(@Id, 0))
        THROW 51200, N'Bu stok kodu zaten kullanılıyor.', 1;

    DECLARE @Loglanan INT = 0, @n INT;

    BEGIN TRAN;

    IF @Yeni = 1
    BEGIN
        INSERT INTO dbo.STOKLAR
            (KOD, STOKADI, KATEGORI, TIPI, MARKA, MODEL, GRUBU, OZELLIK, OZELKOD, OZELKOD2,
             MUHKODU, ANABIRIM, BIRIM2, BIRIM2MIKTAR, MINSTOK, YERI, URETICIID, SATICIID,
             KDV, EKVERGI, DURUM, IZLEME, RAFOMRU_SURE, RAFOMRU_BIRIM, MASRAFID, GELIRID,
             NOTLAR, YETKIKODU, GARANTISURESI, PAKET, DETAYBOLUMU, URETICI, ICERIK, ISK2,
             ISKONTOSUZ, KULLANIM, EKIPMAN, OTVYUZDE, OTVMIKTAR, MIKTARSEC, INTERNET_SATIS,
             TEMINSURESI, BILDIRIM, URUNNO, GTIP, HUCRE, GIRISKAYNAK,
             EKLEYEN, EKLEMETARIHI, SUBEID)
        VALUES
            (@Kod, @Ad,
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Kategori') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Tipi') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Marka') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Model') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Grubu') AS INT),
             JSON_VALUE(@Kosullar, '$.Kart.Ozellik'),
             JSON_VALUE(@Kosullar, '$.Kart.OzelKod'),
             JSON_VALUE(@Kosullar, '$.Kart.OzelKod2'),
             JSON_VALUE(@Kosullar, '$.Kart.MuhKodu'),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.AnaBirim') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Birim2') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Birim2Miktar') AS FLOAT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.MinStok') AS FLOAT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Yeri') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.UreticiId') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.SaticiId') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Kdv') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.EkVergi') AS MONEY),
             ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Durum') AS INT), 1),
             ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Izleme') AS INT), 0),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.RafOmruSure') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.RafOmruBirim') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.MasrafId') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.GelirId') AS INT),
             JSON_VALUE(@Kosullar, '$.Kart.Notlar'),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.YetkiKodu') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.GarantiSuresi') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Paket') AS BIT),
             JSON_VALUE(@Kosullar, '$.Kart.DetayBolumu'),
             JSON_VALUE(@Kosullar, '$.Kart.Uretici'),
             JSON_VALUE(@Kosullar, '$.Kart.Icerik'),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Isk2') AS FLOAT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Iskontosuz') AS BIT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Kullanim') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Ekipman') AS BIT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.OtvYuzde') AS FLOAT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.OtvMiktar') AS FLOAT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.MiktarSec') AS BIT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.InternetSatis') AS BIT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.TeminSuresi') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Bildirim') AS BIT),
             JSON_VALUE(@Kosullar, '$.Kart.UrunNo'),
             JSON_VALUE(@Kosullar, '$.Kart.Gtip'),
             JSON_VALUE(@Kosullar, '$.Kart.Hucre'),
             ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.GirisKaynak') AS INT), 0),
             @KulId, @Simdi, @SubeId);

        SET @Id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.STOKLAR SET
            KOD          = ISNULL(@Kod, KOD),
            STOKADI      = ISNULL(@Ad, STOKADI),
            KATEGORI     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Kategori') AS INT), KATEGORI),
            TIPI         = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Tipi') AS INT), TIPI),
            MARKA        = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Marka') AS INT), MARKA),
            MODEL        = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Model') AS INT), MODEL),
            GRUBU        = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Grubu') AS INT), GRUBU),
            OZELLIK      = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Ozellik'), OZELLIK),
            OZELKOD      = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.OzelKod'), OZELKOD),
            OZELKOD2     = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.OzelKod2'), OZELKOD2),
            MUHKODU      = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.MuhKodu'), MUHKODU),
            ANABIRIM     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.AnaBirim') AS INT), ANABIRIM),
            BIRIM2       = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Birim2') AS INT), BIRIM2),
            BIRIM2MIKTAR = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Birim2Miktar') AS FLOAT), BIRIM2MIKTAR),
            MINSTOK      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.MinStok') AS FLOAT), MINSTOK),
            YERI         = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Yeri') AS INT), YERI),
            URETICIID    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.UreticiId') AS INT), URETICIID),
            SATICIID     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.SaticiId') AS INT), SATICIID),
            KDV          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Kdv') AS INT), KDV),
            EKVERGI      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.EkVergi') AS MONEY), EKVERGI),
            DURUM        = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Durum') AS INT), DURUM),
            IZLEME       = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Izleme') AS INT), IZLEME),
            RAFOMRU_SURE = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.RafOmruSure') AS INT), RAFOMRU_SURE),
            RAFOMRU_BIRIM= ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.RafOmruBirim') AS INT), RAFOMRU_BIRIM),
            MASRAFID     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.MasrafId') AS INT), MASRAFID),
            GELIRID      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.GelirId') AS INT), GELIRID),
            NOTLAR       = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Notlar'), NOTLAR),
            YETKIKODU    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.YetkiKodu') AS INT), YETKIKODU),
            GARANTISURESI= ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.GarantiSuresi') AS INT), GARANTISURESI),
            PAKET        = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Paket') AS BIT), PAKET),
            DETAYBOLUMU  = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.DetayBolumu'), DETAYBOLUMU),
            URETICI      = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Uretici'), URETICI),
            ICERIK       = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Icerik'), ICERIK),
            ISK2         = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Isk2') AS FLOAT), ISK2),
            ISKONTOSUZ   = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Iskontosuz') AS BIT), ISKONTOSUZ),
            KULLANIM     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Kullanim') AS INT), KULLANIM),
            EKIPMAN      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Ekipman') AS BIT), EKIPMAN),
            OTVYUZDE     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.OtvYuzde') AS FLOAT), OTVYUZDE),
            OTVMIKTAR    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.OtvMiktar') AS FLOAT), OTVMIKTAR),
            MIKTARSEC    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.MiktarSec') AS BIT), MIKTARSEC),
            INTERNET_SATIS = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.InternetSatis') AS BIT), INTERNET_SATIS),
            TEMINSURESI  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.TeminSuresi') AS INT), TEMINSURESI),
            BILDIRIM     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Bildirim') AS BIT), BILDIRIM),
            URUNNO       = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.UrunNo'), URUNNO),
            GTIP         = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Gtip'), GTIP),
            HUCRE        = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Hucre'), HUCRE),
            DEGISTIREN   = @KulId,
            DEGISTIRMETARIHI = @Simdi
        WHERE ID = @Id;
    END

    ------------------------------------------------------------------ BARKODLAR
    IF JSON_QUERY(@Kosullar, '$.Barkodlar') IS NOT NULL
    BEGIN
        DECLARE @B TABLE (SatirId INT, Sil BIT, Barkod NVARCHAR(50), Tipi INT, Birim INT, Varsayilan BIT);
        INSERT @B SELECT ISNULL(ID,0), ISNULL(Sil,0), Barkod, Tipi, Birim, ISNULL(Varsayilan,0)
        FROM OPENJSON(@Kosullar, '$.Barkodlar')
        WITH (ID INT, Sil BIT, Barkod NVARCHAR(50), Tipi INT, Birim INT, Varsayilan BIT);

        DELETE SB FROM dbo.STOKBARKOD SB INNER JOIN @B B ON B.SatirId = SB.ID WHERE B.Sil = 1;
        IF @Mod = N'tam'
            DELETE FROM dbo.STOKBARKOD
             WHERE STOKID = @Id AND ID NOT IN (SELECT SatirId FROM @B WHERE SatirId > 0);

        UPDATE SB SET BARKOD = B.Barkod, BARKODTIPI = B.Tipi, BARKODBIRIMI = B.Birim,
                      VARSAYILAN = B.Varsayilan, DEGISTIREN = @KulId, DEGISTIRMETARIHI = @Simdi
          FROM dbo.STOKBARKOD SB INNER JOIN @B B ON B.SatirId = SB.ID
         WHERE B.Sil = 0;

        INSERT INTO dbo.STOKBARKOD (STOKID, BARKOD, BARKODTIPI, BARKODBIRIMI, VARSAYILAN, EKLEYEN, EKLEMETARIHI, SUBEID)
        SELECT @Id, B.Barkod, B.Tipi, B.Birim, B.Varsayilan, @KulId, @Simdi, @SubeId
          FROM @B B WHERE B.SatirId = 0 AND B.Sil = 0 AND ISNULL(B.Barkod, N'') <> N'';
    END

    ------------------------------------------------------------------ FIYATLAR
    IF JSON_QUERY(@Kosullar, '$.Fiyatlar') IS NOT NULL
    BEGIN
        DECLARE @F TABLE (SatirId INT, Sil BIT, FiyatAdi INT, Birim INT, Fiyat MONEY,
                          Kur NVARCHAR(5), KdvDurum BIT, PaketId INT, Satis BIT);
        INSERT @F SELECT ISNULL(ID,0), ISNULL(Sil,0), FiyatAdi, Birim, Fiyat,
                         ISNULL(Kur,N'TL'), ISNULL(KdvDurum,0), ISNULL(PaketId,0), ISNULL(Satis,1)
        FROM OPENJSON(@Kosullar, '$.Fiyatlar')
        WITH (ID INT, Sil BIT, FiyatAdi INT, Birim INT, Fiyat MONEY, Kur NVARCHAR(5),
              KdvDurum BIT, PaketId INT, Satis BIT);

        DELETE SF FROM dbo.STOKFIYAT SF INNER JOIN @F F ON F.SatirId = SF.ID WHERE F.Sil = 1;
        IF @Mod = N'tam'
            DELETE FROM dbo.STOKFIYAT
             WHERE STOKID = @Id AND ID NOT IN (SELECT SatirId FROM @F WHERE SatirId > 0);

        UPDATE SF SET FIYATADI = F.FiyatAdi, BIRIM = F.Birim, FIYAT = F.Fiyat, KUR = F.Kur,
                      KDVDURUM = F.KdvDurum, PAKETID = F.PaketId, SATIS = F.Satis,
                      DEGISTIREN = @KulId, DEGISTIRMETARIHI = @Simdi
          FROM dbo.STOKFIYAT SF INNER JOIN @F F ON F.SatirId = SF.ID
         WHERE F.Sil = 0;

        INSERT INTO dbo.STOKFIYAT (STOKID, FIYATADI, BIRIM, FIYAT, KUR, KDVDURUM, PAKETID, SATIS, EKLEYEN, EKLEMETARIHI)
        SELECT @Id, F.FiyatAdi, F.Birim, F.Fiyat, F.Kur, F.KdvDurum, F.PaketId, F.Satis, @KulId, @Simdi
          FROM @F F WHERE F.SatirId = 0 AND F.Sil = 0;
    END

    ------------------------------------------------------------------ BIRIM CEVRIMLERI
    IF JSON_QUERY(@Kosullar, '$.Cevrimler') IS NOT NULL
    BEGIN
        DECLARE @C TABLE (SatirId INT, Sil BIT, Adet1 FLOAT, Birim1 INT, Adet2 FLOAT, Birim2 INT);
        INSERT @C SELECT ISNULL(ID,0), ISNULL(Sil,0), Adet1, Birim1, Adet2, Birim2
        FROM OPENJSON(@Kosullar, '$.Cevrimler')
        WITH (ID INT, Sil BIT, Adet1 FLOAT, Birim1 INT, Adet2 FLOAT, Birim2 INT);

        DELETE SC FROM dbo.STOKCEVRIM SC INNER JOIN @C C ON C.SatirId = SC.ID WHERE C.Sil = 1;
        IF @Mod = N'tam'
            DELETE FROM dbo.STOKCEVRIM
             WHERE STOKID = @Id AND ID NOT IN (SELECT SatirId FROM @C WHERE SatirId > 0);

        UPDATE SC SET ADET1 = C.Adet1, BIRIM1 = C.Birim1, ADET2 = C.Adet2, BIRIM2 = C.Birim2,
                      DEGISTIREN = @KulId, DEGISTIRMETARIHI = @Simdi
          FROM dbo.STOKCEVRIM SC INNER JOIN @C C ON C.SatirId = SC.ID
         WHERE C.Sil = 0;

        INSERT INTO dbo.STOKCEVRIM (STOKID, ADET1, BIRIM1, ADET2, BIRIM2, EKLEYEN, EKLEMETARIHI)
        SELECT @Id, C.Adet1, C.Birim1, C.Adet2, C.Birim2, @KulId, @Simdi
          FROM @C C WHERE C.SatirId = 0 AND C.Sil = 0;
    END

    ------------------------------------------------------------------ DEPO SEVIYELERI
    IF JSON_QUERY(@Kosullar, '$.Seviyeler') IS NOT NULL
    BEGIN
        DECLARE @V TABLE (SatirId INT, Sil BIT, DepoId INT, Maksimum FLOAT, Kritik FLOAT, Minimum FLOAT);
        INSERT @V SELECT ISNULL(ID,0), ISNULL(Sil,0), DepoId, Maksimum, Kritik, Minimum
        FROM OPENJSON(@Kosullar, '$.Seviyeler')
        WITH (ID INT, Sil BIT, DepoId INT, Maksimum FLOAT, Kritik FLOAT, Minimum FLOAT);

        DELETE SS FROM dbo.STOKSEVIYE SS INNER JOIN @V V ON V.SatirId = SS.ID WHERE V.Sil = 1;
        IF @Mod = N'tam'
            DELETE FROM dbo.STOKSEVIYE
             WHERE STOKID = @Id AND ID NOT IN (SELECT SatirId FROM @V WHERE SatirId > 0);

        UPDATE SS SET DEPOID = V.DepoId, MAKSIMUM = V.Maksimum, KRITIK = V.Kritik, MINIMUM = V.Minimum,
                      DEGISTIREN = @KulId, DEGISTIRMETARIHI = @Simdi
          FROM dbo.STOKSEVIYE SS INNER JOIN @V V ON V.SatirId = SS.ID
         WHERE V.Sil = 0;

        INSERT INTO dbo.STOKSEVIYE (STOKID, DEPOID, MAKSIMUM, KRITIK, MINIMUM, EKLEYEN, EKLEMETARIHI)
        SELECT @Id, V.DepoId, V.Maksimum, V.Kritik, V.Minimum, @KulId, @Simdi
          FROM @V V WHERE V.SatirId = 0 AND V.Sil = 0;
    END

    ------------------------------------------------------------------ LOG
    -- EXEC parametresi IFADE alamaz (CASE) -> once degiskene [[declare-batch-param]]
    DECLARE @Tip TINYINT = CASE WHEN @Yeni = 1 THEN 1 ELSE 2 END;
    EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'STOKLAR', @Kosul = N'ID=@pB', @KosulPar = @Id,
         @TabNo = 88, @UstTabNo = 88, @UstId = @Id, @KulId = @KulId, @SubeId = @SubeId,
         @IslemTipi = @Tip, @Yazilan = @n OUTPUT;
    SET @Loglanan += ISNULL(@n, 0);

    COMMIT;

    SET @KayitIdOut = @Id;
    IF @SonucDondur = 1
        SELECT Sonuc = 1, KayitId = @Id, Yeni = @Yeni, Loglanan = @Loglanan
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- dbo.sp_Api_Stok_Klonla_Json ----

-- ---- dbo.sp_Api_Stok_Klonla_Json  (1 yer) ----

-- ============================================================
-- KLONLAMA: kaynagi okuyup KAYDET API'sine verir.
--   Klon "elden girilmis yeni kart" ile ayni yoldan gecer.
--   Benzersiz kod: <KOD>-K, dolu ise -K2, -K3 ... (en fazla 99 deneme)
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Stok_Klonla_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KaynakId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KaynakId') AS INT);
    DECLARE @KulId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);
    DECLARE @YeniKod  NVARCHAR(50) = JSON_VALUE(@Kosullar, '$.Kod');
    DECLARE @YeniAd   NVARCHAR(200) = JSON_VALUE(@Kosullar, '$.StokAdi');
    -- Kaydet API'sinin koleksiyonlarina girmeyen, ama stok kopyasinda
    --   tasinmasi beklenen ekler (sihirbazin eski 'K' dalindaki davranis):
    DECLARE @Detay    BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Detay')  AS BIT), 0);  -- REHBERBILGI (ek bilgi)
    DECLARE @Resim    BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Resim')  AS BIT), 1);  -- IMAJ (resim/belge)
    DECLARE @Ekler    BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Ekler')  AS BIT), 1);  -- ISORTAGI + STOKESDEGER

    IF @KaynakId IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.STOKLAR WHERE ID = @KaynakId)
        THROW 51002, N'Kaynak stok kartı bulunamadı.', 1;

    -- Benzersiz kod uret
    IF DATALENGTH(ISNULL(@YeniKod, N'')) = 0
    BEGIN
        -- Kural (10.08.2026): <KAYNAKKOD>_K1, dolu ise _K2, _K3 ...
        DECLARE @Kok NVARCHAR(50) = (SELECT KOD FROM dbo.STOKLAR WHERE ID = @KaynakId);
        DECLARE @i INT = 1;
        SET @YeniKod = LEFT(@Kok, 45) + N'_K1';
        WHILE EXISTS (SELECT 1 FROM dbo.STOKLAR WHERE KOD = @YeniKod) AND @i < 100
        BEGIN
            SET @i += 1;
            SET @YeniKod = LEFT(@Kok, 45) + N'_K' + CAST(@i AS NVARCHAR(3));
        END
    END

    DECLARE @Kart NVARCHAR(MAX) =
    (
        SELECT Kod = @YeniKod,
               StokAdi = ISNULL(@YeniAd, LEFT(S.STOKADI, 190) + N' (KOPYA)'),
               Kategori = S.KATEGORI, Tipi = S.TIPI, Marka = S.MARKA, Model = S.MODEL,
               Grubu = S.GRUBU, Ozellik = S.OZELLIK, OzelKod = S.OZELKOD, OzelKod2 = S.OZELKOD2,
               MuhKodu = S.MUHKODU, AnaBirim = S.ANABIRIM, Birim2 = S.BIRIM2,
               Birim2Miktar = S.BIRIM2MIKTAR, MinStok = S.MINSTOK, Yeri = S.YERI,
               UreticiId = S.URETICIID, SaticiId = S.SATICIID, Kdv = S.KDV, EkVergi = S.EKVERGI,
               Durum = S.DURUM, Izleme = S.IZLEME, RafOmruSure = S.RAFOMRU_SURE,
               RafOmruBirim = S.RAFOMRU_BIRIM, MasrafId = S.MASRAFID, GelirId = S.GELIRID,
               Notlar = S.NOTLAR, YetkiKodu = S.YETKIKODU, GarantiSuresi = S.GARANTISURESI,
               Paket = S.PAKET, DetayBolumu = S.DETAYBOLUMU, Uretici = S.URETICI, Icerik = S.ICERIK,
               Isk2 = S.ISK2, Iskontosuz = S.ISKONTOSUZ, Kullanim = S.KULLANIM, Ekipman = S.EKIPMAN,
               OtvYuzde = S.OTVYUZDE, OtvMiktar = S.OTVMIKTAR, MiktarSec = S.MIKTARSEC,
               InternetSatis = S.INTERNET_SATIS, TeminSuresi = S.TEMINSURESI, Bildirim = S.BILDIRIM,
               UrunNo = S.URUNNO, Gtip = S.GTIP, Hucre = S.HUCRE
        FROM dbo.STOKLAR S WHERE S.ID = @KaynakId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    );

    -- BARKOD KLONLANMAZ: barkod fiziksel urune aittir, benzersiz olmali.
    DECLARE @Fiy NVARCHAR(MAX) = ISNULL((
        SELECT FiyatAdi = FIYATADI, Birim = BIRIM, Fiyat = FIYAT, Kur = KUR,
               KdvDurum = KDVDURUM, PaketId = PAKETID, Satis = SATIS
        FROM dbo.STOKFIYAT WHERE STOKID = @KaynakId FOR JSON PATH), N'[]');
    DECLARE @Cev NVARCHAR(MAX) = ISNULL((
        SELECT Adet1 = ADET1, Birim1 = BIRIM1, Adet2 = ADET2, Birim2 = BIRIM2
        FROM dbo.STOKCEVRIM WHERE STOKID = @KaynakId FOR JSON PATH), N'[]');
    DECLARE @Sev NVARCHAR(MAX) = ISNULL((
        SELECT DepoId = DEPOID, Maksimum = MAKSIMUM, Kritik = KRITIK, Minimum = MINIMUM
        FROM dbo.STOKSEVIYE WHERE STOKID = @KaynakId FOR JSON PATH), N'[]');

    DECLARE @J NVARCHAR(MAX) =
        N'{"SatirModu":"tam","Kart":' + @Kart +
        N',"Fiyatlar":' + @Fiy + N',"Cevrimler":' + @Cev + N',"Seviyeler":' + @Sev +
        N',"Oturum":{"KulId":' + CAST(@KulId AS NVARCHAR(20)) +
        N',"SubeId":' + CAST(@SubeId AS NVARCHAR(20)) + N'}}';

    DECLARE @YeniId INT;
    EXEC dbo.sp_Api_Stok_Kaydet_Json @Kosullar = @J, @KayitIdOut = @YeniId OUTPUT, @SonucDondur = 0;

    IF ISNULL(@YeniId, 0) = 0 THROW 51202, N'Klon stok kartı oluşturulamadı.', 1;

    ------------------------------------------------------------------ EK KOLEKSIYONLAR
    --   Kaydet API'sinin sozlesmesinde olmayan, kopyaya ait olan tablolar.
    IF @Ekler = 1
    BEGIN
        INSERT INTO dbo.ISORTAGI (STOKID, REHBERID, ILISKI, EKLEYEN, EKLEMETARIHI, SUBEID)
        SELECT @YeniId, REHBERID, ILISKI, @KulId, GETDATE(), SUBEID
          FROM dbo.ISORTAGI WHERE STOKID = @KaynakId;

        INSERT INTO dbo.STOKESDEGER (STOKID, STOKESDEGERID, TUR, ACIKLAMA, EKLEYEN, EKLEMETARIHI, SUBEID)
        SELECT @YeniId, STOKESDEGERID, TUR, ACIKLAMA, @KulId, GETDATE(), SUBEID
          FROM dbo.STOKESDEGER WHERE STOKID = @KaynakId;
    END

    IF @Detay = 1
        INSERT INTO dbo.REHBERBILGI (MODUL, YERI, YER_ID, SIRA, ETIKET, BILGI, EKLEYEN, EKLEMETARIHI, SUBEID)
        SELECT MODUL, YERI, @YeniId, SIRA, ETIKET, BILGI, @KulId, GETDATE(), SUBEID
          FROM dbo.REHBERBILGI WHERE YERI = 88 AND YER_ID = @KaynakId;

    IF @Resim = 1
        INSERT INTO dbo.IMAJ (VARSAYILAN, REHBERID, YERI, YER_ID, BELGEADI, BELGE, ACIKLAMA,
                              BELGENO, TUR, ICDIS, DURUM, DOSYAID, EKLEYEN, DEGISTIRMETARIHI, SUBEID)
        SELECT VARSAYILAN, @YeniId, YERI, @YeniId, BELGEADI, BELGE, ACIKLAMA,
               BELGENO, TUR, ICDIS, DURUM, DOSYAID, @KulId, GETDATE(), SUBEID
          FROM dbo.IMAJ WHERE YERI = 88 AND YER_ID = @KaynakId;

    -- ISLEMLOG izi: bu kayit KOPYA ve kaynagi su (ALTISLEMTIPI=3)
    EXEC dbo.sp_Api_Log_Kaynak_Isaretle @TabNo = 88, @KayitId = @YeniId,
         @AltTip = 3, @KaynakId = @KaynakId, @KaynakTabNo = 88;

    SELECT Sonuc = 1, KaynakId = @KaynakId, KayitId = @YeniId,
           Kod = (SELECT KOD FROM dbo.STOKLAR WHERE ID = @YeniId)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- dbo.sp_Prog_Mesaj_Avatar_Toplu ----

-- ---- dbo.sp_Prog_Mesaj_Avatar_Toplu  (1 yer) ----

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Avatar_Toplu
    @Idler NVARCHAR(MAX)          -- '1064,1098,3228'
AS
BEGIN
    SET NOCOUNT ON;
    IF DATALENGTH(ISNULL(@Idler, N'')) = 0 RETURN;

    DECLARE @X XML = CAST(N'<i>' + REPLACE(@Idler, N',', N'</i><i>') + N'</i>' AS XML);

    ;WITH Idler AS
    (
        SELECT ID = T.c.value(N'.', N'INT')
        FROM @X.nodes(N'/i') T(c)
    )
    SELECT R.ID, R.RESIM
    FROM dbo.REHBER R
        INNER JOIN Idler I ON I.ID = R.ID
    WHERE R.RESIM IS NOT NULL;
END
GO
