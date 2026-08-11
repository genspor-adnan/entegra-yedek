-- ============================================================
-- GenDepoUpdate133.sql
-- SILME ALTYAPISI - STOK KARTI ve STOK SAYIMI (envanter)
--
-- Kapsam kontrolu (10.08.2026): transfer ve stok talebi ZATEN kapsamda -
--   transfer FATBASLIK TUR=20 (sp_Api_Belge_Sil_Json), stok talebi SIPARIS
--   TUR=105 (modul 91 plani). Eksik olan iki modul burada eklenir:
--     88  STOKLAR    (stok karti)      - Utablo.StokSilmeIslemleri devri
--     520 STOKSAYIM  (sayim/envanter)  - UStokSayim.SayimSilClick devri
--
-- STOK ENGELLERI (Utablo.StokHareketVarMi ile ayni): stok bir yerde KULLANILMISSA
--   silinmez - sayim kalemi, fatura/siparis/teklif satiri, izleme, recete...
--
-- SAYIM: kalemleri olan sayim silinemez (once kalemler temizlenir). Sayimin
--   urettigi envanter belgesi (FATBASLIK TUR=7, ANAKAYITID=sayim) kartla
--   birlikte silinir - eskiden LOGSUZ ve transaction'siz siliniyordu.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- STOKSAYIM icin TABLOLAR kaydi (UInfo'da "Stok Sayimi" olarak gorunsun)
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 520)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL)
    VALUES (520, 'STOKSAYIM', N'Kart', N'Stok Sayımı');
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 521)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL)
    VALUES (521, 'STOKSAYIMKALEMLERI', N'Detay', N'Stok Sayımı');
GO

-- ---- ENGEL KURALLARI: mevcut TVF'ye iki modul EKLENIR ----
--   (fn_Prog_Silme_Engel tamamen yeniden yazilmaz; 129'daki govde korunur ve
--    sonuna iki blok eklenir -> tek dosyada tam tanim)
CREATE OR ALTER FUNCTION dbo.fn_Prog_Silme_Engel_Ek()
RETURNS @T TABLE
(
    Modul  INT,
    Sira   INT,
    Tablo  sysname,
    Kosul  NVARCHAR(1000),
    Mesaj  NVARCHAR(200)
)
AS
BEGIN
    ------------------------------------------------------------------ STOK (88)
    INSERT @T VALUES
    (88, 10, 'STOKSAYIMKALEMLERI', N'SELECT 1 FROM STOKSAYIMKALEMLERI WHERE STOKID={ID}', N'Bu stok sayımda kullanılmış, silinemez.'),
    (88, 20, 'FATURA',             N'SELECT 1 FROM FATURA WHERE TUR=1 AND URUNID={ID}',   N'Bu stok faturada kullanılmış, silinemez.'),
    (88, 30, 'SIPARISDETAY',       N'SELECT 1 FROM SIPARISDETAY WHERE TUR=1 AND URUNID={ID}', N'Bu stok siparişte kullanılmış, silinemez.'),
    (88, 40, 'TEKLIFDETAY',        N'SELECT 1 FROM TEKLIFDETAY WHERE TUR=1 AND URUNID={ID}',  N'Bu stok teklifte kullanılmış, silinemez.'),
    (88, 50, 'STOKIZLEME',         N'SELECT 1 FROM STOKIZLEME WHERE STOKID={ID}',         N'Bu stokun lot/seri hareketi var, silinemez.'),
    (88, 60, 'URETIMRECETE',       N'SELECT 1 FROM URETIMRECETE WHERE STOKID={ID}',       N'Bu stok üretim reçetesinde kullanılmış, silinemez.'),
    (88, 70, 'STOKDURUM',          N'SELECT 1 FROM STOKDURUM WHERE STOKID={ID} AND ISNULL(KALAN,0)<>0', N'Bu stokun depo bakiyesi var, silinemez.');

    ------------------------------------------------------------------ STOK SAYIMI (520)
    INSERT @T VALUES
    (520, 10, 'STOKSAYIMKALEMLERI', N'SELECT 1 FROM STOKSAYIMKALEMLERI WHERE SAYIMID={ID}', N'Bu sayımın kalemleri var, önce kalemleri silin.');

    RETURN;
