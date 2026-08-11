-- ============================================================
-- GenDepoUpdate124.sql
-- DONUSUM KURALI (genel):
--   1) Donusmus belge / satir SILINEMEZ.        -> sp_Prog_*_Silinebilir_Mi (117/119/120)
--   2) Adet, DONUSEN adedin ALTINA dusurulemez. -> BU DOSYA
--      Ornek: 10'luk siparis satirinin 8'i irsaliyeye donustuyse adet 8'in
--      altina inemez; 8 ve uzeri her deger serbesttir (ust sinir yok).
--
-- Iki nesne:
--   fn_Prog_Donusum_DonusenAdet(@KaynakDetayTablo, @SatirId)
--       Kaynak satirdan URETILMIS hedef satirlarin adet toplami.
--       Rota matrisinden okur (fn_Prog_BelgeDonusum_Rota) - yeni rota
--       eklendiginde kural kendiliginden kapsar, elle liste yoktur.
--       Hedef iki tabloda olabilir: FATURA ya da SIPARISDETAY.
--       ADET isaretli olabilir (uretim sarfi Carpan=-1) -> ABS.
--
--   sp_Prog_Donusum_SatirAdetKontrol(@KaynakDetayTablo, @SatirId, @YeniAdet)
--       Tek satir sonuc: DONUSENADET, UYGUN (bit), MESAJ + ilk hedef belge
--       bilgisi (kullaniciya "hangi belgeye donustu" demek icin).
--       @YeniAdet NULL verilirse yalniz DONUSENADET dondurur (UYGUN=1).
--
-- KAYNAK TABLO degerleri rota matrisindeki KaynakDetayTablo ile ayni:
--   'SIPARISDETAY' | 'FATURA' | 'TEKLIFDETAY'
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER FUNCTION dbo.fn_Prog_Donusum_DonusenAdet
(
    @KaynakDetayTablo varchar(30),
    @SatirId          int
)
RETURNS decimal(18,6)
AS
BEGIN
    DECLARE @Toplam decimal(18,6);

    SELECT @Toplam =
        -- hedefi FATURA olan rotalar (irsaliye/fatura/fis/konsinye/transfer/uretim)
        ISNULL((SELECT SUM(ABS(ISNULL(F.ADET, 0)))
                  FROM FATURA F
                       INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                               ON R.DonusumTuru      = F.YERI
                              AND R.KaynakDetayTablo = @KaynakDetayTablo
                              AND R.KalanHedefTablo  = 'FATURA'
                 WHERE F.YERID = @SatirId), 0)
      + -- hedefi SIPARISDETAY olan rotalar (talep->siparis, teklif->siparis)
        ISNULL((SELECT SUM(ABS(ISNULL(SD.ADET, 0)))
                  FROM SIPARISDETAY SD
                       INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                               ON R.DonusumTuru      = SD.YERI
                              AND R.KaynakDetayTablo = @KaynakDetayTablo
                              AND R.KalanHedefTablo  = 'SIPARISDETAY'
                 WHERE SD.YERID = @SatirId), 0);

    RETURN ISNULL(@Toplam, 0);
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Donusum_SatirAdetKontrol
    @KaynakDetayTablo varchar(30),
    @SatirId          int,
    @YeniAdet         decimal(18,6) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Donusen decimal(18,6) =
            dbo.fn_Prog_Donusum_DonusenAdet(@KaynakDetayTablo, @SatirId);

    -- Ilk hedef belge (mesajda gosterilir). Birden cok hedef olabilir; kullaniciya
    --   ornek olmasi yeter, tam liste raporda (sp_Prog_Donusum_KopukZincir_Rapor).
    DECLARE @BelgeAd varchar(100), @BelgeNo varchar(50), @BelgeTarih datetime;

    SELECT TOP 1
           @BelgeAd    = X.BelgeAd,
           @BelgeNo    = X.BelgeNo,
           @BelgeTarih = X.BelgeTarih
    FROM (
        SELECT BelgeAd    = (SELECT TOP 1 I.AD FROM ISLEMTURLERI I WHERE I.TUR = FB.TUR),
               BelgeNo    = CAST(FB.FATURANO AS varchar(50)),
               BelgeTarih = CAST(FB.FATURATARIH AS datetime)
        FROM FATURA F
             INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                     ON R.DonusumTuru      = F.YERI
                    AND R.KaynakDetayTablo = @KaynakDetayTablo
                    AND R.KalanHedefTablo  = 'FATURA'
             INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID
        WHERE F.YERID = @SatirId
        UNION ALL
        SELECT (SELECT TOP 1 I.AD FROM ISLEMTURLERI I WHERE I.TUR = S.TUR),
               CAST(S.SIPARISNO AS varchar(50)),
               CAST(S.SIPARISTARIH AS datetime)
        FROM SIPARISDETAY SD
             INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                     ON R.DonusumTuru      = SD.YERI
                    AND R.KaynakDetayTablo = @KaynakDetayTablo
                    AND R.KalanHedefTablo  = 'SIPARISDETAY'
             INNER JOIN SIPARIS S ON S.ID = SD.SIPARISID
        WHERE SD.YERID = @SatirId
    ) X
    ORDER BY X.BelgeTarih;

    DECLARE @Uygun bit = 1, @Mesaj nvarchar(400) = N'';

    IF @YeniAdet IS NOT NULL AND @Donusen > 0 AND @YeniAdet < @Donusen
    BEGIN
        SET @Uygun = 0;
        SET @Mesaj = N'Bu satırın ' +
                     CAST(CAST(@Donusen AS decimal(18,2)) AS nvarchar(30)) +
                     N' adedi zaten dönüştürülmüş' +
                     CASE WHEN @BelgeAd IS NULL THEN N''
                          ELSE N' (' + @BelgeAd + N' ' + ISNULL(@BelgeNo, N'') + N')' END +
                     N'. Adet bu değerin altına düşürülemez.';
    END;

    -- UYGUN INT olarak doner: bit alan FireDAC'ta Boolean'a maplenip
    --   AsInteger okunusunda "Cannot access field 'UYGUN' as type Integer" veriyordu.
    SELECT DONUSENADET = @Donusen,
           UYGUN       = CAST(@Uygun AS int),
           MESAJ       = @Mesaj,
           BELGEAD     = @BelgeAd,
           BELGENO     = @BelgeNo,
           BELGETARIH  = @BelgeTarih;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_Prog_Donusum_SatirAdetKontrol TO gentegre_api;
    GRANT EXECUTE ON dbo.fn_Prog_Donusum_DonusenAdet TO gentegre_api;
END
GO
