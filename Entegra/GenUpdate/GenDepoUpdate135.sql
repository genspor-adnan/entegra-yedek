-- ============================================================
-- GenDepoUpdate135.sql
-- MERKEZI NUMARA URETIMI (sayac servisi)
--
-- SORUN: numara uretimi iki yerde de "max(...)+1" ile yapiliyor:
--   * Istemcide: IMAJ.BELGENO, KOCANAYARLARI.KOCANNO, DEMIRBAS_TUTANAK.BELGENO,
--     GENINI.SIRA, adisyon FATURA.YERI, FATURA/SIPARISDETAY/TEKLIFDETAY.POZNO
--   * Sunucuda: sp_BelgeNoGetir'in FATBASLIK/SIPARIS/SERVIS/TEKLIF/URETIMEMRI/
--     DOKUMAN dallari (kasa/cek/senet dallari SEQUENCE kullandigi icin sorunsuz)
--   Iki kullanici ayni anda kaydederse AYNI numarayi alir. Bugun nadir; web/API
--   ile es zamanli istek artinca kural haline gelir.
--
-- COZUM: tek sayac servisi.
--   sp_Prog_SiradakiNo        : atomik tahsis (tek UPDATE ... OUTPUT)
--   sp_Prog_SiradakiNo_Iade   : belge iptal edilirse SON numarayi geri ver (bosluk olmasin)
--   sp_Prog_SiradakiNo_Ayarla : yonetici; sayaci elle kur/duzelt
--
-- UYUM: sayac ILK kullanimda gercek tablodan MAX ile tohumlanir. Eski kod
--   yollari max()+1 ile yazmaya devam etse bile carpisma olmaz - tahsis sonrasi
--   numara gercekten tabloda var mi diye bakilir, varsa atlanir (@Dogrula=1).
--
-- BOSLUK (gap): rezervasyon bosluk uretebilir (numara alindi, belge kaydedilmedi).
--   Iki onlem: (1) iptalde sp_Prog_SiradakiNo_Iade, (2) GENINI opsiyonu ile
--   sp_BelgeNoGetir'de rezervasyon KAPALI baslar - musteri hazir olunca acilir.
--
-- GENINI -24121 : 0/1  "Belge numarasi rezervasyonu" (varsayilan 0 = eski davranis)
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ---- SAYAC TABLOSU -------------------------------------------------------
IF OBJECT_ID('dbo.SAYAC') IS NULL
BEGIN
    CREATE TABLE dbo.SAYAC
    (
        ANAHTAR     NVARCHAR(200) NOT NULL,   -- 'FATBASLIK.FATURANO|T14|S-1|K1401'
        TABLOADI    sysname       NULL,
        ALANADI     sysname       NULL,
        KAPSAM      NVARCHAR(80)  NULL,       -- tur/sube/kocan/yil ayrimi
        SONNO       BIGINT        NOT NULL CONSTRAINT DF_SAYAC_SONNO DEFAULT (0),
        GUNCELLEME  DATETIME      NULL,
        CONSTRAINT PK_SAYAC PRIMARY KEY CLUSTERED (ANAHTAR)
    );
END
GO

-- GENINI opsiyon satiri (yoksa ekle) - varsayilan KAPALI.
--   Bool opsiyon deseni: ANAHTAR NULL, DEGER 0/1, DIL 0 (bkz -24119 UBL_ZIP).
--   -24130 DOLU (e-Fatura seri kurallari) -> serbest slot -24121 kullanildi.
IF NOT EXISTS (SELECT 1 FROM dbo.GENINI WHERE BOLUM = -24121)
    INSERT INTO dbo.GENINI (BOLUM, ANAHTAR, DEGER, DIL, SIRA)
    VALUES (-24121, NULL, 0, 0, NULL);
GO