END
GO

CREATE OR ALTER FUNCTION dbo.fn_Prog_Silme_Detay_Ek()
RETURNS @T TABLE
(
    Modul   INT,
    Sira    INT,
    Tablo   sysname,
    Kosul   NVARCHAR(1000),
    TabloId INT
)
AS
BEGIN
    ------------------------------------------------------------------ STOK (88)
    --   Utablo.StokSilmeIslemleri sirasi
    INSERT @T VALUES
    (88, 10, 'IMAJ',                 N'YERI BETWEEN 71 AND 72 AND YER_ID={ID}', 42),
    (88, 20, 'IMAJ',                 N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=88 AND GOREVID={ID}))', 42),
    (88, 30, 'DOKUMAN',              N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=88 AND GOREVID={ID})', 321),
    (88, 40, 'GOREVYORUM',           N'TUR=88 AND GOREVID={ID}', 210),
    (88, 50, 'STOKFIYAT',            N'STOKID={ID}', 346),
    (88, 60, 'ISORTAGI',             N'STOKID={ID}', 88),
    (88, 70, 'STOKESDEGER',          N'STOKID={ID}', 344),
    (88, 80, 'STOKBARKOD',           N'STOKID={ID}', 340),
    (88, 90, 'STOKBOYUTKOMBINASYON', N'STOKID={ID}', 342),
    (88,100, 'STOKSEVIYE',           N'STOKID={ID}', 88),
    (88,110, 'STOKMUHASEBE',         N'STOKID={ID}', 88),
    (88,120, 'STOKCEVRIM',           N'STOKID={ID}', 88),
    (88,130, 'EKIPMANLAR',           N'URUNID={ID}', 88),
    (88,140, 'PAKETDETAY',           N'PAKETID={ID}', 88),
    (88,150, 'PAKETDETAY',           N'URUNID={ID} AND STOK=1', 88),
    (88,160, 'REHBERBILGI',          N'YERI=88 AND YER_ID={ID}', 76),
    (88,170, 'STOKLAR_USER',         N'ID={ID}', 508),
    (88,900, 'STOKLAR',              N'ID={ID}', 88);

    ------------------------------------------------------------------ STOK SAYIMI (520)
    INSERT @T VALUES
    (520, 10, 'STOKIZLEME',   N'BELGETUR=99 AND BASLIKID={ID}', 367),
    (520, 20, 'STOKLOKASYON', N'DURUM=0 AND BELGETUR=99 AND BASLIKID={ID}', 520),
    -- Sayimin urettigi envanter belgesi (FATBASLIK TUR=7) once satirlari, sonra basligi
    (520, 30, 'FATURA',       N'FATBASID IN (SELECT ID FROM FATBASLIK WHERE TUR=7 AND ANAKAYITID={ID})', 132),
    (520, 40, 'FATBASLIK',    N'TUR=7 AND ANAKAYITID={ID}', 29),
    (520,900, 'STOKSAYIM',    N'ID={ID}', 520);

    RETURN;
END
GO

