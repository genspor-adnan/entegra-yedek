-- ============================================================
-- GenDepoUpdate98.sql
-- IZLEME EKRANI - ADIM A4: sp_Prog_Izleme_Aktar_Json  (KANONIK TASIMA)
--
-- Bir KAYNAK belge satirindaki seri/lot kayitlarini HEDEF belge satirina tasir.
--   Tek uygulama; iki cagiran:
--     1) UBelgeDonusum ekrani (elle yazilmis SQL blogunun yerine)
--     2) sp_Prog_BelgeDonusum_IzlemeAktar (donusum SP zinciri)
--
-- NEDEN: ayni is BUGUN IKI YERDE, iki farkli sekilde yapiliyor:
--   a) UBelgeDonusum.pas satir 880-903: Tablo.SQLSatiriKopyala ile satir satir
--      kopyalama + elle STOKIZLEMEDEPO insert + "update STOKIZLEME set KALAN=0"
--   b) sp_Prog_BelgeDonusum_IzlemeAktar (GenDepoUpdate92)
--   (a)'daki "KALAN = 0" AYNI HATA: TG_IzlemOrjinalYap kaynagin KALAN'ini
--   ZATEN dogru dusuruyor (dogrulandi: kalan 2, 1 adet tasima -> 1). Ustune
--   sifir yazmak kismi tasimada kalani yok ediyor. Bu SP kalana ELLE DOKUNMAZ.
--
-- GIRDI
--   {"kaynak":{"satirId":3557439},
--    "hedef" :{"tur":15,"baslikId":114090,"satirId":3557581},
--    "depoId":1,                     -- yazilacak depo (yon asagida)
--    "stokHareketi":true,            -- false ise STOKIZLEMEDEPO'ya ADET=0 yazilir
--    "secim":[{"serilotId":21365,"adet":2}],   -- BOS ise kaynagin TUM kalani FIFO
--    "kullaniciId":5}
--
-- CIKTI {"Sonuc":1,"Aktarilan":n,"ToplamAdet":x}
--
-- YON KURALI: hedef belge turu cikis nitelikliyse (4,14,15,16,99,119) depo
--   hareketi NEGATIF, degilse POZITIF. stokHareketi=false ise ADET=0 yazilir
--   (K-B karari: satir yine de acilir - "izlemliydi ama stok dusmedi" bilgisi
--   ve gecmis veriyle tutarlilik korunur).
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Izleme_Aktar_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KaynakSatir INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.kaynak.satirId') AS INT);
    DECLARE @HedefTur    INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.hedef.tur')      AS INT);
    DECLARE @HedefBaslik INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.hedef.baslikId') AS INT);
    DECLARE @HedefSatir  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.hedef.satirId')  AS INT);
    DECLARE @DepoId      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.depoId')         AS INT);
    DECLARE @StokHar     BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.stokHareketi') AS BIT), 1);
    DECLARE @KulId       INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.kullaniciId') AS INT), 0);

    IF @KaynakSatir IS NULL OR @KaynakSatir <= 0 THROW 51001, N'kaynak.satirId zorunlu.', 1;
    IF @HedefSatir  IS NULL OR @HedefSatir  <= 0 THROW 51001, N'hedef.satirId zorunlu.', 1;
    IF @HedefBaslik IS NULL OR @HedefBaslik <= 0 THROW 51001, N'hedef.baslikId zorunlu.', 1;
    IF @HedefTur    IS NULL                      THROW 51001, N'hedef.tur zorunlu.', 1;

    -- Depo zorunlulugu: hareket yapilacaksa gecerli depo SART.
    --   (Utablo.IzlemBilgisiKaydet'e eklenen korumanin SP karsiligi - BILIM'de
    --    DEPOID=0 ile 15 hareket yazilmisti.)
    IF @StokHar = 1 AND ISNULL(@DepoId, 0) <= 0
        THROW 51001, N'Stok hareketi yapilacaksa gecerli depoId zorunlu.', 1;

    -- ---------- Tasinacaklar ----------
    DECLARE @T TABLE (KaynakIzlemId INT PRIMARY KEY, SerilotId INT, StokId INT,
                      IzlemTur INT, Yer INT, Adet DECIMAL(18,6));

    DECLARE @SecimVar BIT = CASE WHEN EXISTS (SELECT 1 FROM OPENJSON(@Kosullar, '$.secim')) THEN 1 ELSE 0 END;

    IF @SecimVar = 1
        -- Acik secim: hangi seri/lottan ne kadar
        INSERT @T (KaynakIzlemId, SerilotId, StokId, IzlemTur, Yer, Adet)
        SELECT MIN(SI.ID), SI.SERILOTID, MIN(SI.STOKID), MIN(SI.IZLEMTUR), MIN(SI.YER), MIN(J.Adet)
        FROM OPENJSON(@Kosullar, '$.secim')
             WITH (SerilotId INT '$.serilotId', Adet DECIMAL(18,6) '$.adet') J
             INNER JOIN dbo.STOKIZLEME SI ON SI.SATIRID = @KaynakSatir
                                         AND SI.SERILOTID = J.SerilotId
        WHERE J.Adet > 0
        GROUP BY SI.SERILOTID;
    ELSE
        -- Secim gonderilmediyse kaynagin TUM kalani (eski akisin davranisi)
        INSERT @T (KaynakIzlemId, SerilotId, StokId, IzlemTur, Yer, Adet)
        SELECT SI.ID, SI.SERILOTID, SI.STOKID, SI.IZLEMTUR, SI.YER, ABS(ISNULL(SI.KALAN, 0))
        FROM dbo.STOKIZLEME SI
        WHERE SI.SATIRID = @KaynakSatir AND ABS(ISNULL(SI.KALAN, 0)) > 0.0001;

    IF NOT EXISTS (SELECT 1 FROM @T)
    BEGIN
        SELECT (SELECT 1 AS Sonuc, 0 AS Aktarilan, 0 AS ToplamAdet
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
        RETURN;
    END

    -- Yon: cikis nitelikli hedef turlerde depo hareketi NEGATIF
    DECLARE @Yon INT = CASE WHEN @HedefTur IN (4, 14, 15, 16, 99, 119) THEN -1 ELSE 1 END;

    DECLARE @Kid INT, @Adet DECIMAL(18,6), @YeniId INT, @Aktarilan INT = 0,
            @Toplam DECIMAL(18,6) = 0;

    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT KaynakIzlemId, Adet FROM @T ORDER BY KaynakIzlemId;
    OPEN c; FETCH NEXT FROM c INTO @Kid, @Adet;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO dbo.STOKIZLEME (STOKID, BELGETUR, BASLIKID, SATIRID, IZLEMTUR,
                                    ADET, KALAN, YER, YERID, DONUSID, SERILOTID, EKLEYEN)
        SELECT SI.STOKID, @HedefTur, @HedefBaslik, @HedefSatir, SI.IZLEMTUR,
               @Adet, @Adet, SI.YER, 0, SI.ID, SI.SERILOTID, @KulId
        FROM dbo.STOKIZLEME SI WHERE SI.ID = @Kid;

        SET @YeniId = CAST(SCOPE_IDENTITY() AS INT);
        IF @YeniId IS NOT NULL
        BEGIN
            -- K-B: stok hareketi yoksa da satir acilir, ADET = 0
            INSERT INTO dbo.STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET)
            VALUES (@YeniId, ISNULL(@DepoId, 0),
                    CASE WHEN @StokHar = 1 THEN @Yon * @Adet ELSE 0 END);

            -- KAYNAGIN KALAN'INA ELLE DOKUNULMUYOR: TG_IzlemOrjinalYap yeni
            --   satirin DONUSID'sine bakip kaynagi zaten dusuruyor. Eski akisin
            --   "update STOKIZLEME set KALAN=0" satiri kismi tasimada kalani
            --   yok ediyordu.
            SET @Aktarilan = @Aktarilan + 1;
            SET @Toplam = @Toplam + @Adet;
        END
        FETCH NEXT FROM c INTO @Kid, @Adet;
    END
    CLOSE c; DEALLOCATE c;

    SELECT (SELECT 1 AS Sonuc, @Aktarilan AS Aktarilan, @Toplam AS ToplamAdet
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Izleme_Aktar_Json TO gentegre_api;
GO
