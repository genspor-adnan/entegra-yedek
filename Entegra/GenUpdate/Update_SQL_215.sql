/*
  Update_SQL_215 - Ayni lot no, farkli SKT/URT

  Kullanici (17.10.2026): musteri ayni lot numarasini farkli SKT/URT ile
  girebiliyor; her biri STOKSERILOT'ta AYRI tanimdir. Izleme ekrani
  (UIzleme) lot yazilinca o lot no'lu tanimlari listeler; secilirse
  serilotId gelir, "Yeni" denirse serilotId 0 gelir ve kart burada aranir.

  Eskiden butun "kart var mi" aramalari yalniz lot no ile yapiliyordu:
  ayni lot no'nun ikinci tanimi hic acilmiyor, satir ilk karta baglaniyordu;
  gelen e-faturada ise ikinci tanim varken "Subquery returned more than 1
  value" hatasi cikiyordu.

  1) dbo.fn_SeriLot_TarihUyar: tek kural. Seri no'lu satir -> 1 (eski
     davranis). Salt lotta stogun izleme turune gore gorunen tarih
     karsilastirilir: lot izlemi (STOKLAR.IZLEME 2) URT, digerleri SKT.
     Gelen tarih bossa (1990 ve oncesi) her tanim kabul edilir.
  2) sp_Prog_Izleme_Yaz_Json (CREATE OR ALTER, tam metin): kart aramasi
     kurala baglandi. Ayni zamanda daha once YALNIZ gelistirme
     veritabanina uygulanmis "metni degisen lot" duzeltmesini tasir
     (kayitli satirin lotu degisince yeni karta baglanir, kopan bos eski
     kart silinir) - o duzeltme hicbir update dosyasina yazilmamisti.
  3) Ayni aramayi yapan diger nesneler yerinde yamalanir (metin bulunamazsa
     DEGISTIRILMEZ, mesaj basilir):
       sp_Prog_BelgeDonusum_Uygula_Json2  (toplu donusum, izleme secimi)
       sp_Prog_BelgeDonusum_IzlemeAktar   (donusumde yeni kart acma)
       sp_Prog_Irs_Fat_Satir_Ekleme       (Excel'den irsaliye/fatura)
       sp_Grnt_AlisFaturaHareketIslem     (gelen e-fatura; TOP 1 da eklendi)
       sp_Api_Belge_SeriLot_Yaz_Ic        (API)

  Tekrar calistirilabilir. Veri degistirmez.
*/
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE OR ALTER FUNCTION dbo.fn_SeriLot_TarihUyar
(
    @StokId  INT,
    @SeriNo  NVARCHAR(100),
    @KartSkt DATETIME,
    @KartUrt DATETIME,
    @Skt     DATETIME,
    @Urt     DATETIME
)
RETURNS BIT
AS
BEGIN
    -- Seri no'lu kartin kimligi seri no'dur; tarih bakilmaz.
    IF ISNULL(@SeriNo, N'') <> N'' RETURN 1;

    DECLARE @UrtEsas BIT = CASE WHEN (SELECT IZLEME FROM dbo.STOKLAR WHERE ID = @StokId) = 2 THEN 1 ELSE 0 END;
    DECLARE @Gelen DATE = CASE WHEN @UrtEsas = 1 THEN
                               CASE WHEN @Urt > '19900101' THEN CAST(@Urt AS DATE) END
                          ELSE CASE WHEN @Skt > '19900101' THEN CAST(@Skt AS DATE) END END;
    -- Tarih gelmediyse ayirt edilemez: her tanim kabul (eski davranis)
    IF @Gelen IS NULL RETURN 1;

    DECLARE @Kart DATE = CASE WHEN @UrtEsas = 1 THEN
                              CASE WHEN @KartUrt > '19900101' THEN CAST(@KartUrt AS DATE) END
                         ELSE CASE WHEN @KartSkt > '19900101' THEN CAST(@KartSkt AS DATE) END END;
    RETURN CASE WHEN @Kart = @Gelen THEN 1 ELSE 0 END;