-- ---- MOTOR: ek planlari da okusun ---------------------------------------
--   Iki TVF birlestirilir; boylece 129'daki tanim degistirilmeden yeni modul
--   eklenebilir (ileride de ayni desen kullanilir).
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Kayit_Silinebilir_Mi
    @Modul   INT,
    @KayitId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    IF @KayitId IS NULL OR @KayitId <= 0
        THROW 51001, N'KayitId zorunlu.', 1;

    DECLARE @Sira INT, @Tablo sysname, @Kosul NVARCHAR(1000), @Mesaj NVARCHAR(200);
    DECLARE @Var BIT, @SQL NVARCHAR(MAX);
    DECLARE @Neden sysname = NULL, @NedenMesaj NVARCHAR(200) = NULL;

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT Sira, Tablo, Kosul, Mesaj FROM dbo.fn_Prog_Silme_Engel()    WHERE Modul = @Modul
        UNION ALL
        SELECT Sira, Tablo, Kosul, Mesaj FROM dbo.fn_Prog_Silme_Engel_Ek() WHERE Modul = @Modul
        ORDER BY 1;
    OPEN cur;
    FETCH NEXT FROM cur INTO @Sira, @Tablo, @Kosul, @Mesaj;
    WHILE @@FETCH_STATUS = 0 AND @Neden IS NULL
    BEGIN
        IF OBJECT_ID(@Tablo) IS NOT NULL
        BEGIN
            SET @Var = 0;
            SET @SQL = N'SELECT @v = 1 WHERE EXISTS (' +
                       REPLACE(@Kosul, N'{ID}', CAST(@KayitId AS NVARCHAR(20))) + N')';
            EXEC sp_executesql @SQL, N'@v BIT OUTPUT', @v = @Var OUTPUT;
            IF ISNULL(@Var, 0) = 1
            BEGIN
                SET @Neden = @Tablo;
                SET @NedenMesaj = @Mesaj;
            END
        END
        FETCH NEXT FROM cur INTO @Sira, @Tablo, @Kosul, @Mesaj;
    END
    CLOSE cur; DEALLOCATE cur;

    SELECT SILINEBILIR = CASE WHEN @Neden IS NULL THEN 1 ELSE 0 END,
           NEDEN       = @Neden,
           MESAJ       = ISNULL(@NedenMesaj, N'');
END
GO

-- Plan okuyan tek gorunum: motor bunu kullanir
CREATE OR ALTER FUNCTION dbo.fn_Prog_Silme_Plan(@Modul INT)
RETURNS TABLE
AS
RETURN
    SELECT Sira, Tablo, Kosul, TabloId FROM dbo.fn_Prog_Silme_Detay()    WHERE Modul = @Modul
    UNION ALL
    SELECT Sira, Tablo, Kosul, TabloId FROM dbo.fn_Prog_Silme_Detay_Ek() WHERE Modul = @Modul;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Kasa_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic 480, @Kosullar; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Api_Stok_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  88, @Kosullar; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Api_StokSayim_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic 520, @Kosullar; END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_Api_Stok_Sil_Json      TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_StokSayim_Sil_Json TO gentegre_api;
    GRANT SELECT  ON dbo.fn_Prog_Silme_Plan        TO gentegre_api;
END
GO

