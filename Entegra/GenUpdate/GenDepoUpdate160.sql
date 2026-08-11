-- ============================================================
-- GenDepoUpdate160.sql
-- MESAJLASMA: iki asamali silme  ("Sil" / "Herkesten Sil")
--
--   "Sil"           : mesaj YALNIZ SILENDEN gizlenir (digerlerinde durur).
--                     Her uye kendine gelen/yazdigi her mesaj icin yapabilir.
--   "Herkesten Sil" : mesaj TUM uyelerde "(bu mesaj silindi)" olur.
--                     Yalniz MESAJI GONDEREN ya da GRUP YONETICISI yapabilir.
--
--   Kisiye ozel gizleme icin yeni tablo: MESAJGIZLI (mesaj x kullanici).
--   Gecmis ve icerik aramasi bu tabloyu disarida birakir.
--
-- Yetki kurallari SUNUCUDA; istemci yalnizca menuyu buna gore kisitlar.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.MESAJGIZLI') IS NULL
BEGIN
    CREATE TABLE dbo.MESAJGIZLI
    (
        MESAJID  BIGINT   NOT NULL,
        REHBERID INT      NOT NULL,      -- mesaji KENDINDEN silen kullanici
        TARIH    DATETIME NOT NULL CONSTRAINT DF_MESAJGIZLI_TRH DEFAULT (GETDATE()),
        CONSTRAINT PK_MESAJGIZLI PRIMARY KEY CLUSTERED (MESAJID, REHBERID),
        CONSTRAINT FK_MESAJGIZLI_MESAJ FOREIGN KEY (MESAJID) REFERENCES dbo.MESAJ (ID)
    );
    -- "bu kullanicidan gizlenenler" sorgusu (gecmis suzmesi) icin
    CREATE INDEX IX_MESAJGIZLI_KUL ON dbo.MESAJGIZLI (REHBERID, MESAJID);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 533)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL)
    VALUES (533, 'MESAJGIZLI', N'Detay', N'Mesajlaşma');
GO