-- ============================================================
-- SIRADAKI NUMARA (atomik)
--   @Tablo/@Alan : numaranin tutuldugu gercek tablo/kolon (tohumlama + dogrulama icin)
--   @Kapsam      : ayni kolonun bagimsiz sayaclari (ornek 'T14|S-1|K1401')
--   @Kosul       : tohumlama/dogrulama WHERE'i (kocan/tarih/tur suzgeci) - opsiyonel
--   @Baslangic   : kocan baslangic numarasi (BASLANGICNO)
--   @Adet        : blok tahsis (toplu satir ekleme)
--   @Dijit       : sifir dolgusu (000123)
--   @Rezerve     : 1 = kalici tahsis (atomik), 0 = sadece bak (eski davranis, yarissiz DEGIL)
--   @Dogrula     : 1 = tahsis edilen numara tabloda varsa atla (eski kodla birlikte yasarken)
-- CIKTI: ILKNO, SONNO, NO (dolgulu metin)
-- ============================================================
-- CEKIRDEK: result set DONDURMEZ, OUTPUT parametre verir.
--   Neden: SQL Server'da "INSERT ... EXEC" IC ICE OLAMAZ. sp_BelgeNoGetir gibi
--   cagiranlar sonucu tabloya almak zorunda kalmasin diye cekirdek ayrildi.
CREATE OR ALTER PROCEDURE dbo.sp_Prog_SiradakiNo_Ic
    @Tablo     sysname,
    @Alan      sysname,
    @Kapsam    NVARCHAR(80)   = N'',
    @Kosul     NVARCHAR(1000) = NULL,
    @Baslangic BIGINT         = 1,
    @Adet      INT            = 1,
    @Dijit     INT            = 0,
    @Rezerve   BIT            = 1,
    @Dogrula   BIT            = 1,
    @Ilk       BIGINT         OUTPUT,
    @Son       BIGINT         OUTPUT,
    @No        NVARCHAR(40)   OUTPUT,
    @AnahtarOut NVARCHAR(200) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID(@Tablo) IS NULL
        THROW 51301, N'Sayac icin tablo bulunamadi.', 1;
    IF COL_LENGTH(@Tablo, @Alan) IS NULL
        THROW 51302, N'Sayac icin kolon bulunamadi.', 1;
    IF ISNULL(@Adet, 0) < 1 SET @Adet = 1;

    DECLARE @Anahtar NVARCHAR(200) = @Tablo + N'.' + @Alan +
                                     CASE WHEN ISNULL(@Kapsam, N'') = N'' THEN N'' ELSE N'|' + @Kapsam END;
    DECLARE @Nerede NVARCHAR(1010) = CASE WHEN ISNULL(@Kosul, N'') = N'' THEN N'' ELSE N' WHERE ' + @Kosul END;
    DECLARE @SQL NVARCHAR(MAX), @Mevcut BIGINT;
    SET @AnahtarOut = @Anahtar;

    ------------------------------------------------------------------ tohumlama
    -- Sayac yoksa GERCEK tablodan MAX ile kurulur -> eski verilerle carpismaz.
    IF NOT EXISTS (SELECT 1 FROM dbo.SAYAC WHERE ANAHTAR = @Anahtar)
    BEGIN
        SET @SQL = N'SELECT @m = ISNULL(MAX(TRY_CAST(' + QUOTENAME(@Alan) + N' AS BIGINT)), 0) FROM ' +
                   @Tablo + @Nerede;
        BEGIN TRY
            EXEC sp_executesql @SQL, N'@m BIGINT OUTPUT', @m = @Mevcut OUTPUT;
        END TRY
        BEGIN CATCH
            SET @Mevcut = 0;   -- kolon metin/karisik ise tohum @Baslangic'ten
        END CATCH

        DECLARE @Tohum BIGINT = CASE WHEN ISNULL(@Mevcut, 0) > @Baslangic - 1
                                     THEN @Mevcut ELSE @Baslangic - 1 END;

        -- Es zamanli ilk cagriya dayanikli: varsa dokunma.
        INSERT INTO dbo.SAYAC (ANAHTAR, TABLOADI, ALANADI, KAPSAM, SONNO, GUNCELLEME)
        SELECT @Anahtar, @Tablo, @Alan, @Kapsam, @Tohum, GETDATE()
        WHERE NOT EXISTS (SELECT 1 FROM dbo.SAYAC WITH (UPDLOCK, HOLDLOCK) WHERE ANAHTAR = @Anahtar);
    END

    ------------------------------------------------------------------ tahsis
    DECLARE @C TABLE (ILK BIGINT, SON BIGINT);

    IF @Rezerve = 1
    BEGIN
        -- TEK deyim: okuma+yazma atomik, ayrica transaction gerekmez.
        UPDATE dbo.SAYAC
           SET SONNO = SONNO + @Adet,
               GUNCELLEME = GETDATE()
        OUTPUT deleted.SONNO + 1, inserted.SONNO INTO @C (ILK, SON)
        WHERE ANAHTAR = @Anahtar;
    END
    ELSE
    BEGIN
        -- Sadece bak (eski davranis): yazmaz, dolayisiyla yarisi COZMEZ.
        INSERT @C (ILK, SON)
        SELECT SONNO + 1, SONNO + @Adet FROM dbo.SAYAC WHERE ANAHTAR = @Anahtar;
    END

    SELECT @Ilk = ILK, @Son = SON FROM @C;

    ------------------------------------------------------------------ carpisma kontrolu
    -- Eski kod yollari hala max()+1 ile yaziyor olabilir; tahsis edilen numara
    -- gercekten kullanilmissa bir sonrakine gec (en fazla 1000 deneme).
    IF @Dogrula = 1 AND @Rezerve = 1 AND @Adet = 1
    BEGIN
        DECLARE @Var BIT = 1, @Deneme INT = 0;
        WHILE @Var = 1 AND @Deneme < 1000
        BEGIN
            SET @Var = 0;
            SET @SQL = N'SELECT @v = 1 WHERE EXISTS (SELECT 1 FROM ' + @Tablo +
                       N' WHERE TRY_CAST(' + QUOTENAME(@Alan) + N' AS BIGINT) = @n' +
                       CASE WHEN ISNULL(@Kosul, N'') = N'' THEN N'' ELSE N' AND (' + @Kosul + N')' END + N')';
            BEGIN TRY
                EXEC sp_executesql @SQL, N'@n BIGINT, @v BIT OUTPUT', @n = @Ilk, @v = @Var OUTPUT;
            END TRY
            BEGIN CATCH
                SET @Var = 0;
            END CATCH

            IF ISNULL(@Var, 0) = 1
            BEGIN
                UPDATE dbo.SAYAC SET SONNO = SONNO + 1, GUNCELLEME = GETDATE()
                 OUTPUT inserted.SONNO INTO @C (SON)          -- (bilgi amacli)
                 WHERE ANAHTAR = @Anahtar AND SONNO = @Son;

                SET @Ilk = @Ilk + 1;
                SET @Son = @Son + 1;
                SET @Deneme = @Deneme + 1;
            END
        END
    END

    ------------------------------------------------------------------ cikti
    SET @No = CAST(@Ilk AS NVARCHAR(40));
    IF ISNULL(@Dijit, 0) > LEN(@No)
        SET @No = REPLICATE(N'0', @Dijit - LEN(@No)) + @No;