END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Izleme_Yaz_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Tur      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.tur')      AS INT);
    DECLARE @BaslikId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.baslikId') AS INT);
    DECLARE @SatirId  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.satirId')  AS INT);
    DECLARE @IslemTip INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.islemTip') AS INT), 0);
    DECLARE @StokId   INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.stokId')   AS INT);
    DECLARE @IzlemTur INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.izlemTur') AS INT), 0);
    DECLARE @GirDepo  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.girDepo') AS INT), 0);
    DECLARE @CikDepo  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.cikDepo') AS INT), 0);
    DECLARE @StokHar  BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.stokHareketi') AS BIT), 1);
    DECLARE @KaynakSatir INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.kaynakSatirId') AS INT), 0);
    DECLARE @OncekiSil BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.oncekiSil') AS BIT), 1);
    DECLARE @KulId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.kullaniciId') AS INT), 0);

    IF @Tur      IS NULL                 THROW 51001, N'belge.tur zorunlu.', 1;
    IF @BaslikId IS NULL OR @BaslikId<=0 THROW 51001, N'belge.baslikId zorunlu.', 1;
    IF @SatirId  IS NULL OR @SatirId <=0 THROW 51001, N'belge.satirId zorunlu.', 1;
    IF @StokId   IS NULL OR @StokId  <=0 THROW 51001, N'stokId zorunlu.', 1;

    -- ---------- Girdi satirlari ----------
    DECLARE @S TABLE (Sira INT IDENTITY, SerilotId INT NULL, IzlemId INT NULL,
                      SeriNo NVARCHAR(64) COLLATE DATABASE_DEFAULT,
                      LotNo  NVARCHAR(50) COLLATE DATABASE_DEFAULT,
                      Skt DATETIME NULL, Urt DATETIME NULL, Adet DECIMAL(18,6), Metin BIT NOT NULL DEFAULT 0);
    INSERT @S (SerilotId, IzlemId, SeriNo, LotNo, Skt, Urt, Adet, Metin)
    SELECT J.SerilotId, ISNULL(J.IzlemId, 0), ISNULL(J.SeriNo, N''), ISNULL(J.LotNo, N''),
           J.Skt, J.Urt, J.Adet, CASE WHEN J.SeriNo IS NOT NULL OR J.LotNo IS NOT NULL THEN 1 ELSE 0 END
    FROM OPENJSON(@Kosullar, '$.satirlar')
         WITH (SerilotId INT '$.serilotId', IzlemId INT '$.izlemId',
               SeriNo NVARCHAR(64) '$.seriNo', LotNo NVARCHAR(50) '$.lotNo',
               Skt DATETIME '$.skt', Urt DATETIME '$.urt',
               Adet DECIMAL(18,6) '$.adet') J
    WHERE ISNULL(J.Adet, 0) > 0;

    -- ---------- Depo korumasi ----------
    --   Hareket yapilacaksa gecerli depo SART. Yon asagidaki ile ayni kural.
    DECLARE @Cikis BIT = CASE WHEN @Tur IN (4, 14, 15, 16, 20, 101, 119) THEN 1 ELSE 0 END;
    IF @StokHar = 1 AND EXISTS (SELECT 1 FROM @S)
       AND ((@Cikis = 1 AND @CikDepo <= 0) OR (@Cikis = 0 AND @GirDepo <= 0))
        THROW 51001, N'Bu belgede depo secilmedigi icin seri/lot hareketi kaydedilemez. Once belgenin giris/cikis deposunu secin.', 1;

    -- ---------- Onceki kayitlar ----------
    IF @OncekiSil = 1
    BEGIN
        DECLARE @Eski TABLE (Id INT PRIMARY KEY, SerilotId INT NULL);
        INSERT @Eski (Id, SerilotId)
        SELECT ID, SERILOTID FROM dbo.STOKIZLEME
         WHERE BELGETUR = @Tur AND STOKID = @StokId
           AND BASLIKID = @BaslikId AND SATIRID = @SatirId;

        -- SIRA ONEMLI: STOKIZLEME ONCE silinir.
        --   TG_StokIzlemeDurumSil (STOKIZLEME FOR DELETE) bakiyeyi geri verirken
        --   deleted'i STOKIZLEMEDEPO ile JOIN'ler. Depo satirlarini once
        --   silersek trigger hicbir sey bulamaz ve bakiye eksik kalir.
        --   Olculdu (08.08.2026): ayni satiri iki kez yazinca bakiye
        --   233 -> 223 oluyordu, dogrusu 228.
        DELETE FROM dbo.STOKIZLEME WHERE ID IN (SELECT Id FROM @Eski);
        DELETE FROM dbo.STOKIZLEMEDEPO WHERE IZLEMID IN (SELECT Id FROM @Eski);
    END

    IF NOT EXISTS (SELECT 1 FROM @S)
    BEGIN
        SELECT (SELECT 1 AS Sonuc, 0 AS Yazilan, 0 AS ToplamAdet
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
        RETURN;
    END

    -- ---------- Metni degisen lot (Update_SQL_209) ----------
    --   Istemci seri/lot metnini gonderdiyse (Metin=1) ve metin karttakiyle
    --   ayni degilse kullanici lotu degistirmistir: kart metinden aranir/acilir.
    UPDATE S
       SET S.SerilotId = NULL
      FROM @S S
           INNER JOIN dbo.STOKSERILOT SSL ON SSL.ID = S.SerilotId
     WHERE S.Metin = 1
       AND (S.SeriNo <> N'' OR S.LotNo <> N'')
       AND (ISNULL(SSL.SERINO, N'') COLLATE DATABASE_DEFAULT <> S.SeriNo COLLATE DATABASE_DEFAULT
            OR ISNULL(SSL.LOTNO, N'') COLLATE DATABASE_DEFAULT <> S.LotNo COLLATE DATABASE_DEFAULT);

    -- ---------- Eksik seri/lot kartlari ----------
    --   serilotId gelmemis satirlar once (STOKID, SERINO, LOTNO) ile aranir
    --   (salt lotta tarih de tutmali - fn_SeriLot_TarihUyar, 215),
    --   yoksa STOKSERILOT'a eklenir. Tarih yoksa 1990-01-01 (eski sentinel).
    UPDATE S
       SET S.SerilotId = SSL.ID
      FROM @S S
           INNER JOIN dbo.STOKSERILOT SSL
                   ON SSL.STOKID = @StokId
                  AND ISNULL(SSL.SERINO, N'') COLLATE DATABASE_DEFAULT = S.SeriNo COLLATE DATABASE_DEFAULT
                  AND ISNULL(SSL.LOTNO,  N'') COLLATE DATABASE_DEFAULT = S.LotNo COLLATE DATABASE_DEFAULT
                  -- 215: ayni lot no farkli tarihle ayri tanimdir
                  AND dbo.fn_SeriLot_TarihUyar(@StokId, S.SeriNo, SSL.SKT, SSL.URT, S.Skt, S.Urt) = 1
     WHERE ISNULL(S.SerilotId, 0) = 0;

    DECLARE @Yeni TABLE (Sira INT, SerilotId INT);
    INSERT INTO dbo.STOKSERILOT (STOKID, SERINO, LOTNO, URT, SKT)
    OUTPUT INSERTED.ID INTO @Yeni (SerilotId)
    SELECT @StokId, S.SeriNo, S.LotNo,
           ISNULL(S.Urt, '1990-01-01'), ISNULL(S.Skt, '1990-01-01')
    FROM @S S WHERE ISNULL(S.SerilotId, 0) = 0;

    -- OUTPUT ile Sira eslestirilemez (INSERT...SELECT'te kaynak kolon
    --   OUTPUT'a alinamaz); yeni eklenenler tekrar arama ile baglanir.
    UPDATE S
       SET S.SerilotId = SSL.ID
      FROM @S S
           INNER JOIN dbo.STOKSERILOT SSL
                   ON SSL.STOKID = @StokId
                  AND ISNULL(SSL.SERINO, N'') COLLATE DATABASE_DEFAULT = S.SeriNo COLLATE DATABASE_DEFAULT
                  AND ISNULL(SSL.LOTNO,  N'') COLLATE DATABASE_DEFAULT = S.LotNo COLLATE DATABASE_DEFAULT
                  -- 215: ayni lot no farkli tarihle ayri tanimdir
                  AND dbo.fn_SeriLot_TarihUyar(@StokId, S.SeriNo, SSL.SKT, SSL.URT, S.Skt, S.Urt) = 1
     WHERE ISNULL(S.SerilotId, 0) = 0;

    IF EXISTS (SELECT 1 FROM @S WHERE ISNULL(SerilotId, 0) = 0)
        THROW 51200, N'Seri/lot karti olusturulamadi (seri no ve lot no bos olamaz).', 1;

    -- ---------- Yazma ----------
    DECLARE @Sira INT, @Serilot INT, @IzlemId INT, @Adet DECIMAL(18,6),
            @YeniId INT, @Yazilan INT = 0, @Toplam DECIMAL(18,6) = 0,
            @Hareket DECIMAL(18,6);

    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT Sira, SerilotId, IzlemId, Adet FROM @S ORDER BY Sira;
    OPEN c; FETCH NEXT FROM c INTO @Sira, @Serilot, @IzlemId, @Adet;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO dbo.STOKIZLEME (STOKID, BELGETUR, BASLIKID, SATIRID, IZLEMTUR,
                                    ADET, KALAN, YER, YERID, DONUSID, SERILOTID, EKLEYEN)
        VALUES (@StokId, @Tur, @BaslikId, @SatirId, @IzlemTur,
                @Adet, @Adet, 0, 0,
                CASE WHEN @KaynakSatir > 0 THEN ISNULL(@IzlemId, 0) ELSE 0 END,
                @Serilot, @KulId);
        SET @YeniId = CAST(SCOPE_IDENTITY() AS INT);

        SET @Hareket = CASE WHEN @StokHar = 1 THEN @Adet ELSE 0 END;

        IF @Cikis = 1
            INSERT INTO dbo.STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET)
            VALUES (@YeniId, @CikDepo, -1.0 * @Hareket);
        ELSE
            INSERT INTO dbo.STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET)
            VALUES (@YeniId, @GirDepo, @Hareket);

        -- Transfer ve giden konsinye: cikisin karsiligi giris deposuna
        IF @Tur IN (20, 119)
            INSERT INTO dbo.STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET)
            VALUES (@YeniId, @GirDepo, @Hareket);
        -- Gelen konsinye IADE (islemTip 2): konsinyeden cikis, ana depoya giris
        ELSE IF @Tur = 109 AND @IslemTip = 2
            INSERT INTO dbo.STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET)
            VALUES (@YeniId, @CikDepo, -1.0 * @Hareket);

        SET @Yazilan = @Yazilan + 1;
        SET @Toplam = @Toplam + @Adet;
        FETCH NEXT FROM c INTO @Sira, @Serilot, @IzlemId, @Adet;
    END
    CLOSE c; DEALLOCATE c;

    -- Bu satirdan kopan eski kart (lot metni degisti) hicbir harekette
    --   kullanilmiyorsa silinir; trigger'in biraktigi sifir bakiye satirlari
    --   da onunla gider (Update_SQL_209).
    DECLARE @Kopan TABLE (Id INT PRIMARY KEY);
    INSERT @Kopan (Id)
    SELECT SSL.ID
      FROM dbo.STOKSERILOT SSL
     WHERE SSL.STOKID = @StokId
       AND SSL.ID IN (SELECT E.SerilotId FROM @Eski E WHERE E.SerilotId IS NOT NULL)
       AND NOT EXISTS (SELECT 1 FROM @S S WHERE S.SerilotId = SSL.ID)
       AND NOT EXISTS (SELECT 1 FROM dbo.STOKIZLEME X WHERE X.SERILOTID = SSL.ID)
       AND NOT EXISTS (SELECT 1 FROM dbo.STOKDURUMIZLEME X WHERE X.SERILOTID = SSL.ID AND ISNULL(X.KALAN, 0) <> 0);
    DELETE FROM dbo.STOKDURUMIZLEME WHERE SERILOTID IN (SELECT Id FROM @Kopan);
    DELETE FROM dbo.STOKSERILOT WHERE ID IN (SELECT Id FROM @Kopan);

    SELECT (SELECT 1 AS Sonuc, @Yazilan AS Yazilan, @Toplam AS ToplamAdet
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO
DECLARE @d NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID(N'dbo.sp_Prog_BelgeDonusum_Uygula_Json2'));
IF @d IS NULL
    PRINT N'sp_Prog_BelgeDonusum_Uygula_Json2: yok, atlandi';
