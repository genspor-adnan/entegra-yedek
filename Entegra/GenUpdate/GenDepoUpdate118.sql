-- ============================================================
-- GenDepoUpdate118.sql
-- sp_Prog_Donusum_KopukZincir_Rapor - kaynagi silinmis donusum baglari
--
-- Donusumle uretilen her hedef satir, kaynagini YERI (donusum turu) + YERID
--   (kaynak satir ID) ile tutar. Kaynak satir silinirse bag BOSTA kalir:
--     - "kaynak belgeyi ac" hicbir sey bulamaz
--     - kalan hesabi o donusumu artik kimsenin donuseni saymaz
--     - listelerdeki Kaynak/Hedef sutunlari bos gorunur
--
-- Bu duruma sp_Prog_Siparis_Silinebilir_Mi'nin eksik kurali yol acti
--   (GenDepoUpdate117'de duzeltildi): konsinye/fis/transfer/talep donusumleri
--   silmeyi engellemiyordu.
--
-- SP HICBIR SEY YAZMAZ - yalnizca raporlar.
--
-- CIKTI
--   Yon           : 'FATURA' (hedef satir FATURA'da) | 'SIPARISDETAY'
--   DonusumTuru   : rota kodu + aciklamasi
--   HedefBelgeId  : hedef belge basligi
--   HedefBelgeNo  : belge numarasi (goruntuleme icin)
--   HedefTarih    : belge tarihi
--   HedefSatirId  : bosta kalan satir
--   KayipSatirId  : bulunamayan kaynak satir ID'si (YERID)
--   Adet          : hedef satirin adedi (etkinin buyuklugu)
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Donusum_KopukZincir_Rapor
    @DonusumTuru INT = 0,      -- 0 = hepsi
    @Ozet        BIT = 0       -- 1 = rota bazinda sayim
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @K TABLE (Yon NVARCHAR(20), DonusumTuru INT, Aciklama NVARCHAR(100),
                      HedefBelgeId INT, HedefBelgeNo NVARCHAR(50), HedefTarih DATETIME,
                      HedefSatirId INT, KayipSatirId INT, Adet DECIMAL(18,6));

    -- 1) Hedefi FATURA olan rotalar, kaynagi SIPARISDETAY
    INSERT @K
    SELECT 'FATURA', R.DonusumTuru, R.Aciklama, FB.ID, FB.FATURANO, FB.FATURATARIH,
           F.ID, F.YERID, ABS(ISNULL(F.ADET, 0))
    FROM FATURA F
         INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                 ON R.DonusumTuru = F.YERI AND R.KaynakDetayTablo = 'SIPARISDETAY'
         INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID
    WHERE ISNULL(F.YERID, 0) > 0
      AND NOT EXISTS (SELECT 1 FROM SIPARISDETAY SD WHERE SD.ID = F.YERID);

    -- 2) Hedefi FATURA olan rotalar, kaynagi da FATURA (irsaliye -> fatura vb.)
    INSERT @K
    SELECT 'FATURA', R.DonusumTuru, R.Aciklama, FB.ID, FB.FATURANO, FB.FATURATARIH,
           F.ID, F.YERID, ABS(ISNULL(F.ADET, 0))
    FROM FATURA F
         INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                 ON R.DonusumTuru = F.YERI AND R.KaynakDetayTablo = 'FATURA'
         INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID
    WHERE ISNULL(F.YERID, 0) > 0
      AND NOT EXISTS (SELECT 1 FROM FATURA F2 WHERE F2.ID = F.YERID);

    -- 3) Hedefi SIPARISDETAY olan rota (428 satinalma talebi -> alis siparisi)
    INSERT @K
    SELECT 'SIPARISDETAY', R.DonusumTuru, R.Aciklama, S.ID, S.SIPARISNO, S.SIPARISTARIH,
           SD.ID, SD.YERID, ABS(ISNULL(SD.ADET, 0))
    FROM SIPARISDETAY SD
         INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                 ON R.DonusumTuru = SD.YERI AND R.KalanHedefTablo = 'SIPARISDETAY'
         INNER JOIN SIPARIS S ON S.ID = SD.SIPARISID
    WHERE ISNULL(SD.YERID, 0) > 0
      AND NOT EXISTS (SELECT 1 FROM SIPARISDETAY S2 WHERE S2.ID = SD.YERID);

    IF @Ozet = 1
        SELECT DonusumTuru, Aciklama, SatirSayisi = COUNT(*),
               BelgeSayisi = COUNT(DISTINCT HedefBelgeId),
               ToplamAdet  = SUM(Adet),
               IlkTarih    = MIN(HedefTarih), SonTarih = MAX(HedefTarih)
        FROM @K
        WHERE @DonusumTuru = 0 OR DonusumTuru = @DonusumTuru
        GROUP BY DonusumTuru, Aciklama
        ORDER BY COUNT(*) DESC;
    ELSE
        SELECT Yon, DonusumTuru, Aciklama, HedefBelgeId, HedefBelgeNo, HedefTarih,
               HedefSatirId, KayipSatirId, Adet
        FROM @K
        WHERE @DonusumTuru = 0 OR DonusumTuru = @DonusumTuru
        ORDER BY HedefTarih DESC, HedefBelgeId, HedefSatirId;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Donusum_KopukZincir_Rapor TO gentegre_api;
GO
