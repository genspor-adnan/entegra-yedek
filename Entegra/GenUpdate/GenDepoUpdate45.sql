-- ============================================================
-- GenDepoUpdate45 (musteri uygulama)
--   StokHizmetAra sag detay panelleri: sp_Prog_StokHizmetAra_DetayPaneller
--   (@Panel ile TEK-resultset; DFM statik SQL -> exec sp @Panel=N).
--   Lazy korunur (her cagri sadece istenen panel). Uygulama build'i de gerekir.
--   Tek CREATE OR ALTER -> tek batch (GO gerekmez).
-- ============================================================
-- ============================================================
-- sp_Prog_StokHizmetAra_DetayPaneller — StokHizmetAra sag detay panelleri (@Panel ile TEK resultset)
--   UStokHizmetAra sag grid-level'lerinin (DFM statik SQL) standart-sistem karsiligi.
--   LAZY korunur: her cagri SADECE istenen panelin resultset'ini doner (@Panel).
--   @Panel: 1=DepoDurum, 2=SonAlislar, 3=SonSatislar, 4=Maliyetler, 5=Uretim, 6=Teklif.
--   Params: @StokID (urun), @Tur (F.TUR: stok=1/hizmet=0), @RehberID (0=tumu), @DepoID (durum).
--   Dialect (declare/set/top) SP govdesinde izole -> app engine-agnostic; PG icin ayri fonksiyon.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_StokHizmetAra_DetayPaneller
    @Panel    INT,
    @StokID   INT,
    @Tur      INT = 1,
    @RehberID INT = 0,
    @DepoID   INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @Panel = 1        -- Depo Durumu (mevcut TVF)
        SELECT * FROM dbo.fn_StokDurumDetay(@StokID, @DepoID);

    ELSE IF @Panel = 2   -- Son Alislar (FB.TUR 11 fatura / 12 fis)
        SELECT * FROM (
            SELECT TOP 10 FB.FATURATARIH,
                BELGETIPI = CASE WHEN FB.TUR = 12 THEN N'Fiş' ELSE N'Fatura' END,
                BASLIK = R.FIRMA,
                BIRIMTUTAR = F.TUTAR / F.MIKTAR, F.KUR,
                BIRIMTUTARDOVIZ = F.DOVIZ_TUTARI / F.MIKTAR, F.DOVIZ_KURU,
                F.MIKTAR, FB.TARIH, FB.TUR, FB.ID
            FROM FATBASLIK FB
            INNER JOIN FATURA F ON FB.ID = F.FATBASID
            INNER JOIN REHBER R ON R.ID = FB.REHBERID
            WHERE (FB.TUR = 11 OR FB.TUR = 12) AND F.TUR = @Tur AND F.MIKTAR > 0
              AND F.URUNID = @StokID AND (@RehberID = 0 OR FB.REHBERID = @RehberID)
            ORDER BY FB.FATURATARIH DESC) AS dd;

    ELSE IF @Panel = 3   -- Son Satislar (FB.TUR 15 fatura / 16 fis)
        SELECT * FROM (
            SELECT TOP 10 FB.FATURATARIH,
                BELGETIPI = CASE WHEN FB.TUR = 16 THEN N'Fiş' ELSE N'Fatura' END,
                BASLIK = R.FIRMA,
                BIRIMTUTAR = F.TUTAR / F.MIKTAR, F.KUR,
                BIRIMTUTARDOVIZ = F.DOVIZ_TUTARI / F.MIKTAR, F.DOVIZ_KURU,
                F.MIKTAR, FB.TARIH, FB.TUR, FB.ID
            FROM FATBASLIK FB
            INNER JOIN FATURA F ON FB.ID = F.FATBASID
            INNER JOIN REHBER R ON R.ID = FB.REHBERID
            WHERE (FB.TUR = 15 OR FB.TUR = 16) AND F.TUR = @Tur AND F.MIKTAR > 0
              AND F.URUNID = @StokID AND (@RehberID = 0 OR FB.REHBERID = @RehberID)
            ORDER BY FB.FATURATARIH DESC) AS dd;

    ELSE IF @Panel = 4   -- Maliyetler (STOKFIYAT, FIYATADI<0, SATIS=0)
        SELECT DISTINCT ID = STOKID, FIYATADI,
            TUR = (SELECT TOP 1 CASE WHEN DEGER = -2 THEN ANAHTAR + N' (Son' + CAST(PAKETID AS VARCHAR(5)) + N')'
                                     ELSE ANAHTAR END
                   FROM GENINI WHERE BOLUM = -1008 AND DEGER = FIYATADI),
            MALIYET = FIYAT, KUR, KDVDURUM
        FROM STOKFIYAT
        WHERE STOKID = @StokID AND SATIS = 0 AND FIYATADI < 0;

    ELSE IF @Panel = 5   -- Uretim (bu urunu tuketen receteler)
        SELECT S.KOD, S.STOKADI, URD.MIKTAR, KALAN = SUM(SD.KALAN)
        FROM URETIMRECETE UR
        INNER JOIN URETIMRECETEDETAY URD ON UR.ID = URD.URETIMRECETEID
        INNER JOIN STOKLAR S ON S.ID = URD.URUNID
        INNER JOIN STOKDURUM SD ON S.ID = SD.STOKID
        WHERE URD.MIKTAR < 0.0 AND UR.STOKID = @StokID
        GROUP BY S.KOD, S.STOKADI, URD.MIKTAR;

    ELSE IF @Panel = 6   -- Son Teklifler
        SELECT * FROM (
            SELECT TOP 10 FB.TARIH,
                BASLIK = (SELECT R.FIRMA FROM REHBER R WHERE R.ID = FB.REHBERID),
                BIRIMTUTAR = F.TUTAR / F.MIKTAR, F.KUR,
                BIRIMTUTARDOVIZ = F.DOVIZ_TUTARI / F.MIKTAR, F.DOVIZ_KURU,
                F.MIKTAR, FB.ID
            FROM TEKLIF FB
            INNER JOIN TEKLIFDETAY F ON FB.ID = F.TEKLIFID
            WHERE F.TUR = @Tur AND F.MIKTAR > 0 AND F.URUNID = @StokID
              AND (@RehberID = 0 OR FB.REHBERID = @RehberID)
            ORDER BY FB.TARIH DESC) AS dd;
END;
