-- ============================================================
-- GenDepoUpdate95.sql
-- IZLEME BAKIYE ONARIMI  (KUTU 2: opt-in, kayitli, geri alinabilir)
--
-- GenDepoUpdate94 trigger'lari duzeltti ama GECMIS sapmalari duzeltmedi.
--   Bu dosya onarim aracini kurar. ARAC KENDILIGINDEN CALISMAZ:
--   varsayilan @Uygula = 0 (KURU CALISMA) - ne yapacagini gosterir, yazmaz.
--
-- NEDEN OTOMATIK DEGIL
--   Musteri veritabaninda STOKDURUMIZLEME bakiyesi ile hareket toplaminin
--   ayrilmasinin TEK sebebi bozuk trigger olmayabilir:
--     - trigger'lar eklenmeden onceki donemden kalan bakiyeler
--     - elle duzeltilmis (SQL ile mudahale edilmis) bakiyeler
--     - hareket kayitlari arsivlenmis/silinmis ama bakiye birakilmis kayitlar
--   Korlemesine "yeniden hesapla" bu durumlarda DOGRU bakiyeyi de bozar.
--   Bu yuzden: once rapor (sp_Prog_Izleme_BakiyeKontrol), sonra karar,
--   sonra kapsam daraltilarak onarim.
--
-- GUVENLIK KURALLARI
--   1  @Uygula = 0 varsayilan. Yazma yalnizca acikca 1 verilirse.
--   2  Her degisiklik IZLEMEBAKIYEONARIM tablosuna yazilir (eski deger dahil)
--      -> tam olarak geri alinabilir.
--   3  Bakiyesi olup HIC HAREKETI OLMAYAN kayitlar varsayilan olarak
--      DOKUNULMAZ (@HareketsizSifirla = 0). Bunlar devir/mudahale olabilir.
--   4  Kapsam daraltilabilir: @StokID, @DepoID.
--   5  Gecersiz depo (DEPOID = 0) kayitlari varsayilan olarak DISARIDA
--      (@GecersizDepoDahil = 0). Bunlar ayri bir veri sorunudur.
--
-- KULLANIM
--   -- 1) once rapor
--   EXEC dbo.sp_Prog_Izleme_BakiyeKontrol @Ayrinti = 1;
--   -- 2) kuru calisma: ne degisecek
--   EXEC dbo.sp_Prog_Izleme_BakiyeOnar;
--   -- 3) uygula (parti numarasi doner)
--   EXEC dbo.sp_Prog_Izleme_BakiyeOnar @Uygula = 1, @KullaniciID = 5;
--   -- 4) gerekirse geri al
--   EXEC dbo.sp_Prog_Izleme_BakiyeOnar_GeriAl @PartiID = <donen deger>;
--
-- PG NOTU: MSSQL icindir. GenUpdate komutu olarak dagitilirsa #pg etiketi
--   KULLANILMAYACAK.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- Onarim kayit tablosu - ANA veritabaninda
-- ============================================================
IF OBJECT_ID('dbo.IZLEMEBAKIYEONARIM', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.IZLEMEBAKIYEONARIM (
        ID           INT IDENTITY(1,1) NOT NULL,
        PARTIID      INT               NOT NULL,   -- ayni calistirmanin satirlari
        TARIH        DATETIME          NOT NULL CONSTRAINT DF_IZLEMEBAKIYEONARIM_TRH DEFAULT (GETDATE()),
        KULLANICIID  INT               NULL,
        STOKID       INT               NOT NULL,
        DEPOID       INT               NOT NULL,
        SERILOTID    INT               NOT NULL,
        ESKIKALAN    FLOAT             NULL,       -- NULL = satir yoktu, eklendi
        YENIKALAN    FLOAT             NOT NULL,
        FARK         FLOAT             NOT NULL,
        GERIALINDI   BIT               NOT NULL CONSTRAINT DF_IZLEMEBAKIYEONARIM_GA DEFAULT (0),
        CONSTRAINT PK_IZLEMEBAKIYEONARIM PRIMARY KEY CLUSTERED (ID)
    );
    CREATE INDEX IX_IZLEMEBAKIYEONARIM_PARTI ON dbo.IZLEMEBAKIYEONARIM (PARTIID);
END
GO

-- ============================================================
-- sp_Prog_Izleme_BakiyeOnar
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Izleme_BakiyeOnar
    @Uygula            BIT   = 0,      -- 0 = KURU CALISMA (yazma yok)
    @Esik              FLOAT = 0.0001,
    @StokID            INT   = NULL,   -- kapsam daraltma
    @DepoID            INT   = NULL,
    @GecersizDepoDahil BIT   = 0,      -- DEPOID = 0 kayitlari
    @HareketsizSifirla BIT   = 0,      -- bakiyesi olup hareketi olmayanlari sifirla
    @KullaniciID       INT   = NULL,
    @PartiID           INT   = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Aday TABLE (
        STOKID INT, DEPOID INT, SERILOTID INT,
        EskiKalan FLOAT NULL, YeniKalan FLOAT, Fark FLOAT, SatirVar BIT,
        PRIMARY KEY (STOKID, DEPOID, SERILOTID));

    INSERT @Aday (STOKID, DEPOID, SERILOTID, EskiKalan, YeniKalan, Fark, SatirVar)
    SELECT K.STOKID, K.DEPOID, K.SERILOTID, K.Bakiye, K.Hareket,
           K.Bakiye - K.Hareket, K.SatirVar
    FROM (
        SELECT STOKID    = ISNULL(S.STOKID, G.STOKID),
               DEPOID    = ISNULL(S.DEPOID, G.DEPOID),
               SERILOTID = ISNULL(S.SERILOTID, G.SERILOTID),
               Bakiye    = S.KALAN,                 -- NULL = bakiye satiri YOK
               Hareket   = ISNULL(G.Hareket, 0),
               SatirVar  = CASE WHEN S.STOKID IS NULL THEN 0 ELSE 1 END,
               HareketVar= CASE WHEN G.STOKID IS NULL THEN 0 ELSE 1 END
        FROM (SELECT SI.STOKID, D.DEPOID, SI.SERILOTID, Hareket = SUM(ISNULL(D.ADET, 0))
              FROM dbo.STOKIZLEMEDEPO D
                   INNER JOIN dbo.STOKIZLEME SI ON SI.ID = D.IZLEMID
              GROUP BY SI.STOKID, D.DEPOID, SI.SERILOTID) G
             FULL OUTER JOIN dbo.STOKDURUMIZLEME S
                  ON S.STOKID = G.STOKID AND S.DEPOID = G.DEPOID
                 AND S.SERILOTID = G.SERILOTID
    ) K
    WHERE ABS(ISNULL(K.Bakiye, 0) - K.Hareket) >= @Esik
      AND (@StokID IS NULL OR K.STOKID = @StokID)
      AND (@DepoID IS NULL OR K.DEPOID = @DepoID)
      AND (@GecersizDepoDahil = 1 OR ISNULL(K.DEPOID, 0) <> 0)
      -- Bakiyesi var ama HIC hareketi yok: varsayilan olarak DOKUNMA
      AND (@HareketsizSifirla = 1 OR K.HareketVar = 1);

    IF @Uygula = 0
    BEGIN
        -- KURU CALISMA: ne yapilacagini goster, hicbir sey yazma
        SELECT Mod = N'KURU CALISMA - hicbir sey yazilmadi',
               Etkilenecek = COUNT(*),
               EklenecekSatir = SUM(CASE WHEN SatirVar = 0 THEN 1 ELSE 0 END),
               GuncellenecekSatir = SUM(CASE WHEN SatirVar = 1 THEN 1 ELSE 0 END),
               EnBuyukFark = MAX(ABS(Fark))
        FROM @Aday;

        SELECT TOP 200
               A.STOKID, StokKodu = ST.KOD, StokAdi = ST.STOKADI,
               A.DEPOID, DepoAdi = DP.DEPOADI,
               A.SERILOTID, SSL.SERINO, SSL.LOTNO,
               EskiKalan = A.EskiKalan, YeniKalan = A.YeniKalan, Fark = A.Fark,
               Islem = CASE WHEN A.SatirVar = 0 THEN N'EKLE' ELSE N'GUNCELLE' END
        FROM @Aday A
             LEFT JOIN dbo.STOKLAR     ST  ON ST.ID  = A.STOKID
             LEFT JOIN dbo.DEPOLAR     DP  ON DP.ID  = A.DEPOID
             LEFT JOIN dbo.STOKSERILOT SSL ON SSL.ID = A.SERILOTID
        ORDER BY ABS(A.Fark) DESC;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM @Aday)
    BEGIN
        SELECT Mod = N'Onarilacak kayit yok', Etkilenen = 0, PartiID = 0;
        RETURN;
    END

    SET @PartiID = ISNULL((SELECT MAX(PARTIID) FROM dbo.IZLEMEBAKIYEONARIM), 0) + 1;

    BEGIN TRAN;

        -- Once kaydi yaz (eski deger dahil) - geri alinabilirlik icin
        INSERT dbo.IZLEMEBAKIYEONARIM
               (PARTIID, KULLANICIID, STOKID, DEPOID, SERILOTID, ESKIKALAN, YENIKALAN, FARK)
        SELECT @PartiID, @KullaniciID, STOKID, DEPOID, SERILOTID, EskiKalan, YeniKalan, Fark
        FROM @Aday;

        -- Eksik bakiye satirlarini ac
        INSERT dbo.STOKDURUMIZLEME (STOKID, DEPOID, SERILOTID, KALAN)
        SELECT A.STOKID, A.DEPOID, A.SERILOTID, A.YeniKalan
        FROM @Aday A WHERE A.SatirVar = 0;

        -- Mevcutlari duzelt
        UPDATE S
           SET S.KALAN = A.YeniKalan
          FROM dbo.STOKDURUMIZLEME S
               INNER JOIN @Aday A ON A.STOKID = S.STOKID AND A.DEPOID = S.DEPOID
                                 AND A.SERILOTID = S.SERILOTID
         WHERE A.SatirVar = 1;

    COMMIT;

    SELECT Mod = N'UYGULANDI', PartiID = @PartiID,
           Etkilenen = (SELECT COUNT(*) FROM dbo.IZLEMEBAKIYEONARIM WHERE PARTIID = @PartiID),
           GeriAlmaKomutu = N'EXEC dbo.sp_Prog_Izleme_BakiyeOnar_GeriAl @PartiID = '
                          + CAST(@PartiID AS nvarchar(12));
