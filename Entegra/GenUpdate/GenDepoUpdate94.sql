-- ============================================================
-- GenDepoUpdate94.sql
-- IZLEME BAKIYE TRIGGER'LARI - DUZELTME  (KUTU 1: DB-only, eski exe ile uyumlu)
--
-- Bu dosya SEMA DEGISTIRMEZ, yeni tablo/kolon EKLEMEZ. Yalnizca iki trigger'i
--   duzeltir ve bir RAPOR SP'si ekler. Eski exe de yeni exe de kazanir;
--   uygulama tarafinda hicbir degisiklik gerekmez.
--
-- ARKA PLAN
--   STOKDURUMIZLEME (seri/lot x depo bakiyesi) YALNIZCA trigger'larla bakim
--   goruyor. Izleme ekraninin "secilebilir miktar" hesabi bu tabloyu okuyor.
--   Uc trigger bakiyeye dokunuyordu:
--     TG_StokIzlemeDurumEkle   (STOKIZLEMEDEPO INSERT) : KALAN = KALAN + ADET   DOGRU
--     TG_StokIzlemeDurumSil    (STOKIZLEME   DELETE)   : KALAN = KALAN - ADET   DOGRU
--     TG_StokIzlemeDurumUpdate (STOKIZLEMEDEPO UPDATE) : KALAN = ADET           HATALI
--
-- HATA 1 - TG_StokIzlemeDurumUpdate ARTIMSAL DEGIL, ATAMA YAPIYORDU
--   Bir depo hareketi guncellenince, o (STOKID, DEPOID, SERILOTID) bakiyesi
--   DIGER TUM hareketleri yok sayarak tek satirin degerine esitleniyordu.
--   Ayrica "bakiye satiri yoksa ac" guvenligi yorum satirindaydi: satir yoksa
--   UPDATE sessizce hicbir sey yapmiyordu.
--   Trigger ULASILABILIR - UPDATE STOKIZLEMEDEPO yapan uc yer var:
--     UIzleme.pas:679 (izleme ekraninin "adet duzelt" islevi)
--     UTS/UUTSDlg.pas:2156 ve :2184
--   VERI KANITI (BILIM, 08.08.2026): STOKDURUMIZLEME.KALAN ile
--   SUM(STOKIZLEMEDEPO.ADET) karsilastirildiginda 48.948 kombinasyondan 4'u
--   sapiyor ve dordu de ayni imzayi tasiyor - isaret ters, fark tam iki kati
--   (cache +600 / gercek -600 gibi). Atama davranisinin imzasi.
--
-- HATA 2 - TG_IzlemOrjinalYap UPDATE'te TETIKLENMIYORDU
--   Kaynak izlem kaydinin KALAN'ini "ADET - SUM(cocuklarin ADET'i)" ile
--   hesapliyor ama yalnizca INSERT/DELETE'te calisiyordu. Bir cocuk kaydin
--   ADET'i ya da DONUSID'si GUNCELLENIRSE kaynagin KALAN'i eski kaliyordu.
--
-- BU DOSYA GECMIS VERIYI DUZELTMEZ. Sapan kayitlarin onarimi AYRI bir adimdir
--   (KUTU 2) ve once rapor gorulmeden yapilmamalidir: musteri veritabaninda
--   trigger'lardan onceki donemden gelen ya da elle duzeltilmis bakiyeler
--   olabilir; korlemesine yeniden hesap DOGRU bakiyeleri de bozabilir.
--   Rapor icin: EXEC dbo.sp_Prog_Izleme_BakiyeKontrol
--
-- PG NOTU: PostgreSQL tarafinda bu tablolarda trigger YOK; bakiye bakimi PG
--   gecisinde ayrica tasarlanacak. Bu dosya MSSQL icindir (GenUpdate komutu
--   olarak dagitilirken #pg ETIKETI KULLANILMAYACAK).
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- 1) TG_StokIzlemeDurumUpdate - ARTIMSAL hale getirildi
--
--    Delta, inserted ve deleted'in AYRI AYRI toplanmasiyla bulunur:
--      + inserted.ADET      - deleted.ADET
--    Bu bicim, guncelleme sirasinda IZLEMID/DEPOID (yani PK) degisse bile
--    dogru calisir: eski anahtar dusulur, yeni anahtara eklenir.
--
--    Cursor yerine SET BAZLI: cok satirli UPDATE'te de dogru (eski cursor
--    surumu cok satirda da calisiyordu ama satir satir, yavas).
-- ============================================================
CREATE OR ALTER TRIGGER [dbo].[TG_StokIzlemeDurumUpdate]
ON [dbo].[STOKIZLEMEDEPO]
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(ADET) AND NOT UPDATE(DEPOID) AND NOT UPDATE(IZLEMID) RETURN;

    DECLARE @D TABLE (STOKID INT, DEPOID INT, SERILOTID INT, Delta FLOAT,
                      PRIMARY KEY (STOKID, DEPOID, SERILOTID));

    INSERT @D (STOKID, DEPOID, SERILOTID, Delta)
    SELECT X.STOKID, X.DEPOID, X.SERILOTID, SUM(X.Delta)
    FROM (
        SELECT SI.STOKID, I.DEPOID, SI.SERILOTID, Delta = ISNULL(I.ADET, 0)
        FROM inserted I INNER JOIN dbo.STOKIZLEME SI ON SI.ID = I.IZLEMID
        UNION ALL
        SELECT SI.STOKID, D.DEPOID, SI.SERILOTID, Delta = -1.0 * ISNULL(D.ADET, 0)
        FROM deleted D INNER JOIN dbo.STOKIZLEME SI ON SI.ID = D.IZLEMID
    ) X
    GROUP BY X.STOKID, X.DEPOID, X.SERILOTID
    HAVING SUM(X.Delta) <> 0.0;

    IF NOT EXISTS (SELECT 1 FROM @D) RETURN;

    -- Bakiye satiri yoksa ac (eski surumde bu guvenlik yorum satirindaydi)
    INSERT INTO dbo.STOKDURUMIZLEME (STOKID, DEPOID, SERILOTID, KALAN)
    SELECT D.STOKID, D.DEPOID, D.SERILOTID, 0.0
    FROM @D D
    WHERE NOT EXISTS (SELECT 1 FROM dbo.STOKDURUMIZLEME S
                       WHERE S.STOKID = D.STOKID AND S.DEPOID = D.DEPOID
                         AND S.SERILOTID = D.SERILOTID);

    UPDATE S
       SET S.KALAN = ISNULL(S.KALAN, 0) + D.Delta
      FROM dbo.STOKDURUMIZLEME S
           INNER JOIN @D D ON D.STOKID = S.STOKID AND D.DEPOID = S.DEPOID
                          AND D.SERILOTID = S.SERILOTID;
END
GO

-- ============================================================
-- 2) TG_IzlemOrjinalYap - UPDATE olayi eklendi
--
--    Govde AYNEN korundu (set bazli, cok satirli islemlere dayanikli).
--    Tek fark: FOR INSERT, DELETE -> FOR INSERT, UPDATE, DELETE.
--    Boylece bir cocuk kaydin ADET'i ya da DONUSID'si degistiginde kaynak
--    izlem kaydinin KALAN'i yeniden hesaplanir.
--    Trigger kendi tablosuna yaziyor; veritabaninda RECURSIVE TRIGGERS KAPALI
--    oldugu icin kendini tekrar tetiklemez.
-- ============================================================
CREATE OR ALTER TRIGGER [dbo].[TG_IzlemOrjinalYap]
ON [dbo].[STOKIZLEME]
FOR INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Etkilenen AS
    (
        SELECT DONUSID AS ID FROM inserted WHERE ISNULL(DONUSID, 0) > 0
        UNION
        SELECT DONUSID AS ID FROM deleted  WHERE ISNULL(DONUSID, 0) > 0
    ),
    Donusen AS
    (
        SELECT S.DONUSID AS ID, SUM(ISNULL(S.ADET, 0)) AS ToplamAdet
        FROM dbo.STOKIZLEME AS S
             INNER JOIN Etkilenen AS E ON E.ID = S.DONUSID
        WHERE ISNULL(S.DONUSID, 0) > 0
        GROUP BY S.DONUSID
    )
    UPDATE O
       SET O.KALAN = ISNULL(O.ADET, 0) - ISNULL(D.ToplamAdet, 0)
    FROM dbo.STOKIZLEME AS O
         INNER JOIN Etkilenen AS E ON E.ID = O.ID
         LEFT JOIN Donusen AS D ON D.ID = O.ID;
END
GO

-- ============================================================
-- 3) sp_Prog_Izleme_BakiyeKontrol - SALT OKUMA RAPOR
--
--    STOKDURUMIZLEME (trigger'la tutulan bakiye) ile gercek hareket toplamini
--    (SUM(STOKIZLEMEDEPO.ADET)) karsilastirir. HICBIR SEY YAZMAZ.
--
--    @Ayrinti = 0 : yalnizca ozet (toplam / uyusan / sapan)
--    @Ayrinti = 1 : sapan kayitlarin listesi (en buyuk farktan baslayarak)
--    @Esik        : bu degerden kucuk mutlak farklar yok sayilir (yuvarlama)
--
--    Onarim BU DOSYADA YOK. Rapor gorulup karar verildikten sonra ayri bir
--    adimda yapilacak: musteride trigger'lardan onceki donemden gelen ya da
--    elle duzeltilmis bakiyeler olabilir.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Izleme_BakiyeKontrol
    @Ayrinti BIT   = 0,
    @Esik    FLOAT = 0.0001,
    @UstSinir INT  = 200
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Gercek AS
    (
        SELECT SI.STOKID, D.DEPOID, SI.SERILOTID, Hareket = SUM(ISNULL(D.ADET, 0))
        FROM dbo.STOKIZLEMEDEPO D
             INNER JOIN dbo.STOKIZLEME SI ON SI.ID = D.IZLEMID
        GROUP BY SI.STOKID, D.DEPOID, SI.SERILOTID
    ),
    Karsilastirma AS
    (
        SELECT STOKID    = ISNULL(S.STOKID, G.STOKID),
               DEPOID    = ISNULL(S.DEPOID, G.DEPOID),
               SERILOTID = ISNULL(S.SERILOTID, G.SERILOTID),
               Bakiye    = ISNULL(S.KALAN, 0),
               Hareket   = ISNULL(G.Hareket, 0),
               Fark      = ISNULL(S.KALAN, 0) - ISNULL(G.Hareket, 0)
        FROM Gercek G
             FULL OUTER JOIN dbo.STOKDURUMIZLEME S
                  ON S.STOKID = G.STOKID AND S.DEPOID = G.DEPOID
                 AND S.SERILOTID = G.SERILOTID
    )
    SELECT Toplam  = COUNT(*),
           Uyusan  = SUM(CASE WHEN ABS(Fark) <  @Esik THEN 1 ELSE 0 END),
           Sapan   = SUM(CASE WHEN ABS(Fark) >= @Esik THEN 1 ELSE 0 END),
           EnBuyukFark = MAX(ABS(Fark)),
           -- Gecersiz depo (0) kayitlari ayrica sayilir: bakiye satiri gecerli
           --   bir depo olmadan olusmus demektir.
           GecersizDepo = SUM(CASE WHEN ISNULL(DEPOID, 0) = 0 THEN 1 ELSE 0 END)
    FROM Karsilastirma;

    IF @Ayrinti = 1
    BEGIN
        ;WITH Gercek AS
        (
            SELECT SI.STOKID, D.DEPOID, SI.SERILOTID, Hareket = SUM(ISNULL(D.ADET, 0))
            FROM dbo.STOKIZLEMEDEPO D
                 INNER JOIN dbo.STOKIZLEME SI ON SI.ID = D.IZLEMID
            GROUP BY SI.STOKID, D.DEPOID, SI.SERILOTID
        ),
        Karsilastirma AS
        (
            SELECT STOKID    = ISNULL(S.STOKID, G.STOKID),
                   DEPOID    = ISNULL(S.DEPOID, G.DEPOID),
                   SERILOTID = ISNULL(S.SERILOTID, G.SERILOTID),
                   Bakiye    = ISNULL(S.KALAN, 0),
                   Hareket   = ISNULL(G.Hareket, 0),
                   Fark      = ISNULL(S.KALAN, 0) - ISNULL(G.Hareket, 0)
            FROM Gercek G
                 FULL OUTER JOIN dbo.STOKDURUMIZLEME S
                      ON S.STOKID = G.STOKID AND S.DEPOID = G.DEPOID
                     AND S.SERILOTID = G.SERILOTID
        )
        SELECT TOP (@UstSinir)
               K.STOKID, StokKodu = ST.KOD, StokAdi = ST.STOKADI,
               K.DEPOID, DepoAdi = DP.DEPOADI,
               K.SERILOTID, SSL.SERINO, SSL.LOTNO,
               K.Bakiye, K.Hareket, K.Fark
        FROM Karsilastirma K
             LEFT JOIN dbo.STOKLAR     ST ON ST.ID = K.STOKID
             LEFT JOIN dbo.DEPOLAR     DP ON DP.ID = K.DEPOID
             LEFT JOIN dbo.STOKSERILOT SSL ON SSL.ID = K.SERILOTID
        WHERE ABS(K.Fark) >= @Esik
        ORDER BY ABS(K.Fark) DESC;
    END
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Izleme_BakiyeKontrol TO gentegre_api;
GO