-- ---- SILME (kapsamli) ----------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Sil_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId   INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);
    DECLARE @MesajId BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.MesajId') AS BIGINT);
    -- Kapsam: 'ben' (varsayilan, yalniz benden gizle) | 'herkes'
    DECLARE @Kapsam  NVARCHAR(10) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.Kapsam'), N'ben'));
    IF @KulId <= 0 OR ISNULL(@MesajId, 0) <= 0 THROW 51001, N'MesajId ve Oturum.KulId zorunlu.', 1;

    DECLARE @KanalId INT, @Gonderen INT;
    SELECT @KanalId = KANALID, @Gonderen = GONDERENID FROM dbo.MESAJ WHERE ID = @MesajId;
    IF @KanalId IS NULL THROW 51002, N'Mesaj bulunamadı.', 1;

    -- Her iki kapsamda da kanalin uyesi olmak SART
    IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                    WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL)
        THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;

    IF @Kapsam = N'herkes'
    BEGIN
        -- Yalniz GONDEREN ya da GRUP YONETICISI
        IF @Gonderen <> @KulId
           AND NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                            WHERE KANALID = @KanalId AND REHBERID = @KulId
                              AND ROL = 1 AND AYRILMATARIHI IS NULL)
            THROW 51200, N'Mesajı herkesten silme yetkiniz yok.', 1;

        UPDATE dbo.MESAJ SET SILINDI = 1, SILEN = @KulId, SILMETARIHI = GETDATE()
         WHERE ID = @MesajId AND SILINDI = 0;
    END
    ELSE
    BEGIN
        -- Kendinden gizle: herkes kendi ekraninda yapabilir
        IF NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI WHERE MESAJID = @MesajId AND REHBERID = @KulId)
            INSERT INTO dbo.MESAJGIZLI (MESAJID, REHBERID) VALUES (@MesajId, @KulId);
    END

    SELECT Sonuc = 1, MesajId = @MesajId, KanalId = @KanalId, Kapsam = @Kapsam
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- GECMIS: kullanicidan gizlenen mesajlar gelmesin ---------------------
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Gecmis_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- ListeSPJson imza uyumu (kullanilmiyor)
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId   INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KulId')   AS INT), 0);
    DECLARE @KanalId INT    = TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId')  AS INT);
    DECLARE @Onceki  BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.OncekiId') AS BIGINT);
    DECLARE @Sonraki BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.SonrakiId')AS BIGINT);
    DECLARE @TopN    INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.TopN') AS INT), 50);

    IF @KulId <= 0 OR ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KulId ve KanalId zorunlu.', 1;

    DECLARE @Baslangic BIGINT =
        (SELECT BASLANGICID FROM dbo.MESAJKANALUYE
          WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL);
    IF @Baslangic IS NULL THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;

    -- 1) SADECE ID'ler siralanir: dar satir -> kucuk bellek grant'i
    --    (SQL Express'te genis kolonlarla siralama 33 MB grant istiyordu, bkz. 153)
    DECLARE @Sec TABLE (ID BIGINT PRIMARY KEY);
    INSERT @Sec (ID)
    SELECT TOP (CASE WHEN @TopN > 0 THEN @TopN ELSE 2147483647 END) M.ID
    FROM dbo.MESAJ M
    WHERE M.KANALID = @KanalId
      AND M.ID > @Baslangic
      AND (@Onceki  IS NULL OR M.ID < @Onceki)
      AND (@Sonraki IS NULL OR M.ID > @Sonraki)
      -- "Sil" (kendinden gizle) yapilmis mesajlar bu kullaniciya GELMEZ
      AND NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI G
                       WHERE G.MESAJID = M.ID AND G.REHBERID = @KulId)
    ORDER BY CASE WHEN @Sonraki IS NULL THEN M.ID END DESC,
             CASE WHEN @Sonraki IS NOT NULL THEN M.ID END ASC;

    -- 2) Genis kolonlar ID uzerinden getirilir (siralama @Sec'in PK sirasindan)
    SELECT MESAJID   = S.ID,
           GONDERENID= S.GONDERENID,
           GONDEREN  = R.FIRMA,
           BENIMMI   = CASE WHEN S.GONDERENID = @KulId THEN 1 ELSE 0 END,
           TARIH     = S.TARIH,
           METIN     = CAST(CASE WHEN S.SILINDI = 1 THEN NULL ELSE S.METIN END AS NVARCHAR(4000)),
           SILINDI   = CAST(S.SILINDI AS INT),
           YANITID   = S.YANITID,
           YANITMETIN= CAST(LEFT(YM.METIN, 80) AS NVARCHAR(80)),
           DOSYAID   = S.DOSYAID,
           DOSYAADI  = S.DOSYAADI,
           DOSYABOYUT= S.DOSYABOYUT
    FROM @Sec I
        INNER JOIN dbo.MESAJ  S  ON S.ID  = I.ID
        LEFT  JOIN dbo.REHBER R  ON R.ID  = S.GONDERENID
        LEFT  JOIN dbo.MESAJ  YM ON YM.ID = S.YANITID
    ORDER BY I.ID
    OPTION (FORCE ORDER, LOOP JOIN);
END
GO

-- ---- ICERIK ARAMASI: gizlenenler cikmasin -------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Icerik_Ara_Json2
    @Baslik   NVARCHAR(MAX) = N'',
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KulId') AS INT), 0);
    DECLARE @Ara   NVARCHAR(200) = JSON_VALUE(@Kosullar, '$.Ara');
    DECLARE @TopN  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.TopN') AS INT), 100);
    IF @KulId <= 0 THROW 51001, N'KulId zorunlu.', 1;
    IF DATALENGTH(ISNULL(@Ara, N'')) = 0 THROW 51001, N'Aranacak metin zorunlu.', 1;

    SELECT TOP (CASE WHEN @TopN > 0 THEN @TopN ELSE 2147483647 END)
        MESAJID   = M.ID,
        KANALID   = K.ID,
        TUR       = K.TUR,
        KANALADI  = CASE WHEN K.TUR = 2 THEN K.ADI ELSE KS.FIRMA END,
        KARSIID   = CASE WHEN K.TUR = 1 THEN KS.ID END,
        RESIMVAR  = CASE WHEN K.TUR = 1 THEN ISNULL(KS.RESIMVAR, 0)
                         WHEN K.DOSYAID IS NOT NULL THEN 1 ELSE 0 END,
        GRUPDOSYAID = CASE WHEN K.TUR = 2 THEN K.DOSYAID END,
        GONDEREN  = G.FIRMA,
        BENIMMI   = CASE WHEN M.GONDERENID = @KulId THEN 1 ELSE 0 END,
        TARIH     = M.TARIH,
        METIN     = CAST(LEFT(M.METIN, 200) AS NVARCHAR(200))
    FROM dbo.MESAJKANALUYE U
        INNER JOIN dbo.MESAJKANAL K ON K.ID = U.KANALID AND K.DURUM = 1
        INNER JOIN dbo.MESAJ      M ON M.KANALID = K.ID AND M.ID > U.BASLANGICID
                                   AND M.SILINDI = 0
        LEFT  JOIN dbo.REHBER     G ON G.ID = M.GONDERENID
        OUTER APPLY (SELECT TOP 1 R.ID, R.FIRMA,
                            RESIMVAR = CASE WHEN R.RESIM IS NOT NULL THEN 1 ELSE 0 END
                       FROM dbo.MESAJKANALUYE U2 INNER JOIN dbo.REHBER R ON R.ID = U2.REHBERID
                      WHERE U2.KANALID = K.ID AND U2.REHBERID <> @KulId) KS
    WHERE U.REHBERID = @KulId AND U.AYRILMATARIHI IS NULL
      AND M.METIN LIKE N'%' + @Ara + N'%'
      AND NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI G2
                       WHERE G2.MESAJID = M.ID AND G2.REHBERID = @KulId)
    ORDER BY M.ID DESC;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT SELECT, INSERT, DELETE ON dbo.MESAJGIZLI          TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Mesaj_Sil_Json              TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Gecmis_Json2         TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Icerik_Ara_Json2     TO gentegre_api;
END
GO