END
GO

-- ============================================================
-- sp_Prog_Izleme_BakiyeOnar_GeriAl
--   Bir partiyi ESKI degerlerine dondurur. Onarim sirasinda EKLENEN satirlar
--   (ESKIKALAN NULL) SILINIR, guncellenenler eski degerine yazilir.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Izleme_BakiyeOnar_GeriAl
    @PartiID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.IZLEMEBAKIYEONARIM
                    WHERE PARTIID = @PartiID AND GERIALINDI = 0)
    BEGIN
        SELECT Mod = N'Geri alinacak parti yok ya da zaten geri alinmis';
        RETURN;
    END

    BEGIN TRAN;

        -- Onarimda EKLENEN satirlari kaldir
        DELETE S
          FROM dbo.STOKDURUMIZLEME S
               INNER JOIN dbo.IZLEMEBAKIYEONARIM O
                    ON O.STOKID = S.STOKID AND O.DEPOID = S.DEPOID
                   AND O.SERILOTID = S.SERILOTID
         WHERE O.PARTIID = @PartiID AND O.GERIALINDI = 0 AND O.ESKIKALAN IS NULL;

        -- Guncellenenleri eski degerine dondur
        UPDATE S
           SET S.KALAN = O.ESKIKALAN
          FROM dbo.STOKDURUMIZLEME S
               INNER JOIN dbo.IZLEMEBAKIYEONARIM O
                    ON O.STOKID = S.STOKID AND O.DEPOID = S.DEPOID
                   AND O.SERILOTID = S.SERILOTID
         WHERE O.PARTIID = @PartiID AND O.GERIALINDI = 0 AND O.ESKIKALAN IS NOT NULL;

        UPDATE dbo.IZLEMEBAKIYEONARIM SET GERIALINDI = 1 WHERE PARTIID = @PartiID;

    COMMIT;

    SELECT Mod = N'GERI ALINDI', PartiID = @PartiID,
           Satir = (SELECT COUNT(*) FROM dbo.IZLEMEBAKIYEONARIM WHERE PARTIID = @PartiID);
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_Prog_Izleme_BakiyeOnar        TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Prog_Izleme_BakiyeOnar_GeriAl TO gentegre_api;
END
GO