END
GO

-- ORTAK CAGRI YUZU: cekirdegi cagirir, tek satirlik sonuc doner (app/Pascal bunu kullanir).
CREATE OR ALTER PROCEDURE dbo.sp_Prog_SiradakiNo
    @Tablo     sysname,
    @Alan      sysname,
    @Kapsam    NVARCHAR(80)   = N'',
    @Kosul     NVARCHAR(1000) = NULL,
    @Baslangic BIGINT         = 1,
    @Adet      INT            = 1,
    @Dijit     INT            = 0,
    @Rezerve   BIT            = 1,
    @Dogrula   BIT            = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Ilk BIGINT, @Son BIGINT, @No NVARCHAR(40), @Anahtar NVARCHAR(200);
    EXEC dbo.sp_Prog_SiradakiNo_Ic @Tablo, @Alan, @Kapsam, @Kosul, @Baslangic, @Adet,
         @Dijit, @Rezerve, @Dogrula, @Ilk OUTPUT, @Son OUTPUT, @No OUTPUT, @Anahtar OUTPUT;
    SELECT ILKNO = @Ilk, SONNO = @Son, NO = @No, ANAHTAR = @Anahtar;
END
GO

-- ============================================================
-- IADE: belge kaydedilmediyse SON numarayi geri ver (bosluk olusmasin).
--   Yalnizca iade edilen numara sayacin son degeriyse geri alinir; arada baska
--   kullanici numara aldiysa dokunulmaz (o zaman bosluk kacinilmazdir).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_SiradakiNo_Iade
    @Tablo  sysname,
    @Alan   sysname,
    @Kapsam NVARCHAR(80) = N'',
    @No     BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Anahtar NVARCHAR(200) = @Tablo + N'.' + @Alan +
                                     CASE WHEN ISNULL(@Kapsam, N'') = N'' THEN N'' ELSE N'|' + @Kapsam END;
    DECLARE @Alindi BIT = 0;

    UPDATE dbo.SAYAC
       SET SONNO = SONNO - 1, GUNCELLEME = GETDATE(), @Alindi = 1
     WHERE ANAHTAR = @Anahtar AND SONNO = @No;

    SELECT IADE = @Alindi;