ELSE IF CHARINDEX(N'fn_SeriLot_TarihUyar', @d) > 0
    PRINT N'sp_Prog_BelgeDonusum_Uygula_Json2: zaten uygulanmis';
ELSE IF (LEN(@d) - LEN(REPLACE(@d, N'AND ISNULL(SSL.LOTNO,  N'''') = S.LotNo', N''))) / LEN(N'AND ISNULL(SSL.LOTNO,  N'''') = S.LotNo') <> 1
    PRINT N'sp_Prog_BelgeDonusum_Uygula_Json2: beklenen metin bulunamadi, DEGISTIRILMEDI - elle bakilmali';
ELSE
BEGIN
    SET @d = REPLACE(@d, N'AND ISNULL(SSL.LOTNO,  N'''') = S.LotNo', N'AND ISNULL(SSL.LOTNO,  N'''') = S.LotNo AND dbo.fn_SeriLot_TarihUyar(S.UrunId, S.SeriNo, SSL.SKT, SSL.URT, S.Skt, S.Urt) = 1');
    SET @d = STUFF(@d, PATINDEX(N'%CREATE%PROC%', @d), 6, N'ALTER');
    EXEC (@d);
    PRINT N'sp_Prog_BelgeDonusum_Uygula_Json2: guncellendi';
END
GO
DECLARE @d NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID(N'dbo.sp_Prog_BelgeDonusum_IzlemeAktar'));
IF @d IS NULL
    PRINT N'sp_Prog_BelgeDonusum_IzlemeAktar: yok, atlandi';
ELSE IF CHARINDEX(N'fn_SeriLot_TarihUyar', @d) > 0
    PRINT N'sp_Prog_BelgeDonusum_IzlemeAktar: zaten uygulanmis';
ELSE IF (LEN(@d) - LEN(REPLACE(@d, N'AND ISNULL(SSL.LOTNO,  N'''') COLLATE DATABASE_DEFAULT = ISNULL(I.LotNo,  N'''') COLLATE DATABASE_DEFAULT', N''))) / LEN(N'AND ISNULL(SSL.LOTNO,  N'''') COLLATE DATABASE_DEFAULT = ISNULL(I.LotNo,  N'''') COLLATE DATABASE_DEFAULT') <> 2
    PRINT N'sp_Prog_BelgeDonusum_IzlemeAktar: beklenen metin bulunamadi, DEGISTIRILMEDI - elle bakilmali';
ELSE
BEGIN
    SET @d = REPLACE(@d, N'AND ISNULL(SSL.LOTNO,  N'''') COLLATE DATABASE_DEFAULT = ISNULL(I.LotNo,  N'''') COLLATE DATABASE_DEFAULT', N'AND ISNULL(SSL.LOTNO,  N'''') COLLATE DATABASE_DEFAULT = ISNULL(I.LotNo,  N'''') COLLATE DATABASE_DEFAULT AND dbo.fn_SeriLot_TarihUyar(I.UrunId, I.SeriNo, SSL.SKT, SSL.URT, I.Skt, I.Urt) = 1');
    SET @d = STUFF(@d, PATINDEX(N'%CREATE%PROC%', @d), 6, N'ALTER');
    EXEC (@d);
    PRINT N'sp_Prog_BelgeDonusum_IzlemeAktar: guncellendi';
END
GO
DECLARE @d NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID(N'dbo.sp_Prog_Irs_Fat_Satir_Ekleme'));
IF @d IS NULL
    PRINT N'sp_Prog_Irs_Fat_Satir_Ekleme: yok, atlandi';