-- Motor artik plani fn_Prog_Silme_Plan uzerinden okur (temel + ek moduller).
CREATE OR ALTER PROCEDURE dbo.sp_Api_Kayit_Sil_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Modul   INT    = TRY_CAST(JSON_VALUE(@Kosullar, '$.Modul')   AS INT);
    DECLARE @KayitId BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KayitId') AS BIGINT);
    DECLARE @KulId   INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId  INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), 0);
    DECLARE @Ip      VARCHAR(45) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Ip'), ''), 45);
    DECLARE @Ist     VARCHAR(64) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Istasyon'), ''), 64);

    IF @Modul IS NULL OR @KayitId IS NULL OR @KayitId <= 0
        THROW 51001, N'Modul ve KayitId zorunlu.', 1;

    -- Plan var mi? (yeni modul eklenmeden motor calismasin)
    DECLARE @KartTablo sysname =
        (SELECT TOP 1 Tablo FROM dbo.fn_Prog_Silme_Plan(@Modul) WHERE Sira = 900);
    IF @KartTablo IS NULL
        THROW 51003, N'Bu modul icin silme plani tanimli degil.', 1;

    -- Kayit var mi?
    DECLARE @SQL NVARCHAR(MAX), @Var BIT = 0;
    SET @SQL = N'SELECT @v=1 WHERE EXISTS (SELECT 1 FROM ' + QUOTENAME(@KartTablo) + N' WHERE ID=@id)';
    EXEC sp_executesql @SQL, N'@id BIGINT, @v BIT OUTPUT', @id = @KayitId, @v = @Var OUTPUT;
    IF ISNULL(@Var, 0) = 0
        THROW 51002, N'Kayit bulunamadi.', 1;

    -- ---- 1) On-kontrol ----
    DECLARE @K TABLE (SILINEBILIR INT, NEDEN sysname NULL, MESAJ NVARCHAR(200));
    INSERT @K EXEC dbo.sp_Prog_Kayit_Silinebilir_Mi @Modul = @Modul, @KayitId = @KayitId;

    DECLARE @Mesaj NVARCHAR(200) = (SELECT TOP 1 MESAJ FROM @K WHERE ISNULL(SILINEBILIR,1) = 0);
    IF @Mesaj IS NOT NULL
        THROW 51200, @Mesaj, 1;

    DECLARE @Loglanan INT = 0, @Silinen INT = 0, @n INT;

    BEGIN TRAN;

    -- ---- 2) LOGLAMA (SILMEDEN ONCE - Geri Al buna bagli) ----
    --   Kart ONCE loglanir (UInfo'da kart satiri ustte), sonra cocuklar.
    EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = @KartTablo, @Kosul = N'ID=@pB', @KosulPar = @KayitId,
         @TabNo = @Modul, @UstTabNo = @Modul, @UstId = @KayitId,
         @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
         @IslemTipi = 0, @Yazilan = @n OUTPUT;
    SET @Loglanan = @Loglanan + ISNULL(@n, 0);

    DECLARE @Sira INT, @Tablo sysname, @Kosul NVARCHAR(1000), @TabloId INT;
    DECLARE @KosulP NVARCHAR(1000);   -- EXEC parametresi IFADE alamaz -> onceden hesapla
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT Sira, Tablo, Kosul, TabloId
        FROM dbo.fn_Prog_Silme_Plan(@Modul)
        WHERE Sira < 900
        ORDER BY Sira;
    OPEN cur;
    FETCH NEXT FROM cur INTO @Sira, @Tablo, @Kosul, @TabloId;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF OBJECT_ID(@Tablo) IS NOT NULL
        BEGIN
            SET @n = 0;
            SET @KosulP = REPLACE(@Kosul, N'{ID}', N'@pB');   -- ID parametreyle baglanir
            EXEC dbo.sp_Api_Log_Yaz_Ic
                 @Tablo = @Tablo,
                 @Kosul = @KosulP,
                 @KosulPar = @KayitId,
                 @TabNo = @TabloId, @UstTabNo = @Modul, @UstId = @KayitId,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @IslemTipi = 0, @Yazilan = @n OUTPUT;
            SET @Loglanan = @Loglanan + ISNULL(@n, 0);
        END
        FETCH NEXT FROM cur INTO @Sira, @Tablo, @Kosul, @TabloId;
    END
    CLOSE cur; DEALLOCATE cur;

    -- ---- 3) SILME (plan sirasi: once cocuk, en son kart) ----
    DECLARE cur2 CURSOR LOCAL FAST_FORWARD FOR
        SELECT Sira, Tablo, Kosul
        FROM dbo.fn_Prog_Silme_Plan(@Modul)
        ORDER BY Sira;
    OPEN cur2;
    FETCH NEXT FROM cur2 INTO @Sira, @Tablo, @Kosul;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF OBJECT_ID(@Tablo) IS NOT NULL
        BEGIN
            SET @SQL = N'DELETE FROM ' + QUOTENAME(@Tablo) + N' WHERE ' +
                       REPLACE(@Kosul, N'{ID}', N'@pB');
            EXEC sp_executesql @SQL, N'@pB BIGINT', @pB = @KayitId;
            SET @Silinen = @Silinen + @@ROWCOUNT;
        END
        FETCH NEXT FROM cur2 INTO @Sira, @Tablo, @Kosul;
    END
    CLOSE cur2; DEALLOCATE cur2;

    COMMIT;

    SELECT Sonuc = 1, Modul = @Modul, KayitId = @KayitId,
           SilinenSatir = @Silinen, Loglanan = @Loglanan
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO
