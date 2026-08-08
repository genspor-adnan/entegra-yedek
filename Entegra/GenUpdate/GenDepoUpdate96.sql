-- ============================================================
-- GenDepoUpdate96.sql
-- IZLEME EKRANI - ADIM A1: sp_Prog_Izleme_Aday_Json
--
-- Izleme ekraninin gosterecegi seri/lot ADAY LISTESINI uretir.
--   Envanterdeki UC hesabi tek yerde toplar:
--     H1  bu depoda su an secilebilir seri/lot
--         = STOKDURUMIZLEME.KALAN  EKSI  bu belge satirinin kendi hareketi
--     H2  bu belge satirinin HALIHAZIRDAKI secimi (yeniden acildiginda)
--     H3  kaynak belgeden TASINABILIR seri/lot (donusumde)
--
-- Bugun bu hesaplar UIzleme.dfm icinde YEDI TMemo sorgusunda, global gecici
--   tablo (##TmpIzleme_<SPID>_<zaman>) ve metinle uretilen "declare @X ... set
--   @X=123" on ekiyle yapiliyor. Hepsi burada son buluyor.
--
-- ONEMLI FARK - ESLESME SERILOTID ILE
--   Eski SQLCikanUpdate / SQLDonusCikanHedefUpdate, secili kayitlari
--   SERINO + LOTNO (COLLATE SQL_Latin1_General_CP1254_CI_AS) + SKT UCLUSU ile,
--   NULL karsilastirmalarini elle yazarak esliyordu. Collate/NULL/bosluk farki
--   eslesmeyi sessizce bozuyordu. Bu SP SERILOTID kullanir - STOKIZLEME'nin
--   454.379 satirinin HEPSINDE dolu (dogrulandi).
--
-- BU SP HICBIR SEY YAZMAZ. Ekran secimi yapar, yazma cagiranin belge SP'sinde
--   olur (sp_Api_Belge_Kaydet_Json / sp_Prog_BelgeDonusum_Uygula_Json2).
--
-- GIRDI
--   {"mod":"donusum"|"cikis"|"giris",
--    "stokId":726, "izlemTur":2, "depoId":1,
--    "donusumTuru":411,                       -- yalniz mod=donusum
--    "belge" :{"tur":15,"baslikId":114090,"satirId":3557600},
--    "kaynak":{"baslikId":113994,"satirId":3557439},
--    "tarih":"2026-08-08"}
--
-- CIKTI (sonuc kumesi - ekran grid'e baglar)
--   SERILOTID, SERINO, LOTNO, SKT, URT,
--   MEVCUT      : secilebilir miktar (H1/H3)
--   SECILI      : bu satirda halihazirda secili mi (0/1)
--   SECILENADET : secili ise kac adet (H2)
--   KAYNAKIZLEMID : donusumde kaynak STOKIZLEME.ID (tasima bagi icin)
--
-- KAPSAM (A1): mod = 'donusum'. Cikis ve giris modlari A6'da eklenecek;
--   simdilik 51001 ile reddediliyor ki yarim davranis uretmesin.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Izleme_Aday_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Mod         NVARCHAR(20) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.mod'), N'donusum'));
    DECLARE @StokId      INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.stokId')      AS INT);
    DECLARE @IzlemTur    INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.izlemTur')    AS INT);
    DECLARE @DepoId      INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.depoId')      AS INT);
    DECLARE @DonusumTuru INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.donusumTuru') AS INT);
    DECLARE @HedefBaslik INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.baslikId')  AS INT);
    DECLARE @HedefSatir  INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.satirId')   AS INT);
    DECLARE @KaynakBaslik INT     = TRY_CAST(JSON_VALUE(@Kosullar, '$.kaynak.baslikId') AS INT);
    DECLARE @KaynakSatir INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.kaynak.satirId')  AS INT);

    IF @StokId IS NULL OR @StokId <= 0 THROW 51001, N'stokId zorunlu.', 1;

    IF @Mod <> N'donusum'
        THROW 51001, N'Bu surumde yalnizca mod="donusum" destekleniyor (cikis/giris A6 adiminda).', 1;

    IF @DonusumTuru IS NULL THROW 51001, N'mod=donusum icin donusumTuru zorunlu.', 1;
    IF @KaynakSatir IS NULL OR @KaynakSatir <= 0
        THROW 51001, N'mod=donusum icin kaynak.satirId zorunlu.', 1;

    -- Kaynak detay tablosu ROTA MATRISINDEN gelir (uygulamadan tablo adi alinmaz)
    DECLARE @KaynakDetay NVARCHAR(20), @DepoAlani NVARCHAR(20);
    SELECT @KaynakDetay = KaynakDetayTablo, @DepoAlani = DepoAlani
    FROM dbo.fn_Prog_BelgeDonusum_Rota() WHERE DonusumTuru = @DonusumTuru;

    IF @KaynakDetay IS NULL
    BEGIN
        DECLARE @m NVARCHAR(200) = N'Bilinmeyen donusum turu: ' + CAST(@DonusumTuru AS nvarchar(10));
        THROW 51200, @m, 1;
    END

    -- ---------- H2: bu HEDEF satirin halihazirdaki secimi ----------
    --   Ekran ikinci kez acildiginda kullanicinin onceki secimi isaretli gelsin.
    DECLARE @Secili TABLE (SERILOTID INT PRIMARY KEY, Adet DECIMAL(18,6), IzlemId INT);
    IF ISNULL(@HedefSatir, 0) > 0
        INSERT @Secili (SERILOTID, Adet, IzlemId)
        SELECT SI.SERILOTID, SUM(ISNULL(SI.ADET, 0)), MIN(SI.ID)
        FROM dbo.STOKIZLEME SI
        WHERE SI.BASLIKID = @HedefBaslik AND SI.SATIRID = @HedefSatir
          AND ISNULL(SI.SERILOTID, 0) > 0
        GROUP BY SI.SERILOTID;

    IF @KaynakDetay = 'FATURA'
    BEGIN
        -- ---------- H3: KAYNAK BELGEDEN TASIMA ----------
        --   Kaynak FATBASLIK/FATURA ise kaynak satirin STOKIZLEME kayitlari
        --   hedefe tasinir. Secilebilir miktar = kaynagin KALAN'i.
        --   (Eski SQLDonusKaynak / SQLDonusCikanHedef bu isi yapiyordu.)
        SELECT SERILOTID   = SI.SERILOTID,
               SERINO      = SSL.SERINO,
               LOTNO       = SSL.LOTNO,
               SKT         = SSL.SKT,
               URT         = SSL.URT,
               MEVCUT      = CAST(ABS(ISNULL(SI.KALAN, 0)) AS decimal(18,6)),
               SECILI      = CAST(CASE WHEN S.SERILOTID IS NULL THEN 0 ELSE 1 END AS bit),
               SECILENADET = CAST(ISNULL(ABS(S.Adet), 0) AS decimal(18,6)),
               KAYNAKIZLEMID = SI.ID
        FROM dbo.STOKIZLEME SI
             INNER JOIN dbo.STOKSERILOT SSL ON SSL.ID = SI.SERILOTID
             LEFT JOIN @Secili S ON S.SERILOTID = SI.SERILOTID
        WHERE SI.SATIRID = @KaynakSatir
          AND SI.BASLIKID = ISNULL(NULLIF(@KaynakBaslik, 0), SI.BASLIKID)
          -- Tukenmis (KALAN=0) kaynak kayitlari gizlenir - onlardan tasinacak
          --   bir sey yok. ISTISNA: hedefte ZATEN SECILI olan lot, kaynagi
          --   tukenmis olsa da listede kalmali; aksi halde kullanici kendi
          --   secimini goremez ve yanlislikla siler. (H1 dalinda ayni kural.)
          AND (ABS(ISNULL(SI.KALAN, 0)) > 0.0001 OR S.SERILOTID IS NOT NULL)
        ORDER BY SSL.SKT, SSL.LOTNO, SSL.SERINO;
    END
    ELSE
    BEGIN
        -- ---------- H1: DEPODAN SECIM ----------
        --   Kaynak SIPARISDETAY ise SIPARIS stok hareketi yapmaz, STOKIZLEME
        --   kaydi YOKTUR - seri/lot DEPODAN secilir.
        --   Mevcut = STOKDURUMIZLEME bakiyesi EKSI bu HEDEF satirin kendi
        --   hareketi (eski SQLCikan'in iki dalli hesabinin karsiligi).
        IF @DepoId IS NULL OR @DepoId <= 0
            THROW 51001, N'Depodan secim icin gecerli depoId zorunlu.', 1;

        SELECT SERILOTID   = SDI.SERILOTID,
               SERINO      = SSL.SERINO,
               LOTNO       = SSL.LOTNO,
               SKT         = SSL.SKT,
               URT         = SSL.URT,
               MEVCUT      = CAST(ISNULL(SDI.KALAN, 0) - ISNULL(K.Kendi, 0) AS decimal(18,6)),
               SECILI      = CAST(CASE WHEN S.SERILOTID IS NULL THEN 0 ELSE 1 END AS bit),
               SECILENADET = CAST(ISNULL(ABS(S.Adet), 0) AS decimal(18,6)),
               KAYNAKIZLEMID = CAST(NULL AS INT)
        FROM dbo.STOKDURUMIZLEME SDI
             INNER JOIN dbo.STOKSERILOT SSL ON SSL.ID = SDI.SERILOTID
             LEFT JOIN @Secili S ON S.SERILOTID = SDI.SERILOTID
             OUTER APPLY (
                 -- bu hedef satirin kendi depo hareketi (kendi etkisini disla)
                 SELECT Kendi = SUM(ISNULL(D.ADET, 0))
                 FROM dbo.STOKIZLEMEDEPO D
                      INNER JOIN dbo.STOKIZLEME SI2 ON SI2.ID = D.IZLEMID
                 WHERE SI2.SATIRID = @HedefSatir
                   AND SI2.SERILOTID = SDI.SERILOTID
                   AND D.DEPOID = @DepoId
             ) K
        WHERE SDI.STOKID = @StokId
          AND SDI.DEPOID = @DepoId
          -- Halihazirda secili olanlar bakiyesi bitse de listede kalmali
          AND (ISNULL(SDI.KALAN, 0) - ISNULL(K.Kendi, 0) > 0.0001 OR S.SERILOTID IS NOT NULL)
        ORDER BY SSL.SKT, SSL.LOTNO, SSL.SERINO;
    END
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Izleme_Aday_Json TO gentegre_api;
GO