ELSE IF CHARINDEX(N'fn_SeriLot_TarihUyar', @d) > 0
    PRINT N'sp_Prog_Irs_Fat_Satir_Ekleme: zaten uygulanmis';
ELSE IF (LEN(@d) - LEN(REPLACE(@d, N'AND ISNULL(SERINO,'''') = ISNULL(@SERINO,'''')', N''))) / LEN(N'AND ISNULL(SERINO,'''') = ISNULL(@SERINO,'''')') <> 1
    PRINT N'sp_Prog_Irs_Fat_Satir_Ekleme: beklenen metin bulunamadi, DEGISTIRILMEDI - elle bakilmali';
ELSE
BEGIN
    SET @d = REPLACE(@d, N'AND ISNULL(SERINO,'''') = ISNULL(@SERINO,'''')', N'AND ISNULL(SERINO,'''') = ISNULL(@SERINO,'''') AND dbo.fn_SeriLot_TarihUyar(@STOKID, @SERINO, SKT, URT, @SKT, @URT) = 1');
    SET @d = STUFF(@d, PATINDEX(N'%CREATE%PROC%', @d), 6, N'ALTER');
    EXEC (@d);
    PRINT N'sp_Prog_Irs_Fat_Satir_Ekleme: guncellendi';
END
GO
DECLARE @d NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID(N'dbo.sp_Grnt_AlisFaturaHareketIslem'));
IF @d IS NULL
    PRINT N'sp_Grnt_AlisFaturaHareketIslem: yok, atlandi';