END
GO

-- ============================================================
-- AYARLA: yonetici. Sayaci kurar/duzeltir (@Deger = son kullanilan numara).
--   @Deger NULL ise gercek tablodan MAX ile yeniden tohumlar.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_SiradakiNo_Ayarla
    @Tablo  sysname,
    @Alan   sysname,
    @Kapsam NVARCHAR(80)   = N'',
    @Kosul  NVARCHAR(1000) = NULL,
    @Deger  BIGINT         = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID(@Tablo) IS NULL       THROW 51301, N'Sayac icin tablo bulunamadi.', 1;
    IF COL_LENGTH(@Tablo, @Alan) IS NULL THROW 51302, N'Sayac icin kolon bulunamadi.', 1;

    DECLARE @Anahtar NVARCHAR(200) = @Tablo + N'.' + @Alan +
                                     CASE WHEN ISNULL(@Kapsam, N'') = N'' THEN N'' ELSE N'|' + @Kapsam END;

    IF @Deger IS NULL
    BEGIN
        DECLARE @SQL NVARCHAR(MAX) =
            N'SELECT @m = ISNULL(MAX(TRY_CAST(' + QUOTENAME(@Alan) + N' AS BIGINT)), 0) FROM ' + @Tablo +
            CASE WHEN ISNULL(@Kosul, N'') = N'' THEN N'' ELSE N' WHERE ' + @Kosul END;
        EXEC sp_executesql @SQL, N'@m BIGINT OUTPUT', @m = @Deger OUTPUT;
    END

    UPDATE dbo.SAYAC SET SONNO = @Deger, KAPSAM = @Kapsam, GUNCELLEME = GETDATE()
     WHERE ANAHTAR = @Anahtar;

    IF @@ROWCOUNT = 0
        INSERT INTO dbo.SAYAC (ANAHTAR, TABLOADI, ALANADI, KAPSAM, SONNO, GUNCELLEME)
        VALUES (@Anahtar, @Tablo, @Alan, @Kapsam, @Deger, GETDATE());

    SELECT ANAHTAR = @Anahtar, SONNO = @Deger;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_Prog_SiradakiNo_Ic     TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Prog_SiradakiNo        TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Prog_SiradakiNo_Iade   TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Prog_SiradakiNo_Ayarla TO gentegre_api;
END
GO
