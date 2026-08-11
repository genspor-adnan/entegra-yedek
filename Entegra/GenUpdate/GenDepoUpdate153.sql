-- ============================================================
-- GenDepoUpdate153.sql
-- MESAJLASMA: gecmis sorgusu SQL Express'te 25 sn bekliyordu
--
-- TESHIS: sp_Prog_Mesaj_Gecmis_Json2 tek satir donerken bile
--   requested_memory_kb = 33.592 KB istiyordu; SQL Express'in sorgu bellek
--   semaforu toplam 9.720 KB. Istek semafordan BUYUK oldugu icin hicbir zaman
--   karsilanamiyor, sorgu "query wait" (varsayilan ~25 sn) dolana kadar
--   RESOURCE_SEMAPHORE'da bekliyor, sonra zorla (forced grant) calisiyor.
--   Belirti: sohbete tiklayinca ~25 sn bekleme. (dm_exec_query_resource_semaphores
--   forced_grant_count = 68)
--
-- SEBEP: TOP + ORDER BY, METIN (NVARCHAR(4000) cast) ve LOB kolonlarla BIRLIKTE
--   siralaniyordu. Siralama satir genisligi uzerinden bellek istenir; 4000
--   karakterlik kolon tahmini grant'i onlarca MB'a cikariyor.
--
-- COZUM: once YALNIZ ID'ler siralanip secilir (dar satir = kucuk grant), genis
--   kolonlar sonra ID uzerinden join'lenir. Ayni sonuc, ~1 MB grant.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

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
    DECLARE @Sec TABLE (ID BIGINT PRIMARY KEY);
    INSERT @Sec (ID)
    SELECT TOP (CASE WHEN @TopN > 0 THEN @TopN ELSE 2147483647 END) M.ID
    FROM dbo.MESAJ M
    WHERE M.KANALID = @KanalId
      AND M.ID > @Baslangic
      AND (@Onceki  IS NULL OR M.ID < @Onceki)
      AND (@Sonraki IS NULL OR M.ID > @Sonraki)
    ORDER BY CASE WHEN @Sonraki IS NULL THEN M.ID END DESC,   -- eski yon: en yeniden geri
             CASE WHEN @Sonraki IS NOT NULL THEN M.ID END ASC; -- polling: sirali ileri

    -- 2) Genis kolonlar ID uzerinden getirilir (siralama yine ID'ye gore)
    SELECT MESAJID   = S.ID,
           GONDERENID= S.GONDERENID,
           GONDEREN  = R.FIRMA,
           BENIMMI   = CASE WHEN S.GONDERENID = @KulId THEN 1 ELSE 0 END,
           TARIH     = S.TARIH,
           -- NVARCHAR(MAX) -> FireDAC ftWideMemo (blob) olarak esler ve gecikmeli
           --   getirir; istemcide AsString BOS gorunuyordu. Sinirli tipe cast:
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
    -- Siralamayi @Sec'in birincil anahtar sirasindan al: genis kolonlar (METIN
    --   NVARCHAR(4000)) uzerinde SORT olusursa istenen bellek 15 MB'a cikiyor ve
    --   SQL Express'in ~9,7 MB'lik semaforuna sigmiyordu (25 sn bekleme).
    OPTION (FORCE ORDER, LOOP JOIN);
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Gecmis_Json2 TO gentegre_api;
GO