ELSE IF CHARINDEX(N'fn_SeriLot_TarihUyar', @d) > 0
    PRINT N'sp_Grnt_AlisFaturaHareketIslem: zaten uygulanmis';
ELSE IF (LEN(@d) - LEN(REPLACE(@d, N'SL.LOTNO = @LOTNO))', N''))) / LEN(N'SL.LOTNO = @LOTNO))') <> 3
    PRINT N'sp_Grnt_AlisFaturaHareketIslem: beklenen metin bulunamadi, DEGISTIRILMEDI - elle bakilmali';
ELSE
BEGIN
    SET @d = REPLACE(@d, N'SL.LOTNO = @LOTNO))', N'SL.LOTNO = @LOTNO AND dbo.fn_SeriLot_TarihUyar(@URUNID, N'''', SL.SKT, SL.URT, @SKT, NULL) = 1))');
    SET @d = STUFF(@d, PATINDEX(N'%CREATE%PROC%', @d), 6, N'ALTER');
    EXEC (@d);
    PRINT N'sp_Grnt_AlisFaturaHareketIslem: guncellendi';
END
GO
DECLARE @d NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID(N'dbo.sp_Grnt_AlisFaturaHareketIslem'));
IF @d IS NOT NULL AND CHARINDEX(N'SET @SERILOTID = (SELECT ID FROM STOKSERILOT SL', @d) > 0
BEGIN
    SET @d = REPLACE(@d, N'SET @SERILOTID = (SELECT ID FROM STOKSERILOT SL', N'SET @SERILOTID = (SELECT TOP 1 ID FROM STOKSERILOT SL');
    SET @d = STUFF(@d, PATINDEX(N'%CREATE%PROC%', @d), 6, N'ALTER');
    EXEC (@d);
    PRINT N'sp_Grnt_AlisFaturaHareketIslem: TOP 1 eklendi';
END
GO
DECLARE @d NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID(N'dbo.sp_Api_Belge_SeriLot_Yaz_Ic'));
IF @d IS NULL
    PRINT N'sp_Api_Belge_SeriLot_Yaz_Ic: yok, atlandi';
ELSE IF CHARINDEX(N'fn_SeriLot_TarihUyar', @d) > 0
    PRINT N'sp_Api_Belge_SeriLot_Yaz_Ic: zaten uygulanmis';
ELSE IF (LEN(@d) - LEN(REPLACE(@d, N'WHERE SL.STOKID = @UrunId AND SL.SERINO = S.SeriNo AND SL.LOTNO = S.LotNo', N''))) / LEN(N'WHERE SL.STOKID = @UrunId AND SL.SERINO = S.SeriNo AND SL.LOTNO = S.LotNo') <> 1
    PRINT N'sp_Api_Belge_SeriLot_Yaz_Ic: beklenen metin bulunamadi, DEGISTIRILMEDI - elle bakilmali';
ELSE
BEGIN
    SET @d = REPLACE(@d, N'WHERE SL.STOKID = @UrunId AND SL.SERINO = S.SeriNo AND SL.LOTNO = S.LotNo', N'WHERE SL.STOKID = @UrunId AND SL.SERINO = S.SeriNo AND SL.LOTNO = S.LotNo AND dbo.fn_SeriLot_TarihUyar(@UrunId, S.SeriNo, SL.SKT, SL.URT, S.Skt, S.Urt) = 1');
    SET @d = STUFF(@d, PATINDEX(N'%CREATE%PROC%', @d), 6, N'ALTER');
    EXEC (@d);
    PRINT N'sp_Api_Belge_SeriLot_Yaz_Ic: guncellendi';
END
GO
